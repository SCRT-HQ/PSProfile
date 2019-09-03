function Add-PSProfileModuleToInstall {
    <#
    .SYNOPSIS
    Adds a module to ensure is installed in the CurrentUser scope. Module installations are handled via background job during PSProfile import.

    .DESCRIPTION
    Adds a module to ensure is installed in the CurrentUser scope. Module installations are handled via background job during PSProfile import.

    .PARAMETER Name
    The name of the module to install.

    .PARAMETER Repository
    The repository to install the module from. Defaults to the PowerShell Gallery.

    .PARAMETER MinimumVersion
    The minimum version of the module to install.

    .PARAMETER RequiredVersion
    The required version of the module to install.

    .PARAMETER AcceptLicense
    If $true, accepts the license for the module if necessary.

    .PARAMETER AllowPrerelease
    If $true, allows installation of prerelease versions of the module.

    .PARAMETER Force
    If the module already exists in $PSProfile.ModulesToInstall, use -Force to overwrite the existing value.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileModuleToInstall -Name posh-git -RequiredVersion '0.7.3' -Save

    Specifies to install posh-git version 0.7.3 during PSProfile import if missing then saves the updated configuration.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String[]]
        $Name,
        [Parameter()]
        [String]
        $Repository,
        [Parameter()]
        [String]
        $MinimumVersion,
        [Parameter()]
        [String]
        $RequiredVersion,
        [Parameter()]
        [Switch]
        $AcceptLicense,
        [Parameter()]
        [Switch]
        $AllowPrerelease,
        [Parameter()]
        [Switch]
        $Force,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($mod in $Name) {
            if (-not $Force -and $null -ne ($Global:PSProfile.ModulesToInstall | Where-Object {$_.Name -eq $mod})) {
                Write-Error "Unable to add module '$mod' to `$PSProfile.ModulesToInstall as it already exists. Use -Force to overwrite the existing value if desired."
            }
            else {
                $moduleParams = @{
                    Name = $mod
                }
                $PSBoundParameters.GetEnumerator() | Where-Object {$_.Key -in @('Repository','MinimumVersion','RequiredVersion','AcceptLicense','AllowPrerelease','Force')} | ForEach-Object {
                    $moduleParams[$_.Key] = $_.Value
                }
                Write-Verbose "Adding '$mod' to `$PSProfile.ModulesToInstall"
                [hashtable[]]$final = @($moduleParams)
                $Global:PSProfile.ModulesToInstall | Where-Object {$_.Name -ne $mod} | ForEach-Object {
                    $final += $_
                }
                $Global:PSProfile.ModulesToInstall = $final
                if ($Save) {
                    Save-PSProfile
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Add-PSProfileModuleToInstall -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-Module "$wordToComplete*" -ListAvailable | Select-Object -ExpandProperty Name | Sort-Object -Unique | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
