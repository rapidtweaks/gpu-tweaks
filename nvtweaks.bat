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
set "n="

for /f "tokens=*" %%A in ('reg query "%base%" /k /f "*" ^| findstr /r "\\....$"') do (
    reg query "%%A" /v "ProviderName" 2>nul | find /i "NVIDIA" >nul
    if !errorlevel! equ 0 (
        set "n=%%A"
    )
)

if "%n%"=="" (
    echo [ERR] NVIDIA GPU registry key not found!
    pause
    exit /b
)

set "BinaryMask=ffffffff"

@echo disable nvidia driver notification
reg add "HKCU\SOFTWARE\NVIDIA Corporation\Global\GFExperience" /v "NotifyNewDisplayUpdates" /t REG_DWORD /d 0 /f >nul 2>&1

@echo hide nvidia tray icon
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvTray" /v "StartOnLogin" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "HideXGpuTrayIcon" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\CoProcManager" /v "ShowTrayIcon" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable display power savings
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\Software\NVIDIA Corporation\Global\NVTweak" /v "DisplayPowerSaving" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable runtime power management
reg add "%n%" /v "EnableRuntimePowerManagement" /t REG_DWORD /d 0 /f >nul 2>&1

@echo gpu performance counters for all users
reg add "%n%" /v "RmProfilingAdminOnly" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "RmProfilingAdminOnly" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable mpo (windows)
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "OverlayTestMode" /t REG_DWORD /d 5 /f >nul 2>&1

@echo disable dlss indicator
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore" /v "ShowDlssIndicator" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable hd audio d3cold
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableHDAudioD3Cold" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable hardware fault buffer
reg add "%n%" /v "RmDisableHwFaultBuffer" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable per intr dpc queueing
reg add "%n%" /v "RMDisablePerIntrDPCQueueing" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable engine gatings
reg add "%n%" /v "RMElcg" /t REG_DWORD /d 1431655765 /f >nul 2>&1
reg add "%n%" /v "RMBlcg" /t REG_DWORD /d 286331153 /f >nul 2>&1
reg add "%n%" /v "RMElpg" /t REG_DWORD /d 4095 /f >nul 2>&1
reg add "%n%" /v "RMSlcg" /t REG_DWORD /d 262131 /f >nul 2>&1
reg add "%n%" /v "RMFspg" /t REG_DWORD /d 15 /f >nul 2>&1

@echo disable gc6
reg add "%n%" /v "RMGC6Feature" /t REG_DWORD /d 699050 /f >nul 2>&1
reg add "%n%" /v "RMGC6Parameters" /t REG_DWORD /d 85 /f >nul 2>&1
reg add "%n%" /v "RMDidleFeatureGC5" /t REG_DWORD /d 44731050 /f >nul 2>&1

@echo disable hot plug support
reg add "%n%" /v "RMHotPlugSupportDisable" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable the paged dma mode for fbsr
reg add "%n%" /v "RmFbsrPagedDMA" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable post l2 compression
reg add "%n%" /v "RMDisablePostL2Compression" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable logging
reg add "%n%" /v "RmRcWatchdog" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%n%" /v "RmLogonRC" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%n%" /v "RMIntrDetailedLogs" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%n%" /v "RMCtxswLog" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%n%" /v "RMNvLog" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%n%" /v "RMSuppressGPIOIntrErrLog" /t REG_DWORD /d 0 /f >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogDisableMasks" /t REG_BINARY /d "%BinaryMask%" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogWarningEntries" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogPagingEntries" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogEventEntries" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogErrorEntries" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disables usb-c pmu event logging in rm
reg add "%n%" /v "RMUsbcDebugMode" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable feature disablement
reg add "%n%" /v "RMDisableFeatureDisablement" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable breakpoint on debug resource manager on rc errors
reg add "%n%" /v "RmBreakonRC" /t REG_DWORD /d 0 /f >nul 2>&1

@echo turn off i2c nanny
reg add "%n%" /v "RmEnableI2CNanny" /t REG_DWORD /d 0 /f >nul 2>&1

@echo latency tolerance
reg add "%n%" /v "RMPcieLtrOverride" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%n%" /v "RMPcieLtrL12ThresholdOverride" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%n%" /v "RMDeepL1EntryLatencyUsec" /t REG_DWORD /d 1 /f >nul 2>&1

@echo rmperflimitsoverride
reg add "%n%" /v "RmPerfLimitsOverride" /t REG_DWORD /d 21 /f >nul 2>&1

@echo rmgcofffeature
reg add "%n%" /v "RMGCOffFeature" /t REG_DWORD /d 2 /f >nul 2>&1

@echo disable aspm
reg add "%n%" /v "RmOverrideSupportChipsetAspm" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%n%" /v "RMEnableASPMDT" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%n%" /v "RMDisableGpuASPMFlags" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "%n%" /v "RMEnableASPMAtLoad" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable event tracer
reg add "%n%" /v "RMEnableEventTracer" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable error checks
reg add "%n%" /v "SkipSwStateErrChecks" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable advanced error reporting
reg add "%n%" /v "RMAERRForceDisable" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable opsb feature
reg add "%n%" /v "RM580312" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable war
reg add "%n%" /v "RmWar1760398" /t REG_DWORD /d 1 /f >nul 2>&1

@echo configure low power features
reg add "%n%" /v "RMLpwrArch" /t REG_DWORD /d 349525 /f >nul 2>&1
reg add "%n%" /v "RmLpwrGrPgSwFilterFunction" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%n%" /v "RmLpwrCtrlMsDifrSwAsrParameters" /t REG_DWORD /d 5461 /f >nul 2>&1
reg add "%n%" /v "RmLpwrCacheStatsOnD3" /t REG_DWORD /d 0 /f >nul 2>&1

@echo configure paging features
reg add "%n%" /v "RmPgCtrlParameters" /t REG_DWORD /d 1431655765 /f >nul 2>&1

@echo disable mscg from rm side
reg add "%n%" /v "RmDwbMscg" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable bbx inform
reg add "%n%" /v "RmDisableInforomBBX" /t REG_DWORD /d 15 /f >nul 2>&1

@echo prefer system memory contiguous
reg add "%n%" /v "PreferSystemMemoryContiguous" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "PreferSystemMemoryContiguous" /t REG_DWORD /d 1 /f >nul 2>&1

@echo configure sec2 to not use profile with apm task enabled
reg add "%n%" /v "RmSec2EnableApm" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable slowdowns
reg add "%n%" /v "RmOverrideIdleSlowdownSettings" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%n%" /v "RMClkSlowDown" /t REG_DWORD /d 71303168 /f >nul 2>&1

@echo disable bunch of power features as war for bug
reg add "%n%" /v "RM2644249" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable 10 types of acpi calls from the resource manager to the sbios.
reg add "%n%" /v "RmDisableACPI" /t REG_DWORD /d 1023 /f >nul 2>&1

@echo disable native pcie l1
reg add "%n%" /v "RMNativePcieL1WarFlags" /t REG_DWORD /d 16 /f >nul 2>&1

@echo force disable clear perfmon and reset level when entering d4 state
reg add "%n%" /v "RMResetPerfMonD4" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable the wddm power saving mode for fbsr
reg add "%n%" /v "RmFbsrWDDMMode" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable edc replay
reg add "%n%" /v "PerfLevelSrc" /t REG_DWORD /d 8738 /f >nul 2>&1

@echo disable lpwr fsms on init
reg add "%n%" /v "RMElpgStateOnInit" /t REG_DWORD /d 3 /f >nul 2>&1

@echo force never power off the mios
reg add "%n%" /v "RmMIONoPowerOff" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable optimal power for padlink pll
reg add "%n%" /v "RMDisableOptimalPowerForPadlinkPll" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable the power-off-dram-pll-when-unused feature
reg add "%n%" /v "RmClkPowerOffDramPllWhenUnused" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable 6 power savings
reg add "%n%" /v "RMOPSB" /t REG_DWORD /d 10914 /f >nul 2>&1

@echo force p0 state
reg add "%n%" /v "DisableDynamicPstate" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable async p-states
reg add "%n%" /v "DisableAsyncPstates" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable uphy init sequence
reg add "%n%" /v "RMNvlinkUPHYInitControl" /t REG_DWORD /d 16 /f >nul 2>&1

@echo disable genoa system power controller
reg add "%n%" /v "RmGpsGenoa" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable control panel telemetry
reg add "HKLM\Software\Nvidia Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f >nul 2>&1

@echo dont send telemetry data
reg add "HKLM\System\CurrentControlSet\Services\nvlddmkm\Global\Startup" /v "SendTelemetryData" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable registry caching
reg add "%n%" /v "RmDisableRegistryCaching" /t REG_DWORD /d 15 /f >nul 2>&1

@echo enable d3 pc latency
reg add "%n%" /v "D3PCLatency" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable ms hybrid
reg add "%n%" /v "EnableMsHybrid" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable illegal compstat access
reg add "%n%" /v "RMDisableIntrIllegalCompstatAccess" /t REG_DWORD /d 1 /f >nul 2>&1

@echo set panel refresh rate
reg add "%n%" /v "SetPanelRefreshRate" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable non-contiguous allocation
reg add "%n%" /v "RMDisableNoncontigAlloc" /t REG_DWORD /d 1 /f >nul 2>&1

@echo unrestricted application clock permissions
if exist "%SystemRoot%\System32\nvidia-smi.exe" (
    "%SystemRoot%\System32\nvidia-smi.exe" -acp 0 >nul 2>&1
) else (
    nvidia-smi.exe -acp 0 >nul 2>&1
)

echo.
echo [OK] Successfully applied NVIDIA tweaks.
pause
exit
