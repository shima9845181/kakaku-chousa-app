@echo off
chcp 65001 >nul
setlocal
rem ============================================================
rem  価格調査ソフト  ---  GitHub への初回公開（1回だけ実行）
rem  1) このフォルダを git 管理にして初回コミット
rem  2) GitHub に公開リポジトリ kakaku-chousa-app を作成して push
rem  3) GitHub Pages を有効化（数分で公開URLが使えるようになります）
rem  ※ 自動保存/ _backup/ *.json は .gitignore で除外＝データは公開されません
rem  ※ 2回目以降の更新は deploy.bat を使ってください
rem ============================================================

set "GIT=C:\Program Files\Git\cmd\git.exe"
if not exist "%GIT%" set "GIT=git"
set "GH=C:\Program Files\GitHub CLI\gh.exe"
if not exist "%GH%" set "GH=gh"

cd /d "%~dp0"
echo.
echo === 1) git 初期化・初回コミット ===
if not exist ".git" "%GIT%" init -b main
"%GIT%" add -A
echo --- 公開されるファイル一覧 ---
"%GIT%" diff --cached --name-only
echo -----------------------------
"%GIT%" diff --cached --name-only | findstr /I /R "自動保存 \.json$ _backup \.zip$" >nul
if not errorlevel 1 (
  echo *** データファイルが含まれています。公開を中止します（.gitignore を確認してください） ***
  pause
  exit /b 1
)
"%GIT%" -c user.name=shima9845181 -c user.email=shima9845181@gmail.com commit -m "価格調査ソフト: 公開版（スマホ・PWA）初回登録"
if errorlevel 1 echo （コミット済み、または変更なし）

echo.
echo === 2) GitHub にリポジトリを作成して push ===
"%GH%" repo create kakaku-chousa-app --public --source=. --remote=origin --push --description "価格調査ソフト - 仕入価格・市場価格の検索と簡易集計（さかえ電気）"
if errorlevel 1 (
  echo （作成済みの場合は push のみ試します）
  "%GIT%" remote get-url origin >nul 2>&1 || "%GIT%" remote add origin https://github.com/shima9845181/kakaku-chousa-app.git
  "%GIT%" push -u origin main
  if errorlevel 1 goto err
)

echo.
echo === 3) GitHub Pages を有効化 ===
"%GH%" api -X POST repos/shima9845181/kakaku-chousa-app/pages -f build_type=legacy -f "source[branch]=main" -f "source[path]=/" >nul 2>&1
if errorlevel 1 echo （既に有効、または後で GitHub の Settings ^> Pages で main / root を選んでください）

echo.
echo ============================================================
echo  完了しました。数分後に下のURLをスマホで開いてください:
echo  https://shima9845181.github.io/kakaku-chousa-app/
echo  （開いたら「ホーム画面に追加」でアプリのように使えます）
echo ============================================================
echo.
pause
exit /b 0

:err
echo.
echo *** エラーが発生しました。上の表示をご確認ください。 ***
echo （gh のログインが切れている場合: gh auth login を実行）
echo.
pause
exit /b 1
