function Write-PSProfileLog {
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
