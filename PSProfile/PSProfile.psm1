# If we're in an interactive shell, load the profile.
if ([Environment]::UserInteractive -or ($null -eq [Environment]::UserInteractive -and $null -eq ([Environment]::GetCommandLineArgs() | Where-Object { $_ -like '-NonI*' }))) {
    $global:OriginalPrompt =
    $global:PSProfile = [PSProfile]::new()
    $global:PSProfile.Load()
    Export-ModuleMember -Variable PSProfile
    $fsw = [System.IO.FileSystemWatcher]::new($(Split-Path $global:PSProfile.Settings.ConfigurationPath -Parent),'Configuration.psd1')
    $global:PSProfileConfigurationWatcher = Register-ObjectEvent -InputObject $fsw -EventName Changed -Action {
        [PSProfile]$conf = Import-Configuration -Name PSProfile -CompanyName 'SCRT HQ' -Verbose:$false
        $conf._internal = $global:PSProfile._internal
        $global:PSProfile = $conf
    }
    $PSProfile_OnRemoveScript = {
        $global:PSProfileConfigurationWatcher.Dispose()
        Remove-Variable PSProfileConfigurationWatcher -Scope Global -Force
        Remove-Variable PSProfile -Scope Global -Force
    }
    $ExecutionContext.SessionState.Module.OnRemove += $PSProfile_OnRemoveScript
    Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $PSProfile_OnRemoveScript
}
