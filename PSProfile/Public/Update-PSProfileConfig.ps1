function Update-PSProfileConfig {
    [CmdletBinding()]
    Param()
    Process {
        Write-Verbose "Refreshing PSProfile config!"
        $global:PSProfile.Refresh()
    }
}