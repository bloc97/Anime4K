@echo off && set "WD=%~dp0"
pushd "%WD%"

start /b /wait cmd /c mvn clean compile assembly:single

move /y "target\Anime4K-static.jar" "Anime4K.jar"

pause