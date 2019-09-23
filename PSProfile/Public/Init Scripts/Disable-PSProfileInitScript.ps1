function Disable-PSProfileInitScript {
    <#
    .SYNOPSIS
    Disables an enabled InitScript in $PSProfile.InitScripts.

    .DESCRIPTION
    Disables an enabled InitScript in $PSProfile.InitScripts.

    .PARAMETER Name
    The name of the InitScript to disable in $PSProfile.InitScripts.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Disable-PSProfileInitScript -Name PSReadlineSettings,DevOpsTools

    Disables the InitScripts 'PSReadlineSettings' and 'DevOpsTools' in $PSProfile.InitScripts.
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
            Write-Verbose "Disabling InitScript '$N' in `$PSProfile.InitScripts"
            if ($Global:PSProfile.InitScripts.Contains($N)) {
                $Global:PSProfile.InitScripts[$N]['Enabled'] = $false
            }
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}

Register-ArgumentCompleter -CommandName Disable-PSProfileInitScript -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.InitScripts.GetEnumerator() | Where-Object {$_.Value.Enabled -and $_.Key -like "$wordToComplete*"} | Select-Object -ExpandProperty Key | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
