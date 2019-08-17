function Remove-PSProfileSymbolicLink {
    <#
    .SYNOPSIS
    Removes a Symbolic Link from $PSProfile.SymbolicLinks.

    .DESCRIPTION
    Removes a PSProfile Plugin from $PSProfile.SymbolicLinks.

    .PARAMETER LinkPath
    The path of the symbolic link to remove from $PSProfile.SymbolicLinks.

    .PARAMETER Force
    If $true, also removes the SymbolicLink itself from the OS if it exists.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileSymbolicLink -LinkPath 'C:\workstation' -Force -Save

    Removes the SymbolicLink 'C:\workstation' from $PSProfile.SymbolicLinks, removes the  then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String]
        $LinkPath,
        [Parameter()]
        [Switch]
        $Force,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$LinkPath' from `$PSProfile.SymbolicLinks")) {
            Write-Verbose "Removing '$LinkPath' from `$PSProfile.SymbolicLinks"
            @($LinkPath,(Resolve-Path $LinkPath).Path) | Select-Object -Unique | ForEach-Object {
                if ($Global:PSProfile.SymbolicLinks.ContainsKey($_)) {
                    $Global:PSProfile.SymbolicLinks.Remove($_)
                }
            }
            if ($Force -and (Test-Path $LinkPath)) {
                Write-Verbose "Removing SymbolicLink: $LinkPath"
                Remove-Item $LinkPath -Force
            }
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileSymbolicLink -ParameterName LinkPath -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.SymbolicLinks.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
