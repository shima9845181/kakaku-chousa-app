@echo off
chcp 65001 >nul
setlocal
rem ============================================================
rem  価格調査ソフト  ---  GitHub 公開サイト（スマホ版）へ反映
rem  ダブルクリックすると、このフォルダの内容を GitHub(kakaku-chousa-app)
rem  へ push し、公開サイトを更新します。
rem  ※ 自動保存/ _backup/ *.json は .gitignore で除外＝データは公開されません
rem ============================================================

set "GIT=C:\Program Files\Git\cmd\git.exe"
if not exist "%GIT%" set "GIT=git"

cd /d "%~dp0"

echo.
echo === 変更をGitHubへ反映します ===
echo フォルダ: %cd%
echo.

"%GIT%" add -A
if errorlevel 1 goto err

for /f "tokens=1-5 delims=/: " %%a in ("%date% %time%") do set "STAMP=%%a-%%b-%%c %%d:%%e"
"%GIT%" commit -m "アプリ更新 %STAMP%"
if errorlevel 1 (
  echo.
  echo 反映する変更がありませんでした（またはコミットをスキップしました）。
)

echo.
echo === push 中 ===
"%GIT%" push
if errorlevel 1 goto err

echo.
echo ============================================================
echo  完了しました。数分で公開サイトに反映されます:
echo  https://shima9845181.github.io/kakaku-chousa-app/
echo ============================================================
echo.
pause
exit /b 0

:err
echo.
echo *** エラーが発生しました。上の表示をご確認ください。 ***
echo （初回や認証切れの場合、GitHubのログインを求められることがあります）
echo.
pause
exit /b 1
