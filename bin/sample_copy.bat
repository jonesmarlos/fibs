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
ECHO  Let's consider that you need constant backup file name like LASTBACKUP.FBK,
ECHO  NOT changing like SAMPLETASK_2-0231.FBK, ..232.FBK, ..233.FBK.
ECHO  After running this batch file with FIBS (or manually with last backup's name
ECHO  as parameter), the last backup file (%~n1%~x1) will be copied to
ECHO  root of "C" as named LASTBACKUP%~x1.
ECHO.
ECHO  Full Path of Backup File = %~1
ECHO  Drive Letter             = %~d1
ECHO  Path                     = %~p1
ECHO  File Name                = %~n1
ECHO  File Extension           = %~x1
ECHO.
COPY %1 C:\LASTBACKUP%~x1
ECHO.
IF errorlevel 1  (ECHO ERROR !! COPYING ABORTED) ELSE (ECHO %1 IS COPIED TO ROOT OF DRIVE C AS "LASTBACKUP%~x1")
ECHO.
PAUSE
CLS
EXIT 

