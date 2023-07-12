rd /s /q dist

pyinstaller -F main_fatigue.py
pyinstaller -F fatigue_fem_fatdef_split_limit.py
pyinstaller -F fatigue_fem_path_edit.py
pyinstaller -F py_bat_opt_run.py
pyinstaller -F stat_time_read.py
pyinstaller -F hmCompChange_2021to2017.py
pyinstaller -F sub_get_h3d_files.py
pyinstaller -F auto_hvSumH3dDamage.py


del /f /q *.spec
rd /s /q build
rd /s /q __pycache__

copy hvSumH3dDamage.tcl dist
copy hvAutoRun.tcl dist
copy hmmenu.set dist
copy hwpost.dat dist

pause 

