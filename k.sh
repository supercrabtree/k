zmodload zsh/datetime
zmodload -F zsh/stat b:zstat

k () {
  # ----------------------------------------------------------------------------
  # Setup
  # ----------------------------------------------------------------------------

  # Stop stat failing when a directory contains either no files or no hidden files
  # Track if we _accidentally_ create a new global variable
  setopt local_options null_glob warn_create_global typeset_silent

  # Turn on 256 colour terminal, not sure this works at all.
  typeset OLD_TERM="$TERM"
  TERM='xterm-256color'

  # Process options and get files/directories
  # Options:
  # -a      --all           list entries starting with .
  # -A      --almost-all    list all except . and ..
  # -d      --directory     list directory entries instead of contents
  # -n      --no-directory  do not list directories
  # -h      --help          show this help
  typeset -a o_all o_almost_all o_directory o_no_directory o_help
  zparseopts -E -D \
             a=o_all -all=o_all \
             A=o_almost_all -almost-all=o_almost_all \
             d=o_directory -directory=o_directory \
             n=o_no_directory -no-directory=o_no_directory \
             h=o_help -help=o_help

  # Print Help if bad usage, or they asked for it
  if [[ $? != 0 || "$o_help" != "" ]]
  then
      print "Usage: k [options] DIR"
      print "Options:"
      print "\t-a      --all           list entries starting with ."
      print "\t-A      --almost-all    list all except . and .."
      print "\t-d      --directory     list directory entries instead of contents"
      print "\t-h      --help          show this help"
      print "\t-n      --no-directory  do not list directories"
      return 1
  fi

  # Check for conflicts
  if [[ "$o_directory" != "" && "$o_no_directory" != "" ]]; then
    print "$o_directory and $o_no_directory cannot be used together" 1>&2
    return 1
  fi

  typeset -a base_dirs

  if [[ "$@" == "" ]]; then
    base_dirs=.
  else
    base_dirs=($@)
  fi

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

    # only set once so must be out of the main loop
    typeset -i IS_GIT_REPO=0

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
    # Break total blocks of the front of the stat call, then push the rest to results
    if [[ "$o_almost_all" == "" && "$o_no_directory" == "" ]]; then
      show_list+=($base_dir/.)
      show_list+=($base_dir/..)
    fi

    if [[ "$o_all" != "" ]]; then
      if [[ "$o_directory" != "" ]]; then
        show_list+=($base_dir/*(D/))

      elif [[ "$o_no_directory" != "" ]]; then
        #Use (^/) instead of (.) so sockets and symlinks get displayed
        show_list+=($base_dir/*(D^/))

      else
        show_list+=($base_dir/*(D))

      fi

    else
      if [[ "$o_directory" != "" ]]; then
        show_list+=($base_dir/*(/))

      elif [[ "$o_no_directory" != "" ]]; then
        #Use (^/) instead of (.) so sockets and symlinks get displayed
        show_list+=($base_dir/*(^/))

      else
        show_list+=($base_dir/*)

      fi
    fi

    # ----------------------------------------------------------------------------
    # Stat call to get directory listing
    # ----------------------------------------------------------------------------
    typeset -i i=1 j=1 k=1
    typeset -a STATS_PARAMS_LIST
    typeset fn statvar
    typeset -A sv

    for fn in $show_list
    do
      if [[ "$+commands[realpath]" != 0 ]]; then
        fn=$(realpath --relative-to=. -es $fn)
      fi
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
      if [[ ${#sv[size]}  -gt $MAX_LEN[5] ]]; then MAX_LEN[5]=${#sv[size]}  ; fi
      TOTAL_BLOCKS+=$sv[blocks]
    done

    # Print total block before listing
    echo "total $TOTAL_BLOCKS"

    # ----------------------------------------------------------------------------
    # Loop through each line of stat, pad where appropriate and do git dirty checking
    # ----------------------------------------------------------------------------

    typeset REPOMARKER
    typeset PERMISSIONS HARDLINKCOUNT OWNER GROUP FILESIZE DATE NAME SYMLINK_TARGET
    typeset FILETYPE PER1 PER2 PER3 PERMISSIONS_OUTPUT STATUS
    typeset TIME_DIFF TIME_COLOR DATE_OUTPUT
    typeset -i IS_DIRECTORY IS_SYMLINK IS_EXECUTABLE
    typeset -i COLOR

    k=1
    for statvar in "${STATS_PARAMS_LIST[@]}"
    do
      sv=("${(@Pkv)statvar}")

      # We check if the result is a git repo later, so set a blank marker indication the result is not a git repo
      REPOMARKER=" "
      IS_DIRECTORY=0
      IS_SYMLINK=0
      IS_EXECUTABLE=0

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
      if [[ -L "$NAME" ]]; then   IS_SYMLINK=1; fi

      # is this a git repo
      [[ $IS_DIRECTORY ]] && cd $show_base_dir || cd $(dirname $show_base_dir)
      if [[ $k == 1 && $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]
        then
        IS_GIT_REPO=1
      fi;
      cd - >/dev/null

      # Pad so all the lines align - firstline gets padded the other way
        PERMISSIONS="${(r:MAX_LEN[1]:)PERMISSIONS}"
      HARDLINKCOUNT="${(l:MAX_LEN[2]:)HARDLINKCOUNT}"
              OWNER="${(l:MAX_LEN[3]:)OWNER}"
              GROUP="${(l:MAX_LEN[4]:)GROUP}"
           FILESIZE="${(l:MAX_LEN[5]:)FILESIZE}"

      # --------------------------------------------------------------------------
      # Colour the permissions - TODO
      # --------------------------------------------------------------------------
      # Colour the first character based on filetype
      FILETYPE="${PERMISSIONS[1]}"
      if (( IS_DIRECTORY ))
        then
        FILETYPE=${FILETYPE//d/$'\e[1;36m'd$'\e[0m'};
      elif (( IS_SYMLINK ))
        then
        FILETYPE=${FILETYPE//l/$'\e[0;35m'l$'\e[0m'};
      elif [[ $FILETYPE == "-" ]];
        then
        FILETYPE=${FILETYPE//-/$'\e[0;37m'-$'\e[0m'};
      fi

      # Permissions Owner
      PER1="${PERMISSIONS[2,4]}"

      # Permissions Group
      PER2="${PERMISSIONS[5,7]}"

      # Permissions User
      PER3="${PERMISSIONS[8,10]}"

      PERMISSIONS_OUTPUT="$FILETYPE$PER1$PER2$PER3"

      # --x --x --x warning
      if [[ $PER1[3] == "x" || $PER2[3] == "x" || $PER3[3] == "x" ]]; then IS_EXECUTABLE=1; fi

      # --- --- rwx warning
      if [[ $PER3 == "rwx" ]]; then PERMISSIONS_OUTPUT=$'\e[30;41m'"$PERMISSIONS"$'\e[0m'; fi

      # --------------------------------------------------------------------------
      # Colour the symlinks - TODO
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

      FILESIZE=$'\e[38;5;'"${COLOR}m$FILESIZE"$'\e[0m'

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
      # Check for git repo, first checking if the result is a directory
      if (( IS_GIT_REPO == 0)) || (( k <= 2 ))
      then
        if (( IS_DIRECTORY )) && [[ -d "$NAME/.git" ]]
        then
          if command git --git-dir="$PWD/$NAME/.git" --work-tree="$PWD/$NAME" diff --quiet --ignore-submodules HEAD &>/dev/null # if dirty
            then REPOMARKER=$'\e[38;5;46m|\e[0m' # Show a green vertical bar for dirty
            else REPOMARKER=$'\e[0;31m|\e[0m' # Show a red vertical bar if clean
          fi
        fi
      fi

      if (( IS_GIT_REPO )) && (( k > 2 )) && [[ "$NAME" != '.git' ]]
        then
        STATUS="$(command git status --porcelain --ignored --untracked-files=normal "$NAME")"
        STATUS="${STATUS[1,2]}"
          if [[ $STATUS == ' M' ]]; then REPOMARKER=$'\e[0;31m|\e[0m';     # Modified
        elif [[ $STATUS == '??' ]]; then REPOMARKER=$'\e[38;5;214m|\e[0m'; # Untracked
        elif [[ $STATUS == '!!' ]]; then REPOMARKER=$'\e[38;5;238m|\e[0m'; # Ignored
        elif [[ $STATUS == 'A ' ]]; then REPOMARKER=$'\e[38;5;093m|\e[0m'; # Added
        else                             REPOMARKER=$'\e[38;5;082m|\e[0m';     # Good
        fi
      fi

      # --------------------------------------------------------------------------
      # Colour the filename
      # --------------------------------------------------------------------------
      # Unfortunately, the choices for quoting which escape ANSI color sequences are q & qqqq; none of q- qq qqq work.
      # But we don't want to quote '.'; so instead we escape the escape manually and use q-
      NAME="${(q-)NAME//$'\e'/\\e}"    # also propagate changes to SYMLINK_TARGET below

      if (( IS_DIRECTORY ))
      then
        NAME=$'\e[38;5;32m'"$NAME"$'\e[0m'
      elif (( IS_SYMLINK ))
      then
        NAME=$'\e[0;35m'"$NAME"$'\e[0m'
      fi

      # --------------------------------------------------------------------------
      # Format symlink target
      # --------------------------------------------------------------------------
      if [[ $SYMLINK_TARGET != "" ]]; then SYMLINK_TARGET="-> ${(q-)SYMLINK_TARGET//$'\e'/\\e}"; fi

      # --------------------------------------------------------------------------
      # Display final result
      # --------------------------------------------------------------------------
      print -r -- "$PERMISSIONS_OUTPUT $HARDLINKCOUNT $OWNER $GROUP $FILESIZE $DATE_OUTPUT $REPOMARKER $NAME $SYMLINK_TARGET"

      k=$((k+1)) # Bump loop index
    done
  done

  # cleanup / recovery
  TERM="$OLD_TERM"
}

# http://upload.wikimedia.org/wikipedia/en/1/15/Xterm_256color_chart.svg
# vim: set ts=2 sw=2 ft=zsh et :
