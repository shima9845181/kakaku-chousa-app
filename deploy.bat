@echo off
setlocal
rem ============================================================
rem  Kakaku-Chousa Soft --- push updates to the public site (GitHub Pages)
rem  Double-click: git add / commit / push. The site updates in a few minutes.
rem  NOTE: jidou-hozon/, _backup/, *.json are excluded by .gitignore
rem        so NO data is published.
rem  (ASCII only: Japanese text in a .bat breaks cmd parsing.)
rem ============================================================

set "GIT=C:\Program Files\Git\cmd\git.exe"
if not exist "%GIT%" set "GIT=git"

cd /d "%~dp0"

echo.
echo === pushing changes to GitHub ===
echo folder: %cd%
echo.

"%GIT%" add -A
if errorlevel 1 goto err

"%GIT%" diff --cached --name-only | findstr /I /R "\.json$ _backup \.zip$" >nul
if not errorlevel 1 (
  echo *** DATA FILE DETECTED. ABORT. Check .gitignore ***
  pause
  exit /b 1
)

for /f "tokens=1-5 delims=/: " %%a in ("%date% %time%") do set "STAMP=%%a-%%b-%%c %%d:%%e"
"%GIT%" -c user.name=shima9845181 -c user.email=shima9845181@gmail.com commit -m "app update %STAMP%"
if errorlevel 1 (
  echo.
  echo (nothing to commit - pushing anyway)
)

echo.
echo === push ===
"%GIT%" push
if errorlevel 1 goto err

echo.
echo ============================================================
echo  DONE. The site updates in a few minutes:
echo  https://shima9845181.github.io/kakaku-chousa-app/
echo ============================================================
echo.
pause
exit /b 0

:err
echo.
echo *** ERROR. See messages above. ***
echo (first run or expired login: GitHub may ask you to sign in)
echo.
pause
exit /b 1
