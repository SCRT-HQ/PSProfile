$global:PSProfile = [PSProfile]::new()
$global:PSProfile.Load()
Export-ModuleMember -Variable PSProfile
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Get-RSJob | Where-Object {$_.Name -match 'PSProfile'} | Remove-RSJob -Force
}
