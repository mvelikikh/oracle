#!/bin/sh
AWK=/bin/awk
FILE="$1"
#SCRIPT_DIR=`echo $SQLPATH | cut -d: -f1`
SCRIPT_DIR=/home/vma/scripts/vma
AWK_SCRIPT=/home/vma/scripts/vma/help.awk
for f in $(find $SCRIPT_DIR -type f -iname "$FILE"\*) ;
do
  $AWK -f $AWK_SCRIPT $f
done
