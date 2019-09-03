function Remove-PSProfileVariable {
    <#
    .SYNOPSIS
    Removes a Variable from $PSProfile.Variables.

    .DESCRIPTION
    Removes a Variable from $PSProfile.Variables.

    .PARAMETER Name
    The name of the Variable to remove from $PSProfile.Variables.

    .PARAMETER Scope
    The scope of the Variable to remove between Environment or Global.

    .PARAMETER Force
    If $true, also removes the variable from the current session at the specified scope.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileVariable -Scope Environment -Name '~' -Save

    Removes the Environment variable '~' from $PSProfile.Variables then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('Environment','Global')]
        [String]
        $Scope,
        [Parameter(Mandatory,Position = 1)]
        [String[]]
        $Name,
        [Parameter()]
        [Switch]
        $Force,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($item in $Name) {
            if ($PSCmdlet.ShouldProcess("Removing $Scope variable '$item' from `$PSProfile.Variables")) {
                Write-Verbose "Removing $Scope variable '$item' from `$PSProfile.Variables"
                if ($Global:PSProfile.Variables[$Scope].ContainsKey($item)) {
                    $Global:PSProfile.Variables[$Scope].Remove($item)
                }
                if ($Force) {
                    switch ($Scope) {
                        Environment {
                            Remove-Item "Env:\$item"
                        }
                        Global {
                            Remove-Variable -Name $item -Scope Global
                        }
                    }
                }
            }
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileVariable -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Variables[$fakeBoundParameter.Scope].Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
