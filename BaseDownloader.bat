@echo off
setlocal enabledelayedexpansion
title Base Downloader

:: Создание временной папки
set "temp_dir=%TEMP%\\downloader"
if not exist "%temp_dir%" mkdir "%temp_dir%"

:: Массив (Ссылка|Наименование)
set "progs[1]=https://aka.ms/vs/17/release/vc_redist.x64.exe|VC redist 2015-2022"
set "progs[2]=https://builds.dotnet.microsoft.com/dotnet/Sdk/6.0.428/dotnet-sdk-6.0.428-win-x64.exe|NET Framework 6.0"
set "progs[3]=https://go.microsoft.com/fwlink/?linkid=2109047&Channel=Stable&language=ru&brand=M100|Microsoft Edge"
set "progs[4]=https://dl.google.com/chrome/install/latest/chrome_installer.exe|Google Chrome"
set "progs[5]=https://download.mozilla.org/?product=firefox-latest&os=win64&lang=ru|Firefox"
set "progs[6]=https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe|Steam"
set "progs[7]=https://www.7-zip.org/a/7z2407-x64.exe|7-Zip"
set "progs[8]=https://download.scdn.co/SpotifySetup.exe|Spotify"
set "progs[9]=https://telegram.org/dl/desktop/win64|Telegram"
set "progs[10]=https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.4/npp.8.6.4.Installer.x64.exe|Notepad++"
set "progs[11]=https://mirror.yandex.ru/mirrors/ftp.videolan.org/vlc/3.0.20/win64/vlc-3.0.20-win64.exe|VLC Player"
set "progs[12]=https://unlimited.dl.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-5.1.2/qbittorrent_5.1.2_x64_setup.exe?viasf=1|Qbittorrent"
set "progs[13]=https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-user|Visual Studio Code"

:menu
cls
echo Version 1.0
echo ================================
echo Preferred
echo 1 - VC redist 2015-2022
echo 2 - NET Framework 6.0
echo ================================
echo Browsers
echo 3 - Microsoft Edge
echo 4 - Google Chrome
echo 5 - Firefox
echo ================================
echo Optional
echo 6 - Steam
echo 7 - 7-Zip
echo 8 - Spotify
echo 9 - Telegram
echo 10 - Notepad++
echo 11 - VLC Player
echo 12 - Qbittorrent
echo 13 - Visual Studio Code
echo ================================
echo 0 - Exit
echo ================================

set /p choice="Enter number: "
if "%choice%"=="0" exit

:: Проверка наличия числа в массиве (подлинность выбора)
if not defined progs[%choice%] (
    echo Invalid choice. Please try again...
    timeout /t 5 >nul
    goto menu
)

:: Начало блока выполнения установки
call :install_program %choice%
goto menu

:install_program
set "prog_data=!progs[%1]!"
for /f "tokens=1,2 delims=|" %%a in ("!prog_data!") do (
    set "url=%%a"
    set "description=%%b"
)

echo Installing !description!...
set "file_name=!temp_dir!\\installer_%1.exe"

:: Скачивание и установка
powershell -Command "Invoke-WebRequest -Uri '!url!' -OutFile '!file_name!'" && (
    echo Download is completed. Launching the installation...
    start /wait "" "!file_name!"
    del "!file_name!" 2>nul
    echo Installing !description! is completed.
) || (
    echo Error during download or installation !description!!
    if exist "!file_name!" del "!file_name!" 2>nul
)

timeout /t 5 >nul
exit /b