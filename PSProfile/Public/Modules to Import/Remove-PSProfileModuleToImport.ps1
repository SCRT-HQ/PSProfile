function Remove-PSProfileModuleToImport {
    <#
    .SYNOPSIS
    Removes a module from $PSProfile.ModulesToImport.

    .DESCRIPTION
    Removes a module from $PSProfile.ModulesToImport.

    .PARAMETER Name
    The name of the module to remove from $PSProfile.ModulesToImport.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileModuleToImport -Name posh-git -Save

    Removes posh-git from $PSProfile.ModulesToImport then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String[]]
        $Name,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($mod in $Name) {
            if ($PSCmdlet.ShouldProcess("Removing '$mod' from `$PSProfile.ModulesToImport")) {
                Write-Verbose "Removing '$mod' from `$PSProfile.ModulesToImport"
                $Global:PSProfile.ModulesToImport = $Global:PSProfile.ModulesToImport | Where-Object {($_ -is [hashtable] -and $_.Name -ne $mod) -or ($_ -is [string] -and $_ -ne $mod)}
                if ($Save) {
                    Save-PSProfile
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileModuleToImport -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.ModulesToImport | ForEach-Object {
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
