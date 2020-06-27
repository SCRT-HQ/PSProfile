function Remove-PSProfileConfigurationPath {
    <#
    .SYNOPSIS
    Removes a configuration path from $PSProfile.ConfigurationPaths.

    .DESCRIPTION
    Removes a configuration path from $PSProfile.ConfigurationPaths.

    .PARAMETER Path
    The path to remove from $PSProfile.ConfigurationPaths.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileConfigurationPath -Name ~\PSProfile\MyConfig.psd1 -Save

    Removes the path '~\PSProfile\MyConfig.psd1' from $PSProfile.ConfigurationPaths then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String]
        $Path,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$Path' from `$PSProfile.ConfigurationPaths")) {
            Write-Verbose "Removing '$Path' from `$PSProfile.ConfigurationPaths"
            $Global:PSProfile.ConfigurationPaths = $Global:PSProfile.ConfigurationPaths | Where-Object {$_ -notin @($Path,(Resolve-Path $Path).Path)}
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileConfigurationPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.ConfigurationPaths | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
