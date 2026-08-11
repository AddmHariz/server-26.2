@echo off
setlocal

REM ===== MEMORY SETTINGS =====
REM You can adjust these if needed
set MIN_RAM=12G
set MAX_RAM=16G

echo.
echo ============================================
echo   Starting Fabric Server with %MIN_RAM% RAM, %MAX_RAM% RAM MAX
echo ============================================
echo.

REM ===== JAVA OPTIONS =====
set JAVA_OPTS=-XX:+UseG1GC ^
 -XX:+ParallelRefProcEnabled ^
 -XX:MaxGCPauseMillis=200 ^
 -XX:+UnlockExperimentalVMOptions ^
 -XX:+DisableExplicitGC ^
 -XX:G1NewSizePercent=20 ^
 -XX:G1MaxNewSizePercent=40 ^
 -XX:G1HeapRegionSize=16M ^
 -XX:G1ReservePercent=20 ^
 -XX:G1HeapWastePercent=5 ^
 -XX:G1MixedGCCountTarget=4 ^
 -XX:InitiatingHeapOccupancyPercent=15 ^
 -XX:G1MixedGCLiveThresholdPercent=90 ^
 -XX:G1RSetUpdatingPauseTimePercent=5 ^
 -XX:SurvivorRatio=32 ^
 -XX:MaxTenuringThreshold=1 ^
 -XX:+PerfDisableSharedMem ^
 -Dio.netty.eventLoopThreads=6

REM ===== SERVER LAUNCH =====
java -Xms%MIN_RAM% -Xmx%MAX_RAM% %JAVA_OPTS% -jar fabric-server-launch.jar

echo.
echo Server process has exited.
echo Verifying shutdown and session safety...

:waitForSessionLockRelease
(
    REM Try to lock the file to confirm it is not in use
    >"world\session.lock" (
        echo session.lock is not locked. Proceeding...
    )
) 2>nul || (
    echo session.lock is still in use. Waiting...
    timeout /t 2 >nul
    goto waitForSessionLockRelease
)

echo Done shutting down! Please commit and push your gameplay and changes to GitHub.
pause