function Set-MyCreds {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0,ValueFromPipeline)]
        [PSCredential]
        $Credential
    )
    Process {
        Write-Verbose "Adding credential for user $($Credential.UserName) to `$PSProfile.Vault"
        $Global:PSProfile.Vault.SetSecret($Credential)
        $Global:PSProfile.Save()
    }
}
