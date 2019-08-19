function Import-PSProfileConfiguration {
    <#
    .SYNOPSIS
    Imports a Configuration.psd1 file from a specific path and overwrites differing values on the PSProfile, if any.

    .DESCRIPTION
    Imports a Configuration.psd1 file from a specific path and overwrites differing values on the PSProfile, if any.

    .PARAMETER Path
    The path to the PSD1 file you would like to import.

    .PARAMETER Save
    If $true, saves the updated PSProfile after importing.

    .EXAMPLE
    Import-PSProfileConfiguration -Path ~\MyProfile.psd1 -Save
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [String]
        $Path,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        $Path = (Resolve-Path $Path).Path
        Write-Verbose "Loading PSProfile configuration from path: $Path"
        $Global:PSProfile._loadAdditionalConfiguration($Path)
        if ($Save) {
            Save-PSProfile
        }
    }
}
