@ECHO OFF
REM  *******************************************************************************
REM  This is a sample batch file to show you to be done by using the "External File 
REM  executing feature of FIBS.
REM  *******************************************************************************
REM  File Version : 1.0.0 - June 01, 2006 
REM  Author       : Talat Dogan
REM  *******************************************************************************
ECHO.
ECHO  FIBS 1.0 can run external files with a parameter of the last backup file's
ECHO  fully qualified path. This feature of FIBS make it possible, for user, to do
ECHO  extra tasks related with last backup files. 
ECHO.
ECHO  Let's consider that you need to archive all backup files into the a zip archive.
ECHO  After running this batch file of sampleTask2 every backup of the task will be 
ECHO  added to C:\SAMPLETASK2_ARCHIVE.ZIP.
ECHO.
ECHO  Full Path of Backup File = %~1
ECHO  Drive Letter             = %~d1
ECHO  Path                     = %~p1
ECHO  File Name                = %~n1
ECHO  File Extension           = %~x1
ECHO.
"C:\Program Files\Filzip\filzip.exe" -a -rp C:\SAMPLETASK2_ARCHIVE.ZIP %1
ECHO.
IF errorlevel 1  (ECHO ERROR !! ARCHIVING ABORTED) ELSE (ECHO %1 IS ADDED TO THE c:\SAMPLETASK_ARCHIVE.ZIP)
ECHO.
PAUSE
CLS
EXIT 

