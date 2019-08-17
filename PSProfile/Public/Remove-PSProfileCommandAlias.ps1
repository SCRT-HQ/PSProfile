function Remove-PSProfileCommandAlias {
    <#
    .SYNOPSIS
    Removes an alias from $PSProfile.CommandAliases.

    .DESCRIPTION
    Removes an alias from $PSProfile.CommandAliases.

    .PARAMETER Alias
    The alias to remove from $PSProfile.CommandAliases.

    .PARAMETER Force
    If $true, also removes the alias itself from the session if it exists.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileCommandAlias -Alias code -Save

    Removes the alias 'code' from $PSProfile.CommandAliases then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String]
        $Alias,
        [Parameter()]
        [Switch]
        $Force,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$Alias' from `$PSProfile.CommandAliases")) {
            Write-Verbose "Removing '$Alias' from `$PSProfile.CommandAliases"
            $Global:PSProfile.CommandAliases.Remove($Alias)
            if ($Force -and $null -ne (Get-Alias "$Alias*")) {
                Write-Verbose "Removing Alias: $Alias"
                Remove-Item $LinkPath -Force
            }
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileCommandAlias -ParameterName Alias -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.CommandAliases.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
