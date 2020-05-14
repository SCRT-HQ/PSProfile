function Get-PSProfileImportedCommand {
    <#
    .SYNOPSIS
    Gets the list of commands imported from scripts and plugins that are not part of PSProfile itself.

    .DESCRIPTION
    Gets the list of commands imported from scripts and plugins that are not part of PSProfile itself.

    .PARAMETER Command
    The command to get from the list of imported commands.

    .EXAMPLE
    Get-PSProfileImportedCommand

    Gets the full list of commands imported during PSProfile load.
    #>
    [OutputType('System.Management.Automation.FunctionInfo')]
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Command
    )
    Begin {
        $commands = Get-Command -Module PSProfile.* #| Where-Object {$_.Name -notin (Get-Module PSProfile).ExportedCommands.Keys}
    }
    Process {
        if ($PSBoundParameters.ContainsKey('Command')) {
            Write-Verbose "Getting imported command '$Command'"
            $commands | Where-Object {$_.Name -in $Command}
        }
        else {
            Write-Verbose "Getting commands imported during PSProfile load that are not part of PSProfile itself"
            $commands
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileImportedCommand -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Command -Module PSProfile | Where-Object {$_.Name -notin (Get-Module PSProfile).ExportedCommands.Keys} | Where-Object {$_ -like "$wordToComplete*"}).Name | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
