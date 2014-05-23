@echo off
:: SQL*Plus
doskey sp=sqlplus $*
doskey /exename=sqlplus.exe scrloop=ho scrloop.bat $*$tstart tmp.sql
:: Linux like command
doskey ls=dir $*
doskey rm=del $*
doskey mv=rename $*
doskey clear=cls $*
doskey cp=copy $*
doskey quit=exit $*
doskey cat=type $*
doskey grep=find $*
doskey man=help $*
doskey mv=ren $1 $2 $T del $1
doskey history=doskey /history
doskey connections=netstat -an $B find "80" $B find /V "TIME_WAIT"
doskey ps=tasklist
doskey psgrep=tasklist /FI "IMAGENAME eq $1"
doskey pwd=cd
doskey time=time /T
:: cmd command
doskey lock=%SystemRoot%\system32\rundll32.exe USER32.DLL,LockWorkStation
@echo on
