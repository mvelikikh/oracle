--ho C:\oracle\scripts\vma\win\search_help.bat &1.
--ho for /F %f in ('"%UNIX_UTILS%\find" C:\oracle\scripts\vma -type f -name &1.') do "%UNIX_UTILS%\gawk" -f C:\oracle\scripts\vma\help.awk %f
ho /home/vma/scripts/vma/unix/search_help.sh &1.
