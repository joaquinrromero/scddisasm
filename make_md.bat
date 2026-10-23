@echo off

rem Builds the Mega Drive port (one unified ROM): out\sonic_cd_md.bin
rem Dev switches (optional, set before running):
rem   set MDACT=1                           start in act 2 (0-based)
rem   set MDZONE=past|goodfuture|badfuture  start in that time zone
rem   set MDWARPTEST=1                      boot straight into the time warp screen

set REGION=1
set OUTPUT=sonic_cd_md.bin

if not exist out mkdir out
if not exist out\misc mkdir out\misc

set EXTRA=
if defined MDWARPTEST set EXTRA=%EXTRA% /e MDWARPTEST=1
if defined MDACT set EXTRA=%EXTRA% /e MDSTARTACT=%MDACT%
if "%MDZONE%"=="past" set EXTRA=%EXTRA% /e MDSTARTTZ=0
if "%MDZONE%"=="goodfuture" set EXTRA=%EXTRA% /e MDSTARTTZ=2 /e MDSTARTGOOD=1
if "%MDZONE%"=="badfuture" set EXTRA=%EXTRA% /e MDSTARTTZ=2

cd src

set ASM68K=..\bin\asm68k.exe /p /o ae-,l.,ow+ /e REGION=%REGION% /e DEMO=0 /e MDPORT=1

%ASM68K% %EXTRA% "MD Port\Main.asm", "..\out\%OUTPUT%", , "MD Port\Main.lst" > "..\out\misc\build.log"
type "..\out\misc\build.log"

cd ..

findstr /R /C:"[^0-9]0 error(s)" /C:"^0 error(s)" out\misc\build.log > nul
if errorlevel 1 (
    echo.
    echo **************************************************************************************
    echo *  Build failed. See out\misc\build.log                                              *
    echo **************************************************************************************
    pause
    exit /b 1
)

echo.
echo Fixing header (ROM end + checksum)...
powershell -NoProfile -Command "$p='out\%OUTPUT%'; $d=[IO.File]::ReadAllBytes($p); $n=$d.Length-1; $d[0x1A4]=($n -shr 24) -band 255; $d[0x1A5]=($n -shr 16) -band 255; $d[0x1A6]=($n -shr 8) -band 255; $d[0x1A7]=$n -band 255; $s=0; for($i=0x200;$i -lt $d.Length;$i+=2){ $s=($s + ($d[$i] -shl 8) + $d[$i+1]) -band 0xFFFF }; $d[0x18E]=$s -shr 8; $d[0x18F]=$s -band 255; [IO.File]::WriteAllBytes($p,$d); 'ROM {0}: {1} bytes, checksum ${2:X4}' -f $p,$d.Length,$s"

pause
