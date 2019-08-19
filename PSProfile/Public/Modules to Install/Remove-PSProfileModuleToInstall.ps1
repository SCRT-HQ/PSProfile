function Remove-PSProfileModuleToInstall {
    <#
    .SYNOPSIS
    Removes a module from $PSProfile.ModulesToInstall.

    .DESCRIPTION
    Removes a module from $PSProfile.ModulesToInstall.

    .PARAMETER Name
    The name of the module to remove from $PSProfile.ModulesToInstall.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileModuleToInstall -Name posh-git -Save

    Removes posh-git from $PSProfile.ModulesToInstall then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String]
        $Name,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$Name' from `$PSProfile.ModulesToInstall")) {
            Write-Verbose "Removing '$Name' from `$PSProfile.ModulesToInstall"
            $Global:PSProfile.ModulesToInstall = $Global:PSProfile.ModulesToInstall | Where-Object {($_ -is [hashtable] -and $_.Name -ne $Name) -or ($_ -is [string] -and $_ -ne $Name)}
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileModuleToInstall -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.ModulesToInstall | ForEach-Object {
        if ($_ -is [hashtable]) {
            $_.Name
        }
        else {
            $_
        }
    } | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
