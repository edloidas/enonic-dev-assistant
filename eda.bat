@ECHO OFF

REM =========
REM User variables. Should be defined before first launch
REM =========
SET XP_REPO=d:\repo
SET XP_HOME=d:\tmp\xp_home

REM =========
REM Runtime variables
REM =========

REM   Task "run":
SET ARG_DEBUG=""
SET ARG_DEV="dev"

REM   Task "build":
SET ARG_RERUN=""
SET ARG_DEBUG=""
SET ARG_DEV=""
SET ARG_SKIP_LINT=""
SET ARG_SKIP_TEST=""
SET ARG_ALL=""

REM   Tasks flags:
REM     DO_BUILD, DO_LINT, DO_TEST, DO_RUN, DO_INIT, DO_DEFAULT
REM     DO_BUILD_ONLY_XP, DO_BUILD_ONLY_LIB, DO_BUILD_ONLY_APPS

REM =========
REM Arguments parsing
REM =========
IF "%~1" == "" (
  SET DO_DEFAULT=1
)

:loop
IF NOT "%1"=="" (
  IF "%1"=="build" (
    SET DO_BUILD=1
    SHIFT & GOTO :loop
  )
  IF "%1"=="clean" (
    SET DO_CLEAN=1
    SHIFT & GOTO :loop
  )
  IF "%1"=="lint" (
    SET DO_LINT=1
    SHIFT & GOTO :loop
  )
  IF "%1"=="test" (
    SET DO_TEST=1
    SHIFT & GOTO :loop
  )
  IF "%1"=="run" (
    SET DO_RUN=1
    SHIFT & GOTO :loop
  )
  IF "%1"=="init" (
    SET DO_INIT=1
    SHIFT & GOTO :loop
  )
  IF "%1"=="default" (
    SET DO_DEFAULT=1
    SHIFT & GOTO :loop
  )
  IF "%1"=="-r" (
    SET ARG_RERUN="--rerun-tasks"
    SHIFT & GOTO :loop
  )
  IF "%1"=="-d" (
    SET ARG_DEBUG="debug"
    SHIFT & GOTO :loop
  )
  IF "%1"=="-p" (
    SET ARG_DEV=""
    SHIFT & GOTO :loop
  )
  IF "%1"=="-a" (
    SET ARG_ALL="-Pall"
    SHIFT & GOTO :loop
  )
  IF "%1"=="-x" (
    :skip
    IF "%2"=="lint" (
      SET ARG_SKIP_LINT="-x lint"
      SHIFT & GOTO :skip
    )
    IF "%2"=="test" (
      SET ARG_SKIP_TEST="-x test"
      SHIFT & GOTO :skip
    )
    SHIFT & GOTO :loop
  )
  IF "%1"=="-o" (
    :only
    IF "%2"=="xp" (
      SET DO_BUILD_ONLY_XP=1
      SHIFT & GOTO :only
    )
    IF "%2"=="lib-admin-ui" (
      SET DO_BUILD_ONLY_LIB=1
      SHIFT & GOTO :only
    )
    IF "%2"=="xp-apps" (
      SET DO_BUILD_ONLY_APPS=1
      SHIFT & GOTO :only
    )
    SHIFT & GOTO :loop
  )
  IF "%1"=="--help" (
    SET HELP=1
    SHIFT & GOTO :loopend
  )
  SHIFT & GOTO :loop
)
:loopend

REM =========
REM Executing tasks
REM =========

REM   --help
IF NOT [%HELP%]==[] (
  ECHO Usage: & ECHO. & ECHO   eda [..TASKS] [..FLAGS]
  ECHO. & ECHO Tasks and flags:
  ECHO. & ECHO   init         # Clone repos [xp, lib-admin-ui, xp-apps]
  ECHO. & ECHO   clean        # Clean builded files of REPO [xp, lib-admin-ui, xp-apps]
  ECHO     -o [REPO]  # Build only a specific REPO [xp, lib-admin-ui, xp-apps]
  ECHO. & ECHO   build        # Build all REPO [xp, lib-admin-ui, xp-apps]
  ECHO     -r         # Rerun cached Gradle tasks [--rerun-tasks]
  ECHO     -a         # Use local lib-admin-ui repo, when building xp-apps [-Pall]
  ECHO     -x [TASK]  # Skip Gradle tasks, while building [test, lint]
  ECHO     -o [REPO]  # Build only a specific REPO [xp, lib-admin-ui, xp-apps]
  ECHO. & ECHO   run          # Run server at the end
  ECHO     -d         # Run server in "debug" mode with open port :8080
  ECHO     -p         # Run server in production [without "dev"] and HMR
  ECHO. & ECHO   default      # Only task, executes for [xp-apps] and [lib-admin-ui]
  ECHO                # gradle build deploy -x lint -x test -Pall
  ECHO. & ECHO Examples:
  ECHO   eda build -o xp run -d
  ECHO   eda clean build -x test -o xp-apps -a
  EXIT 0
)

REM   Default task, with no args or with "default" argument
IF NOT [%DO_DEFAULT%]==[] (
  ECHO. & ECHO Building LIB-ADMIN-UI: & ECHO.
  gradle build -x lint -x test -p %XP_REPO%\lib-admin-ui

  ECHO. & ECHO Building XP-APPS:
  gradle build deploy -x lint -x test -Pall -p %XP_REPO%\xp-apps

  ECHO. & ECHO %TIME% & ECHO.

  EXIT 0
)

REM   Initializing with git clone
IF NOT [%DO_INIT%]==[] (
  ECHO Initializing...
  git clone https://github.com/enonic/xp.git %XP_REPO%\xp
  git clone https://github.com/enonic/lib-admin-ui.git %XP_REPO%\lib-admin-ui
  git clone https://github.com/enonic/xp-apps.git %XP_REPO%\xp-apps
)

REM   Task "clean"
IF NOT [%DO_CLEAN%]==[] (
  ECHO Cleaning...
  IF NOT [%DO_BUILD_ONLY_XP%]==[] ( gradle clean -p %XP_REPO%\xp )
  IF NOT [%DO_BUILD_ONLY_LIB%]==[] ( gradle clean -p %XP_REPO%\lib-admin-ui )
  IF NOT [%DO_BUILD_ONLY_APPS%]==[] ( gradle clean -p %XP_REPO%\xp-apps )
  IF [%DO_BUILD_ONLY_XP%]==[] ( IF [%DO_BUILD_ONLY_LIB%]==[] ( IF [%DO_BUILD_ONLY_APPS%]==[] (
    gradle clean -p %XP_REPO%\xp
    gradle clean -p %XP_REPO%\lib-admin-ui
    gradle clean -p %XP_REPO%\xp-apps
  ) ) )
)

REM   Task "build"
IF NOT [%DO_BUILD%]==[] (
  ECHO Building...
  IF NOT [%DO_BUILD_ONLY_XP%]==[] (
    ECHO. & ECHO Building XP: %ARG_SKIP_TEST:"=% %ARG_RERUN:"=%
    gradle build %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% -p %XP_REPO%\xp
  )
  IF NOT [%DO_BUILD_ONLY_LIB%]==[] (
    ECHO. & ECHO Building LIB-ADMIN-UI: %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=%
    gradle build %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% -p %XP_REPO%\lib-admin-ui
  )
  IF NOT [%DO_BUILD_ONLY_APPS%]==[] (
    IF [%DO_BUILD_ONLY_LIB%]==[] ( IF %ARG_ALL%=="-Pall" (
        ECHO. & ECHO Building LIB-ADMIN-UI: %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=%
        gradle build %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% -p %XP_REPO%\lib-admin-ui
    ) )
    ECHO. & ECHO Building XP-APPS: %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% %ARG_ALL:"=%
    gradle build deploy %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% %ARG_ALL:"=% -p %XP_REPO%\xp-apps
  )
  IF [%DO_BUILD_ONLY_XP%]==[] ( IF [%DO_BUILD_ONLY_LIB%]==[] ( IF [%DO_BUILD_ONLY_APPS%]==[] (
        ECHO. & ECHO Building XP: %ARG_SKIP_TEST:"=% %ARG_RERUN:"=%
        gradle build %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% -p %XP_REPO%\xp
        ECHO. & ECHO Building LIB-ADMIN-UI: %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=%
        gradle build %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% -p %XP_REPO%\lib-admin-ui
        ECHO. & ECHO Building XP-APPS: %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% %ARG_ALL:"=%
        gradle build deploy %ARG_SKIP_LINT:"=% %ARG_SKIP_TEST:"=% %ARG_RERUN:"=% %ARG_ALL:"=% -p %XP_REPO%\xp-apps
  ) ) )

  ECHO. & ECHO %TIME% & ECHO.
)

REM   Task "run"
IF NOT [%DO_RUN%]==[] (
  ECHO. & ECHO Starting server: %ARG_DEBUG:"=% %ARG_DEV:"=%
  CALL %XP_REPO%\xp\modules\runtime\build\install\bin\server.bat %ARG_DEBUG:"=% %ARG_DEV:"=% -Dxp.home=%XP_HOME%
)
