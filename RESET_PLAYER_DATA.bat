@echo off
setlocal EnableExtensions EnableDelayedExpansion
title GrimCity - Official Launch Player Data Wipe
color 0C

:: ============================================================
::  RESET EVERYTHING (player data only)
::  Users / cars / freecars / inventory / VIP / phone / etc.
::  Does NOT wipe jobs, vehicle catalog, dealership stock, doors.
:: ============================================================

cd /d "%~dp0"

set "DB_HOST=localhost"
set "DB_USER=root"
set "DB_PASS="
set "DB_NAME=grimcity"
set "SQL_FILE=%~dp0database\wipe_player_data.sql"
set "BACKUP_DIR=%~dp0database\backups"

:: Prefer MariaDB / XAMPP mysql if not on PATH
set "MYSQL=mysql"
set "MYSQLDUMP=mysqldump"
if exist "C:\Program Files\MariaDB 12.3\bin\mysql.exe" (
  set "MYSQL=C:\Program Files\MariaDB 12.3\bin\mysql.exe"
  set "MYSQLDUMP=C:\Program Files\MariaDB 12.3\bin\mysqldump.exe"
) else if exist "C:\xampp\mysql\bin\mysql.exe" (
  set "MYSQL=C:\xampp\mysql\bin\mysql.exe"
  set "MYSQLDUMP=C:\xampp\mysql\bin\mysqldump.exe"
)

echo.
echo  ========================================================
echo   GrimCity OFFICIAL LAUNCH WIPE
echo  ========================================================
echo.
echo   Database : %DB_NAME% @ %DB_HOST%
echo   SQL file : %SQL_FILE%
echo.
echo   THIS WILL DELETE:
echo     - users / characters / licenses / groups
echo     - owned vehicles / private garages
echo     - freecars / beta cars / playtime rewards / newplayer kits
echo     - project cars / mechanic vehicle data
echo     - skins / outfits
echo     - ox_inventory stashes + player inventories
echo     - playtime coins / VIP / banking pins / invoices
echo     - phone / parties / leaderboards / regions
echo     - gangs / pvp / prison / comserv
echo     - university students / MDT / reports / documents
echo     - dealership sales + mechanic invoices/history
echo     - society money reset to 0
echo.
echo   KEPT:
echo     - jobs / grades / items / license types
echo     - vehicle shop catalog / categories
echo     - dealership locations / stock / display cars
echo     - ox_doorlock / mechanic shop settings
echo.
echo   STOP FXServer BEFORE CONTINUING.
echo  ========================================================
echo.

if not exist "%SQL_FILE%" (
  echo [ERROR] Missing wipe SQL: %SQL_FILE%
  pause
  exit /b 1
)

set /p "CONFIRM=Type WIPE to continue (anything else cancels): "
if /I not "%CONFIRM%"=="WIPE" (
  echo Cancelled.
  pause
  exit /b 0
)

echo.
set /p "DO_BACKUP=Create SQL backup first? [Y/N]: "
if /I "%DO_BACKUP%"=="Y" (
  if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
  for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "STAMP=%%i"
  set "BACKUP_FILE=%BACKUP_DIR%\grimcity_before_wipe_!STAMP!.sql"
  echo Backing up to !BACKUP_FILE! ...
  if "%DB_PASS%"=="" (
    "%MYSQLDUMP%" -h %DB_HOST% -u %DB_USER% --single-transaction --routines --triggers %DB_NAME% > "!BACKUP_FILE!"
  ) else (
    "%MYSQLDUMP%" -h %DB_HOST% -u %DB_USER% -p%DB_PASS% --single-transaction --routines --triggers %DB_NAME% > "!BACKUP_FILE!"
  )
  if errorlevel 1 (
    echo [ERROR] Backup failed. Wipe aborted.
    pause
    exit /b 1
  )
  echo Backup OK.
)

echo.
echo Running wipe...
if "%DB_PASS%"=="" (
  "%MYSQL%" -h %DB_HOST% -u %DB_USER% %DB_NAME% < "%SQL_FILE%"
) else (
  "%MYSQL%" -h %DB_HOST% -u %DB_USER% -p%DB_PASS% %DB_NAME% < "%SQL_FILE%"
)

if errorlevel 1 (
  echo.
  echo [ERROR] Wipe failed. Check MySQL path / credentials / that FXServer is stopped.
  pause
  exit /b 1
)

echo.
echo  ========================================================
echo   WIPE COMPLETE — player data cleared for official launch.
echo   Start FXServer when ready.
echo  ========================================================
echo.
pause
exit /b 0
