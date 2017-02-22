

@echo off & setlocal EnableDelayedExpansion
color 0e & title Win7无线热点客户端管理程序
rem 无线热点客户端查看程序
rem 版本 0.2 Beta
(
set "ismode=" &rem 无线热点模式是否启用
set "isstart=" &rem 无线热点状态是否开启
set "isap=" &rem 是否找到ap信息
set "apssid=" &rem 无线热点的ssid
set "apmac=" &rem 无线热点的物理地址
set "apip=" &rem 无线热点的IP地址
set "sumclient=" &rem 连接到无线热点的客户端总数
set "clientip=" &rem 客户端ip
set "clientmac=" &rem 客户端mac
set "clientstate=" &rem 客户端验证状态
set "ipclass=" &rem 客户端ip类型
set "n=" &rem 临时变量
)

:Begin
cls
echo 无线热点信息:
rem 获取无线热点模式信息
for /f "skip=3 tokens=2 usebackq delims=:" %%i in (`netsh wlan show hostednetwork`) do (
 if "!ismode!"=="" (
  if "%%i"==" 已启用" (set "ismode=true") else (set "ismode=false") 
  if "%%i"=="" (echo 无线热点模式：不可用) else echo 无线热点模式：%%i 
 )
)
rem 获取无线热点状态信息
for /f "skip=11 tokens=2 usebackq delims=:" %%i in (`netsh wlan show hostednetwork`) do (
 if "!isstart!"=="" (
  if "%%i"==" 已启动" (set "isstart=true") else (set "isstart=false")
  if "%%i"=="" (echo 无线热点状态：不可用) else echo 无线热点状态：%%i
 )
)
rem 获取无线热点的SSID、MAC、IP
if /i "!isstart!"=="true" (
 for /f "skip=4 tokens=1* usebackq delims=:" %%i in (`netsh wlan show hostednetwork`) do if "!apssid!"=="" set "apssid=%%j"  echo 无线热点的SSID：!apssid!
 for /f "skip=12 tokens=1* usebackq delims=:" %%i in (`netsh wlan show hostednetwork`) do if "!apmac!"=="" set "apmac=%%j"  set "apmac=!apmac::=-!" &rem 将:转换为-
 echo 无线热点的物理地址：!apmac!
 for /f "tokens=1* usebackq delims=:" %%i in (`ipconfig /all`) do (
  if /i "%%j"==" !apmac!" set "isap=true" &rem 已进入ap信息
  if /i "!isap!"=="true" (
   set "n=%%i"
   if /i "!n:~0,7!"==" IPv4" (
    set "apip=%%j"
    set "isap=false" &rem 已离开ap信息
   )
  )
 )
 for /f "delims=(" %%i in ("!apip!") do set "apip=%%i" &rem 分离出ip地址
 echo 无线热点的IP地址：!apip!
) else echo 未启动无线热点，SSID不可用 & echo 未启动无线热点，IP和物理地址不可用
echo - - - - - - echo;

if /i not "!isstart!"=="true" (echo 未启动无线热点，客户端信息不可用) else (
 echo 连接到无线热点上的客户端信息：
 rem 获取客户端总数
 for /f "skip=15 tokens=2 usebackq delims=:" %%i in (`netsh wlan show hostednetwork`) do (
  if "!sumclient!"=="" (
   set "sumclient=%%i"
   echo 连接到无线热点的客户端总数：!sumclient!
  )
 )
 if !sumclient! gtr 0 (
  echo 编号 类型 验证状态 物理地址 IP地址
  set "n=1"
  for /f "skip=16 tokens=1,2 usebackq delims= " %%i in (`netsh wlan show hostednetwork`) do (
   set "clientmac=%%i"
   set "clientmac=!clientmac::=-!" &rem 将:转换为-
   set "clientstate=%%j"
   for /f "tokens=1,3 usebackq delims= " %%l in (`arp -a -n %apip% ^| find /i "!clientmac!"`) do (
    set "clientip=%%l"
    set "ipclass=%%m"
   )
   echo !n! !ipclass! !clientstate! !clientmac! !clientip!
   set /a n+=1
  )
 ) else echo 当前没有客户端连接到无线热点上
)
echo - - - - - -
:return
@echo off
@echo ___________________________________
@echo +++++++++++功能选择++++++++++++++++
@echo + 1.开启有线共享 +
@echo + 2.开启无线共享 +
@echo + 3.设置SSID及KEY+
@echo + 4.修改密码KEY +
@echo + 5.显示热点信息 +
@echo + 6.退出程序并关闭WIFI +
@echo +++++++++++++++++++++++++++++++++++
set /p choice=请选择数字
if %choice%==1 goto a
if %choice%==2 goto b
if %choice%==3 goto c
if %choice%==4 goto d
if %choice%==5 goto Begin
if %choice%==6 goto exit
cls
@echo -_-。sorry！输入错误，请输入有效数字!
goto return
:a
netsh wlan stop hostednetwork
cscript /nologo ics.vbs "!apssid!" "无线网络连接" "off"
cscript /nologo ics.vbs "!apssid!" "本地连接" "on"
netsh wlan start hostednetwork
goto :end
:b
netsh wlan stop hostednetwork
cscript /nologo ics.vbs "!apssid!" "本地连接" "off"
cscript /nologo ics.vbs "!apssid!" "无线网络连接" "on"
netsh wlan start hostednetwork
goto :end
:c
@echo →_→
@echo 警告：开启Windows 7无线网络需要管理员权限
@echo 请确认是以管理员身份登录Windows！！！
@echo 即将为您开启Windows 7无线网络
@echo 请牢记您输入的无线网络名称(ssid)以及无线网络密码(key)!!!
@pause
@echo off
echo 请输入网络名SSID和密码KEY
echo 请输入共享无线网络名SSID（Enter确认）：
set/p SSID=
echo 请输入密码KEY(长度不少于8位，少于8位将开启失败，Enter确认）：
set/p Password=
netsh wlan set hostednetwork mode=allow ssid=%SSID% key=%Password%
netsh wlan start hostednetwork
@echo ……OK！
cls
goto return
:d
@echo 警告：请牢记您输入的无线网络密码(KEY)!!!
@echo off
echo 请输入新密码(长度不得少于8位，少于8位将开启失败，Enter确认）：
:PW2
set/p Password=

netsh wlan set hostednetwork mode=allow key=%Password%
netsh wlan start hostednetwork
cls
goto return
:end
rem cls
goto return
pause

:exit
cls
netsh wlan stop hostednetwork
@echo 3秒后程序自动关闭
ping /n 1 /w 3000 1.0.0.1>nul
exit

rem
(
pause
set "apn=%%i"
set /p choice=选择
if %choice%==Y goto l
if %choice%==y goto l
if %choice%==Y goto m
if %choice%==n goto m
for /f "usebackq tokens=2 delims= " %%i in (`ipconfig /all^|find "无线局域网适配器"`) do (
echo %%i

pause
netsh interface set interface name=!apn! newname=共享无线2
)
）