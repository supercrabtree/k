zmodload zsh/datetime
zmodload -F zsh/stat b:zstat

k () {
  # ----------------------------------------------------------------------------
  # Setup
  # ----------------------------------------------------------------------------

  # Stop stat failing when a directory contains either no files or no hidden files
  # Track if we _accidentally_ create a new global variable
  setopt local_options null_glob typeset_silent no_auto_pushd nomarkdirs

  # Process options and get files/directories
  typeset -a o_all o_almost_all o_human o_si o_directory o_group_directories \
	  o_no_directory o_no_vcs o_sort o_sort_reverse o_help
  zparseopts -E -D \
             a=o_all -all=o_all \
             A=o_almost_all -almost-all=o_almost_all \
             c=o_sort \
             d=o_directory -directory=o_directory \
	     -group-directories-first=o_group_directories \
             h=o_human -human=o_human \
             -si=o_si \
             n=o_no_directory -no-directory=o_no_directory \
             -no-vcs=o_no_vcs \
             r=o_sort_reverse -reverse=o_sort_reverse \
             -sort:=o_sort \
             S=o_sort \
             t=o_sort \
             u=o_sort \
             U=o_sort \
             -help=o_help

  # Print Help if bad usage, or they asked for it
  if [[ $? != 0 || "$o_help" != "" ]]
  then
    print -u2 "Usage: k [options] DIR"
    print -u2 "Options:"
    print -u2 "\t-a      --all           list entries starting with ."
    print -u2 "\t-A      --almost-all    list all except . and .."
    print -u2 "\t-c                      sort by ctime (inode change time)"
    print -u2 "\t-d      --directory     list only directories"
    print -u2 "\t-n      --no-directory  do not list directories"
    print -u2 "\t-h      --human         show filesizes in human-readable format"
    print -u2 "\t        --si            with -h, use powers of 1000 not 1024"
    print -u2 "\t-r      --reverse       reverse sort order"
    print -u2 "\t-S                      sort by size"
    print -u2 "\t-t                      sort by time (modification time)"
    print -u2 "\t-u                      sort by atime (use or access time)"
    print -u2 "\t-U                      Unsorted"
    print -u2 "\t        --sort WORD     sort by WORD: none (U), size (S),"
    print -u2 "\t                        time (t), ctime or status (c),"
    print -u2 "\t       		 atime or access or use (u)"
    print -u2 "\t        --no-vcs        do not get VCS status (much faster)"
    print -u2 "\t        --help          show this help"
    return 1
  fi

  # Check for conflicts
  if [[ "$o_directory" != "" && "$o_no_directory" != "" ]]; then
    print -u2 "$o_directory and $o_no_directory cannot be used together"
    return 1
  fi

  # case is like a mnemonic for sort order:
  # lower-case for standard, upper-case for descending
  local S_ORD="o" R_ORD="O" SPEC="n"  # default: by name

  # translate ls options to glob-qualifiers,
  # ignoring "--sort" prefix of long-args form
  case ${o_sort:#--sort} in
    -U|none)                     SPEC="N";;
    -t|time)                     SPEC="m";;
    -c|ctime|status)             SPEC="c";;
    -u|atime|access|use)         SPEC="a";;
    # reverse default order for sort by size
    -S|size) S_ORD="O" R_ORD="o" SPEC="L";;
  esac

  if [[ "$o_sort_reverse" == "" ]]; then
    typeset SORT_GLOB="${S_ORD}${SPEC}"
  else
    typeset SORT_GLOB="${R_ORD}${SPEC}"
  fi
  if [[ "$o_group_directories" != "" ]]; then
    SORT_GLOB="oe:[[ -d \$REPLY ]];REPLY=\$?:$SORT_GLOB"
  fi

  # Check which numfmt available (if any), warn user if not available
  typeset -i numfmt_available=0
  typeset -i gnumfmt_available=0
  if [[ "$o_human" != "" ]]; then
    if [[ $+commands[numfmt] == 1 ]]; then
      numfmt_available=1
    elif [[ $+commands[gnumfmt] == 1 ]]; then
      gnumfmt_available=1
    else
      print -u2 "'numfmt' or 'gnumfmt' command not found, human readable output will not work."
      print -u2 "\tFalling back to normal file size output"
      # Set o_human to off
      o_human=""
    fi
  fi

  # Create numfmt local function
  numfmt_local () {
    if [[ "$o_si" != "" ]]; then
      if (( $numfmt_available )); then
        numfmt --to=si $1
      elif (( $gnumfmt_available )); then
        gnumfmt --to=si $1
      fi
    else
      if (( $numfmt_available )); then
        numfmt --to=iec $1
      elif (( $gnumfmt_available )); then
        gnumfmt --to=iec $1
      fi
    fi
  }

  # Set if we're in a repo or not
  typeset -i INSIDE_WORK_TREE=0
  if [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]; then
    INSIDE_WORK_TREE=1
  fi

  # Setup array of directories to print
  typeset -a base_dirs
  typeset base_dir

  if [[ "$@" == "" ]]; then
    base_dirs=.
  else
    base_dirs=($@)
  fi


  # Colors
  # ----------------------------------------------------------------------------
  # default colors
  K_COLOR_DI="0;34"  # di:directory
  K_COLOR_LN="0;35"  # ln:symlink
  K_COLOR_SO="0;32"  # so:socket
  K_COLOR_PI="0;33"  # pi:pipe
  K_COLOR_EX="0;31"  # ex:executable
  K_COLOR_BD="34;46" # bd:block special
  K_COLOR_CD="34;43" # cd:character special
  K_COLOR_SU="30;41" # su:executable with setuid bit set
  K_COLOR_SG="30;46" # sg:executable with setgid bit set
  K_COLOR_TW="30;42" # tw:directory writable to others, with sticky bit
  K_COLOR_OW="30;43" # ow:directory writable to others, without sticky bit
  K_COLOR_BR="0;30"  # branch

  # read colors if osx and $LSCOLORS is defined
  if [[ $(uname) == 'Darwin' && -n $LSCOLORS ]]; then
    # Translate OSX/BSD's LSCOLORS so we can use the same here
    K_COLOR_DI=$(_k_bsd_to_ansi $LSCOLORS[1]  $LSCOLORS[2])
    K_COLOR_LN=$(_k_bsd_to_ansi $LSCOLORS[3]  $LSCOLORS[4])
    K_COLOR_SO=$(_k_bsd_to_ansi $LSCOLORS[5]  $LSCOLORS[6])
    K_COLOR_PI=$(_k_bsd_to_ansi $LSCOLORS[7]  $LSCOLORS[8])
    K_COLOR_EX=$(_k_bsd_to_ansi $LSCOLORS[9]  $LSCOLORS[10])
    K_COLOR_BD=$(_k_bsd_to_ansi $LSCOLORS[11] $LSCOLORS[12])
    K_COLOR_CD=$(_k_bsd_to_ansi $LSCOLORS[13] $LSCOLORS[14])
    K_COLOR_SU=$(_k_bsd_to_ansi $LSCOLORS[15] $LSCOLORS[16])
    K_COLOR_SG=$(_k_bsd_to_ansi $LSCOLORS[17] $LSCOLORS[18])
    K_COLOR_TW=$(_k_bsd_to_ansi $LSCOLORS[19] $LSCOLORS[20])
    K_COLOR_OW=$(_k_bsd_to_ansi $LSCOLORS[21] $LSCOLORS[22])
  fi

  # read colors if linux and $LS_COLORS is defined
  # if [[ $(uname) == 'Linux' && -n $LS_COLORS ]]; then

  # fi

  # ----------------------------------------------------------------------------
  # Loop over passed directories and files to display
  # ----------------------------------------------------------------------------
  for base_dir in $base_dirs
  do
    # ----------------------------------------------------------------------------
    # Display name if multiple paths were passed
    # ----------------------------------------------------------------------------
    if [[ "$#base_dirs" > 1 ]]; then
      # Only add a newline if its not the first iteration
      if [[ "$base_dir" != "${base_dirs[1]}" ]]; then
        print
      fi
      print -r "${base_dir}:"
    fi
    # ----------------------------------------------------------------------------
    # Vars
    # ----------------------------------------------------------------------------

    typeset -a MAX_LEN A RESULTS STAT_RESULTS
    typeset TOTAL_BLOCKS

    # Get now
    typeset K_EPOCH="${EPOCHSECONDS:?}"

    typeset -i TOTAL_BLOCKS=0

    MAX_LEN=(0 0 0 0 0 0)

    # Array to hold results from `stat` call
    RESULTS=()

    # only set once per directory so must be out of the main loop
    typeset -i IS_GIT_REPO=0
    typeset GIT_TOPLEVEL

    typeset -i LARGE_FILE_COLOR=196
    typeset -a SIZELIMITS_TO_COLOR
    SIZELIMITS_TO_COLOR=(
        1024  46    # <= 1kb
        2048  82    # <= 2kb
        3072  118   # <= 3kb
        5120  154   # <= 5kb
       10240  190   # <= 10kb
       20480  226   # <= 20kb
       40960  220   # <= 40kb
      102400  214   # <= 100kb
      262144  208   # <= 0.25mb || 256kb
      524288  202   # <= 0.5mb || 512kb
      )
    typeset -i ANCIENT_TIME_COLOR=236  # > more than 2 years old
    typeset -a FILEAGES_TO_COLOR
    FILEAGES_TO_COLOR=(
             0 196  # < in the future, #spooky
            60 255  # < less than a min old
          3600 252  # < less than an hour old
         86400 250  # < less than 1 day old
        604800 244  # < less than 1 week old
       2419200 244  # < less than 28 days (4 weeks) old
      15724800 242  # < less than 26 weeks (6 months) old
      31449600 240  # < less than 1 year old
      62899200 238  # < less than 2 years old
      )

    # ----------------------------------------------------------------------------
    # Build up list of files/directories to show
    # ----------------------------------------------------------------------------

    typeset -a show_list
    show_list=()

    # Check if it even exists
    if [[ ! -e $base_dir ]]; then
      print -u2 "k: cannot access $base_dir: No such file or directory"

    # If its just a file, skip the directory handling
    elif [[ -f $base_dir ]]; then
      show_list=($base_dir)

    #Directory, add its contents
    else
      # Break total blocks of the front of the stat call, then push the rest to results
      if [[ "$o_all" != "" && "$o_almost_all" == "" && "$o_no_directory" == "" ]]; then
        show_list+=($base_dir/.)
        show_list+=($base_dir/..)
      fi

      if [[ "$o_all" != "" || "$o_almost_all" != "" ]]; then
        if [[ "$o_directory" != "" ]]; then
          show_list+=($base_dir/*(D/$SORT_GLOB))
        elif [[ "$o_no_directory" != "" ]]; then
          #Use (^/) instead of (.) so sockets and symlinks get displayed
          show_list+=($base_dir/*(D^/$SORT_GLOB))
        else
          show_list+=($base_dir/*(D$SORT_GLOB))
        fi
      else
        if [[ "$o_directory" != "" ]]; then
          show_list+=($base_dir/*(/$SORT_GLOB))
        elif [[ "$o_no_directory" != "" ]]; then
          #Use (^/) instead of (.) so sockets and symlinks get displayed
          show_list+=($base_dir/*(^/$SORT_GLOB))
        else
	  show_list+=($base_dir/*($SORT_GLOB))
        fi
      fi
    fi

    # ----------------------------------------------------------------------------
    # Stat call to get directory listing
    # ----------------------------------------------------------------------------
    typeset -i i=1 j=1 k=1
    typeset -a STATS_PARAMS_LIST
    typeset fn statvar h
    typeset -A sv

    STATS_PARAMS_LIST=()
    for fn in $show_list
    do
      statvar="stats_$i"
      typeset -A $statvar
      zstat -H $statvar -Lsn -F "%s^%d^%b^%H:%M^%Y" -- "$fn"  # use lstat, render mode/uid/gid to strings
      STATS_PARAMS_LIST+=($statvar)
      i+=1
    done


    # On each result calculate padding by getting max length on each array member
    for statvar in "${STATS_PARAMS_LIST[@]}"
    do
      sv=("${(@Pkv)statvar}")
      if [[ ${#sv[mode]}  -gt $MAX_LEN[1] ]]; then MAX_LEN[1]=${#sv[mode]}  ; fi
      if [[ ${#sv[nlink]} -gt $MAX_LEN[2] ]]; then MAX_LEN[2]=${#sv[nlink]} ; fi
      if [[ ${#sv[uid]}   -gt $MAX_LEN[3] ]]; then MAX_LEN[3]=${#sv[uid]}   ; fi
      if [[ ${#sv[gid]}   -gt $MAX_LEN[4] ]]; then MAX_LEN[4]=${#sv[gid]}   ; fi

      if [[ "$o_human" != "" ]]; then
        h=$(numfmt_local ${sv[size]})
        if (( ${#h} > $MAX_LEN[5] )); then MAX_LEN[5]=${#h}; fi
      else
        if [[ ${#sv[size]} -gt $MAX_LEN[5] ]]; then MAX_LEN[5]=${#sv[size]}; fi
      fi

      TOTAL_BLOCKS+=$sv[blocks]
    done

    # Print total block before listing
    echo "total $TOTAL_BLOCKS"

    # ----------------------------------------------------------------------------
    # Loop through each line of stat, pad where appropriate and do git dirty checking
    # ----------------------------------------------------------------------------

    typeset REPOMARKER
    typeset REPOBRANCH
    typeset PERMISSIONS HARDLINKCOUNT OWNER GROUP FILESIZE FILESIZE_OUT DATE NAME SYMLINK_TARGET
    typeset FILETYPE PER1 PER2 PER3 PERMISSIONS_OUTPUT STATUS
    typeset TIME_DIFF TIME_COLOR DATE_OUTPUT
    typeset -i IS_DIRECTORY IS_SYMLINK IS_SOCKET IS_PIPE IS_EXECUTABLE IS_BLOCK_SPECIAL IS_CHARACTER_SPECIAL HAS_UID_BIT HAS_GID_BIT HAS_STICKY_BIT IS_WRITABLE_BY_OTHERS
    typeset -i COLOR

    k=1
    for statvar in "${STATS_PARAMS_LIST[@]}"
    do
      sv=("${(@Pkv)statvar}")

      # We check if the result is a git repo later, so set a blank marker indication the result is not a git repo
      REPOMARKER=" "
      REPOBRANCH=""
      IS_DIRECTORY=0
      IS_SYMLINK=0
      IS_SOCKET=0
      IS_PIPE=0
      IS_EXECUTABLE=0
      IS_BLOCK_SPECIAL=0
      IS_CHARACTER_SPECIAL=0
      HAS_UID_BIT=0
      HAS_GID_BIT=0
      HAS_STICKY_BIT=0
      IS_WRITABLE_BY_OTHERS=0

         PERMISSIONS="${sv[mode]}"
       HARDLINKCOUNT="${sv[nlink]}"
               OWNER="${sv[uid]}"
               GROUP="${sv[gid]}"
            FILESIZE="${sv[size]}"
                DATE=(${(s:^:)sv[mtime]}) # Split date on ^
                NAME="${sv[name]}"
      SYMLINK_TARGET="${sv[link]}"

      # Check for file types
      if [[ -d "$NAME" ]]; then IS_DIRECTORY=1; fi
      if [[ -L "$NAME" ]]; then IS_SYMLINK=1; fi
      if [[ -S "$NAME" ]]; then IS_SOCKET=1; fi
      if [[ -p "$NAME" ]]; then IS_PIPE=1; fi
      if [[ -x "$NAME" ]]; then IS_EXECUTABLE=1; fi
      if [[ -b "$NAME" ]]; then IS_BLOCK_SPECIAL=1; fi
      if [[ -c "$NAME" ]]; then IS_CHARACTER_SPECIAL=1; fi
      if [[ -u "$NAME" ]]; then HAS_UID_BIT=1; fi
      if [[ -g "$NAME" ]]; then HAS_GID_BIT=1; fi
      if [[ -k "$NAME" ]]; then HAS_STICKY_BIT=1; fi
      if [[ $PERMISSIONS[9] == 'w' ]]; then IS_WRITABLE_BY_OTHERS=1; fi

      # IS_GIT_REPO is a 1 if $NAME is a file/directory in a git repo, OR if $NAME is a git-repo itself
      # GIT_TOPLEVEL is set to the directory containing the .git folder of a git-repo

      # is this a git repo
      if [[ "$o_no_vcs" != "" ]]; then
        IS_GIT_REPO=0
        GIT_TOPLEVEL=''
      else
        if (( IS_DIRECTORY ));
          then builtin cd -q $NAME     2>/dev/null || builtin cd -q - >/dev/null && IS_GIT_REPO=0 #Say no if we don't have permissions there
          else builtin cd -q $NAME:a:h 2>/dev/null || builtin cd -q - >/dev/null && IS_GIT_REPO=0
        fi
        if [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]; then
          IS_GIT_REPO=1
          GIT_TOPLEVEL=$(command git rev-parse --show-toplevel)
        else
          IS_GIT_REPO=0
        fi
        builtin cd -q - >/dev/null
      fi

      # Get human readable output if necessary
      if [[ "$o_human" != "" ]]; then
        # I hate making this call twice, but its either that, or do a bunch
        # of calculations much earlier.
        FILESIZE_OUT=$(numfmt_local $FILESIZE)
      else
        FILESIZE_OUT=$FILESIZE
      fi

      # Pad so all the lines align - firstline gets padded the other way
        PERMISSIONS="${(r:MAX_LEN[1]:)PERMISSIONS}"
      HARDLINKCOUNT="${(l:MAX_LEN[2]:)HARDLINKCOUNT}"
              OWNER="${(l:MAX_LEN[3]:)OWNER}"
              GROUP="${(l:MAX_LEN[4]:)GROUP}"
       FILESIZE_OUT="${(l:MAX_LEN[5]:)FILESIZE_OUT}"

      # --------------------------------------------------------------------------
      # Colour the permissions - TODO
      # --------------------------------------------------------------------------
      # Colour the first character based on filetype
      FILETYPE="${PERMISSIONS[1]}"

      # Permissions Owner
      PER1="${PERMISSIONS[2,4]}"

      # Permissions Group
      PER2="${PERMISSIONS[5,7]}"

      # Permissions User
      PER3="${PERMISSIONS[8,10]}"

      PERMISSIONS_OUTPUT="$FILETYPE$PER1$PER2$PER3"

      # --------------------------------------------------------------------------
      # Colour the symlinks
      # --------------------------------------------------------------------------

      # --------------------------------------------------------------------------
      # Colour Owner and Group
      # --------------------------------------------------------------------------
      OWNER=$'\e[38;5;241m'"$OWNER"$'\e[0m'
      GROUP=$'\e[38;5;241m'"$GROUP"$'\e[0m'

      # --------------------------------------------------------------------------
      # Colour file weights
      # --------------------------------------------------------------------------
      COLOR=LARGE_FILE_COLOR
      for i j in ${SIZELIMITS_TO_COLOR[@]}
      do
        (( FILESIZE <= i )) || continue
        COLOR=$j
        break
      done

      FILESIZE_OUT=$'\e[38;5;'"${COLOR}m$FILESIZE_OUT"$'\e[0m'

      # --------------------------------------------------------------------------
      # Colour the date and time based on age, then format for output
      # --------------------------------------------------------------------------
      # Setup colours based on time difference
      TIME_DIFF=$(( K_EPOCH - DATE[1] ))
      TIME_COLOR=$ANCIENT_TIME_COLOR
      for i j in ${FILEAGES_TO_COLOR[@]}
      do
        (( TIME_DIFF < i )) || continue
        TIME_COLOR=$j
        break
      done

      # Format date to show year if more than 6 months since last modified
      if (( TIME_DIFF < 15724800 )); then
        DATE_OUTPUT="${DATE[2]} ${(r:5:: :)${DATE[3][0,5]}} ${DATE[4]}"
      else
        DATE_OUTPUT="${DATE[2]} ${(r:6:: :)${DATE[3][0,5]}} ${DATE[5]}"  # extra space; 4 digit year instead of 5 digit HH:MM
      fi;
      DATE_OUTPUT[1]="${DATE_OUTPUT[1]//0/ }" # If day of month begins with zero, replace zero with space

      # Apply colour to formated date
      DATE_OUTPUT=$'\e[38;5;'"${TIME_COLOR}m${DATE_OUTPUT}"$'\e[0m'

      # --------------------------------------------------------------------------
      # Colour the repomarker
      # --------------------------------------------------------------------------
      if [[ "$o_no_vcs" != "" ]]; then
        REPOMARKER=""
      elif (( IS_GIT_REPO != 0)); then
        # If we're not in a repo, still check each directory if it's a repo, and
        # then mark appropriately
        if (( INSIDE_WORK_TREE == 0 )); then
          REPOBRANCH=$(command git --git-dir="$GIT_TOPLEVEL/.git" --work-tree="${NAME}" rev-parse --abbrev-ref HEAD 2>/dev/null)
          if (( IS_DIRECTORY )); then
            if command git --git-dir="$GIT_TOPLEVEL/.git" --work-tree="${NAME}" diff --stat --quiet --ignore-submodules HEAD &>/dev/null # if dirty
              then REPOMARKER=$'\e[38;5;46m|\e[0m' # Show a green vertical bar for clean
              else REPOMARKER=$'\e[0;31m+\e[0m' # Show a red vertical bar if dirty
            fi
          fi
        else
          if (( IS_DIRECTORY )); then
            # If the directory isn't ignored or clean, we'll just say it's dirty
            if command git check-ignore --quiet ${NAME} 2>/dev/null; then STATUS='!!'
            elif command git diff --stat --quiet --ignore-submodules ${NAME} 2> /dev/null; then STATUS='';
            else STATUS=' M'
            fi
          else
            # File
            STATUS=$(command git status --porcelain --ignored --untracked-files=normal $GIT_TOPLEVEL/${${${NAME:a}##$GIT_TOPLEVEL}#*/})
          fi
          STATUS=${STATUS[1,2]}
            if [[ $STATUS == ' M' ]]; then REPOMARKER=$'\e[0;31m+\e[0m';     # Tracked & Dirty
          elif [[ $STATUS == 'M ' ]]; then REPOMARKER=$'\e[38;5;082m+\e[0m'; # Tracked & Dirty & Added
          elif [[ $STATUS == '??' ]]; then REPOMARKER=$'\e[38;5;214m+\e[0m'; # Untracked
          elif [[ $STATUS == '!!' ]]; then REPOMARKER=$'\e[38;5;238m|\e[0m'; # Ignored
          elif [[ $STATUS == 'A ' ]]; then REPOMARKER=$'\e[38;5;082m+\e[0m'; # Added
          else                             REPOMARKER=$'\e[38;5;082m|\e[0m'; # Good
          fi
        fi
      fi

      # --------------------------------------------------------------------------
      # Colour the filename
      # --------------------------------------------------------------------------
      # Unfortunately, the choices for quoting which escape ANSI color sequences are q & qqqq; none of q- qq qqq work.
      # But we don't want to quote '.'; so instead we escape the escape manually and use q-
      NAME="${${NAME##*/}//$'\e'/\\e}"    # also propagate changes to SYMLINK_TARGET below

      if [[ $IS_DIRECTORY == 1 ]]; then
        if [[ $IS_WRITABLE_BY_OTHERS == 1 ]]; then
          if [[ $HAS_STICKY_BIT == 1 ]]; then
            NAME=$'\e['"$K_COLOR_TW"'m'"$NAME"$'\e[0m';
          fi
          NAME=$'\e['"$K_COLOR_OW"'m'"$NAME"$'\e[0m';
        fi
        NAME=$'\e['"$K_COLOR_DI"'m'"$NAME"$'\e[0m';
      elif [[ $IS_SYMLINK           == 1 ]]; then NAME=$'\e['"$K_COLOR_LN"'m'"$NAME"$'\e[0m';
      elif [[ $IS_SOCKET            == 1 ]]; then NAME=$'\e['"$K_COLOR_SO"'m'"$NAME"$'\e[0m';
      elif [[ $IS_PIPE              == 1 ]]; then NAME=$'\e['"$K_COLOR_PI"'m'"$NAME"$'\e[0m';
      elif [[ $HAS_UID_BIT          == 1 ]]; then NAME=$'\e['"$K_COLOR_SU"'m'"$NAME"$'\e[0m';
      elif [[ $HAS_GID_BIT          == 1 ]]; then NAME=$'\e['"$K_COLOR_SG"'m'"$NAME"$'\e[0m';
      elif [[ $IS_EXECUTABLE        == 1 ]]; then NAME=$'\e['"$K_COLOR_EX"'m'"$NAME"$'\e[0m';
      elif [[ $IS_BLOCK_SPECIAL     == 1 ]]; then NAME=$'\e['"$K_COLOR_BD"'m'"$NAME"$'\e[0m';
      elif [[ $IS_CHARACTER_SPECIAL == 1 ]]; then NAME=$'\e['"$K_COLOR_CD"'m'"$NAME"$'\e[0m';
      fi

      # --------------------------------------------------------------------------
      # Colour branch
      # --------------------------------------------------------------------------
      REPOBRANCH=$'\e['"$K_COLOR_BR"'m'"$REPOBRANCH"$'\e[0m';

      # --------------------------------------------------------------------------
      # Format symlink target
      # --------------------------------------------------------------------------
      if [[ $SYMLINK_TARGET != "" ]]; then SYMLINK_TARGET=" -> ${SYMLINK_TARGET//$'\e'/\\e}"; fi

      # --------------------------------------------------------------------------
      # Display final result
      # --------------------------------------------------------------------------
      print -r -- "$PERMISSIONS_OUTPUT $HARDLINKCOUNT $OWNER $GROUP $FILESIZE_OUT $DATE_OUTPUT $REPOMARKER $NAME$SYMLINK_TARGET $REPOBRANCH"

      k=$((k+1)) # Bump loop index
    done
  done
}

_k_bsd_to_ansi() {
  local foreground=$1 background=$2 foreground_ansi background_ansi
  case $foreground in
    a) foreground_ansi=30;;
    b) foreground_ansi=31;;
    c) foreground_ansi=32;;
    d) foreground_ansi=33;;
    e) foreground_ansi=34;;
    f) foreground_ansi=35;;
    g) foreground_ansi=36;;
    h) foreground_ansi=37;;
    x) foreground_ansi=0;;
  esac
  case $background in
    a) background_ansi=40;;
    b) background_ansi=41;;
    c) background_ansi=42;;
    d) background_ansi=43;;
    e) background_ansi=44;;
    f) background_ansi=45;;
    g) background_ansi=46;;
    h) background_ansi=47;;
    x) background_ansi=0;;
  esac
  printf "%s;%s" $background_ansi $foreground_ansi
}

# http://upload.wikimedia.org/wikipedia/en/1/15/Xterm_256color_chart.svg
# vim: set ts=2 sw=2 ft=zsh et :
