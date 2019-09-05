function Format-Syntax {
    <#
    .SYNOPSIS
    Formats a command's syntax in an easy-to-read view.

    .DESCRIPTION
    Formats a command's syntax in an easy-to-read view.

    .PARAMETER Command
    The command to get the syntax of.

    .EXAMPLE
    Format-Syntax Get-Process

    Gets the formatted syntax by parameter set for Get-Process

    .EXAMPLE
    syntax Get-Process

    Same as Example 1, but uses the alias 'syntax' instead.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position = 0)]
        [String[]]
        $Command
    )
    Process {
        foreach ($comm in $Command) {
            Write-Verbose "Getting formatted syntax for command: $comm"
            $check = Get-Command -Name $comm
            $params = @{
                Name   = if ($check.CommandType -eq 'Alias') {
                    Get-Command -Name $check.Definition
                }
                else {
                    $comm
                }
                Syntax = $true
            }
            (Get-Command @params) -replace '(\s(?=\[)|\s(?=-))', "`r`n "
        }
    }
}

Register-ArgumentCompleter -CommandName Format-Syntax -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Command "$wordToComplete*").Name | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
