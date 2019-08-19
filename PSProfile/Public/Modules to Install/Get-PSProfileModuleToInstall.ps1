function Get-PSProfileModuleToInstall {
    <#
    .SYNOPSIS
    Gets a module from $PSProfile.ModulesToInstall.

    .DESCRIPTION
    Gets a module from $PSProfile.ModulesToInstall.

    .PARAMETER Name
    The name of the module to get from $PSProfile.ModulesToInstall.

    .EXAMPLE
    Get-PSProfileModuleToInstall -Name posh-git

    Gets posh-git from $PSProfile.ModulesToInstall

    .EXAMPLE
    Get-PSProfileModuleToInstall

    Gets the list of modules to install from $PSProfile.ModulesToInstall
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Name
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Name')) {
            Write-Verbose "Getting ModuleToImport '$Name' from `$PSProfile.ModulesToInstall"
            $Global:PSProfile.ModulesToInstall | Where-Object {$_ -in $Name -or $_.Name -in $Name}
        }
        else {
            Write-Verbose "Getting all command aliases from `$PSProfile.ModulesToInstall"
            $Global:PSProfile.ModulesToInstall
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileModuleToInstall -ParameterName Name -ScriptBlock {
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
