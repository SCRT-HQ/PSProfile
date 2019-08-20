function Remove-PSProfilePluginPath {
    <#
    .SYNOPSIS
    Removes a Plugin Path from $PSProfile.PluginPaths.

    .DESCRIPTION
    Removes a Plugin Path from $PSProfile.PluginPaths.

    .PARAMETER Path
    The path to remove from $PSProfile.PluginPaths.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfilePluginPath -Name E:\MyPluginPaths -Save

    Removes the path 'E:\MyPluginPaths' from $PSProfile.PluginPaths then saves the updated configuration.
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
        if ($PSCmdlet.ShouldProcess("Removing '$Path' from `$PSProfile.PluginPaths")) {
            Write-Verbose "Removing '$Path' from `$PSProfile.PluginPaths"
            $Global:PSProfile.PluginPaths = $Global:PSProfile.PluginPaths | Where-Object {$_ -notin @($Path,(Resolve-Path $Path).Path)}
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfilePluginPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.PluginPaths | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
