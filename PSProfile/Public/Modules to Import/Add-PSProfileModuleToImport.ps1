function Add-PSProfileModuleToImport {
    <#
    .SYNOPSIS
    Adds a module to import during PSProfile import.

    .DESCRIPTION
    Adds a module to import during PSProfile import.

    .PARAMETER Name
    The name of the module to import.

    .PARAMETER Prefix
    Add the specified prefix to the nouns in the names of imported module members.

    .PARAMETER MinimumVersion
    Import only a version of the module that is greater than or equal to the specified value. If no version qualifies, Import-Module generates an error.

    .PARAMETER RequiredVersion
    Import only the specified version of the module. If the version is not installed, Import-Module generates an error.

    .PARAMETER ArgumentList
    Specifies arguments (parameter values) that are passed to a script module during the Import-Module command. Valid only when importing a script module.

    .PARAMETER Force
    If the module already exists in $PSProfile.ModulesToImport, use -Force to overwrite the existing value.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileModuleToImport -Name posh-git -RequiredVersion '0.7.3' -Save

    Specifies to import posh-git version 0.7.3 during PSProfile import then saves the updated configuration.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String[]]
        $Name,
        [Parameter()]
        [String]
        $Prefix,
        [Parameter()]
        [String]
        $MinimumVersion,
        [Parameter()]
        [String]
        $RequiredVersion,
        [Parameter()]
        [Object[]]
        $ArgumentList,
        [Parameter()]
        [Switch]
        $Force,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($mod in $Name) {
            if (-not $Force -and $null -ne ($Global:PSProfile.ModulesToImport | Where-Object {$_.Name -eq $mod})) {
                Write-Error "Unable to add module to `$PSProfile.ModulesToImport as it already exists. Use -Force to overwrite the existing value if desired."
            }
            else {
                $moduleParams = @{
                    Name = $mod
                }
                $PSBoundParameters.GetEnumerator() | Where-Object {$_.Key -in @('Prefix','MinimumVersion','RequiredVersion','ArgumentList')} | ForEach-Object {
                    $moduleParams[$_.Key] = $_.Value
                }
                Write-Verbose "Adding '$mod' to `$PSProfile.ModulesToImport"
                [hashtable[]]$final = @($moduleParams)
                $Global:PSProfile.ModulesToImport | Where-Object {$_.Name -ne $mod} | ForEach-Object {
                    $final += $_
                }
                $Global:PSProfile.ModulesToImport = $final
                if ($Save) {
                    Save-PSProfile
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Add-PSProfileModuleToImport -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-Module "$wordToComplete*" -ListAvailable | Select-Object -ExpandProperty Name | Sort-Object -Unique | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
