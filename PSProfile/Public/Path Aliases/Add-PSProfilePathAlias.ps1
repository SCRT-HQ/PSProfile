function Add-PSProfilePathAlias {
    <#
    .SYNOPSIS
    Adds a path alias to your PSProfile configuration. Path aliases are used for path shortening in prompts via Get-PathAlias.

    .DESCRIPTION
    Adds a path alias to your PSProfile configuration. Path aliases are used for path shortening in prompts via Get-PathAlias.

    .PARAMETER Alias
    The alias to substitute the full path for in prompts via Get-PathAlias.

    .PARAMETER Path
    The full path to be substituted.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfilePathAlias -Alias ~ -Path $env:USERPROFILE -Save

    Adds a path alias of ~ for the current UserProfile folder and saves your PSProfile configuration.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Alias,
        [Parameter(Mandatory,Position = 1)]
        [String]
        $Path,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        Write-Verbose "Adding alias '$Alias' to path '$Path' to PSProfile"
        $Global:PSProfile.PathAliases[$Alias] = $Path
        if ($Save) {
            Save-PSProfile
        }
    }
}
