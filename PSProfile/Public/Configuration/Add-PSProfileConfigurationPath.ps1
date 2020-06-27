function Add-PSProfileConfigurationPath {
    <#
    .SYNOPSIS
    Adds a ConfigurationPath to your PSProfile to import during PSProfile load.

    .DESCRIPTION
    Adds a ConfigurationPath to your PSProfile to import during PSProfile load. Useful for synced configurations.

    .PARAMETER Path
    The path of the script to add to your $PSProfile.ConfigurationPaths.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileConfigurationPath -Path ~\SyncConfiguration.psd1 -Save

    Adds the configuration 'SyncConfiguration.ps1' to $PSProfile.ConfigurationPaths and saves the configuration after updating.

    .EXAMPLE
    Get-ChildItem .\PSProfileConfigurations -Recurse -File | Add-PSProfileConfigurationPath -Verbose

    Adds all psd1 files under the PSProfileConfigurations folder to $PSProfile.ConfigurationPaths but does not save to allow inspection. Call Save-PSProfile after to save the results if satisfied.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [String[]]
        $Path,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($p in $Path) {
            if ($p -match '\.psd1$') {
                $fP = (Resolve-Path $p).Path
                if ($Global:PSProfile.ConfigurationPaths -notcontains $fP) {
                    Write-Verbose "Adding ConfigurationPath to PSProfile: $fP"
                    $Global:PSProfile.ConfigurationPaths += $fP
                }
                else {
                    Write-Verbose "ConfigurationPath already in PSProfile: $fP"
                }
            }
            else {
                Write-Verbose "Skipping non-psd1 file: $fP"
            }
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}
