# new k
k () {
  MAX_LEN=(0 0 0 0 0 0)
  stat -f "%Sp~%l~%Su~%Sg~%Z~%Sm~%N~%Y" -t "%D" . .. .* * | while read RES
  do
    A=(${(s:~:)RES})
    # dont need to pad the first line
    # if [[ $#A[1] -ge $MAX_LEN[1] ]]; then MAX_LEN[1]=$#A[1]; fi;
    if [[ $#A[2] -ge $MAX_LEN[2] ]]; then MAX_LEN[2]=$#A[2]; fi;
    if [[ $#A[3] -ge $MAX_LEN[3] ]]; then MAX_LEN[3]=$#A[3]; fi;
    if [[ $#A[4] -ge $MAX_LEN[4] ]]; then MAX_LEN[4]=$#A[4]; fi;
    if [[ $#A[5] -ge $MAX_LEN[5] ]]; then MAX_LEN[5]=$#A[5]; fi;
    if [[ $#A[6] -ge $MAX_LEN[6] ]]; then MAX_LEN[6]=$#A[6]; fi;
  done

  stat -f "%Sp~%l~%Su~%Sg~%Z~%Sm~%N~%Y" -t "%D" . .. .* * | while read RES2
  do
    # create array from results by splitting on ~
    # 1: permissions
    # 2: num of sym links pointing to this file
    # 3: owner
    # 4: group
    # 5: filesize in bytes
    # 6: date last modified
    # 7: name
    ARR=(${(s:~:)RES2})

    REPOMARKER=" "  

    if [[ -d $ARR[7] ]] # if a directory
      then
      if [[ -d $ARR[7]"/.git" ]] # if contains a git folder
        then
        if git --git-dir=`pwd`/$ARR[7]/.git --work-tree=`pwd`/$ARR[7] diff --quiet --ignore-submodules HEAD &>/dev/null # if dirty
          then REPOMARKER="\033[0;32m|\033[0m"
          else REPOMARKER="\033[0;31m|\033[0m"
        fi
      fi
      # color directory
      ARR[7]="\033[1;36m"$ARR[7]"\033[0m"
    fi

    if [[ ! -z $ARR[8] ]]
      # color symblink
      then ARR[7]="\033[0;35m"$ARR[7]"\033[0m ->"
    fi
    # pad so they align
    # dont need to pad the first line ?
    # while [[ $#ARR[1] -lt $MAX_LEN[1] ]]; do ARR[1]=" "$ARR[1]; done;
    while [[ $#ARR[2] -lt $MAX_LEN[2] ]]; do ARR[2]=" "$ARR[2]; done;
    while [[ $#ARR[3] -lt $MAX_LEN[3] ]]; do ARR[3]=" "$ARR[3]; done;
    while [[ $#ARR[4] -lt $MAX_LEN[4] ]]; do ARR[4]=" "$ARR[4]; done;
    while [[ $#ARR[5] -lt $MAX_LEN[5] ]]; do ARR[5]=" "$ARR[5]; done;
    while [[ $#ARR[6] -lt $MAX_LEN[6] ]]; do ARR[6]=" "$ARR[6]; done;

    # this works but is slow
    # ARR[1]=$(echo "$ARR[1]" | sed 's/^\(d\)/\\033[1;36m\1\\033[0m/')
    
    # oh zing!
    # ARR[1]=${ARR[1]//d/"\033[1;36md\033[0m"}

    # type
    T=$ARR[1]
    T=$T[1]
    if [[ $T == "d" ]]; then T=${T//d/"\033[1;36md\033[0m"}; fi
    if [[ $T == "l" ]]; then T=${T//l/"\033[0;35ml\033[0m"}; fi
    if [[ $T == "-" ]]; then T=${T//-/"\033[0;37m-\033[0m"}; fi

    # permissions 1
    PER1=$ARR[1]
    PER1=$PER1[2,4]

    # permissions 2
    PER2=$ARR[1]
    PER2=$PER2[5,7]

    # permissions 3
    PER3=$ARR[1]
    PER3=$PER3[8,10]

    echo $T$PER1$PER2$PER3 $ARR[2] $ARR[3] $ARR[4] $ARR[5] $ARR[6] $REPOMARKER $ARR[7] $ARR[8]
  done
}





    # if $ARR[1][1]
    # if --git-dir=`pwd`/$ARR[7]/.git
    #   then repoMarker='*'
    #   if git --git-dir=`pwd`/$ARR[7]/.git --work-tree=`pwd`/$ARR[7] diff --quiet --ignore-submodules HEAD &>/dev/null
    #     then repoMarker='&'
    #     fi
    # fi
    # echo $ARR[1] $ARR[2] $ARR[3] $ARR[4] $ARR[5] '\033[31;0m'$ARR[6]'\033[0m' '\033[0;34m'$ARR[7]'\033[0m'





  # git --git-dir=`pwd`/.git --work-tree=`pwd` rev-parse --is-inside-work-tree &>/dev/null || return

  # filesArr=(. .. .* *) | ehite

  # stat -f "%Sp %l %Su %Sg %Z %Sm | %N %Y" -t "%D" $i

  # cd $1 && git rev-parse --is-inside-work-tree &>/dev/null || return && cd $owd

  # for i in $filesArr
    # do
    # repoMarker=''
    # if true #git --git-dir=`pwd`/$i/.git --work-tree=`pwd`/$1 rev-parse --is-inside-work-tree  &>/dev/null
    #   then repoMarker='*'
    #   if true #git --git-dir=`pwd`/$i/.git --work-tree=`pwd`/$1 diff --quiet --ignore-submodules HEAD &>/dev/null
    #     then repoMarker='&'
    #     fi
    # fi
    # stat -f "%Sp %l %Su %Sg %Z %Sm $repoMarker %N %Y" -t "%D" $i
  # done

# git_dirty() {
#     # Check if we're in a git repo
#     command git rev-parse --is-inside-work-tree &>/dev/null || return
#     # Check if it's dirty
#     command git diff --quiet --ignore-submodules HEAD &>/dev/null; [ $? -eq 1 ] && echo "*"
# }






# old k, suck old features from here before deleting
kk() {
  GREEN_TO_RED=(46 82 118 154 190 226 220 214 208 202 196)
  # ls with file sizes highlighted
  # echo " $( script -q /dev/null ls -laG | sed 's/^\([^ ]*[ ]*\)\([^ ]*[ ]*\)\([^ ]*[ ]*\)\([^ ]*\)\([ ]*[0-9]*\)/\1\2\3\4\\033[41m\5\\033[0m/' ) "

  # Get all the file sizes from a ls call (i know this is bad, but i dont know any better)
  FILESIZES="$(script -q /dev/null ls -laG | sed 's/^\([^ ]*[ ]*\)\([^ ]*[ ]*\)\([^ ]*[ ]*\)\([^ ]*\)\([ ]*[0-9]*\)\(.*\)/\5/')"
  # Split them into array on linebreaks
  SIZE_ARRAY=("${(@f)FILESIZES}")

  # Get all the results from a ls call
  LSRESULTS="$(script -q /dev/null ls -laG)"
  # Split them into array on linebreaks
  LSRESULT_ARRAY=("${(@f)LSRESULTS}")

  # make them unique
  SIZE_UNIQ=(${(u)SIZE_ARRAY})
  SIZE_UNIQ_SORTED=(${(o)SIZE_UNIQ})

  # get the lowest filesize
  LOWEST=$SIZE_UNIQ_SORTED[1]

  # get the highest filesize
  HIGHEST=$SIZE_UNIQ_SORTED[$#SIZE_UNIQ_SORTED]

  # get the difference between the highest and lowest filesizes
  DIFF=$(($HIGHEST-$LOWEST))

  STEP=$(($DIFF/11.0))

  echo $(($DIFF/$STEP))

  # echo $DIFF $LOWEST

  # for ((i = 1; i <= $#SIZE_UNIQ_SORTED; i++))
    # do echo $(($SIZE_UNIQ_SORTED[$i] - $LOWEST))
  # done

  # ((JUMP=11.0 / #SIZE_UNIQ_SORTED))
  # for ((i = 1; i <= $#SIZE_UNIQ_SORTED; i++))
  #   do echo $i $((int($i * $JUMP))) "\t" $SIZE_UNIQ_SORTED[$i]
  # done
}
