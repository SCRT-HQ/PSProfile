function Add-PSProfilePluginPath {
    <#
    .SYNOPSIS
    Adds a PluginPath to your PSProfile to search for PSProfile plugins in during module load.

    .DESCRIPTION
    Adds a PluginPath to your PSProfile to search for PSProfile plugins in during module load.

    .PARAMETER Path
    The path of the folder to add to your $PSProfile.PluginPaths. This path should contain PSProfile.Plugins

    .PARAMETER NoRefresh
    If $true, skips reloading your PSProfile after updating.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfilePluginPath -Path ~\PSProfilePlugins -Save

    Adds the folder ~\PSProfilePlugins to $PSProfile.PluginPaths and saves the configuration after updating.

    .EXAMPLE
    Add-PSProfilePluginPath C:\PSProfilePlugins -Verbose

    Adds the path C:\PSProfilePlugins to your $PSProfile.PluginPaths, refreshes your PathDict but does not save. Call Save-PSProfile after if satisfied with the results.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateScript({if ((Get-Item $_).PSIsContainer){$true}else{throw "$_ is not a folder! Please add only folders to this PSProfile property. If you would like to add a script, use Add-PSProfileScriptPath instead."}})]
        [Alias('FullName')]
        [String[]]
        $Path,
        [Parameter()]
        [Switch]
        $NoRefresh,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($p in $Path) {
            $fP = (Resolve-Path $p).Path
            [string[]]$base = @()
            $Global:PSProfile.PluginPaths | Where-Object {-not [string]::IsNullOrEmpty($_)} | ForEach-Object {
                $base += $_
            }
            if ($Global:PSProfile.PluginPaths -notcontains $fP) {
                Write-Verbose "Adding PluginPath to PSProfile: $fP"
                $base += $fP
            }
            else {
                Write-Verbose "PluginPath already in PSProfile: $fP"
            }
            $Global:PSProfile.PluginPaths = $base
        }
        if ($Save) {
            Save-PSProfile
        }
        if (-not $NoRefresh) {
            Import-PSProfile -Verbose:$false
        }
    }
}
