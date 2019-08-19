function Get-PSProfileCommand {
    <#
    .SYNOPSIS
    Gets the list of commands provided by PSProfile directly.

    .DESCRIPTION
    Gets the list of commands provided by PSProfile directly.

    .PARAMETER Command
    The command to get from the list of PSProfile commands.

    .EXAMPLE
    Get-PSProfileCommand

    Gets the full list of commands provided by PSProfile directly.
    #>
    [OutputType('System.Management.Automation.FunctionInfo')]
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Command
    )
    Begin {
        $commands = Get-Command -Module PSProfile | Where-Object {$_.Name -in (Get-Module PSProfile).ExportedCommands.Keys}
    }
    Process {
        if ($PSBoundParameters.ContainsKey('Command')) {
            Write-Verbose "Getting PSProfile command '$Command'"
            $commands | Where-Object {$_.Name -in $Command}
        }
        else {
            Write-Verbose "Getting all commands provided by PSProfile directly"
            $commands
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileCommand -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Module PSProfile).ExportedCommands.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
