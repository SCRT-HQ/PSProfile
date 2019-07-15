function Set-MyConfig {
    [cmdletbinding()]
    Param
    (
        [parameter(Mandatory = $false,Position = 0,ValueFromRemainingArguments = $true)]
        [Object[]]
        $Data
    )
    Begin {
        if (!($configHash = Import-Configuration -ErrorAction SilentlyContinue -Verbose:$false)) {
            $configHash = @{}
        }
    }
    Process {
        try {
            if ($PSBoundParameters.Keys -contains "Data") {
                foreach ($item in $Data) {
                    switch ($item.GetType().Name) {
                        Hashtable {
                            foreach ($key in $item.Keys) {
                                $configHash[$key] = (Encrypt $item[$key])
                            }
                        }
                        PSCustomObject {
                            foreach ($prop in $item.PSObject.Properties.Name) {
                                $configHash[$prop] = (Encrypt $item.$prop)
                            }
                        }
                        PSCredential {
                            if (!$configHash['CredStore']) {
                                $configHash['CredStore'] = @{}
                            }
                            $configHash['CredStore']["cred_$($item.GetNetworkCredential().UserName)"] = $item
                        }
                        Default {
                            $configHash["$($item.GetType().Name)"] = ($item[$key])
                        }
                    }
                }
            }
            $configHash | Export-Configuration -Verbose:$false
            Get-MyConfig -Verbose:$false
        }
        catch {
            throw $_
        }
    }
}
