function Get-PSProfilePlugin {
    <#
    .SYNOPSIS
    Gets a Plugin from $PSProfile.Plugins.

    .DESCRIPTION
    Gets a Plugin from $PSProfile.Plugins.

    .PARAMETER Name
    The name of the Plugin to get from $PSProfile.Plugins.

    .EXAMPLE
    Get-PSProfilePlugin -Name PSProfile.Prompt

    Gets PSProfile.Prompt from $PSProfile.Plugins

    .EXAMPLE
    Get-PSProfilePlugin

    Gets the list of Plugins from $PSProfile.Plugins
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Name
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Name')) {
            Write-Verbose "Getting Plugin '$Name' from `$PSProfile.Plugins"
            $Global:PSProfile.Plugins | Where-Object {$_.Name -in $Name}
        }
        else {
            Write-Verbose "Getting all Plugins from `$PSProfile.Plugins"
            $Global:PSProfile.Plugins
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfilePlugin -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Plugins | ForEach-Object {$_.Name} | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
