function Import-PSProfile {
    <#
    .SYNOPSIS
    Reloads your PSProfile by running $PSProfile.Load()

    .DESCRIPTION
    Reloads your PSProfile by running $PSProfile.Load()

    .EXAMPLE
    Import-PSProfile

    .EXAMPLE
    Load-PSProfile
    #>
    [CmdletBinding()]
    Param()
    Process {
        Write-Verbose "Loading PSProfile configuration!"
        $global:PSProfile.Load()
    }
}
