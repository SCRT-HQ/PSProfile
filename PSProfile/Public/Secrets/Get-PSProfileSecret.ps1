function Get-PSProfileSecret {
    <#
    .SYNOPSIS
    Gets a Secret from the $PSProfile.Vault.

    .DESCRIPTION
    Gets a Secret from the $PSProfile.Vault.

    .PARAMETER Name
    The name of the Secret you would like to retrieve from the Vault. If excluded, returns the entire Vault contents.

    .PARAMETER AsPlainText
    If $true and Confirm:$true, returns the decrypted password if the secret is a PSCredential object or the plain-text string if a SecureString. Requires confirmation.

    .PARAMETER Force
    If $true and AsPlainText is $true, bypasses Confirm prompt and returns the plain-text password or decrypted SecureString.

    .EXAMPLE
    Get-PSProfileSecret -Name MyApiKey

    Gets the Secret named 'MyApiKey' from the $PSProfile.Vault.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param(
        [parameter(Position = 0)]
        [String]
        $Name,
        [parameter()]
        [Switch]
        $AsPlainText,
        [parameter()]
        [Switch]
        $Force
    )
    Process {
        if ($Name) {
            Write-Verbose "Getting Secret '$Name' from `$PSProfile.Vault"
            if ($sec = $global:PSProfile.Vault._secrets[$Name]) {
                if ($AsPlainText -and ($Force -or $PSCmdlet.ShouldProcess("Return plain-text value for Secret '$Name'"))) {
                    if ($sec -is [pscredential]) {
                        [PSCustomObject]@{
                            UserName = $sec.UserName
                            Password = $sec.GetNetworkCredential().Password
                        }
                    }
                    else {
                        Get-DecryptedValue $sec
                    }
                }
                else {
                    $sec
                }
            }
        }
        else {
            Write-Verbose "Getting all Secrets"
            $global:PSProfile.Vault._secrets
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileSecret -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Vault._secrets.Keys | Where-Object {$_ -notin @('GitCredentials','PSCredentials','SecureStrings') -and $_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
