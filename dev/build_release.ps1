# BBF Release Build Script
# Kills stale Java processes, clears lint cache, then builds

Write-Host "Stopping Java processes..." -ForegroundColor Yellow
Get-Process java -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "Clearing file_picker lint cache..." -ForegroundColor Yellow
Remove-Item "build\file_picker\intermediates\lint-cache" -Recurse -Force -ErrorAction SilentlyContinue

$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

Write-Host "Building release APK..." -ForegroundColor Green
flutter build apk --release
