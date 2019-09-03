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

    .PARAMETER NoRefresh
    If $true, skips reloading your PSProfile after updating.

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
        $NoRefresh,
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
            $temp = @()
            $Global:PSProfile.Plugins | Where-Object {$_.Name -ne $pName} | ForEach-Object {
                $temp += $_
            }
            $temp += $plugin
            $Global:PSProfile.Plugins = $temp
        }
        if ($Save) {
            Save-PSProfile
        }
        if (-not $NoRefresh) {
            Import-PSProfile -Verbose:$false
        }
    }
}

Register-ArgumentCompleter -CommandName Add-PSProfilePlugin -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.PluginPaths | Get-ChildItem | Select-Object -ExpandProperty BaseName -Unique | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
