function Get-MyCreds {
    <#
    .SYNOPSIS
    Gets a credential object from the PSProfile Vault. Defaults to getting your current user's PSCredentials if stored in the Vault.

    .DESCRIPTION
    Gets a credential object from the PSProfile Vault. Defaults to getting your current user's PSCredentials if stored in the Vault.

    .PARAMETER Item
    The name of the Secret you would like to retrieve from the Vault.

    .PARAMETER IncludeDomain
    If $true, prepends the domain found in $env:USERDOMAIN to the Username on the PSCredential object before returning it. If not currently in a domain, prepends the MachineName instead.

    .EXAMPLE
    Get-MyCreds

    Gets the current user's PSCredentials from the Vault.

    .EXAMPLE
    Invoke-Command -ComputerName Server01 -Credential (Creds)

    Passes your current user credentials via the `Creds` alias to the Credential parameter of Invoke-Command to make a call against Server01 using your PSCredential

    .EXAMPLE
    Invoke-Command -ComputerName Server01 -Credential (Get-MyCreds SvcAcct07)

    Passes the credentials for account SvcAcct07 to the Credential parameter of Invoke-Command to make a call against Server01 using a different PSCredential than your own.
    #>
    [OutputType('PSCredential')]
    [CmdletBinding()]
    Param(
        [parameter(Mandatory = $false,Position = 0)]
        [String]
        $Item = $(if ($env:USERNAME) {
                $env:USERNAME
            }
            elseif ($env:USER) {
                $env:USER
            }),
        [parameter(Mandatory = $false)]
        [Alias('d','Domain')]
        [Switch]
        $IncludeDomain
    )
    Process {
        if ($Item) {
            Write-Verbose "Checking Credential Vault for user '$Item'"
            if ($creds = $global:PSProfile.Vault.GetSecret($Item)) {
                Write-Verbose "Found item in CredStore"
                if (!$env:USERDOMAIN) {
                    $env:USERDOMAIN = [System.Environment]::MachineName
                }
                if ($IncludeDomain -and $creds.UserName -notlike "$($env:USERDOMAIN)\*") {
                    $creds = New-Object PSCredential "$($env:USERDOMAIN)\$($creds.UserName)",$creds.Password
                }
                return $creds
            }
            else {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        ([System.Management.Automation.ItemNotFoundException]"Could not find secret item '$Item' in the PSProfileVault"),
                        'PSProfile.Vault.SecretNotFound',
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $global:PSProfile
                    )
                )
            }
        }
        else {
            $global:PSProfile.Vault._secrets
        }
    }
}

Register-ArgumentCompleter -CommandName Get-MyCreds -ParameterName Item -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Vault._secrets.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
