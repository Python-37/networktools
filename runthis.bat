chcp 936 &gt;nul
@echo off
mode con lines=30 cols=60
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"
:main
cls
color 2f
echo   $       $              **********$****
echo **$**   **$**               $****$ $
echo   $   $   $                 $****$ $
echo   *$**$**$*              **********$****
echo ***$**$**$***               $****$ $
echo   *$**$**$*                 $****$ $
echo ******$******                    * $
echo       $                           *$
echo.----------------------------------------------------------- 
color 2e
echo.-----------------------------------------------------------
echo.輸入指令：
echo.
echo. 1.更換hosts（在下面輸入1）
echo.
echo. 2.恢復hosts（在下面輸入2）
echo.-----------------------------------------------------------

if exist "%SystemRoot%\System32\choice.exe" goto Win7Choice

set /p choice=輸入數字指令並按Enter確認:

echo.
if %choice%==1 goto host DNS
if %choice%==2 goto CL
cls
"set choice="
echo 輸入有誤，請重新選擇。
ping 127.0.1 -n "2">nul
goto main

:Win7Choice
choice /c 12 /n /m "輸入對應數字："
if errorlevel 2 goto CL
if errorlevel 1 goto host DNS
cls
goto main

:host DNS
cls
color 2f
copy /y "hosts" "%SystemRoot%\System32\drivers\etc\hosts"
ipconfig /flushdns
echo.-----------------------------------------------------------
echo.
echo 更換HOSTS文件成功！
goto end

:CL
cls
color 2f
@echo 127.0.0.1 localhost > %SystemRoot%\System32\drivers\etc\hosts
echo 恢復HOSTS文件成功！
echo.
goto end

:end
echo 按任意鍵退出
@Pause>nul