@echo off &SETLOCAL ENABLEDELAYEDEXPANSION
set input=%~1
set times=%2
set sleep=%3
if "%3"=="" set sleep=1
set tmpsql=tmp.sql
echo. 2> %tmpsql%
call:echoscript "@save_sqlplus_settings.sql"
call:echoscript "set timi off"

for /L %%i in (1,1,%times%) do (
  call:echoscript "%input%"
  rem call:echoscript "exec sys.dbms_lock.sleep(%sleep%)"
  rem call:echoscript "%%i"
  rem call:echoscript "%times%"
  if not %%i == %times% (
    call:echoscript "exec sys.dbms_lock.sleep(%sleep%)"
  )
)
call:echoscript "@restore_sqlplus_settings.sql"

goto:eof

:echoscript
  @echo %~1 >>%tmpsql%
goto:eof

