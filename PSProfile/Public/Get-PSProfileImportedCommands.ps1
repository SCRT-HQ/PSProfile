function Get-PSProfileImportedCommands {
    <#
    .SYNOPSIS
    Gets the list of commands imported from scripts and plugins that are not part of PSProfile itself.

    .DESCRIPTION
    Gets the list of commands imported from scripts and plugins that are not part of PSProfile itself.

    .EXAMPLE
    Get-PSProfileImportedCommands
    #>
    [OutputType('System.Management.Automation.FunctionInfo')]
    [CmdletBinding()]
    Param ()
    Process {
        Get-Command -Module PSProfile | Where-Object {$_.Name -notin (Get-Module PSProfile).ExportedCommands.Keys}
    }
}
