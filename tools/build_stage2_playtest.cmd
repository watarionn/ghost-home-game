@echo off
setlocal EnableExtensions
set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"
if not defined GODOT_EXE (
  for /f "delims=" %%G in ('where godot.exe 2^>nul') do if not defined GODOT_EXE set "GODOT_EXE=%%G"
)
if not defined GODOT_EXE (
  echo [ERROR] GODOT_EXE is not set and godot.exe is not on PATH.
  echo Set GODOT_EXE to the Godot 4.7.2 console executable and retry.
  exit /b 2
)
if not exist "%GODOT_EXE%" (
  echo [ERROR] Godot executable not found: "%GODOT_EXE%"
  exit /b 2
)
set "VERFILE=%TEMP%\ghost-home-godot-version-%RANDOM%.txt"
"%GODOT_EXE%" --version > "%VERFILE%" 2>&1
set /p "GODOT_VERSION="<"%VERFILE%"
del /q "%VERFILE%" >nul 2>&1
echo %GODOT_VERSION% | findstr /b /c:"4.7.2.stable" >nul || (
  echo [ERROR] Godot 4.7.2 stable required. Found: %GODOT_VERSION%
  exit /b 3
)
set "TEMPLATE_DIR=%APPDATA%\Godot\export_templates\4.7.2.stable"
if not exist "%TEMPLATE_DIR%\windows_release_x86_64.exe" (
  echo [BLOCKER] Godot 4.7.2 Windows export templates are not installed.
  echo Expected: "%TEMPLATE_DIR%\windows_release_x86_64.exe"
  echo Install templates manually in Godot, then run this script again.
  exit /b 4
)
set "OUTDIR=%ROOT%\build\stage2-playtest"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"
copy /Y "%ROOT%\playtest\PLAYTEST_README.txt" "%OUTDIR%\PLAYTEST_README.txt" >nul
"%GODOT_EXE%" --headless --path "%ROOT%" --export-release "Windows Desktop" "build/stage2-playtest/GhostHomePlaytest.exe"
if errorlevel 1 (
  echo [ERROR] Godot export failed.
  exit /b 5
)
echo [OK] Stage 2 playtest package created: "%OUTDIR%"
exit /b 0
