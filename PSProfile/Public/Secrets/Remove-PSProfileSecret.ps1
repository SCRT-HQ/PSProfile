function Remove-PSProfileSecret {
    <#
    .SYNOPSIS
    Removes a Secret from $PSProfile.Vault.

    .DESCRIPTION
    Removes a Secret from $PSProfile.Vault.

    .PARAMETER Name
    The Secret's Name or UserName to remove from the Vault.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileSecret -Name $env:USERNAME -Save

    Removes the current user's stored credentials from the $PSProfile.Vault, then saves the configuration after updating.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [Alias('UserName')]
        [String]
        $Name,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing '$Name' from `$PSProfile.Vault")) {
            if ($Global:PSProfile.Vault._secrets.ContainsKey($Name)) {
                Write-Verbose "Removing '$Name' from `$PSProfile.Vault"
                $Global:PSProfile.Vault._secrets.Remove($Name) | Out-Null
            }
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileSecret -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Vault._secrets.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
