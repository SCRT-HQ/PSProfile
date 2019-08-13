function Write-PSProfileLog {
    <#
    .SYNOPSIS
    Adds a log entry to the current PSProfile Log.

    .DESCRIPTION
    Adds a log entry to the current PSProfile Log. Used for external plugins to hook into the existing log so items like Plugin load logging are contained in one place.

    .PARAMETER Message
    The message to log.

    .PARAMETER Section
    The name of the section you are logging for, e.g. the name of the plugin or overall what action is being done.

    .PARAMETER LogLevel
    The Level of the Log event. Defaults to Debug.

    .EXAMPLE
    Write-PSProfileLog -Message "Hunting for missing KBs" -Section 'KBUpdate' -LogLevel 'Verbose'
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Message,
        [Parameter(Mandatory,Position = 1)]
        [String]
        $Section,
        [Parameter(Position = 2)]
        [PSProfileLogLevel]
        $LogLevel = 'Debug'
    )
    Process {
        $Global:PSProfile._log(
            $Message,
            $Section,
            $LogLevel
        )
    }
}
