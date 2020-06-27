function Get-PSProfileConfigurationPath {
    <#
    .SYNOPSIS
    Gets a configuration path from $PSProfile.ConfigurationPaths.

    .DESCRIPTION
    Gets a configuration path from $PSProfile.ConfigurationPaths.

    .PARAMETER Path
    The configuration path to get from $PSProfile.ConfigurationPaths.

    .EXAMPLE
    Get-PSProfileConfigurationPath -Path E:\Git\MyPSProfileConfig.psd1

    Gets the path 'E:\Git\MyPSProfileConfig.psd1' from $PSProfile.ConfigurationPaths

    .EXAMPLE
    Get-PSProfileConfigurationPath

    Gets the list of configuration paths from $PSProfile.ConfigurationPaths
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Path
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Path')) {
            Write-Verbose "Getting configuration path '$Path' from `$PSProfile.ConfigurationPaths"
            $Global:PSProfile.ConfigurationPaths | Where-Object {$_ -match "($(($Path | ForEach-Object {[regex]::Escape($_)}) -join '|'))"}
        }
        else {
            Write-Verbose "Getting all configuration paths from `$PSProfile.ConfigurationPaths"
            $Global:PSProfile.ConfigurationPaths
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileConfigurationPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.ConfigurationPaths | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
