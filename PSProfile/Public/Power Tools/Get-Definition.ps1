function Get-Definition {
    <#
    .SYNOPSIS
    Convenience function to easily get the defition of a function

    .DESCRIPTION
    Convenience function to easily get the defition of a function

    .PARAMETER Command
    The command or function to get the definition for

    .EXAMPLE
    Get-Definition Open-Code

    .EXAMPLE
    def Open-Code

    Uses the shorter alias to get the definition of the Open-Code function
    #>
    [CmdletBinding()]
    Param(
        [parameter(Mandatory,Position = 0)]
        [String]
        $Command
    )
    Process {
        try {
            Write-Verbose "Getting definition for command: $Command"
            $Definition = (Get-Command $Command -ErrorAction Stop).Definition
            "function $Command {$Definition}"
        }
        catch {
            throw
        }
    }
}

Register-ArgumentCompleter -CommandName Get-Definition -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Command "$wordToComplete*").Name | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
