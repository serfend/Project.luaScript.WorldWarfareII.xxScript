@COLOR 20
@echo off
setlocal enabledelayedexpansion
title 字库训练工具-by滨州IT疯子
set work_path=%cd%\work
set out_path=%cd%\output
:help
cls

echo   使用说明
echo   1、把处理好的tif文件放入work目录下 命名格式为 xxx.1.tif  xxx.2.tif ....
echo   2、先运行1运行完1后打开jTessBoxEditer 修改box文件
echo   3、在运行2即可完成字库训练并合并到到一个字库
echo   4、字库输出目录为%cd%\output
echo   5、默认用于训练中文 训练英文可自行修改tesseract %work_path%\%%a -psm 7 %work_path%\%%~na -l chi_sim batch.nochop makebox 这一句中的 -l 还有psm用的是7 如果要用6请自行修改一下
echo   6、完全开源 请保留title版权标识
pause
goto main

:main
cls
echo ┌──────────────────────────┐
echo │                    字库训练工具                    │
echo ├──────────────────────────┤
echo │ 1、work目录下所有tif文件生成box文件                │
echo │ 2、开始训练并合并字库                              │
echo │ j、启动jTessBoxEditer                              │
echo │ h、使用说明                                        │
echo │ e、退出工具                                        │
echo └──────────────────────────┘

set /P INPUT=请输入选项：

if "%INPUT%"=="1"  goto createbox
if "%INPUT%"=="2"  goto dotrain
if "%INPUT%"=="j"  goto startjbox
if "%INPUT%"=="h"  goto help
if "%INPUT%"=="e"  goto exit

:createbox
cls
echo ----------------------------------
echo 清理历史文件
echo ------------------------------------
del %work_path%\*.tr
del %work_path%\my.inttemp
del %work_path%\my.normproto
del %work_path%\my.pffmtable
del %work_path%\my.shapetable
del %work_path%\my.unicharset
del %work_path%\font_properties
echo ----------------------------------
echo 查找work目录下所有tif文件并生成box
echo ------------------------------------
for /f "delims=" %%a in ('dir /aa /b %work_path%\*.tif ') do (
echo 正在处理%%a
if exist "%work_path%\%%~na.box" (
echo %%~na.box已经存在) else (
tesseract %work_path%\%%a -psm 7 %work_path%\%%~na -l eng batch.nochop makebox
)
echo %%~na 0 0 0 0 0 >>%work_path%\font_properties
)
echo BOX文件全部生成完毕 请打开jTessBoxEditer修改BOX文件
pause
goto main


:dotrain
cls
echo ----------------------------------
echo 开始训练并合并字库
echo -----------------------------------
echo 生成相应的tr文件
echo -----------------------------------
for /f "delims=" %%a in ('dir /aa /b %work_path%\*.tif') do (
echo 正在处理%%a
tesseract %work_path%\%%a -psm 7  %work_path%\%%~na nobatch box.train
)
echo -----------------------------------
echo 从所有文件中提取字符
echo -----------------------------------
for /f "delims=" %%a in ('dir /s /b %work_path%\*.box') do (
echo %%a>>%work_path%\boxlist.txt
)
set n=
for /f "tokens=*" %%i in (%work_path%\boxlist.txt) do set n=!n! %%i
echo %n%>%work_path%\boxlistok.txt
set /p d=<%work_path%\boxlistok.txt
unicharset_extractor %d%
del %work_path%\boxlist.txt
del %work_path%\boxlistok.txt
echo -----------------------------------
echo 生成字体特征文件
echo -----------------------------------
for /f "delims=" %%a in ('dir /s /b %work_path%\*.tr') do (
echo %%a>>%work_path%\trlist.txt
)
set n=
for /f "tokens=*" %%i in (%work_path%\trlist.txt) do set n=!n! %%i
echo %n%>%work_path%\trlistok.txt
set /p d=<%work_path%\trlistok.txt
mftraining -F %work_path%\font_properties -U unicharset %d%
echo -----------------------------------
echo 聚集所有tr文件
echo -----------------------------------
cntraining %d%
del %work_path%\trlist.txt
del %work_path%\trlistok.txt
echo -----------------------------------
echo 重命名文件并移动到work目录
echo -----------------------------------
ren normproto my.normproto&move my.normproto %work_path%\my.normproto
ren inttemp my.inttemp&move my.inttemp %work_path%\my.inttemp 
ren pffmtable my.pffmtable&move my.pffmtable %work_path%\my.pffmtable
ren shapetable my.shapetable&move my.shapetable %work_path%\my.shapetable
ren unicharset my.unicharset&move my.unicharset %work_path%\my.unicharset
echo -----------------------------------
echo 开始训练
echo -----------------------------------
combine_tessdata %work_path%\my.
echo -----------------------------------
echo 移动字库文件
echo -----------------------------------
move %work_path%\my.traineddata %out_path%\my.traineddata
echo ----------------------------------------------------------
echo 如果 1，3，4，5，13 行不是-1那么恭喜你字库训练成功
echo 字库文件目录：%out_path%\my.traineddata
echo ----------------------------------------------------------

pause
goto main

:startjbox
start javaw -Xms128m -Xmx1024m -jar jTessBoxEditor/jTessBoxEditor.jar
goto main