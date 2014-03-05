# new k
k () {
  stat -f "%Sp %l %Su %Sg %Z %Sm %N %Y" . .. .* *
}


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