function Get-PSProfilePathAlias {
    <#
    .SYNOPSIS
    Gets a module from $PSProfile.PathAliases.

    .DESCRIPTION
    Gets a module from $PSProfile.PathAliases.

    .PARAMETER Alias
    The Alias to get from $PSProfile.PathAliases.

    .EXAMPLE
    Get-PSProfilePathAlias -Alias ~

    Gets the alias '~' from $PSProfile.PathAliases

    .EXAMPLE
    Get-PSProfilePathAlias

    Gets the list of path aliases from $PSProfile.PathAliases
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Alias
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Alias')) {
            Write-Verbose "Getting Path Alias '$Alias' from `$PSProfile.PathAliases"
            $Global:PSProfile.PathAliases.GetEnumerator() | Where-Object {$_.Key -in $Alias}
        }
        else {
            Write-Verbose "Getting all command aliases from `$PSProfile.PathAliases"
            $Global:PSProfile.PathAliases
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfilePathAlias -ParameterName Alias -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.PathAliases.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
