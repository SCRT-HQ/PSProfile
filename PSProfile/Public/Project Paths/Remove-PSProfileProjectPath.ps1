function Remove-PSProfileProjectPath {
    <#
    .SYNOPSIS
    Removes a Project Path from $PSProfile.ProjectPaths.

    .DESCRIPTION
    Removes a Project Path from $PSProfile.ProjectPaths.

    .PARAMETER Path
    The path to remove from $PSProfile.ProjectPaths.

    .PARAMETER NoRefresh
    If $true, skips refreshing your PSProfile after updating project paths.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileProjectPath -Name E:\Git -Save

    Removes the path 'E:\Git' from $PSProfile.ProjectPaths then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String]
        $Path,
        [Parameter()]
        [Switch]
        $NoRefresh,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$Path' from `$PSProfile.ProjectPaths")) {
            Write-Verbose "Removing '$Path' from `$PSProfile.ProjectPaths"
            $Global:PSProfile.ProjectPaths = $Global:PSProfile.ProjectPaths | Where-Object {$_ -notin @($Path,(Resolve-Path $Path).Path)}
            if (-not $NoRefresh) {
                Update-PSProfileConfig
            }
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileProjectPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.ProjectPaths | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
