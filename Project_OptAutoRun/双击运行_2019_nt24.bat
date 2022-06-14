
REM 版本
set version=2019

REM 线程数
set nthread=24


REM ============================
REM ============================
REM ============================

title="Optistruct %version% running"

REM optistruct.bat 路径索引
if not exist search_optistruct_version.exe (
	for /f "delims=" %%a in ('python search_optistruct_version.py %version%') do (
	   set bat_path=%%a
	)
) else (

	for /f "delims=" %%a in ('search_optistruct_version.exe %version%') do (
	   set bat_path=%%a
	)

)

REM 当前运行路径
set run_dir=%cd%


echo run_dir : %run_dir%
echo bat_path : %bat_path%
echo nthread : %nthread%


if not exist py_bat_opt_run.exe (
	python py_bat_opt_run.py %bat_path% "%run_dir%" %nthread%
	echo run-python
) else (
	py_bat_opt_run.exe %bat_path% "%run_dir%" %nthread%
	echo run-exe
)

pause
