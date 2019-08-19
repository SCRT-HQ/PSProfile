# Set-ProcessPriority

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Set-ProcessPriority [-Process] <String[]> [-Priority] <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Priority
{{ Fill Priority Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Realtime, High, AboveNormal, Normal, BelowNormal, Low

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Process
{{ Fill Process Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Name
Accepted values: AdminService.exe, Adobe CEF Helper.exe, Adobe Desktop Service.exe, AdobeIPCBroker.exe, AdobeUpdateService.exe, AGMService.exe, AGSService.exe, ApplicationFrameHost.exe, audiodg.exe, AutoHotkey.exe, avgnt.exe, avguard.exe, Avira Safe Shopping.exe, Avira.ServiceHost.exe, Avira.SoftwareUpdater.ServiceHost.exe, Avira.Systray.exe, avshadow.exe, avwebg7.exe, BlueJeans.Detector.exe, CCXProcess.exe, Code.exe, com.docker.service, ConEmu64.exe, ConEmuC64.exe, conhost.exe, CoreSync.exe, CorsairLink4.exe, CorsairLink4.Service.exe, crashpad_handler.exe, Creative Cloud.exe, csrss.exe, ctfmon.exe, dasHost.exe, DbxSvc.exe, Discord.exe, Ditto.exe, Divvy.exe, dllhost.exe, Dropbox.exe, DropboxUpdate.exe, dwm.exe, explorer.exe, fontdrvhost.exe, GameScannerService.exe, GoogleCrashHandler.exe, GoogleCrashHandler64.exe, GoogleDriveFS.exe, hpwuschd2.exe, INTERFACE2_AutoSetup.exe, IpOverUsbSvc.exe, jhi_service.exe, jucheck.exe, jusched.exe, LDSvc.exe, LMS.exe, LogiOptions.exe, LogiOptionsMgr.exe, LogiOverlay.exe, LsaIso.exe, lsass.exe, matterbridge.exe, mDNSResponder.exe, Memory Compression, Microsoft.Photos.exe, MicrosoftEdgeUpdateCrashHandler.exe, MicrosoftEdgeUpdateCrashHandler64.exe, msedge.exe, NIHardwareService.exe, NIHostIntegrationAgent.exe, node.exe, nssm.exe, nvcontainer.exe, NVDisplay.Container.exe, NVIDIA Web Helper.exe, NvTelemetryContainer.exe, OpenWith.exe, OriginWebHelperService.exe, Plex Media Server.exe, Plex Tuner Service.exe, Plex Update Service.exe, PlexScriptHost.exe, PlexService.exe, PlexServiceTray.exe, powershell.exe, ProtectedService.exe, PulseSecureService.exe, pwsh.exe, python.exe, pythonw.exe, QtWebEngineProcess.exe, RazerIngameEngine.exe, Registry, remoting_host.exe, rundll32.exe, RuntimeBroker.exe, rzcefrenderprocess.exe, RzSDKServer.exe, RzSDKService.exe, RzStats.Manager.exe, RzSynapse.exe, sched.exe, SearchFilterHost.exe, SearchIndexer.exe, SearchProtocolHost.exe, SearchUI.exe, Secure System, SecurityHealthService.exe, SecurityHealthSystray.exe, services.exe, SgrmBroker.exe, ShareX.exe, ShellExperienceHost.exe, sihost.exe, SkypeApp.exe, SkypeBackgroundHost.exe, SkypeBridge.exe, smss.exe, spoolsv.exe, sqlwriter.exe, ss_conn_service.exe, ssh-agent.exe, StartMenuExperienceHost.exe, svchost.exe, System, System Idle Process, SystemSettings.exe, taskhostw.exe, TeamViewer.exe, TeamViewer_Service.exe, tv_w32.exe, tv_x64.exe, unsecapp.exe, UploaderService.exe, Video.UI.exe, vmcompute.exe, vmms.exe, vsls-agent.exe, WindowsInternal.ComposableShell.Experiences.TextInput.InputApp.exe, wininit.exe, winlogon.exe, winpty-agent.exe, WinStore.App.exe, WmiPrvSE.exe, WUDFHost.exe, YourPhone.exe

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
