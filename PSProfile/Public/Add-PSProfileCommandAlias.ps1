function Add-PSProfileCommandAlias {
    <#
    .SYNOPSIS
    Adds a command alias to your PSProfile configuration to set during PSProfile import.

    .DESCRIPTION
    Adds a command alias to your PSProfile configuration to set during PSProfile import.

    .PARAMETER Alias
    The alias to set for the command.

    .PARAMETER Command
    The name of the command to set the alias for.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileCommandAlias -Alias code -Command Open-Code -Save

    Adds the command alias 'code' targeting the command 'Open-Code' and saves your PSProfile configuration.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Alias,
        [Parameter(Mandatory,Position = 1)]
        [String]
        $Command,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        Write-Verbose "Adding alias '$Alias' for command '$Command' to PSProfile"
        New-Alias -Name $Alias -Value $Command -Option AllScope -Scope Global
        $Global:PSProfile.CommandAliases[$Alias] = $Command
        if ($Save) {
            Save-PSProfile
        }
    }
}

Register-ArgumentCompleter -CommandName Add-PSProfileCommandAlias -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Command "$wordToComplete*").Name | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
