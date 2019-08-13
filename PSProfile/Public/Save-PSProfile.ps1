function Save-PSProfile {
    <#
    .SYNOPSIS
    Saves the current PSProfile configuration by calling the $PSProfile.Save() method.

    .DESCRIPTION
    Saves the current PSProfile configuration by calling the $PSProfile.Save() method.

    .EXAMPLE
    Save-PSProfile
    #>
    [CmdletBinding()]
    Param()
    Process {
        Write-Verbose "Saving PSProfile configuration!"
        $global:PSProfile.Save()
    }
}
