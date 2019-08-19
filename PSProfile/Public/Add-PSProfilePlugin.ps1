function Add-PSProfilePlugin {
    <#
    .SYNOPSIS
    Adds a PSProfile Plugin to the list of plugins. If the plugin already exists, it will overwrite it. Re-imports your PSProfile once done to load any newly added plugins.

    .DESCRIPTION
    Adds a PSProfile Plugin to the list of plugins. If the plugin already exists, it will overwrite it. Re-imports your PSProfile once done to load any newly added plugins.

    .PARAMETER Name
    The name of the Plugin to add, e.g. 'PSProfile.PowerTools'

    .PARAMETER ArgumentList
    Any arguments that need to be passed to the plugin on import, such as a hashtable to process.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfilePlugin -Name 'PSProfile.PowerTools' -Save

    Adds the included plugin 'PSProfile.PowerTools' to your PSProfile and saves it so it persists.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String[]]
        $Name,
        [Parameter(Position = 1)]
        [Object]
        $ArgumentList,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($pName in $Name) {
            Write-Verbose "Adding plugin '$pName' to `$PSProfile.Plugins"
            $plugin = @{
                Name = $pName
            }
            if ($PSBoundParameters.ContainsKey('ArgumentList')) {
                $plugin['ArgumentList'] = $ArgumentList
            }
            $temp = $Global:PSProfile.Plugins | Where-Object {$_.Name -ne $pName}
            $temp += $plugin
            $Global:PSProfile.Plugins = $temp
        }
        if ($Save) {
            Save-PSProfile
        }
        Import-PSProfile -Verbose:$false
    }
}
