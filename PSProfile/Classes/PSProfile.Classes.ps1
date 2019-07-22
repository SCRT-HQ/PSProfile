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
    [System.Collections.Generic.Dictionary[[string],[PSProfileSecret]]] $_secrets

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
class PSProfile {
    [hashtable] $_internal
    [hashtable] $Settings
    [hashtable] $GitPathMap
    [string[]] $GistsToInvoke
    [string[]] $ModulesToImport
    [string[]] $ModulesToInstall
    [hashtable] $PathAliasMap
    [hashtable[]] $Plugins
    [string[]] $PluginPaths
    [string[]] $ProjectPaths
    [hashtable] $SymbolicLinks
    [hashtable] $Variables

    PSProfile() {
        $this.GitPathMap = @{}
        $this.PathAliasMap = @{
            '~' = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
        }
        $this.Settings = @{
            DefaultPrompt          = 'Default'
            ProjectPathSearchDepth = 4
            PSVersionStringLength  = 3
        }
        $this._internal = @{
            ProfileLoadStart = [datetime]::Now
            Log = [System.Collections.Generic.List[PSProfileEvent]]::new()
            Vault = [PSProfileVault]::new()
        }
    }
    [void] Load() {
        # Load the cached profile via the Configuration module
        $configuration = Get-PSProfileConfig

        if ($configuration.Plugins.Count) {
            $this._loadPlugins($configuration.Plugins)
        }

        # Mark the profile load as complete
        $this._internal.ProfileLoadEnd = [datetime]::Now
        $this._internal.ProfileLoadDuration = $this._internal.ProfileLoadEnd - $this._internal.ProfileLoadStart
        Write-Host "Loading personal profile alone took $([Math]::Round($this._internal.ProfileLoadDuration.TotalMilliseconds))ms."
    }
    hidden [void] _installModules([object[]]$modules){
        $sb = {
            Param (
                [parameter()]
                $Module
            )

        }
        $modules | ForEach-Object {
            if ($_ -is [string]) {
                @{Name = $_}
            }
            else {
                $_
            }
        } | Start-RSJob -Name "_PSProfile_InstallModule_$($_.Name)" -ScriptBlock $sb
    }
    hidden [void] _loadPlugins([hashtable[]]$plugins){
        $plugins.ForEach({
            try {
                $importParams = @{
                    ErrorAction = 'Stop'
                }
                if ($_.Arguments) {
                    $importParams['ArgumentList'] = $_.Arguments
                }
                if ($null -ne (Get-Module $_.Name -ListAvailable)) {
                    Import-Module -Name $_.Name @importParams
                }
                elseif ($this.PluginPaths.Count) {

                }
                $this._log(
                    "'$($_.Class)' plugin loaded!",
                    'Plugins'
                )
            }
            catch {
                $this._log(
                    "'$($_.Class)' plugin not found!",
                    'Plugins',
                    'Warning'
                )
            }
        })
    }
    hidden [void] _log([string]$message,[string]$section,[PSProfileLogLevel]$logLevel) {
        $dt = Get-Date
        $shortMessage = "[$($dt.ToString('HH:mm:ss'))] $message"

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
                Write-Debug $shortMessage -Debug
            }
        }
    }
    hidden [void] _log([string]$message,[string]$section) {
        $this._internal.Log($message,$section,'Quiet')
    }
    [void] SetPathAlias([string]$alias,[string]$path,[PSProfileLogLevel]$logLevel) {
        $this._log("Setting Path Alias '$alias' to '$path'",$logLevel)
        $this.PathAliases[$alias] = $path
    }
    [void] RemovePathAlias([string]$alias,[PSProfileLogLevel]$logLevel) {
        $this._log("Removing Path Alias '$alias'",$logLevel)
        $this.PathAliases.Remove($alias)
    }
    [void] SetPathAlias([string]$alias,[string]$path) {
        $this.SetPathAlias($alias,$path,'Quiet')
    }
    [void] RemovePathAlias([string]$alias) {
        $this.RemovePathAlias($alias,'Quiet')
    }
}
$PSProfile = [PSProfile]::new()
