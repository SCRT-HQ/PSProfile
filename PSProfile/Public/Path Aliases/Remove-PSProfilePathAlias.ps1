function Remove-PSProfilePathAlias {
    <#
    .SYNOPSIS
    Removes an alias from $PSProfile.PathAliases.

    .DESCRIPTION
    Removes an alias from $PSProfile.PathAliases.

    .PARAMETER Alias
    The alias to remove from $PSProfile.PathAliases.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfilePathAlias -Alias Workplace -Save

    Removes the alias 'Workplace' from $PSProfile.PathAliases then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String]
        $Alias,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$Alias' from `$PSProfile.PathAliases")) {
            Write-Verbose "Removing '$Alias' from `$PSProfile.PathAliases"
            $Global:PSProfile.PathAliases.Remove($Alias)
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfilePathAlias -ParameterName Alias -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.PathAliases.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
