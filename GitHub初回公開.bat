@echo off
setlocal
rem ============================================================
rem  Kakaku-Chousa Soft --- first-time publish to GitHub (run ONCE)
rem  1) init git in this folder and make the first commit
rem  2) create public repo "kakaku-chousa-app" on GitHub and push
rem  3) enable GitHub Pages (public URL becomes available in a few minutes)
rem  NOTE: data folders/files (jidou-hozon, _backup, *.json) are excluded
rem        by .gitignore, so NO data is published.
rem  For later updates use deploy.bat instead.
rem  (ASCII only: Japanese text in a .bat breaks cmd parsing.)
rem ============================================================

set "GIT=C:\Program Files\Git\cmd\git.exe"
if not exist "%GIT%" set "GIT=git"
set "GH=C:\Program Files\GitHub CLI\gh.exe"
if not exist "%GH%" set "GH=gh"

cd /d "%~dp0"
echo.
echo === 1) git init / first commit ===
if not exist ".git" "%GIT%" init -b main
"%GIT%" add -A
echo --- files to be published ---
"%GIT%" diff --cached --name-only
echo -----------------------------
"%GIT%" diff --cached --name-only | findstr /I /R "\.json$ _backup \.zip$" >nul
if not errorlevel 1 (
  echo *** DATA FILE DETECTED. ABORT. Check .gitignore ***
  pause
  exit /b 1
)
"%GIT%" -c user.name=shima9845181 -c user.email=shima9845181@gmail.com commit -m "Kakaku-Chousa Soft: initial publish (smartphone / PWA)"
if errorlevel 1 echo (already committed or nothing to commit)

echo.
echo === 2) create GitHub repo and push ===
"%GH%" repo create kakaku-chousa-app --public --source=. --remote=origin --push --description "Kakaku-Chousa Soft - purchase/market price lookup and quick estimate (Sakae Denki, browser-only, data stays on device)"
if errorlevel 1 (
  echo (repo may already exist - trying push only)
  "%GIT%" remote get-url origin >nul 2>&1 || "%GIT%" remote add origin https://github.com/shima9845181/kakaku-chousa-app.git
  "%GIT%" push -u origin main
  if errorlevel 1 goto err
)

echo.
echo === 3) enable GitHub Pages ===
"%GH%" api -X POST repos/shima9845181/kakaku-chousa-app/pages -f build_type=legacy -f "source[branch]=main" -f "source[path]=/" >nul 2>&1
if errorlevel 1 echo (already enabled, or enable later in GitHub Settings ^> Pages : main / root)

echo.
echo ============================================================
echo  DONE. Open this URL on your phone in a few minutes:
echo  https://shima9845181.github.io/kakaku-chousa-app/
echo  (then "Add to Home Screen" to use it like an app)
echo ============================================================
echo.
pause
exit /b 0

:err
echo.
echo *** ERROR. See messages above. ***
echo (if gh login expired: run  gh auth login)
echo.
pause
exit /b 1
