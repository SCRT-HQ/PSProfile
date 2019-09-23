function Remove-PSProfileInitScript {
    <#
    .SYNOPSIS
    Removes an InitScript from $PSProfile.InitScripts.

    .DESCRIPTION
    Removes an InitScript from $PSProfile.InitScripts.

    .PARAMETER Name
    The name of the InitScript to remove from $PSProfile.InitScripts.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileInitScript -Name PSReadlineSettings,DevOpsTools

    Removes the InitScripts 'PSReadlineSettings' and 'DevOpsTools' from $PSProfile.InitScripts.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]
        $Name,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($initScript in $Name) {
            if ($Global:PSProfile.InitScripts.Contains($initScript)) {
                if ($PSCmdlet.ShouldProcess("Removing InitScript '$initScript' from `$PSProfile.InitScripts")) {
                    Write-Verbose "Removing InitScript '$initScript' from `$PSProfile.InitScripts"
                    $Global:PSProfile.InitScripts.Remove($initScript)
                }
            }
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileInitScript -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.InitScripts.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
