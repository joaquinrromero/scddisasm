@echo off
rem Build the Mega Drive port on Windows. No installs needed: asm68k.exe is in bin\ and the checksum is
rem patched with the PowerShell that ships with Windows.
rem   build_md.bat                  -> out\sonic_cd_md.bin
rem   set MDACT=1 & build_md.bat    -> starts in act 2 (0-based)
rem   set MDZONE=past|goodfuture|badfuture   set MDWARPTEST=1   (dev switches, same as build_md.sh)
setlocal
cd /d "%~dp0"
if not exist out mkdir out
set EXTRA=
if defined MDWARPTEST set EXTRA=%EXTRA% /e MDWARPTEST=1
if defined MDACT set EXTRA=%EXTRA% /e MDSTARTACT=%MDACT%
if "%MDZONE%"=="past" set EXTRA=%EXTRA% /e MDSTARTTZ=0
if "%MDZONE%"=="goodfuture" set EXTRA=%EXTRA% /e MDSTARTTZ=2 /e MDSTARTGOOD=1
if "%MDZONE%"=="badfuture" set EXTRA=%EXTRA% /e MDSTARTTZ=2
pushd src
..\bin\asm68k.exe /p /o ae-,l.,ow+ /e REGION=1 /e DEMO=0 /e MDPORT=1 %EXTRA% "MD Port\Main.asm", "..\out\sonic_cd_md.bin", , "MD Port\Main.lst" > "..\out\build.log"
type "..\out\build.log"
popd
findstr /R /C:"[^0-9]0 error(s)" /C:"^0 error(s)" out\build.log >nul || (echo BUILD FAILED & exit /b 1)
powershell -NoProfile -Command "$p='out\sonic_cd_md.bin'; $d=[IO.File]::ReadAllBytes($p); $n=$d.Length-1; $d[0x1A4]=($n -shr 24) -band 255; $d[0x1A5]=($n -shr 16) -band 255; $d[0x1A6]=($n -shr 8) -band 255; $d[0x1A7]=$n -band 255; $s=0; for($i=0x200;$i -lt $d.Length;$i+=2){ $s=($s + ($d[$i] -shl 8) + $d[$i+1]) -band 0xFFFF }; $d[0x18E]=$s -shr 8; $d[0x18F]=$s -band 255; [IO.File]::WriteAllBytes($p,$d); 'ROM {0}: {1} bytes, checksum ${2:X4}' -f $p,$d.Length,$s"
