function Set-MyCreds {
    <#
    .SYNOPSIS
    Adds a PSCredential object to the PSProfile Vault then saves the current PSProfile.

    .DESCRIPTION
    Adds a PSCredential object to the PSProfile Vault then saves the current PSProfile.

    .PARAMETER Credential
    The PSCredential to add to the Vault.

    .EXAMPLE
    Set-MyCreds (Get-Credential)

    Opens a Get-Credential window or prompt to enable entering credentials securely, then stores it in the Vault.
    #>
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
