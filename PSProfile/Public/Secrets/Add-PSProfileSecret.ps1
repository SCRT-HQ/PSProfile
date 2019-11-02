function Add-PSProfileSecret {
    <#
    .SYNOPSIS
    Adds a PSCredential object or named SecureString to the PSProfile Vault then saves the current PSProfile.

    .DESCRIPTION
    Adds a PSCredential object or named SecureString to the PSProfile Vault then saves the current PSProfile.

    .PARAMETER Credential
    The PSCredential to add to the Vault. PSCredentials are recallable by the UserName from the stored PSCredential object via either `Get-MyCreds` or `Get-PSProfileSecret -UserName $UserName`.

    .PARAMETER Name
    For SecureString secrets, the friendly name to store them as for easy recall later via `Get-PSProfileSecret`.

    .PARAMETER SecureString
    The SecureString to store as the provided Name for recall later.

    .PARAMETER Force
    If $true and the PSCredential's UserName or SecureString's Name already exists, it overwrites it. Defaults to $false to prevent accidentally overwriting existing secrets in the $PSProfile.Vault.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileSecret (Get-Credential) -Save

    Opens a Get-Credential window or prompt to enable entering credentials securely, then stores it in the Vault and saves your PSProfile configuration after updating.

    .EXAMPLE
    Add-PSProfileSecret -Name HomeApiKey -Value (ConvertTo-SecureString 1234567890xxx -AsPlainText -Force) -Save

    Stores the secret value '1234567890xxx' as the name 'HomeApiKey' in $PSProfile.Vault and saves your PSProfile configuration after updating.
    #>
    [CmdletBinding(DefaultParameterSetName = "PSCredential")]
    Param (
        [Parameter(Mandatory,ValueFromPipeline,Position = 0,ParameterSetName = "PSCredential")]
        [pscredential]
        $Credential,
        [Parameter(Mandatory,ParameterSetName = "SecureString")]
        [string]
        $Name,
        [Parameter(Mandatory,ParameterSetName = "SecureString")]
        [securestring]
        $SecureString,
        [Parameter()]
        [Switch]
        $Force,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            PSCredential {
                if ($Force -or -not $Global:PSProfile.Vault._secrets.ContainsKey($Credential.UserName)) {
                    Write-Verbose "Adding PSCredential for user '$($Credential.UserName)' to `$PSProfile.Vault"
                    $Global:PSProfile.Vault._secrets[$Credential.UserName] = $Credential
                    if ($Save) {
                        Save-PSProfile
                    }
                }
                elseif (-not $Force -and $Global:PSProfile.Vault._secrets.ContainsKey($Credential.UserName)) {
                    Write-Error "A secret with the name '$($Credential.UserName)' already exists! Include -Force to overwrite it."
                }
            }
            SecureString {
                if ($Force -or -not $Global:PSProfile.Vault._secrets.ContainsKey($Name)) {
                    Write-Verbose "Adding SecureString secret with name '$Name' to `$PSProfile.Vault"
                    $Global:PSProfile.Vault._secrets[$Name] = $SecureString
                    if ($Save) {
                        Save-PSProfile
                    }
                }
                elseif (-not $Force -and $Global:PSProfile.Vault._secrets.ContainsKey($Name)) {
                    Write-Error "A secret with the name '$Name' already exists! Include -Force to overwrite it."
                }
            }
        }
    }
}
