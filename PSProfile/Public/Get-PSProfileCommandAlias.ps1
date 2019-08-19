function Get-PSProfileCommandAlias {
    <#
    .SYNOPSIS
    Gets an alias from $PSProfile.CommandAliases.

    .DESCRIPTION
    Gets an alias from $PSProfile.CommandAliases.

    .PARAMETER Alias
    The alias to get from $PSProfile.CommandAliases.

    .EXAMPLE
    Get-PSProfileCommandAlias -Alias code

    Gets the alias 'code' from $PSProfile.CommandAliases.

    .EXAMPLE
    Get-PSProfileCommandAlias

    Gets the list of command aliases from $PSProfile.CommandAliases.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Alias
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Alias')) {
            Write-Verbose "Getting command alias '$Alias' from `$PSProfile.CommandAliases"
            $Global:PSProfile.CommandAliases.GetEnumerator() | Where-Object {$_.Key -in $Alias}
        }
        else {
            Write-Verbose "Getting all command aliases from `$PSProfile.CommandAliases"
            $Global:PSProfile.CommandAliases
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileCommandAlias -ParameterName Alias -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.CommandAliases.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
