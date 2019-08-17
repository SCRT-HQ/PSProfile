function Add-PSProfileVariable {
    <#
    .SYNOPSIS
    Adds a global or environment variable to your PSProfile configuration. Variables added to PSProfile will be set during profile load.

    .DESCRIPTION
    Adds a global or environment variable to your PSProfile configuration. Variables added to PSProfile will be set during profile load.

    .PARAMETER Name
    The name of the variable.

    .PARAMETER Value
    The value to set the variable to.

    .PARAMETER Scope
    The scope of the variable to set between Environment or Global. Defaults to Environment.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileVariable -Name HomeBase -Value C:\HomeBase -Save

    Adds the environment variable named 'HomeBase' to be set to the path 'C:\HomeBase' during profile load and saves your PSProfile configuration.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Name,
        [Parameter(Mandatory,Position = 1)]
        [Object]
        $Value,
        [Parameter(Position = 2)]
        [ValidateSet('Environment','Global')]
        [String]
        $Scope = 'Environment',
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if (-not ($Global:PSProfile.Variables.ContainsKey($Scope))) {
            $Global:PSProfile.Variables[$Scope] = @{}
        }
        Write-Verbose "Adding $Scope variable '$Name' to PSProfile"
        $Global:PSProfile.Variables[$Scope][$Name] = $Value
        if ($Save) {
            Save-PSProfile
        }
    }
}
