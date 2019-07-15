function Get-MyConfig {
    [cmdletbinding()]
    Param
    ( )
    $script:PSProfile = Import-Configuration
    if (!$script:PSProfile) {
        Write-Verbose "No configuration found! Please run 'Set-MyConfig' to create the configuration"
    }
    else {
        Write-Verbose "Imported config successfully!"
    }
}
