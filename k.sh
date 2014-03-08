# https://developer.apple.com/library/mac/documentation/Darwin/Reference/Manpages/man1/ls.1.html // useful, can click links
# http://upload.wikimedia.org/wikipedia/en/1/15/Xterm_256color_chart.svg
# new k
k () {
  EPOCH=`date -j +%s`
  MAX_LEN=(0 0 0 0 0 0)

  stat -f "%Sp~%l~%Su~%Sg~%Z~%Sm~%N~%Y" -t "%s" . .. .* * | while read RES
  do
    A=(${(s:~:)RES})
    if [[ $#A[1] -ge $MAX_LEN[1] ]]; then MAX_LEN[1]=$#A[1]; fi;
    if [[ $#A[2] -ge $MAX_LEN[2] ]]; then MAX_LEN[2]=$#A[2]; fi;
    if [[ $#A[3] -ge $MAX_LEN[3] ]]; then MAX_LEN[3]=$#A[3]; fi;
    if [[ $#A[4] -ge $MAX_LEN[4] ]]; then MAX_LEN[4]=$#A[4]; fi;
    if [[ $#A[5] -ge $MAX_LEN[5] ]]; then MAX_LEN[5]=$#A[5]; fi;
    if [[ $#A[6] -ge $MAX_LEN[6] ]]; then MAX_LEN[6]=$#A[6]; fi;
  done

  stat -f "%Sp~%l~%Su~%Sg~%Z~%Sm~%N~%Y" -t "%s" . .. .* * | while read RES2
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
    fi

    # pad so they align - firstline gets padded the other way
    while [[ $#ARR[1] -lt $MAX_LEN[1] ]]; do ARR[1]=$ARR[1]" "; done;
    while [[ $#ARR[2] -lt $MAX_LEN[2] ]]; do ARR[2]=" "$ARR[2]; done;
    while [[ $#ARR[3] -lt $MAX_LEN[3] ]]; do ARR[3]=" "$ARR[3]; done;
    while [[ $#ARR[4] -lt $MAX_LEN[4] ]]; do ARR[4]=" "$ARR[4]; done;
    while [[ $#ARR[5] -lt $MAX_LEN[5] ]]; do ARR[5]=" "$ARR[5]; done;
    while [[ $#ARR[6] -lt $MAX_LEN[6] ]]; do ARR[6]=" "$ARR[6]; done;

    ITEM=$ARR[7]

    # type
    T=$ARR[1]
    T=$T[1]
    if [[ $T == "d" ]]; then
      T=${T//d/"\033[1;36md\033[0m"};
      ITEM="\033[1;36m"$ARR[7]"\033[0m"
    fi
    if [[ $T == "l" ]]; then
      T=${T//l/"\033[0;35ml\033[0m"};
      ITEM="\033[0;35m"$ARR[7]"\033[0m ->"
    fi
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

    PERMISSIONS=$T$PER1$PER2$PER3

    # --7 warning
    if [[ $PER3 == "rwx" ]]; then PERMISSIONS="\033[30;41m$ARR[1]\033[0m"; fi

    # color file weights
    # GREEN_TO_RED=(46 82 118 154 190 226 220 214 208 202 196)
    S=(7) # cant get int to work somehow?
      if [[ $ARR[5] -le 1024 ]];    then S[1]=46;    # <= 1kb
    elif [[ $ARR[5] -le 2048 ]];    then S[1]=82;    # <= 2kb
    elif [[ $ARR[5] -le 3072 ]];    then S[1]=118;   # <= 3kb
    elif [[ $ARR[5] -le 5120 ]];    then S[1]=154;   # <= 5kb
    elif [[ $ARR[5] -le 10240 ]];   then S[1]=190;   # <= 10kb
    elif [[ $ARR[5] -le 20480 ]];   then S[1]=226;   # <= 20kb
    elif [[ $ARR[5] -le 40960 ]];   then S[1]=220;   # <= 40kb
    elif [[ $ARR[5] -le 102400 ]];  then S[1]=214;   # <= 100kb
    elif [[ $ARR[5] -le 262144 ]];  then S[1]=208;   # <= 0.25mb ]] 256kb
    elif [[ $ARR[5] -le 524288 ]];  then S[1]=202;   # <= 0.5mb || 512kb
    else                                 S[1]=196;   # >= 0.5mb || 512kb
    fi;
    ARR[5]="\033[38;5;$S[1]m$ARR[5]\033[0m"

    # fade older times
    S5=(7)
    TIMEDIFF=$(($EPOCH-$ARR[6]))
      if [[ $TIMEDIFF -lt 0 ]];        then S5[1]=196;   # < in the future, #spooky
    elif [[ $TIMEDIFF -lt 60 ]];       then S5[1]=252;   # < less than a min old
    elif [[ $TIMEDIFF -lt 3600 ]];     then S5[1]=250;   # < less than an hour old
    elif [[ $TIMEDIFF -lt 43200 ]];    then S5[1]=248;   # < less than 12 hours old
    elif [[ $TIMEDIFF -lt 86400 ]];    then S5[1]=246;   # < less than 1 day old
    elif [[ $TIMEDIFF -lt 604800 ]];   then S5[1]=244;   # < less than 1 week old
    elif [[ $TIMEDIFF -lt 2419200 ]];  then S5[1]=242;   # < less than 28 days (4 weeks) old
    elif [[ $TIMEDIFF -lt 15724800 ]]; then S5[1]=240;   # < less than 26 weeks (6 months) old
    elif [[ $TIMEDIFF -lt 31449600 ]]; then S5[1]=238;   # < less than 1 year old
    elif [[ $TIMEDIFF -lt 62899200 ]]; then S5[1]=236;   # < less than 2 years old
    else                                    S5[1]=234;   # > more than 2 years old
    fi;
    # ARR[6]="\033[38;5;$S5[1]m$ARR[6]\033[0m"
    # slow
    if [[ $TIMEDIFF -lt 15724800 ]]; then
      DATE="$(stat -f "%Sm" -t "%d %b %H:%M" $ARR[7])"
      else
      DATE="$(stat -f "%Sm" -t "%d %b  %Y" $ARR[7])"
    fi;
    # echo $S5
    DATE[1]=${DATE[1]//0/"\033[0;37m \033[0m"}
    DATE="\033[38;5;$S5[1]m$DATE\033[0m"

    # here is answer, http://stackoverflow.com/questions/11188621/how-can-i-convert-seconds-since-the-epoch-to-hours-minutes-seconds-in-java/11197532#11197532

    # slow
    # DATE=$(date -r $ARR[6])
    # DATE=$ARR[6]
    echo $PERMISSIONS " "$ARR[2] $ARR[3] " "$ARR[4] " "$ARR[5] $DATE $REPOMARKER $ITEM $ARR[8]
  done
}

# git_dirty() {
#     # Check if we're in a git repo
#     command git rev-parse --is-inside-work-tree &>/dev/null || return
#     # Check if it's dirty
#     command git diff --quiet --ignore-submodules HEAD &>/dev/null; [ $? -eq 1 ] && echo "*"
# }
