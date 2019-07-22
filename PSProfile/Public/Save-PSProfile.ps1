function Save-PSProfile {
    [CmdletBinding()]
    Param()
    Process {
        Write-Verbose "Saving PSProfile configuration!"
        $global:PSProfile.Save()
    }
}