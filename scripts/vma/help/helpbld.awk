#!/bin/awk -f
BEGIN {
}
/^--DOCSTART/ { startline=NR ; }
/^--DOCSTART/,/^--DOCEND/ {
  if($0 ~/^--DOC/) { next;};
  print "insert into help(topic, seq, info) values ('"fbase"', "(NR-startline)", '"substr($0,3)"');";
}
END {
}
