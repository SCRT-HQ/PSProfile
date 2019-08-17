function Remove-PSProfilePlugin {
    <#
    .SYNOPSIS
    Removes a PSProfile Plugin from $PSProfile.Plugins.

    .DESCRIPTION
    Removes a PSProfile Plugin from $PSProfile.Plugins.

    .PARAMETER Name
    The name of the Plugin to remove from $PSProfile.Plugins.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfilePlugin -Name 'PSProfile.PowerTools' -Save

    Removes the Plugin 'PSProfile.PowerTools' from $PSProfile.Plugins then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [String]
        $Name,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$Name' from `$PSProfile.Plugins")) {
            Write-Verbose "Removing '$Name' from `$PSProfile.Plugins"
            $Global:PSProfile.Plugins = $Global:PSProfile.Plugins | Where-Object {$_.Name -ne $Name}
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfilePlugin -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Plugins.Name | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
