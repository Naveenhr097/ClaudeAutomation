@echo off
setlocal EnableDelayedExpansion

for /f "tokens=2 delims=\" %%i in ('whoami') do set USER_ID=%%i

echo %USER_ID%

set "FILEPATH=C:\Users\%USER_ID%\OneDrive - SAP SE"
set "ROOTFOLDER=%FILEPATH%\Claude"
set "CLAUDE_FOLDER=%ROOTFOLDER%\Claude"
set "HYPERSPACE_FOLDER=%ROOTFOLDER%\Hyperspace\"

echo ==========================================
echo Creating folders
echo ==========================================

if not exist "%ROOTFOLDER%" mkdir "%ROOTFOLDER%"
if not exist "%CLAUDE_FOLDER%" mkdir "%CLAUDE_FOLDER%"
if not exist "%HYPERSPACE_FOLDER%" mkdir "%HYPERSPACE_FOLDER%"

echo.
echo ==========================================
echo Downloading hai.exe
echo ==========================================

@echo off

set "HAI_URL=https://github.com/Naveenhr097/ClaudeAutomation/raw/refs/heads/main/Hai/hai.exe"

curl.exe -L "%HAI_URL%" -o "%HYPERSPACE_FOLDER%\hai.exe"

if exist "%HYPERSPACE_FOLDER%\hai.exe" (
    echo Download successful
) else (
    echo Download failed
)
if exist "%HYPERSPACE_FOLDER%\hai.exe" (
    echo hai.exe available.
) else (
    echo ERROR: Failed to download hai.exe
)

echo.
echo ==========================================
echo Updating PATH
echo ==========================================

powershell -NoProfile -ExecutionPolicy Bypass -Command "$haiPath='%HYPERSPACE_FOLDER%'; $userPath=[Environment]::GetEnvironmentVariable('Path','User'); if($userPath -notlike ('*'+$haiPath+'*')) { [Environment]::SetEnvironmentVariable('Path',$userPath+';'+$haiPath,'User'); Write-Host 'PATH updated.' } else { Write-Host 'PATH already contains folder.' }"

echo.
echo ==========================================
echo Installing Claude CLI
echo ==========================================

powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-Location '%CLAUDE_FOLDER%'; irm https://claude.ai/install.ps1 | iex"

echo.
echo ==========================================
echo Locating claude.exe
echo ==========================================

for /f "delims=" %%i in ('powershell -NoProfile -Command "(Get-ChildItem C:\Users\%USER_ID% -Recurse -Filter claude.exe -ErrorAction SilentlyContinue | Select-Object -First 1).FullName"') do (
    set "CLAUDE_EXE=%%i"
)

for %%i in ("!CLAUDE_EXE!") do (
    set "CLAUDE_EXE_PATH=%%~dpi"
)

echo.
echo Claude Executable:
echo !CLAUDE_EXE!

echo.
echo Claude Executable Directory:
echo !CLAUDE_EXE_PATH!

echo.
echo ==========================================
echo Creating claude.cmd
echo ==========================================

(
    echo @"!CLAUDE_EXE!" %%*
) > "!HYPERSPACE_FOLDER!claude.cmd"

echo Created:
echo !HYPERSPACE_FOLDER!claude.cmd

echo.
echo ==========================================================
echo Starting HAI Proxy
echo ==========================================================

cd /d "C:\Users\%USER_ID%\"

echo Current Directory:
echo %CD%

echo Running: hai configure claude-code
hai configure claude-code

echo.
echo Configuration completed.

hai proxy start


echo.
echo ==========================================
echo Installation Complete
echo ==========================================

pause