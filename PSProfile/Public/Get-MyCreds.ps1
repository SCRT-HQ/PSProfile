function Get-MyCreds {
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
            if ($global:PSProfile.Vault._secrets.$Item) {
                Write-Verbose "Found item in CredStore"
                $creds = $global:PSProfile.Vault._secrets.$Item
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
                        ([System.Management.Automation.ItemNotFoundException]"Could not find credentials"),
                        'My.ID',
                        [System.Management.Automation.ErrorCategory]::InvalidArgument,
                        $MyObject
                    )
                )
            }
        }
        else {
            $global:PSProfile.Vault._secrets
        }
    }
}

New-Alias -Name Creds -Value 'Get-MyCreds' -Option AllScope -Scope Global -Force
