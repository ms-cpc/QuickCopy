:: QUICK COPY
:: Why not just run Xcopy from Command Line?
:: This batch runs the command as SYSTEM using a PSEXEC feature
:: as long as the user has admin priviledges, also does not require right click run as admin. 
:: This allows for more system files to be acquired. Not as perfect as a DD from a sector, but very quick and thorough.

::required for getadmin
@setlocal enableextensions
::set current working directory
@cd /d "%~dp0
@ECHO OFF
IF EXIST %temp%\cd.tmp GOTO one
CD > %temp%\cd.tmp
set /p currentdirectory=<%temp%\cd.tmp
del %temp%\cd.tmp
%currentdirectory:~0,2%
cd %currentdirectory:~2,100%

:one
if _%1_==_payload_  goto :payload

::Create QC.cmd
ECHO @ECHO OFF > QC.CMD
ECHO TITLE QUICK COPY >> QC.cmd
ECHO COLOR 5C >> QC.cmd
ECHO ECHO Running as: >>QC.cmd
ECHO WHOAMI >> QC.cmd
ECHO ECHO. >> QC.cmd
ECHO ECHO Listing Drives  >> QC.cmd
ECHO :ListDisk  >> QC.cmd
ECHO wmic logicaldisk get deviceid, volumename, description, size, filesystem, freespace  >> QC.cmd
ECHO ECHO.
ECHO ECHO.
ECHO ECHO Supports full paths with spaces and special characters. No \ required at end of path.
ECHO ECHO If doing root of drive, you do need : after drive letter [eg C:]
ECHO.
ECHO SET /p source=Source Path [eg: C:\user\bob] : >> QC.cmd
ECHO SET /p dest=Destination Path [Folders will be created if non existant [eg: D:\bobs files] ] : >> QC.cmd
ECHO ECHO. >> QC.cmd
ECHO ECHO will run: >> QC.cmd
ECHO ECHO XCOPY ^"%%source%%^" ^"%%dest%%^" /S /E /H /C /I /Y >> QC.cmd
ECHO ECHO. >> QC.cmd
ECHO ECHO Ctrl-c to cancel or >> QC.cmd
ECHO PAUSE >> QC.cmd
ECHO XCOPY ^"%%source%%^" ^"%%dest%%^" /S /E /H /C /I /Y >> QC.cmd
ECHO ECHO Copy Complete >> QC.cmd
ECHO PAUSE >> QC.cmd
ECHO DEL %currentdirectory:~2,100%\QC.CMD >> QC.cmd

::elevate to ADMIN
:getadmin
    echo %~nx0: ELEVATING TO ADMINISTRATOR PROMPT...
    set vbs=%temp%\getadmin.vbs
    echo Set UAC = CreateObject^("Shell.Application"^)                >> "%vbs%"
    echo UAC.ShellExecute "%~s0", "payload %~sdp0 %*", "", "runas", 1 >> "%vbs%"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
:: DO NOT CHANGE :EOF or it will go on for ever and crash machine!
goto :eof

:payload
::Run as SYSTEM
psexec -i -s -d %currentdirectory:~2,100%\qc.cmd /noeula
