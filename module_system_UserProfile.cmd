:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION		::
::  Semantic Versioning used	::
::   http://semver.org/			::
::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@Echo Off
SETLOCAL Enableextensions
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET $SCRIPT_NAME=module_system_UserProfile
SET $SCRIPT_VERSION=0.1.0
SET $SCRIPT_BUILD=20240209
Title %$SCRIPT_NAME% Version: %$SCRIPT_VERSION%
mode con:cols=81
mode con:lines=40
Prompt $G
color 70
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::###########################################################################::
:: Declare Global variables
::###########################################################################::

::	Log Directory
SET $LD=%PUBLIC%\logs

::	Advise the default log file name.
SET $LOG_FILE=%$SCRIPT_NAME%_%COMPUTERNAME%.txt

:: Local cache directory
SET $CACHE=%PUBLIC%\cache

::###########################################################################::
::		*******************
::		Advanced Settings 
::		*******************
::###########################################################################::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:SLT
::	Start Lapse Time
::	will be used to calculate how long the script runs for
SET $START_TIME=%Time%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:: CONSOLE OUTPUT WHEN RUNNING Manually
ECHO ****************************************************************
ECHO. 
ECHO      %$SCRIPT_NAME% %$SCRIPT_VERSION%
ECHO.
ECHO ****************************************************************
ECHO.
ECHO Processing...
echo.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::	cache	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
IF NOT EXIST "%$cache%" MD "%$cache%"
CD /D "%$cache%"
:: Get list of domain user profiles and write to file in cache
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::	Powershell check	:::::::::::::::::::::::::::::::::::::::::::::::::::
@powershell $PSVersionTable 2> nul 1> nul 
IF %ERRORLEVEL% NEQ 0 GoTo End
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::	Formatted time	:::::::::::::::::::::::::::::::::::::::::::::::::::::::
@powershell Get-Date -format "yyyy-MM-dd" > "%$cache%\var_ISO8601_Date.txt"
SET /P $ISO_DATE= < "%$cache%\var_ISO8601_Date.txt"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:start
echo. >> "%$LD%\%$LOG_FILE%"
echo %DATE% %TIME% Start... >> "%$LD%\%$LOG_FILE%"
echo Script Name: %$SCRIPT_NAME% >> "%$LD%\%$LOG_FILE%"
echo Script Version: %$SCRIPT_VERSION% >> "%$LD%\%$LOG_FILE%"
echo Computer: %COMPUTERNAME% >> "%$LD%\%$LOG_FILE%"
echo User: %USERNAME% >> "%$LD%\%$LOG_FILE%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::	User List	:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
echo List of domain user profiles: >> "%$LD%\%$LOG_FILE%"
echo List of domain user profiles::
@powershell Get-CimInstance -className win32_userprofile | FIND /I "LocalPath" | FIND /I "Users"> .\UserProfiles.txt
type .\UserProfiles.txt >> "%$LD%\%$LOG_FILE%"
type .\UserProfiles.txt
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::	User Profiles Deletion	:::::::::::::::::::::::::::::::::::::::::::::::
REM Core command
echo Processing profile deletion...
echo Processing profile deletion... >> "%$LD%\%$LOG_FILE%"
:: Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq 'UserA' } | Remove-CimInstance
REM How to string powershell piping within command shell
:: @powershell -command "(Get-Content -Encoding UTF8 '%0' | select-string -pattern '^[^@]')" | @powershell -NoProfile -ExecutionPolicy ByPass
FOR /F "Tokens=3 delims=^\" %%P IN (.\UserProfiles.txt) DO IF /I NOT %USERNAME%==%%P @powershell -command "(Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.split('\')[-1] -eq '%%P' } | Remove-CimInstance)" & (echo Deleted Profile: %%P >> "%$LD%\%$LOG_FILE%") & (echo Deleted Profile: %%P )
echo Process completed! >> "%$LD%\%$LOG_FILE%"
echo Process completed!
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ELT
::	Stop Lapse Time
::	will be used to calculate how long the script runs for
	SET $STOP_TIME=%Time%
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:Close
	::	Close out log file
	:: Calculate the actual lapse time
	@PowerShell.exe -c "$span=([datetime]'%Time%' - [datetime]'%$START_TIME%'); '{0:00}:{1:00}:{2:00}' -f $span.Hours, $span.Minutes, $span.Seconds" > "%$CACHE%\Total_Lapsed_Time.txt"
	SET /P $TOTAL_TIME= < "%$CACHE%\Total_Lapsed_Time.txt"
	ECHO Total Time Lapsed (hh:mm:ss): %$TOTAL_TIME% >> "%$LD%\%$LOG_FILE%"
	ECHO %Date% %TIME%	End. >> "%$LD%\%$LOG_FILE%"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


:End
Exit /B