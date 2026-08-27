@echo off
:: Create Desktop Shortcut.bat
:: Put this in the SAME folder as ToggleResolution.ps1 and double-click it ONCE.
:: It creates a "Toggle Resolution" shortcut on your desktop with a monitor icon.

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ws = New-Object -ComObject WScript.Shell;" ^
  "$lnk = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Toggle Resolution.lnk');" ^
  "$lnk.TargetPath = 'powershell.exe';" ^
  "$lnk.Arguments = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"%~dp0ToggleResolution.ps1\"';" ^
  "$lnk.WorkingDirectory = '%~dp0';" ^
  "$lnk.IconLocation = '%SystemRoot%\System32\shell32.dll,15';" ^
  "$lnk.WindowStyle = 7;" ^
  "$lnk.Description = 'Toggle between 2560x1600 and 3840x1600';" ^
  "$lnk.Save();" ^
  "Write-Host 'Shortcut created on your desktop!'"

pause
