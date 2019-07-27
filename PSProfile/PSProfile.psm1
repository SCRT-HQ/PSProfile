$global:PSProfile = [PSProfile]::new()
$global:PSProfile.Load()
Export-ModuleMember -Variable PSProfile
