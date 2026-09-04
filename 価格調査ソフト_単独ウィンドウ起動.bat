@echo off
rem === Launch the kakaku-chousa app (price research) in a standalone browser window ===
rem Double-click to open the app in its OWN window (no tabs / no address bar).
rem Picks the .html in THIS folder, ignoring any backup files (name containing ".bak").
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName System.Windows.Forms; try { $h = Get-ChildItem -Filter *.html | Where-Object { $_.Name -notmatch '\.bak' -and $_.Name -ne 'index.html' } | Select-Object -First 1; if(-not $h){ [System.Windows.Forms.MessageBox]::Show('App html not found in this folder.','Kakaku Chousa Soft') | Out-Null; exit 1 }; $u=([Uri]$h.FullName).AbsoluteUri; $c='C:\Program Files\Google\Chrome\Application\chrome.exe'; if(-not(Test-Path $c)){ $c='C:\Program Files (x86)\Google\Chrome\Application\chrome.exe' }; if(-not(Test-Path $c)){ $g=Get-Command chrome.exe -ErrorAction SilentlyContinue; if($g){ $c=$g.Source } }; if(-not(Test-Path $c)){ $c='C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }; if(-not(Test-Path $c)){ $c='C:\Program Files\Microsoft\Edge\Application\msedge.exe' }; if(-not(Test-Path $c)){ [System.Windows.Forms.MessageBox]::Show('Chrome / Edge not found.','Kakaku Chousa Soft') | Out-Null; exit 1 }; Start-Process $c -ArgumentList @('--app='+$u,'--window-size=1500,950') } catch { [System.Windows.Forms.MessageBox]::Show('Launch error: ' + $_.Exception.Message,'Kakaku Chousa Soft') | Out-Null; exit 1 }"
if errorlevel 1 pause
exit /b
