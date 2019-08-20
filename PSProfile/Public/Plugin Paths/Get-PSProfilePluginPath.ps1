function Get-PSProfilePluginPath {
    <#
    .SYNOPSIS
    Gets a plugin path from $PSProfile.PluginPaths.

    .DESCRIPTION
    Gets a plugin path from $PSProfile.PluginPaths.

    .PARAMETER Path
    The plugin path to get from $PSProfile.PluginPaths.

    .EXAMPLE
    Get-PSProfilePluginPath -Path E:\MyPSProfilePlugins

    Gets the path 'E:\MyPSProfilePlugins' from $PSProfile.PluginPaths

    .EXAMPLE
    Get-PSProfilePluginPath

    Gets the list of plugin paths from $PSProfile.PluginPaths
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Path
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Path')) {
            Write-Verbose "Getting plugin path '$Path' from `$PSProfile.PluginPaths"
            $Global:PSProfile.PluginPaths | Where-Object {$_ -in $Path}
        }
        else {
            Write-Verbose "Getting all plugin paths from `$PSProfile.PluginPaths"
            $Global:PSProfile.PluginPaths
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfilePluginPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.PluginPaths | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
