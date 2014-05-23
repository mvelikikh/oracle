@echo off
for /F %%f in ('"%UNIX_UTILS%\find" C:\oracle\scripts\vma -type f -name %1') do "%UNIX_UTILS%\gawk" -f C:\oracle\scripts\vma\help.awk %%f
@echo on
