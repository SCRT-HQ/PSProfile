function Remove-PSProfileScriptPath {
    <#
    .SYNOPSIS
    Removes a Script Path from $PSProfile.ScriptPaths.

    .DESCRIPTION
    Removes a Script Path from $PSProfile.ScriptPaths.

    .PARAMETER Path
    The path to remove from $PSProfile.ScriptPaths.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileScriptPath -Name ~\Scripts\ProfileLoadScript.ps1 -Save

    Removes the path '~\Scripts\ProfileLoadScript.ps1' from $PSProfile.ScriptPaths then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String]
        $Path,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$Path' from `$PSProfile.ScriptPaths")) {
            Write-Verbose "Removing '$Path' from `$PSProfile.ScriptPaths"
            $Global:PSProfile.ScriptPaths = $Global:PSProfile.ScriptPaths | Where-Object {$_ -notin @($Path,(Resolve-Path $Path).Path)}
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileScriptPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.ScriptPaths | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
