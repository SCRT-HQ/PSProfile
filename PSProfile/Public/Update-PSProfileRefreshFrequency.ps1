function Update-PSProfileRefreshFrequency {
    <#
    .SYNOPSIS
    Sets the Refresh Frequency for PSProfile. The $PSProfile.Refresh() runs tasks that aren't run during every profile load, i.e. SymbolicLink creation, Git project path discovery, module installation, etc.

    .DESCRIPTION
    Sets the Refresh Frequency for PSProfile. The $PSProfile.Refresh() runs tasks that aren't run during every profile load, i.e. SymbolicLink creation, Git project path discovery, module installation, etc.

    .PARAMETER Timespan
    The frequency that you would like to refresh your PSProfile configuration. Refresh will occur during the profile load after the time since last refresh has surpassed the desired refresh frequency.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Update-PSProfileRefreshFrequency -Timespan '03:00:00' -Save

    Updates the RefreshFrequency to 3 hours and saves the PSProfile configuration after updating.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [timespan]
        $Timespan,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        Write-Verbose "Updating PSProfile RefreshFrequency to '$($Timespan.ToString())'"
        $Global:PSProfile.RefreshFrequency = $Timespan.ToString()
        if ($Save) {
            Save-PSProfile
        }
    }
}
