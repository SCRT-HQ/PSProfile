enum PSProfileLogLevel {
    Information
    Warning
    Error
    Debug
    Verbose
    Quiet
}
enum PSProfileSecretType {
    PSCredential
    SecureString
}
class PSProfileEvent {
    [datetime] $Time
    [timespan] $Last
    [timespan] $Total
    [string] $Section
    [string] $Message
    [PSProfileLogLevel] $LogLevel

    PSProfileEvent(
        [datetime] $time,
        [timespan] $last,
        [timespan] $total,
        [string] $section,
        [string] $message,
        [PSProfileLogLevel] $logLevel
    ) {
        $this.Time = $time
        $this.Last = $last
        $this.Total = $total
        $this.Section = $section
        $this.Message = $message
        $this.LogLevel = $logLevel
    }
}
class PSProfileSecret {
    [PSProfileSecretType] $Type
    hidden [pscredential] $PSCredential
    hidden [securestring] $SecureString

    PSProfileSecret([string]$userName, [securestring]$password) {
        $this.Type = [PSProfileSecretType]::PSCredential
        $this.PSCredential = [PSCredential]::new($userName,$password)
    }
    PSProfileSecret([pscredential]$psCredential) {
        $this.Type = [PSProfileSecretType]::PSCredential
        $this.PSCredential = $psCredential
    }
    PSProfileSecret([SecureString]$secureString) {
        $this.Type = [PSProfileSecretType]::SecureString
        $this.SecureString = $secureString
    }
}
class PSProfileVault {
    hidden [System.Collections.Generic.Dictionary[[string],[PSProfileSecret]]] $_secrets

    PSProfileVault(){
        $this._secrets = [System.Collections.Generic.Dictionary[[string],[PSProfileSecret]]]::new()
    }
    [void] SetSecret([string]$name, [string]$userName, [securestring]$password) {
        $this._secrets[$name] = [PSProfileSecret]::new(
            $userName,
            $password
        )
    }
    [void] SetSecret([string]$name, [pscredential]$psCredential) {
        $this._secrets[$name] = [PSProfileSecret]::new(
            $psCredential
        )
    }
    [void] SetSecret([string]$name, [securestring]$secureString) {
        $this._secrets[$name] = [PSProfileSecret]::new(
            $secureString
        )
    }
    [object] GetSecret([string]$name) {
        return $this._secrets[$name].$($this._secrets[$name].Type)
    }
    [void] RemoveSecret([string]$name) {
        $this._secrets.Remove($name)
    }
}
class PSProfileInternal {
    [System.Collections.Generic.List[PSProfileEvent]] $Log
    [datetime] $ProfileLoadStart
    [datetime] $ProfileLoadEnd
    [timespan] $ProfileLoadDuration
    hidden [PSProfileVault] $Vault

    PSProfileInternal() {
        $this.ProfileLoadStart = [datetime]::Now
        $this.Log = [System.Collections.Generic.List[PSProfileEvent]]::new()
        $this.Vault = [PSProfileVault]::new()
    }
}
class PSProfile {
    [hashtable] $PathAliasMap = @{ }
    [hashtable] $GitPathMap = @{ }
    hidden [PSProfileInternal] $_internal = [PSProfileInternal]::new()

    PSProfile() {}
    hidden [void] Log([string]$message,[string]$section,[PSProfileLogLevel]$logLevel) {
        $dt = Get-Date
        $shortMessage = "[$($dt.ToString('HH:mm:ss'))] $message"

        # "[$($timestamp)] $(if($logLevel -ne 'Quiet'){"[$logLevel] "} )$message"
        $lastCommand = if ($this._internal.Log.Count) {
            $dt - $this._internal.Log[-1].Time
        }
        else {
            New-TimeSpan
        }
        $this._internal.Log.Add(
            [PSProfileEvent]::new(
                $dt,
                $lastCommand,
                ($dt - $this._internal.ProfileLoadStart),
                $section,
                $message,
                $logLevel
            )
        )
        switch ($LogLevel) {
            Information {
                Write-Host $shortMessage
            }
            Verbose {
                Write-Verbose $shortMessage -Verbose
            }
            Warning {
                Write-Warning $shortMessage
            }
            Error {
                Write-Error $shortMessage
            }
            Debug {
                Write-Debug $shortMessage
            }
        }
    }
    hidden [void] Log([string]$message,[string]$section) {
        $this._internal.Log($message,$section,'Quiet')
    }
    [void] SetPathAlias([string]$alias,[string]$path,[PSProfileLogLevel]$logLevel) {
        $this.Log("Setting Path Alias '$alias' to '$path'",$logLevel)
        $this.PathAliases[$alias] = $path
    }
    [void] RemovePathAlias([string]$alias,[PSProfileLogLevel]$logLevel) {
        $this.Log("Removing Path Alias '$alias'",$logLevel)
        $this.PathAliases.Remove($alias)
    }
    [void] SetPathAlias([string]$alias,[string]$path) {
        $this.SetPathAlias($alias,$path,'Quiet')
    }
    [void] RemovePathAlias([string]$alias) {
        $this.RemovePathAlias($alias,'Quiet')
    }
    [void] ProfileLoadComplete() {
        $this._internal.ProfileLoadEnd = [datetime]::Now
        $this._internal.ProfileLoadDuration = $this._internal.ProfileLoadEnd - $this._internal.ProfileLoadStart
        Write-Host "Loading personal profile alone took $([Math]::Round($this._internal.ProfileLoadDuration.TotalMilliseconds))ms."
    }
}
$PSProfile = [PSProfile]::new()