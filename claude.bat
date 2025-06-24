@echo off
chcp 65001 >nul
REM Claude - Docker Helper
REM Simple command interface for Claude Code Docker environment

if "%1"=="" (
    echo Claude Code Docker Helper
    echo Usage: claude.bat [command]
    echo.
    echo Commands:
    echo   setup      Initial setup and build
    echo   start      Start container
    echo   connect    Connect to container
    echo   stop       Stop container
    echo   status     Show container status
    echo   move       Move workspace to projects
    echo   list       List all projects
    echo   work       Work on existing project
    echo   save       Save changes back to project
    echo   clean      Clean up everything
    echo   help       Show this help
    echo.
    goto end
)

if "%1"=="setup" goto setup
if "%1"=="start" goto start
if "%1"=="connect" goto connect
if "%1"=="stop" goto stop
if "%1"=="status" goto status
if "%1"=="move" goto move
if "%1"=="list" goto list
if "%1"=="work" goto work
if "%1"=="save" goto save
if "%1"=="clean" goto clean
if "%1"=="help" goto help

echo Error: Unknown command '%1'
echo Use 'claude.bat help' for available commands
goto end

:setup
echo Setting up Claude Code environment...
mkdir workspace 2>nul
echo Building container...
docker-compose build
echo Starting container...
docker-compose up -d
echo Waiting for container to be ready...
timeout /t 3 /nobreak >nul
docker-compose ps
echo Setup complete! Use 'claude.bat connect' to start.
goto end

:start
echo Starting container...
docker-compose up -d
echo Waiting for container to be ready...
timeout /t 2 /nobreak >nul
docker-compose ps
echo Container started. Use 'claude.bat connect' to access.
goto end

:connect
echo Connecting to Claude Code...
echo Commands to run inside container:
echo   /home/claude/check-claude.sh
echo   echo 'alias claude="/home/claude/claude-wrapper.sh"' ^>^> ~/.bashrc
echo   source ~/.bashrc
echo   claude
docker-compose exec claude-code bash
goto end

:stop
docker-compose down
echo Container stopped.
goto end

:status
docker-compose ps
goto end

:move
echo Moving workspace contents to projects...
set /p name="Project name: "
if "%name%"=="" (
    echo Error: Project name is required
    goto end
)
if exist "projects\%name%" (
    echo Error: Project 'projects\%name%' already exists
    echo Choose a different name or delete the existing project
    goto end
)
echo [1/4] Creating projects directory...
mkdir projects 2>nul
echo [2/4] Creating project directory: projects\%name%
mkdir "projects\%name%" 2>nul
echo [3/4] Copying workspace contents to projects\%name%...
xcopy "workspace\*" "projects\%name%\" /E /I /Q 2>nul
if errorlevel 1 (
    echo Warning: Some files may not have been copied
)
echo [4/4] Clearing workspace...
del /Q workspace\* 2>nul
for /d %%x in (workspace\*) do rd /s /q "%%x" 2>nul
echo.
echo Success: Project moved to 'projects\%name%'
echo Workspace is now empty and ready for next project
goto end

:list
echo Available projects:
if exist "projects" (
    dir /b projects 2>nul
    if errorlevel 1 echo   No projects found
) else (
    echo   No projects directory exists
)
goto end

:work
echo Working on existing project with Claude Code...
if not exist "projects" (
    echo Error: No projects directory found
    echo Create a project first using: claude.bat move
    goto end
)
echo Available projects:
dir /b projects 2>nul
if errorlevel 1 (
    echo No projects found
    echo Create a project first using: claude.bat move
    goto end
)
echo.
set /p project_name="Select project to work on: "
if "%project_name%"=="" (
    echo Error: Project name is required
    goto end
)
if not exist "projects\%project_name%" (
    echo Error: Project 'projects\%project_name%' not found
    goto end
)
echo [1/4] Clearing workspace...
del /Q workspace\* 2>nul
for /d %%x in (workspace\*) do rd /s /q "%%x" 2>nul
echo [2/4] Loading project '%project_name%' into workspace...
REM Git関連ファイル・フォルダーを除外してコピー
for /f "delims=" %%i in ('dir /b /a-d "projects\%project_name%"') do (
    if not "%%i"==".git" (
        if not "%%i"==".gitignore" (
            copy "projects\%project_name%\%%i" "workspace\" >nul 2>&1
        )
    )
)
for /f "delims=" %%i in ('dir /b /ad "projects\%project_name%"') do (
    if not "%%i"==".git" (
        xcopy "projects\%project_name%\%%i" "workspace\%%i\" /E /I /Q >nul 2>&1
    )
)
echo [3/4] Starting Claude Code container...
docker-compose up -d
echo [4/4] Connecting to Claude Code with project loaded...
echo.
echo ==========================================
echo  Project '%project_name%' loaded in workspace
echo  Git files (.git, .gitignore) excluded
echo  You can now use Claude Code to work on it
echo  Commands to run in container:
echo  1. /home/claude/check-claude.sh
echo  2. echo 'alias claude="/home/claude/claude-wrapper.sh"' ^>^> ~/.bashrc
echo  3. source ~/.bashrc
echo  4. claude
echo  
echo  After finishing work, exit and run:
echo  claude.bat save %project_name%
echo ==========================================
echo.
docker-compose exec claude-code bash
goto end

:save
if "%2"=="" (
    echo Saving workspace changes back to project...
    set /p project_name="Enter project name to save to: "
) else (
    set project_name=%2
    echo Saving workspace changes back to project: %project_name%
)
if "%project_name%"=="" (
    echo Error: Project name is required
    echo Usage: claude.bat save [project_name]
    goto end
)
if not exist "projects\%project_name%" (
    echo Error: Project 'projects\%project_name%' not found
    echo Available projects:
    dir /b projects 2>nul
    goto end
)
echo [1/3] Saving workspace changes to projects\%project_name%...
REM Git関連ファイル以外を削除
for /f "delims=" %%i in ('dir /b /a-d "projects\%project_name%"') do (
    if not "%%i"==".git" (
        if not "%%i"==".gitignore" (
            del "projects\%project_name%\%%i" 2>nul
        )
    )
)
for /f "delims=" %%i in ('dir /b /ad "projects\%project_name%"') do (
    if not "%%i"==".git" (
        rd /s /q "projects\%project_name%\%%i" 2>nul
    )
)
REM workspaceの内容をコピー
xcopy "workspace\*" "projects\%project_name%\" /E /I /Q 2>nul
echo [2/3] Clearing workspace...
del /Q workspace\* 2>nul
for /d %%x in (workspace\*) do rd /s /q "%%x" 2>nul
echo [3/3] Complete
echo.
echo ✅ Workspace saved to 'projects\%project_name%'
echo ✅ Git files (.git, .gitignore) preserved
echo ✅ Workspace cleared and ready for next project
goto end

:clean
echo Performing complete reset...
docker-compose down
docker system prune -f
docker volume prune -f
echo Reset complete!
goto end

:help
echo Claude Code Docker Helper
echo.
echo Available commands:
echo   setup      Build and start everything
echo   start      Start the container
echo   connect    Connect to container shell  
echo   stop       Stop the container
echo   status     Show container status
echo   move       Move workspace to projects folder
echo   list       List all projects
echo   work       Work on specific project with Claude Code
echo   save       Save current workspace back to project
echo   clean      Remove all containers and images
echo   help       Show this help message
echo.
echo Examples:
echo   claude.bat setup
echo   claude.bat connect
echo   claude.bat work
echo   claude.bat save my-project
goto end

:end