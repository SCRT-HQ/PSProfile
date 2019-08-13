function Update-PSProfileConfig {
    <#
    .SYNOPSIS
    Force refreshes the current PSProfile configuration by calling the $PSProfile.Refresh() method.

    .DESCRIPTION
    Force refreshes the current PSProfile configuration by calling the $PSProfile.Refresh() method. This will update the GitPathMap with any new projects found and other tasks that don't run on every PSProfile load.

    .EXAMPLE
    Update-PSProfileConfig

    .EXAMPLE
    Refresh-PSProfile

    Uses the shorter alias command instead of the long command.
    #>
    [CmdletBinding()]
    Param()
    Process {
        Write-Verbose "Refreshing PSProfile config!"
        $global:PSProfile.Refresh()
    }
}
