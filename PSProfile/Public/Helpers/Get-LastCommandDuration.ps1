function Get-LastCommandDuration {
    <#
    .SYNOPSIS
    Gets the elapsed time of the last command via Get-History. Intended to be used in prompts.

    .DESCRIPTION
    Gets the elapsed time of the last command via Get-History. Intended to be used in prompts.

    .PARAMETER Id
    The Id of the command to get from the history.

    .PARAMETER Format
    The format string for the resulting timestamp.

    .EXAMPLE
    Get-LastCommandDuration
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]
        $Id,
        [Parameter()]
        [string]
        $Format = "{0:h\:mm\:ss\.ffff}"
    )
    $null = $PSBoundParameters.Remove("Format")
    $LastCommand = Get-History -Count 1 @PSBoundParameters
    if (!$LastCommand) {
        return "0:00:00.0000"
    }
    elseif ($null -ne $LastCommand.Duration) {
        $Format -f $LastCommand.Duration
    }
    else {
        $Duration = $LastCommand.EndExecutionTime - $LastCommand.StartExecutionTime
        $Format -f $Duration
    }
}
