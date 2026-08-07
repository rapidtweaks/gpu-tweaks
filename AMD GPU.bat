@echo off
:: Check for Administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERR] You must run this script as admin
    pause
    exit /b
)

setlocal enabledelayedexpansion

set "base=HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
set "a="

for /f "tokens=*" %%A in ('reg query "%base%" /k /f "*" ^| findstr /r "\\....$"') do (
    reg query "%%A" /v "ProviderName" 2>nul | find /i "Advanced Micro Devices, Inc." >nul
    if !errorlevel! equ 0 (
        set "a=%%A"
    )
)

if "%a%"=="" (
    echo [ERR] AMD GPU registry key not found!
    pause
    exit /b
)

@echo disable amd telemetry reporting
reg add "%a%" /v "ReportAnalytics" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable amd driver notifications
reg add "%a%" /v "NotifySubscription" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable amd subscription
reg add "%a%" /v "AllowSubscription" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable release notes
reg add "%a%" /v "ShowReleaseNotes" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable ecc mode
reg add "%a%" /v "ECCMode" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable stutter mode
reg add "%a%" /v "StutterMode" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable ltr
reg add "%a%" /v "DisableLTR" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable background ltr
reg add "%a%" /v "BGM_EnableLTR" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable dynamic ltr support
reg add "%a%" /v "PP_EnableDynamicLTRSupport" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable amd fendr options
reg add "%a%" /v "KMD_EnableAmdFendrOptions" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable radeon chill
reg add "%a%" /v "KMD_ChillEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

@echo enable radeon anti-lag
reg add "%a%" /v "KMD_DeLagEnabled" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable frame pacing support
reg add "%a%" /v "KMD_FramePacingSupport" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable radeon boost
reg add "%a%" /v "KMD_RadeonBoostEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable gpu stutter
reg add "%a%" /v "DalDisableStutter" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable block write
reg add "%a%" /v "DisableBlockWrite" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable frame buffer compression
reg add "%a%" /v "DisableFBCSupport" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable fbc for fullscreen applications
reg add "%a%" /v "DisableFBCForFullScreenApp" /t REG_DWORD /d 1 /f >nul 2>&1

@echo force 3d performance mode
reg add "%a%" /v "PP_Force3DPerformanceMode" /t REG_DWORD /d 1 /f >nul 2>&1

@echo force high dpm level
reg add "%a%" /v "PP_ForceHighDPMLevel" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable gpu sclk deep sleep
reg add "%a%" /v "PP_SclkDeepSleepDisable" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable gfx power off
reg add "%a%" /v "PP_GfxOffControl" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable thermal auto throttling
reg add "%a%" /v "PP_ThermalAutoThrottlingEnable" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable race to idle
reg add "%a%" /v "PP_EnableRaceToIdle" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable sclk dpm
reg add "%a%" /v "PP_SclkDpmDisabled" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable mclk dpm
reg add "%a%" /v "PP_MclkDpmDisabled" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable socclk dpm
reg add "%a%" /v "PP_SocclkDpmDisabled" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable pcie dpm
reg add "%a%" /v "PP_PcieDpmDisabled" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable ulps
reg add "%a%" /v "EnableUlps" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable ulps na
reg add "%a%" /v "EnableUlps_NA" /t REG_SZ /d "0" /f >nul 2>&1

@echo disable ulps power saving
reg add "%a%" /v "PP_DisableULPS" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable kmd ulps
reg add "%a%" /v "KMD_EnableULPS" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable d3 cold support
reg add "%a%" /v "KMD_ForceD3ColdSupport" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable pcie aspm l0s
reg add "%a%" /v "EnableAspmL0s" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable pcie aspm l1
reg add "%a%" /v "EnableAspmL1" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable pcie aspm l1 substates
reg add "%a%" /v "EnableAspmL1SS" /t REG_DWORD /d 0 /f >nul 2>&1

@echo force disable aspm l0s
reg add "%a%" /v "DisableAspmL0s" /t REG_DWORD /d 1 /f >nul 2>&1

@echo force disable aspm l1
reg add "%a%" /v "DisableAspmL1" /t REG_DWORD /d 1 /f >nul 2>&1

@echo force maximum display clock
reg add "%a%" /v "DalForceMaxDisplayClock" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable display deep sleep
reg add "%a%" /v "DalDisableDeepSleep" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable display div2
reg add "%a%" /v "DalDisableDiv2" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable spread spectrum
reg add "%a%" /v "EnableSpreadSpectrum" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable amd services
set "Root=HKLM\System\CurrentControlSet\Services"
for %%S in ("AMD Crash Defender Service" "amdfendr" "amdfendrmgr" "amdlog") do (
    reg query "%Root%\%%~S" >nul 2>&1 && Reg add "%Root%\%%~S" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
)

echo.
echo [OK] Successfully applied AMD tweaks.
pause
exit