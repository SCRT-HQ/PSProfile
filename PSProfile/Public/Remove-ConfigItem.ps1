function Remove-ConfigItem {
    [cmdletbinding()]
    Param
    (
        [parameter(Mandatory = $false,Position = 0)]
        [String[]]
        $Property,
        [parameter(Mandatory = $false)]
        [String[]]
        $Username
    )
    Begin {
        $configHash = Import-SpecificConfiguration -CompanyName 'SCRT HQ' -Name 'PSProfile' -Scope User -Verbose:$false
    }
    Process {
        foreach ($prop in $Property) {
            if ($configHash[$prop]) {
                Write-Verbose "Removing property '$prop'"
                $configHash.Remove($prop)
            }
            else {
                Write-Warning "Property '$prop' not found in config!"
            }
        }
        foreach ($user in $Username) {
            if ($configHash['CredStore']["cred_$($user)"]) {
                Write-Verbose "Removing credentials for user '$user'"
                ($configHash['CredStore']).Remove("cred_$($user)")
            }
            else {
                Write-Warning "Username '$user' not found in CredStore!"
            }
        }
    }
    End {
        $configHash | Export-Configuration -CompanyName 'SCRT HQ' -Name 'PSProfile' -Scope User -Verbose:$false
        Get-MyConfig -Verbose:$false
    }
}