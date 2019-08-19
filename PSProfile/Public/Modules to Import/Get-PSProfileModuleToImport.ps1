function Get-PSProfileModuleToImport {
    <#
    .SYNOPSIS
    Gets a module from $PSProfile.ModulesToImport.

    .DESCRIPTION
    Gets a module from $PSProfile.ModulesToImport.

    .PARAMETER Name
    The name of the module to get from $PSProfile.ModulesToImport.

    .EXAMPLE
    Get-PSProfileModuleToImport -Name posh-git

    Gets posh-git from $PSProfile.ModulesToImport

    .EXAMPLE
    Get-PSProfileModuleToImport

    Gets the list of modules to import from $PSProfile.ModulesToImport
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Name
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Name')) {
            Write-Verbose "Getting ModuleToImport '$Name' from `$PSProfile.ModulesToImport"
            $Global:PSProfile.ModulesToImport | Where-Object {$_ -in $Name -or $_.Name -in $Name}
        }
        else {
            Write-Verbose "Getting all command aliases from `$PSProfile.ModulesToImport"
            $Global:PSProfile.ModulesToImport
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileModuleToImport -ParameterName Name -ScriptBlock {
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
