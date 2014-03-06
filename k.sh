# new k
k () {


  stat -f "%Sp~%l~%Su~%Sg~%Z~%Sm~%N~%Y" -t "%D" . .. .* * | while read RES
  do
    # create array from results by splitting on ~
    # 1: permissions
    # 2: num of sym links pointing to this file
    # 3: owner
    # 4: group
    # 5: filesize in bytes
    # 6: date last modified
    # 7: name
    ARR=(${(s:~:)RES})

    REPOMARKER=" "

    if [[ -d $ARR[7] ]] # if a directory
      then
      if [[ -d $ARR[7]"/.git" ]] # if contains a git folder
        then
        if git --git-dir=`pwd`/$i/.git --work-tree=`pwd`/$1 diff --quiet --ignore-submodules HEAD &>/dev/null # if dirty (not working)
          then REPOMARKER="\033[0;31m*\033[0m"
          else REPOMARKER="\033[0;32m*\033[0m"
        fi
      fi
    fi

    echo $ARR[1] $ARR[2] $ARR[3] $ARR[4] $ARR[5] $ARR[6] $REPOMARKER $ARR[7]
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
