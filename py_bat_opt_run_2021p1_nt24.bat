

set bat_path=D:\software\Altair\2021.1\hwsolvers\scripts\optistruct_v2021p1.bat
set run_dir=%cd%
set nthread=24

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