function Enable-PSProfileInitScript {
    <#
    .SYNOPSIS
    Enables a disabled InitScript in $PSProfile.InitScripts.

    .DESCRIPTION
    Enables a disabled InitScript in $PSProfile.InitScripts.

    .PARAMETER Name
    The name of the InitScript to enable in $PSProfile.InitScripts.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Enable-PSProfileInitScript -Name PSReadlineSettings,DevOpsTools

    Enables the InitScripts 'PSReadlineSettings' and 'DevOpsTools' in $PSProfile.InitScripts.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String[]]
        $Name,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($N in $Name) {
            Write-Verbose "Enabling InitScript '$N' in `$PSProfile.InitScripts"
            if ($Global:PSProfile.InitScripts.Contains($N)) {
                $Global:PSProfile.InitScripts[$N]['Enabled'] = $true
            }
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}

Register-ArgumentCompleter -CommandName Enable-PSProfileInitScript -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.InitScripts.GetEnumerator() | Where-Object {-not $_.Value.Enabled -and $_.Key -like "$wordToComplete*"} | Select-Object -ExpandProperty Key | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
