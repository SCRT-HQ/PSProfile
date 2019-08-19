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
        [String]
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
        if (-not $Force -and $null -ne ($Global:PSProfile.ModulesToInstall | Where-Object {$_ -eq [hashtable] -and $_.Name -eq $Name})) {
            Write-Error "Unable to add module to `$PSProfile.ModulesToInstall as it already exists. Use -Force to overwrite the existing value if desired."
        }
        else {
            $moduleParams = $PSBoundParameters
            foreach ($key in $moduleParams.Keys | Where-Object {$_ -notin @('Verbose','Confirm',((Get-Command Install-Module).Parameters.Keys))}) {
                $moduleParams.Remove($key)
            }
            Write-Verbose "Adding '$Name' to `$PSProfile.ModulesToInstall"
            $Global:PSProfile.ModulesToInstall += $moduleParams
        }
    }
}
