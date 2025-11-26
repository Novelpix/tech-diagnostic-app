@echo off

echo ===============================
echo   UPDATE GITHUB - DELTA OPTIMA
echo ===============================

echo.
echo Git status:
git status

echo.
set /p message=Enter commit message: 

echo.
echo Adding files...
git add .

echo Commiting...
git commit -m "%message%"

echo Pushing to GitHub...
git push

echo.
echo Done.
pause
