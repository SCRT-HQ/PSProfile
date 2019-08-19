# If we're in an interactive shell, load the profile.
if ([Environment]::UserInteractive -or ($null -eq [Environment]::UserInteractive -and $null -eq ([Environment]::GetCommandLineArgs() | Where-Object {$_ -like '-NonI*'}))) {
    $global:PSProfile = [PSProfile]::new()
    $global:PSProfile.Load()
    Export-ModuleMember -Variable PSProfile
}
