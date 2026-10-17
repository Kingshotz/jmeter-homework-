@echo off
cd /d "%~dp0"
if not defined JMETER_HOME set "JMETER_HOME=C:\Program Files\apache-jmeter-5.6.3"
if exist results.csv del results.csv
if exist jmeter.log del jmeter.log
@echo on
"%JMETER_HOME%\bin\jmeter.bat" -n -t sql-reqres-users-test.jmx -l results.csv -j jmeter.log -Jjmeter.save.saveservice.output_format=csv
