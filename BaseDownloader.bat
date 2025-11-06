@echo off
setlocal enabledelayedexpansion
chcp 1251 >nul
title Base Downloader

:: Создание временной папки
set "temp_dir=%TEMP%\downloader"
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

:: Меню
:menu
cls
echo Версия 2.0
echo ================================
echo Желательное
echo 1 - VC redist 2015-2022
echo 2 - NET Framework 6.0
echo ================================
echo Браузеры
echo 3 - Microsoft Edge
echo 4 - Google Chrome
echo 5 - Firefox
echo ================================
echo Опциональное
echo 6 - Steam
echo 7 - 7-Zip
echo 8 - Spotify
echo 9 - Telegram
echo 10 - Notepad++
echo 11 - VLC Player
echo 12 - Qbittorrent
echo 13 - Visual Studio Code
echo ================================
echo Твикеры
echo 14 - Показывать/скрывать все иконки в трее
echo ================================
echo 0 - Exit
echo ================================

set /p choice="Enter number: "
if "%choice%"=="0" exit /b

:: Проверка наличия числа в массиве (подлинность выбора)
if not defined progs[%choice%] (
    if "%choice%"=="14" (
        call :tray_tweaker
        goto menu
    )
    echo Недействительный выбор. Попробуйте ещё раз...
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

echo Установка !description!...
set "file_name=!temp_dir!\installer_%1.exe"

:: Скачивание и установка
powershell -Command "Invoke-WebRequest -Uri '!url!' -OutFile '!file_name!'" && (
    echo Скачивание завершено. Установка...
    start /wait "" "!file_name!"
    del "!file_name!" 2>nul
    echo Установка !description! завершена.
) || (
    echo Ошибка установки... !description!!
    if exist "!file_name!" del "!file_name!" 2>nul
)

timeout /t 5 >nul
exit /b

:: Твикер всех иконок в трее
:tray_tweaker
cls
echo ================================
echo Твикер иконок системного трея
echo ================================

:: Проверяем существование задачи в планировщике
echo Проверка состояния автозапуска иконок трея...
schtasks /query /tn "ShowAllTrayIcons" >nul 2>&1

if !errorlevel! == 0 (
    echo [ОТКЛЮЧЕНИЕ] Задача найдена - удаляем...
    goto :DisableMode
) else (
    echo [ВКЛЮЧЕНИЕ] Задача не найдена - создаем...
    goto :EnableMode
)

:: Процесс включения задачи
:EnableMode
echo ВКЛЮЧЕНИЕ показа всех иконок трея с автозапуском...

:: Создаем VBS скрипт для показа иконок
set "VBSFile=%TEMP%\ShowAllTrayIcons.vbs"
(
echo HKCU = ^&H80000001
echo key = "Control Panel\NotifyIconSettings"
echo Set reg = GetObject^("winmgmts://./root/default:StdRegProv"^)
echo If reg.EnumKey^(HKCU, key, names^) = 0 Then
echo     If Not IsNull^(names^) Then
echo         For Each name In names
echo             reg.SetDWORDValue HKCU, key + "\" + name, "IsPromoted", 1
echo         Next
echo     End If
echo End If
) > "%VBSFile%"

:: Создаем XML для задачи планировщика
set "XMLFile=%TEMP%\ShowAllTrayIcons.xml"
(
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<Triggers^>
echo     ^<LogonTrigger^>
echo       ^<Enabled^>true^</Enabled^>
echo     ^</LogonTrigger^>
echo   ^</Triggers^>
echo   ^<Principals^>
echo     ^<Principal id="Author"^>
echo       ^<UserId^>%USERDOMAIN%\%USERNAME%^</UserId^>
echo       ^<LogonType^>InteractiveToken^</LogonType^>
echo       ^<RunLevel^>LeastPrivilege^</RunLevel^>
echo     ^</Principal^>
echo   ^</Principals^>
echo   ^<Settings^>
echo     ^<MultipleInstancesPolicy^>IgnoreNew^</MultipleInstancesPolicy^>
echo     ^<DisallowStartIfOnBatteries^>false^</DisallowStartIfOnBatteries^>
echo     ^<StopIfGoingOnBatteries^>false^</StopIfGoingOnBatteries^>
echo     ^<AllowHardTerminate^>true^</AllowHardTerminate^>
echo     ^<StartWhenAvailable^>false^</StartWhenAvailable^>
echo     ^<RunOnlyIfNetworkAvailable^>false^</RunOnlyIfNetworkAvailable^>
echo     ^<IdleSettings^>
echo       ^<StopOnIdleEnd^>true^</StopOnIdleEnd^>
echo       ^<RestartOnIdle^>false^</RestartOnIdle^>
echo     ^</IdleSettings^>
echo     ^<AllowStartOnDemand^>true^</AllowStartOnDemand^>
echo     ^<Enabled^>true^</Enabled^>
echo     ^<Hidden^>false^</Hidden^>
echo     ^<RunOnlyIfIdle^>false^</RunOnlyIfIdle^>
echo     ^<WakeToRun^>false^</WakeToRun^>
echo     ^<ExecutionTimeLimit^>PT72H^</ExecutionTimeLimit^>
echo     ^<Priority^>7^</Priority^>
echo   ^</Settings^>
echo   ^<Actions Context="Author"^>
echo     ^<Exec^>
echo       ^<Command^>wscript.exe^</Command^>
echo       ^<Arguments^>"%VBSFile%"^</Arguments^>
echo     ^</Exec^>
echo   ^</Actions^>
echo ^</Task^>
) > "%XMLFile%"

:: Регистрируем задачу в планировщике
schtasks /create /tn "ShowAllTrayIcons" /xml "%XMLFile%" /f >nul

:: Немедленно применяем настройки для текущей сессии
cscript //nologo "%VBSFile%"

echo Все иконки трея ВКЛЮЧЕНЫ
echo Автозапуск АКТИВИРОВАН - будет работать при каждом входе в систему
goto :RestartExplorer

:: Процесс удаления задачи
:DisableMode
echo ОТКЛЮЧЕНИЕ показа всех иконок трея...

:: Удаляем задачу из планировщика
schtasks /delete /tn "ShowAllTrayIcons" /f >nul

:: Создаем VBS скрипт для скрытия иконок (возврат к авторежиму)
set "VBSFile=%TEMP%\HideTrayIcons.vbs"
(
echo HKCU = ^&H80000001
echo key = "Control Panel\NotifyIconSettings"
echo Set reg = GetObject^("winmgmts://./root/default:StdRegProv"^)
echo If reg.EnumKey^(HKCU, key, names^) = 0 Then
echo     If Not IsNull^(names^) Then
echo         For Each name In names
echo             reg.DeleteValue HKCU, key + "\" + name, "IsPromoted"
echo         Next
echo     End If
echo End If
) > "%VBSFile%"

:: Применяем настройки скрытия
cscript //nologo "%VBSFile%"

echo Все иконки трея ОТКЛЮЧЕНЫ (авторежим)
echo Автозапуск УДАЛЕН

:RestartExplorer
echo Перезапуск проводника для применения изменений...
taskkill /f /im explorer.exe >nul 2>&1
timeout /t 1 /nobreak >nul
start explorer.exe

:: Очистка временных файлов
if exist "%TEMP%\ShowAllTrayIcons.vbs" del "%TEMP%\ShowAllTrayIcons.vbs" >nul 2>&1
if exist "%TEMP%\HideTrayIcons.vbs" del "%TEMP%\HideTrayIcons.vbs" >nul 2>&1
if exist "%TEMP%\ShowAllTrayIcons.xml" del "%TEMP%\ShowAllTrayIcons.xml" >nul 2>&1

echo Готово! Текущий статус: 
schtasks /query /tn "ShowAllTrayIcons" >nul 2>&1
if !errorlevel! == 0 (
    echo [ВКЛЮЧЕНО] - Все иконки показываются, автозапуск активен
) else (
    echo [ОТКЛЮЧЕНО] - Иконки в авторежиме, автозапуск не активен
)

echo.
echo Возврат в главное меню через 10 секунд, можете нажать любую кнопку...
timeout /t 10 >nul
exit /b