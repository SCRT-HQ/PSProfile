function Export-PSProfileConfiguration {
    <#
    .SYNOPSIS
    Exports the PSProfile configuration as a PSD1 file to the desired path.

    .DESCRIPTION
    Exports the PSProfile configuration as a PSD1 file to the desired path.

    .PARAMETER Path
    The existing folder or file path with PSD1 extension to export the configuration to. If a folder path is provided, the configuration will be exported to the path with the file name 'PSProfile.Configuration.psd1'.

    .PARAMETER Force
    If $true and the resolved file path exists, overwrite it with the current configuration.

    .EXAMPLE
    Export-PSProfileConfiguration ~\MyPSProfileConfig.psd1

    Exports the configuration to the specified path.

    .EXAMPLE
    Export-PSProfileConfiguration ~\MyScripts -Force

    Exports the configuration to the resolved path of '~\MyScripts\PSProfile.Configuration.psd1' and overwrites the file if it already exists.

    .NOTES
    *Any secrets stored in the `$PSProfile.Vault` will be exported, but will be unable to be decrypted on another machine or by another user on the same machine due to encryption via Data Protection API.*
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [ValidateScript({
            if ($_ -like '*.psd1') {
                $true
            }
            elseif ((Test-Path $_) -and (Get-Item $_).PSIsContainer) {
                $true
            }
            else {
                throw "The path provided was not an existing folder path or a file path ending in a PSD1 extension. Please provide either an existing folder to export the PSProfile configuration to or an exact file path ending in a PSD1 extension to export the configuration to. Path provided: $_"
            }
        })]
        [String]
        $Path,
        [Parameter()]
        [Switch]
        $Force
    )
    Process {
        if (Test-Path $Path) {
            $item = Get-Item $Path
            if ($item.PSIsContainer) {
                $finalPath = [System.IO.Path]::Combine($item.FullName,'PSProfile.Configuration.psd1')
            }
            else {
                if ($item.Extension -ne '.psd1') {
                    Write-Error "Please provide either a file path for a psd1"
                }
                else {
                    $finalPath = $item.FullName
                }
            }
        }
        else {
            $finalPath = $Path
        }
        if ((Test-Path $finalPath) -and -not $Force) {
            Write-Error "File path already exists: $finalPath. Use the -Force parameter to overwrite the contents with the current PSProfile configuration."
        }
        else {
            try {
                if (Test-Path $finalPath) {
                    Write-Verbose "Force specified! Removing existing file: $finalPath"
                    Remove-Item $finalPath -ErrorAction Stop
                }
                Write-Verbose "Importing metadata from path: $($Global:PSProfile.Settings.ConfigurationPath)"
                $metadata = Import-Metadata -Path $Global:PSProfile.Settings.ConfigurationPath -ErrorAction Stop
                Write-Verbose "Exporting cleaned PSProfile configuration to path: $finalPath"
                $metadata | Export-Metadata -Path $finalPath -ErrorAction Stop
            }
            catch {
                Write-Error $_
            }
        }
    }
}
