echo _start_ > ~output.txt
for %%a in ("%~dp0\.") do set "parent=%%~nxa"
for %%a in (*) do if not [%%a]==[master.bat] (echo %%~na ^%parent%/%%a) >> ~output.txt
pause