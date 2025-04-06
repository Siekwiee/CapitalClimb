@echo off
cd C:\Users\bruce\Documents\CursorProjects\CapitalClimb\
zip -9 -r CapitalClimb.love .
copy /b "C:\Program Files\LOVE\love.exe" + CapitalClimb.love "CapitalClimb.exe"
del CapitalClimb.love
echo Done! Check CapitalClimb.exe