#!/bin/bash
INPUT_DIR=/pub/home/velikikh/script_dir
DOCSTART="--DOCSTART"
DOCEND="--DOCEND"

for f in $(find $INPUT_DIR -type f -name '*.sql') ;
do
  fbase=`echo $f | sed -e 's#'$INPUT_DIR'/##'`
  fbase_sed=`echo $fbase | sed -e 's@\\/@\\\/@g'`
  #echo "processing $fbase $fbase_sed"
  #sed -e '/'$DOCSTART'/,/'$DOCEND'/!d' -e '/^--DOC/d' -e 's/^--//' -e 's/^\(.*\)$/insert into help(topic, seq, info) values ('"'"$fbase_sed"'"', 1, '"'"'\1'"'"'/' $f
  awk -f helpbld.awk fbase=$fbase $f
  #sed -ne '/START/,/END/!d' $f
done
