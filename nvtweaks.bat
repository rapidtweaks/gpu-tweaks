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
set "target="

for /f "tokens=*" %%A in ('reg query "%base%" /k /f "*" ^| findstr /r "\\....$"') do (
    reg query "%%A" /v "ProviderName" 2>nul | find /i "NVIDIA" >nul
    if !errorlevel! equ 0 (
        set "target=%%A"
        echo [OK] Found nvidia at: %%A
    )
)

if not defined target (
    echo [ERR] NVIDIA GPU not found on this system
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
reg add "%target%" /v "EnableRuntimePowerManagement" /t REG_DWORD /d 0 /f >nul 2>&1

@echo gpu performance counters for all users
reg add "%target%" /v "RmProfilingAdminOnly" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "RmProfilingAdminOnly" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable mpo (windows)
reg add "HKLM\SOFTWARE\Microsoft\Windows\Dwm" /v "OverlayTestMode" /t REG_DWORD /d 5 /f >nul 2>&1

@echo disable dlss indicator
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore" /v "ShowDlssIndicator" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable hd audio d3cold
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableHDAudioD3Cold" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable hardware fault buffer
reg add "%target%" /v "RmDisableHwFaultBuffer" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable per intr dpc queueing
reg add "%target%" /v "RMDisablePerIntrDPCQueueing" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable engine gatings
reg add "%target%" /v "RMElcg" /t REG_DWORD /d 1431655765 /f >nul 2>&1
reg add "%target%" /v "RMBlcg" /t REG_DWORD /d 286331153 /f >nul 2>&1
reg add "%target%" /v "RMElpg" /t REG_DWORD /d 4095 /f >nul 2>&1
reg add "%target%" /v "RMSlcg" /t REG_DWORD /d 262131 /f >nul 2>&1
reg add "%target%" /v "RMFspg" /t REG_DWORD /d 15 /f >nul 2>&1

@echo disable gc6
reg add "%target%" /v "RMGC6Feature" /t REG_DWORD /d 699050 /f >nul 2>&1
reg add "%target%" /v "RMGC6Parameters" /t REG_DWORD /d 85 /f >nul 2>&1
reg add "%target%" /v "RMDidleFeatureGC5" /t REG_DWORD /d 44731050 /f >nul 2>&1

@echo disable hot plug support
reg add "%target%" /v "RMHotPlugSupportDisable" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable the paged dma mode for fbsr
reg add "%target%" /v "RmFbsrPagedDMA" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable post l2 compression
reg add "%target%" /v "RMDisablePostL2Compression" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable logging
reg add "%target%" /v "RmRcWatchdog" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%target%" /v "RmLogonRC" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%target%" /v "RMIntrDetailedLogs" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%target%" /v "RMCtxswLog" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%target%" /v "RMNvLog" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%target%" /v "RMSuppressGPIOIntrErrLog" /t REG_DWORD /d 0 /f >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogDisableMasks" /t REG_BINARY /d "%BinaryMask%" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogWarningEntries" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogPagingEntries" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogEventEntries" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Parameters" /v "LogErrorEntries" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disables usb-c pmu event logging in rm
reg add "%target%" /v "RMUsbcDebugMode" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable feature disablement
reg add "%target%" /v "RMDisableFeatureDisablement" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable breakpoint on debug resource manager on rc errors
reg add "%target%" /v "RmBreakonRC" /t REG_DWORD /d 0 /f >nul 2>&1

@echo turn off i2c nanny
reg add "%target%" /v "RmEnableI2CNanny" /t REG_DWORD /d 0 /f >nul 2>&1

@echo latency tolerance
reg add "%target%" /v "RMPcieLtrOverride" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%target%" /v "RMPcieLtrL12ThresholdOverride" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%target%" /v "RMDeepL1EntryLatencyUsec" /t REG_DWORD /d 1 /f >nul 2>&1

@echo rmperflimitsoverride
reg add "%target%" /v "RmPerfLimitsOverride" /t REG_DWORD /d 21 /f >nul 2>&1

@echo rmgcofffeature
reg add "%target%" /v "RMGCOffFeature" /t REG_DWORD /d 2 /f >nul 2>&1

@echo disable aspm
reg add "%target%" /v "RmOverrideSupportChipsetAspm" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%target%" /v "RMEnableASPMDT" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "%target%" /v "RMDisableGpuASPMFlags" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "%target%" /v "RMEnableASPMAtLoad" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable event tracer
reg add "%target%" /v "RMEnableEventTracer" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable error checks
reg add "%target%" /v "SkipSwStateErrChecks" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable advanced error reporting
reg add "%target%" /v "RMAERRForceDisable" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable opsb feature
reg add "%target%" /v "RM580312" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable war
reg add "%target%" /v "RmWar1760398" /t REG_DWORD /d 1 /f >nul 2>&1

@echo configure low power features
reg add "%target%" /v "RMLpwrArch" /t REG_DWORD /d 349525 /f >nul 2>&1
reg add "%target%" /v "RmLpwrGrPgSwFilterFunction" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%target%" /v "RmLpwrCtrlMsDifrSwAsrParameters" /t REG_DWORD /d 5461 /f >nul 2>&1
reg add "%target%" /v "RmLpwrCacheStatsOnD3" /t REG_DWORD /d 0 /f >nul 2>&1

@echo configure paging features
reg add "%target%" /v "RmPgCtrlParameters" /t REG_DWORD /d 1431655765 /f >nul 2>&1

@echo disable mscg from rm side
reg add "%target%" /v "RmDwbMscg" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable bbx inform
reg add "%target%" /v "RmDisableInforomBBX" /t REG_DWORD /d 15 /f >nul 2>&1

@echo prefer system memory contiguous
reg add "%target%" /v "PreferSystemMemoryContiguous" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "PreferSystemMemoryContiguous" /t REG_DWORD /d 1 /f >nul 2>&1

@echo configure sec2 to not use profile with apm task enabled
reg add "%target%" /v "RmSec2EnableApm" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable slowdowns
reg add "%target%" /v "RmOverrideIdleSlowdownSettings" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "%target%" /v "RMClkSlowDown" /t REG_DWORD /d 71303168 /f >nul 2>&1

@echo disable bunch of power features as war for bug
reg add "%target%" /v "RM2644249" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable 10 types of acpi calls from the resource manager to the sbios.
reg add "%target%" /v "RmDisableACPI" /t REG_DWORD /d 1023 /f >nul 2>&1

@echo disable native pcie l1
reg add "%target%" /v "RMNativePcieL1WarFlags" /t REG_DWORD /d 16 /f >nul 2>&1

@echo force disable clear perfmon and reset level when entering d4 state
reg add "%target%" /v "RMResetPerfMonD4" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable the wddm power saving mode for fbsr
reg add "%target%" /v "RmFbsrWDDMMode" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable edc replay
reg add "%target%" /v "PerfLevelSrc" /t REG_DWORD /d 8738 /f >nul 2>&1

@echo disable lpwr fsms on init
reg add "%target%" /v "RMElpgStateOnInit" /t REG_DWORD /d 3 /f >nul 2>&1

@echo force never power off the mios
reg add "%target%" /v "RmMIONoPowerOff" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable optimal power for padlink pll
reg add "%target%" /v "RMDisableOptimalPowerForPadlinkPll" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable the power-off-dram-pll-when-unused feature
reg add "%target%" /v "RmClkPowerOffDramPllWhenUnused" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable 6 power savings
reg add "%target%" /v "RMOPSB" /t REG_DWORD /d 10914 /f >nul 2>&1

@echo force p0 state
reg add "%target%" /v "DisableDynamicPstate" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable async p-states
reg add "%target%" /v "DisableAsyncPstates" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable uphy init sequence
reg add "%target%" /v "RMNvlinkUPHYInitControl" /t REG_DWORD /d 16 /f >nul 2>&1

@echo disable genoa system power controller
reg add "%target%" /v "RmGpsGenoa" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable control panel telemetry
reg add "HKLM\Software\Nvidia Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f >nul 2>&1

@echo dont send telemetry data
reg add "HKLM\System\CurrentControlSet\Services\nvlddmkm\Global\Startup" /v "SendTelemetryData" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable registry caching
reg add "%target%" /v "RmDisableRegistryCaching" /t REG_DWORD /d 15 /f >nul 2>&1

@echo enable d3 pc latency
reg add "%target%" /v "D3PCLatency" /t REG_DWORD /d 1 /f >nul 2>&1

@echo disable ms hybrid
reg add "%target%" /v "EnableMsHybrid" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable illegal compstat access
reg add "%target%" /v "RMDisableIntrIllegalCompstatAccess" /t REG_DWORD /d 1 /f >nul 2>&1

@echo set panel refresh rate
reg add "%target%" /v "SetPanelRefreshRate" /t REG_DWORD /d 0 /f >nul 2>&1

@echo disable non-contiguous allocation
reg add "%target%" /v "RMDisableNoncontigAlloc" /t REG_DWORD /d 1 /f >nul 2>&1

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
