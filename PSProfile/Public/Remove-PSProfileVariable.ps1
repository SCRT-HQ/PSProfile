function Remove-PSProfileVariable {
    <#
    .SYNOPSIS
    Removes a Symbolic Link from $PSProfile.Variables.

    .DESCRIPTION
    Removes a PSProfile Plugin from $PSProfile.Variables.

    .PARAMETER Name
    The path of the symbolic link to remove from $PSProfile.Variables.

    .PARAMETER Scope
    The scope of the variable to remove between Environment or Global.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfilePlugin -Name 'PSProfile.PowerTools' -Save

    Removes the Plugin 'PSProfile.PowerTools' from $PSProfile.Variables then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('Environment','Global')]
        [String]
        $Scope,
        [Parameter(Mandatory,Position = 1)]
        [String]
        $Name,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing $Scope variable '$Name' from `$PSProfile.Variables")) {
            Write-Verbose "Removing $Scope variable '$Name' from `$PSProfile.Variables"
            if ($Global:PSProfile.Variables[$Scope].ContainsKey($Name)) {
                $Global:PSProfile.Variables[$Scope].Remove($Name)
            }
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileVariable -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Variables[$fakeBoundParameter.Scope].Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
