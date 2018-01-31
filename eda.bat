@echo off

:: ==========================
:: VARIABLES
:: ==========================
:: - System -----------------
set pathRepo=c:\repo
set pathHome=c:\tmp\xp_home
:: - Repos ------------------
set pathXp=c:\repo\xp
set pathLib=c:\repo\lib-admin-ui
set pathApps=c:\repo\xp-apps
:: - Runtime ----------------
:: Run:   runDebug, runDev
:: Build: buildRerun, buildAll, buildSkipTest, buildSkipLint
:: Tasks: taskBuild, taskClean, taskLint, taskTest, taskRun, taskInit
:: Only:  onlyXp, onlyLib, onlyApps
:: Group: groupDefault, groupQuick, groupFull
set runDev=dev

:: ==========================
:: RUNNERS
:: ==========================
if "%1"=="" set groupDefault=1
call:parseArguments %*

if not "%help%"=="" call:helpFunc
if not "%groupDefault%"=="" call:defaultFunc
if not "%groupQuick%"=="" call:quickFunc
if not "%groupFull%"=="" call:fullFunc

if not "%taskInit%"=="" call:initFunc
if not "%taskLint%"=="" call:lintFunc
if not "%taskClean%"=="" (if "%taskBuild%"=="" call:cleanFunc)
if not "%taskBuild%"=="" call:buildFunc
if not "%taskRun%"=="" call:runFunc

:: ==========================
:: FUNCTIONS
:: ==========================
exit 0
:: - Parse arguments --------
:parseArguments
  if not "%1"=="" (
    if "%1"=="--help"  ( set help=1&                   shift & goto:eof )
    if "%1"=="-h"      ( set help=1&                   shift & goto:eof )

    if "%1"=="build"   ( set taskBuild=1&              shift & goto :parseArguments )
    if "%1"=="clean"   ( set taskClean=clean&          shift & goto :parseArguments )
    if "%1"=="lint"    ( set taskLint=1&               shift & goto :parseArguments )
    if "%1"=="test"    ( set taskTest=1&               shift & goto :parseArguments )
    if "%1"=="run"     ( set taskRun=1&                shift & goto :parseArguments )
    if "%1"=="init"    ( set taskInit=1&               shift & goto :parseArguments )
    if "%1"=="default" ( set groupDefault=1&           shift & goto :parseArguments )
    if "%1"=="quick"   ( set groupQuick=1&             shift & goto :parseArguments )
    if "%1"=="full"    ( set groupFull=1&              shift & goto :parseArguments )
    if "%1"=="-r"      ( set buildRerun=--rerun-tasks& shift & goto :parseArguments )
    if "%1"=="-d"      ( set runDebug=debug&           shift & goto :parseArguments )
    if "%1"=="-p"      ( set runDev=&                  shift & goto :parseArguments )
    if "%1"=="-a"      ( set buildAll=-Pall&           shift & goto :parseArguments )
    if "%1"=="-x" (
      :skip
      if "%2"=="lint"  ( set buildSkipLint=-x lint&    shift & goto :skip )
      if "%2"=="test"  ( set buildSkipTest=-x test&    shift & goto :skip )
      shift & goto :parseArguments )
    if "%1"=="-o" (
      :only
      if "%2"=="xp"           ( set onlyXp=1&          shift & goto :only )
      if "%2"=="lib-admin-ui" ( set onlyLib=1&         shift & goto :only )
      if "%2"=="xp-apps"      ( set onlyApps=1&        shift & goto :only )
      shift & goto :parseArguments )
    shift & goto :parseArguments )

  :: Update flags with complicated state
  if "%onlyXp%"=="" (if "%onlyLib%"=="" (if "%onlyApps%"=="" (
    set   onlyXp=1
    set  onlyLib=1
    set onlyApps=1
  )))

  if not [%taskLint%]==[] (
    if not "%buildSkipLint%"=="" set taskLint=
    if not "%taskBuild%"==""     set taskLint=
  )

  if not "%taskTest%"=="" (
    if not "%buildSkipTest%"=="" set taskTest=
    if not "%taskBuild%"==""     set taskTest=
  )

  if not "%taskInit%"=="" set taskClean=

  if not "%groupDefault%"=="" (if not "%groupQuick%"=="" echo `default` and `quick` tasks cann't run simultaneously & exit 0)
  if not "%groupDefault%"=="" (if not "%groupFull%"==""  echo `default` and `full` tasks cann't run simultaneously & exit 0)
  if not "%groupFull%"==""    (if not "%groupQuick%"=="" echo `full` and `quick` tasks cann't run simultaneously & exit 0)
goto:eof

:: - Help & manual ----------
:helpFunc
  echo.
  echo Usage: & echo.
  echo   eda [..TASKS] [..FLAGS] & echo.
  echo Tasks and flags: & echo.
  echo   init         # Clone repositories. & echo.
  echo   clean        # Clean builded files in repositories. & echo.
  echo   lint         # Lint sources in repositories. & echo.
  echo   build        # Build all repositories [xp, lib-admin-ui, xp-apps].
  echo     -r         # Rerun cached Gradle tasks [--rerun-tasks].
  echo     -a         # Use local lib-admin-ui repo, when building xp-apps [-Pall]. & echo.
  echo   -x [TASK]    # Skip specific Grale task [test, lint]. & echo.
  echo   -o [REPO]    # Run task for the specific repository [xp, lib-admin-ui, xp-apps].
  echo   run          # Run server.
  echo     -d         # Enable "debug" mode with open port :5005
  echo     -p         # Enable production environment. HMR will be disabled. & echo.
  echo Grouped tasks: & echo.
  echo   default      # Build local lib-admin-ui and xp-apps, without test and lint. & echo.
  echo   quick        # Build local xp-apps, without test and lint. & echo.
  echo   full         # Build all repositories, without test and lint. & echo.
  echo Examples:
  echo   eda build -o xp run -d
  echo   eda clean build -x test lint -o xp xp-apps -a
  echo.
exit 0

:: - Git clone --------------
:initFunc
`echo. & echo = Clone =
  if not "%onlyXp%"=="" git clone https://github.com/enonic/xp.git %pathXp%
  if not "%onlyLib%"=="" git clone https://github.com/enonic/lib-admin-ui.git %pathLib%
  if not "%onlyApps%"=="" git clone https://github.com/enonic/xp-apps.git %pathApps%
goto:eof

:: - Linting ----------------
:lintFunc
  echo. & echo = Lint =
  if not "%onlyLib%"=="" gradle lint -p %pathLib%
  if not "%onlyApps%"=="" gradle lint -p %pathApps%
goto:eof

:: - Testing ----------------
:lintFunc
  echo. & echo = Test =
  if not "%onlyXp%"=="" gradle test -p %pathXp%
  if not "%onlyLib%"=="" gradle test -p %pathLib%
  if not "%onlyApps%"=="" gradle test -p %pathApps%
goto:eof

:: - Cleaning ---------------
:cleanFunc
  echo. & echo = Clean =
  if not "%onlyXp%"=="" gradle clean -p %pathXp%
  if not "%onlyLib%"=="" gradle clean -p %pathLib%
  if not "%onlyApps%"=="" gradle clean -p %pathApps%
goto:eof

:: - Building ---------------
:buildFunc
  echo. & echo = Build =
  if not "%onlyXp%"=="" call:buildXpFunc
  if not "%onlyLib%"=="" call:buildLibFunc
  if not "%onlyApps%"=="" call:buildAppsFunc
  echo. & echo %TIME% & echo.
goto:eof

:buildXpFunc
  echo. & echo = XP =
  echo gradle %taskClean% build %buildSkipTest% %buildRerun% -p %pathXp%
  call gradle %taskClean% build %buildSkipTest% %buildRerun% -p %pathXp%
goto:eof

:buildLibFunc
  echo. & echo = LIB ADMIN UI =
  echo gradle %taskClean% build %buildSkipLint% %buildSkipTest% %buildRerun% -p %pathLib%
  call gradle %taskClean% build %buildSkipLint% %buildSkipTest% %buildRerun% -p %pathLib%
goto:eof

:buildAppsFunc
  echo. & echo = XP APPS =
  echo gradle %taskClean% build deploy %buildAll% %buildSkipLint% %buildSkipTest% %buildRerun% -p %pathApps%
  call gradle %taskClean% build deploy %buildAll% %buildSkipLint% %buildSkipTest% %buildRerun% -p %pathApps%
goto:eof

:: - Running server ---------
:runFunc
  echo. & echo = Run Server =
  if not "%runDev%"==""   echo DEV: ON
  if not "%runDebug%"=="" echo DEBUG: ON & echo.
  call %pathXp%\modules\runtime\build\install\bin\server.bat %runDebug% %runDev% -Dxp.home=%pathHome%
exit 0

:: - Default ----------------
:defaultFunc
  echo. & echo = Default =
  echo. & echo gradle build -x lint -x test -p %pathLib%
  call gradle build -x lint -x test -p %pathLib%
  echo. & echo gradle build deploy -Pall -x lint -x test -p %pathApps%
  call gradle build deploy -Pall -x lint -x test -p %pathApps%
exit 0

:: - Quick ------------------
:quickFunc
  echo. & echo = Quick =
  echo. & echo gradle build deploy -x lint -x test -p %pathApps%
  call gradle build deploy -x lint -x test -p %pathApps%
exit 0

:: - Full ------------------
:fullFunc
  echo. & echo = Full =
  echo. & echo gradle build -x test -p %pathXp%
  call gradle build -x test -p %pathXp%
  echo. & echo gradle build -x lint -x test -p %pathLib%
  call gradle build -x lint -x test -p %pathLib%
  echo. & echo gradle build deploy -Pall -x lint -x test -p %pathApps%
  call gradle build deploy -Pall -x lint -x test -p %pathApps%
exit 0
