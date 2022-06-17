
REM 版本
set version=R13.0

REM 线程数
set nthread=8

set bat_path="D:\software\LS-DYNA R13.00\LS-Dyna\Solvers\ls-dyna_smp_s_R13.0_365_x64.exe"

set memory=200


REM ============================
REM ============================
REM ============================

title="Ls-dyna %version% running"

rem REM optistruct.bat 路径索引
rem if not exist search_optistruct_version.exe (
rem 	for /f "delims=" %%a in ('python search_optistruct_version.py %version%') do (
rem 	   set bat_path=%%a
rem 	)
rem ) else (

rem 	for /f "delims=" %%a in ('search_optistruct_version.exe %version%') do (
rem 	   set bat_path=%%a
rem 	)

rem )


REM 当前运行路径
set run_dir=%cd%


echo run_dir : %run_dir%
echo bat_path : %bat_path%
echo nthread : %nthread%
echo memory : %memory%


if not exist py_bat_dyna_run.exe (
	python py_bat_dyna_run.py %bat_path% "%run_dir%" %nthread% %memory%
	echo run-python
) else (
	py_bat_dyna_run.exe %bat_path% "%run_dir%" %nthread% %memory%
	echo run-exe
)

pause
