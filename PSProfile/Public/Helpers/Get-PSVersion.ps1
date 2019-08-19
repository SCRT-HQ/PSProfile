function Get-PSVersion {
    <#
    .SYNOPSIS
    Gets the short formatted PSVersion string for use in a prompt or wherever else desired.

    .DESCRIPTION
    Gets the short formatted PSVersion string for use in a prompt or wherever else desired.

    .PARAMETER Places
    How many decimal places you would like the returned version string to be. Defaults to $PSProfile.Settings.PSVersionStringLength if present.

    .EXAMPLE
    Get-PSVersion -Places 2

    Returns `6.2` when using PowerShell 6.2.2, or `5.1` when using Windows PowerShell 5.1.18362.10000
    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Position = 0)]
        [AllowNull()]
        [int]
        $Places = $global:PSProfile.Settings.PSVersionStringLength
    )
    Process {
        $version = $PSVersionTable.PSVersion.ToString()
        if ($null -ne $Places) {
            $split = ($version -split '\.')[0..($Places - 1)]
            if ("$($split[-1])".Length -gt 1) {
                $split[-1] = "$($split[-1])".Substring(0,1)
            }
            $joined = $split -join '.'
            if ($version -match '[a-zA-Z]+') {
                $joined += "-$(($Matches[0]).Substring(0,1))"
                if ($version -match '\d+$') {
                    $joined += $Matches[0]
                }
            }
            $joined
        }
        else {
            $version
        }
    }
}
