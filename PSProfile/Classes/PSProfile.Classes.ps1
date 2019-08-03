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
    hidden [datetime] $Time
    [timespan] $Total
    [timespan] $Last
    [PSProfileLogLevel] $LogLevel
    [string] $Section
    [string] $Message

    PSProfileEvent(
        [datetime] $time,
        [timespan] $last,
        [timespan] $total,
        [PSProfileLogLevel] $logLevel,
        [string] $section,
        [string] $message
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
class PSProfileVault : Hashtable {
    [hashtable] $_secrets

    PSProfileVault() {
        $this._secrets = @{ }
    }
    [void] SetSecret([string]$name, [string]$userName, [securestring]$password) {
        $this._secrets[$name] = [PSCredential]::new(
            $userName,
            $password
        )
    }
    [void] SetSecret([pscredential]$psCredential) {
        $this._secrets[$psCredential.UserName] = $psCredential
    }
    [void] SetSecret([string]$name, [pscredential]$psCredential) {
        $this._secrets[$name] = $psCredential
    }
    [void] SetSecret([string]$name, [securestring]$secureString) {
        $this._secrets[$name] = $secureString
    }
    [pscredential] GetSecret() {
        if ($env:USERNAME) {
            return $this._secrets[$env:USERNAME]
        }
        elseif ($env:USER) {
            return $this._secrets[$env:USER]
        }
        else {
            return $null
        }
    }
    [object] GetSecret([string]$name) {
        return $this._secrets[$name]
    }
    [void] RemoveSecret([string]$name) {
        $this._secrets.Remove($name)
    }
}
class PSProfile {
    hidden [System.Collections.Generic.List[PSProfileEvent]] $Log
    [hashtable] $_internal
    [hashtable] $Settings
    [datetime] $LastRefresh
    [string] $RefreshFrequency
    [hashtable] $GitPathMap
    [hashtable] $PSBuildPathMap
    [string[]] $ModulesToImport
    [string[]] $ModulesToInstall
    [hashtable] $PathAliases
    [hashtable[]] $Plugins
    [string[]] $PluginPaths
    [string[]] $ProjectPaths
    [hashtable] $Prompts
    [string[]] $ScriptPaths
    [hashtable] $SymbolicLinks
    [hashtable] $Variables
    [PSProfileVault] $Vault

    PSProfile() {
        $this.Log = [System.Collections.Generic.List[PSProfileEvent]]::new()
        $this.Vault = [PSProfileVault]::new()
        $this._internal = @{
            ProfileLoadStart = [datetime]::Now
        }
        $this.GitPathMap = @{
            PSProfileConfiguration = (Join-Path (Get-ConfigurationPath -CompanyName 'SCRT HQ' -Name PSProfile) 'Configuration.psd1')
        }
        $this.PSBuildPathMap = @{ }
        $this.SymbolicLinks = @{ }
        $this.Prompts = @{ }
        $this.Variables = @{
            Environment = @{
                Home         = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
                UserName     = [System.Environment]::UserName
                ComputerName = [System.Environment]::MachineName
            }
            Global      = @{
                PathAliasDirectorySeparator    = "$([System.IO.Path]::DirectorySeparatorChar)"
                AltPathAliasDirectorySeparator = "$([char]0xe0b1)"
            }
        }
        $this.Settings = @{
            DefaultPrompt         = 'Default'
            PSVersionStringLength = 3
        }
        $this.RefreshFrequency = (New-Timespan -Hours 1).ToString()
        $this.LastRefresh = [datetime]::Now.AddHours(-2)
        $this.LastRefresh
        $this.RefreshFrequency
        $this.ProjectPaths = @()
        $this.PluginPaths = @(
            (Join-Path $PSScriptRoot "Plugins")
        )
        $this.ScriptPaths = @()
        $this.PathAliases = @{
            '~' = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
        }
    }
    [void] Load() {
        $this._log(
            "SECTION START",
            "MAIN",
            "Debug"
        )
        $this._loadConfiguration()
        if (([datetime]::Now - $this.LastRefresh) -gt [timespan]$this.RefreshFrequency) {
            $withRefresh = ' with refresh.'
            $this.Refresh()
        }
        else {
            $withRefresh = '.'
            $this._log(
                "Skipped full refresh! Frequency set to '$($this.RefreshFrequency)', but last refresh was: $($this.LastRefresh.ToString())",
                "MAIN",
                "Debug"
            )
        }
        $this._importModules()
        $this._loadPlugins()
        $this._invokeScripts()
        $this._setVariables()
        $this._internal['ProfileLoadEnd'] = [datetime]::Now
        $this._internal['ProfileLoadDuration'] = $this._internal.ProfileLoadEnd - $this._internal.ProfileLoadStart
        $this._log(
            "SECTION END",
            "MAIN",
            "Debug"
        )
        Write-Host "Loading PSProfile alone took $([Math]::Round($this._internal.ProfileLoadDuration.TotalMilliseconds))ms$withRefresh"
    }
    [void] Refresh() {
        $this._log(
            "Refreshing project map, checking for modules to install and creating symbolic links",
            "MAIN",
            "Debug"
        )
        $this._findProjects()
        $this._installModules()
        $this._createSymbolicLinks()
        $this.LastRefresh = [datetime]::Now
        $this.Save()
    }
    [void] Save() {
        $out = @{ }
        $this.PSObject.Properties.Name | Where-Object { $_ -ne '_internal' } | ForEach-Object {
            $out[$_] = $this.$_
        }
        $out | Export-Configuration -Name PSProfile -CompanyName 'SCRT HQ'
    }
    hidden [string] _globalize([string]$content) {
        $noScopePattern = 'function\s+(?<Name>[\w+_-]{1,})\s+\{'
        $globalScopePattern = 'function\s+global\:'
        $noScope = [RegEx]::Matches($content, $noScopePattern, "Multiline, IgnoreCase")
        $globalScope = [RegEx]::Matches($content,$globalScopePattern,"Multiline, IgnoreCase")
        if ($noScope.Count -ge $globalScope.Count) {
            foreach ($match in $noScope) {
                $fullValue = ($match.Groups | Where-Object { $_.Name -eq 0 }).Value
                $funcName = ($match.Groups | Where-Object { $_.Name -eq 'Name' }).Value
                $content = $content.Replace($fullValue, "function global:$funcName {")
            }
        }
        return $content
    }
    hidden [void] _loadAdditionalConfiguration([string]$configurationPath) {
        $this._log(
            "SECTION START",
            "AddlConfiguration",
            "Debug"
        )
        $this._log(
            "Importing additional file: $configurationPath",
            "AddlConfiguration",
            "Debug"
        )
        $additional = Import-Metadata -Path $configurationPath
        $this._log(
            "Adding additional configuration to PSProfile object",
            "AddlConfiguration",
            "Debug"
        )
        $this | Update-Object $additional
        $this._log(
            "SECTION END",
            "AddlConfiguration",
            "Debug"
        )
    }
    hidden [void] _loadConfiguration() {
        $this._log(
            "SECTION START",
            "Configuration",
            "Debug"
        )
        $this._log(
            "Importing layered Configuration",
            "Configuration",
            "Debug"
        )
        $conf = Import-Configuration -Name PSProfile -CompanyName 'SCRT HQ' -DefaultPath (Join-Path $PSScriptRoot "Configuration.psd1")
        $this._log(
            "Adding layered configuration to PSProfile object",
            "Configuration",
            "Debug"
        )
        $this | Update-Object $conf
        $this._log(
            "SECTION END",
            "Configuration",
            "Debug"
        )
    }
    hidden [void] _createSymbolicLinks() {
        $this._log(
            "SECTION START",
            'SymbolicLinks',
            'Debug'
        )
        if ($null -ne $this.SymbolicLinks.Keys) {
            $null = $this.SymbolicLinks.GetEnumerator() | Start-RSJob -Name { "_PSProfile_SymbolicLinks_" + $_.Key } -ScriptBlock {
                if (-not (Test-Path $_.Key)) {
                    New-Item -ItemType SymbolicLink -Path $_.Key -Value $_.Value
                }
            }
        }
        else {
            $this._log(
                "No symbolic links specified!",
                'SymbolicLinks',
                'Debug'
            )
        }
        $this._log(
            "SECTION END",
            'SymbolicLinks',
            'Debug'
        )
    }
    hidden [void] _setVariables() {
        $this._log(
            "SECTION START",
            'SetVariables',
            'Debug'
        )
        if ($null -ne $this.Variables.Keys) {
            foreach ($varType in $this.Variables.Keys) {
                switch ($varType) {
                    Environment {
                        $this.Variables.Environment.GetEnumerator() | ForEach-Object {
                            $this._log(
                                "`$env:$($_.Key) = '$($_.Value)'",
                                'SetVariables',
                                'Debug'
                            )
                            Set-Item "Env:\$($_.Key)" -Value $_.Value -Force
                        }
                    }
                    default {
                        $this.Variables.Global.GetEnumerator() | ForEach-Object {
                            $this._log(
                                "`$global:$($_.Key) = '$($_.Value)'",
                                'SetVariables',
                                'Debug'
                            )
                            Set-Variable -Name $_.Key -Value $_.Value -Scope Global -Force
                        }
                    }
                }
            }
        }
        else {
            $this._log(
                "No variables key/value pairs provided!",
                'SetVariables',
                'Debug'
            )
        }
        $this._log(
            "SECTION END",
            'SetVariables',
            'Debug'
        )
    }
    hidden [void] _findProjects() {
        $this._log(
            "SECTION START",
            'FindProjects',
            'Debug'
        )
        if (-not [string]::IsNullOrEmpty((-join $this.ProjectPaths))) {
            $this.ProjectPaths | ForEach-Object {
                $p = $_
                $cnt = 0
                if (Test-Path $p) {
                    $p = (Resolve-Path $p).Path
                    $cnt++
                    $pInfo = [System.IO.DirectoryInfo]::new($p)
                    $this.PathAliases["@$($pInfo.Name)"] = $pInfo.FullName
                    $this._log(
                        "Added path alias: @$($pInfo.Name) >> $($pInfo.FullName)",
                        'FindProjects',
                        'Debug'
                    )
                    $g = 0
                    $b = 0
                    $pInfo.EnumerateDirectories('.git',[System.IO.SearchOption]::AllDirectories) | ForEach-Object {
                        $g++
                        $this._log(
                            "Found git project @ $($_.Parent.FullName)",
                            'FindProjects',
                            'Debug'
                        )
                        $this.GitPathMap[$_.Parent.BaseName] = $_.Parent.FullName
                        $bldPath = [System.IO.Path]::Combine($_.Parent.FullName,'build.ps1')
                        if ([System.IO.File]::Exists($bldPath)) {
                            $b++
                            $this._log(
                                "Found build script @ $($_.FullName)",
                                'FindProjects',
                                'Debug'
                            )
                            $this.PSBuildPathMap[$_.Parent.BaseName] = $_.Parent.FullName
                        }
                    }
                    $this._log(
                        "$p :: Found: $g git | $b build",
                        'FindProjects',
                        'Debug'
                    )
                }
                else {
                    $this._log(
                        "'$p' Unable to resolve path!",
                        'FindProjects',
                        'Debug'
                    )
                }
            }
        }
        else {
            $this._log(
                "No project paths specified to search in!",
                'FindProjects',
                'Debug'
            )
        }
        $this._log(
            "SECTION END",
            'FindProjects',
            'Debug'
        )
    }
    hidden [void] _invokeScripts() {
        $this._log(
            "SECTION START",
            'InvokeScripts',
            'Debug'
        )
        if (-not [string]::IsNullOrEmpty((-join $this.ScriptPaths))) {
            $this.ScriptPaths | ForEach-Object {
                $p = $_
                if (Test-Path $p) {
                    $i = Get-Item $p
                    $p = $i.FullName
                    if ($p -match '\.ps1$') {
                        try {
                            $this._log(
                                "'$($i.Name)' Invoking script",
                                'InvokeScripts',
                                'Debug'
                            )
                            $sb = [scriptblock]::Create($this._globalize(([System.IO.File]::ReadAllText($i.FullName))))
                            .$sb
                        }
                        catch {
                            $e = $_
                            $this._log(
                                "'$($i.Name)' Failed to invoke script! Error: $e",
                                'InvokeScripts',
                                'Warning'
                            )
                        }
                    }
                    else {
                        [System.IO.DirectoryInfo]::new($p).EnumerateFiles('*.ps1',[System.IO.SearchOption]::AllDirectories) | Where-Object { $_.BaseName -notmatch '^(profile|CONFIG|WIP)' } | ForEach-Object {
                            $s = $_
                            try {
                                $this._log(
                                    "'$($s.Name)' Invoking script",
                                    'InvokeScripts',
                                    'Debug'
                                )
                                $sb = [scriptblock]::Create($this._globalize(([System.IO.File]::ReadAllText($s.FullName))))
                                .$sb
                            }
                            catch {
                                $e = $_
                                $this._log(
                                    "'$($s.Name)' Failed to invoke script! Error: $e",
                                    'InvokeScripts',
                                    'Warning'
                                )
                            }
                        }
                    }
                }
                else {
                    $this._log(
                        "'$p' Unable to resolve path!",
                        'FindProjects',
                        'Debug'
                    )
                }
            }
        }
        else {
            $this._log(
                "No script paths specified to invoke!",
                'InvokeScripts',
                'Debug'
            )
        }
        $this._log(
            "SECTION END",
            'InvokeScripts',
            'Debug'
        )
    }
    hidden [void] _installModules() {
        $this._log(
            "SECTION START",
            'InstallModules',
            'Debug'
        )
        if (-not [string]::IsNullOrEmpty((-join $this.ModulesToInstall))) {
            $null = $this.ModulesToInstall | Start-RSJob -Name { "_PSProfile_InstallModule_$($_)" } -VariablesToImport this -ScriptBlock {
                Param (
                    [parameter()]
                    [string]
                    $ModuleName
                )
                $this._log(
                    "'$($ModuleName)' Checking if module is installed already",
                    'InstallModules',
                    'Debug'
                )
                if ($null -eq (Get-Module $ModuleName -ListAvailable)) {
                    $this._log(
                        "'$($ModuleName)' Installing missing module",
                        'InstallModules',
                        'Debug'
                    )
                    Install-Module -Name $ModuleName -Repository PSGallery -Scope CurrentUser -AllowClobber -SkipPublisherCheck
                }
                else {
                    $this._log(
                        "'$($ModuleName)' Module already installed, skipping",
                        'InstallModules',
                        'Debug'
                    )
                }
            }
        }
        else {
            $this._log(
                "No modules specified to install!",
                'InstallModules',
                'Debug'
            )
        }
        $this._log(
            "SECTION END",
            'InstallModules',
            'Debug'
        )
    }
    hidden [void] _importModules() {
        $this._log(
            "SECTION START",
            'ImportModules',
            'Debug'
        )
        if (-not [string]::IsNullOrEmpty((-join $this.ModulesToImport))) {
            $this.ModulesToImport | ForEach-Object {
                $this._log(
                    "'$($_)' Importing module",
                    'ImportModules',
                    'Debug'
                )
                try {
                    Import-Module $_ -Global -ErrorAction SilentlyContinue
                    $this._log(
                        "'$($_)' Module imported",
                        'ImportModules',
                        'Debug'
                    )
                }
                catch {
                    $this._log(
                        "'$($_)' Error importing module: $($Error[0].Exception.Message)",
                        "ImportModules",
                        "Warning"
                    )
                }
            }
        }
        else {
            $this._log(
                "No modules specified to import!",
                'ImportModules',
                'Debug'
            )
        }
        $this._log(
            "SECTION END",
            'ImportModules',
            'Debug'
        )
    }
    hidden [void] _loadPlugins() {
        $this._log(
            "SECTION START",
            'LoadPlugins',
            'Debug'
        )
        if ($this.Plugins.Count) {
            $this.Plugins.ForEach( {
                $plugin = $_
                $this._log(
                    "'$($plugin.Name)' Searching for plugin",
                    'LoadPlugins',
                    'Debug'
                )
                try {
                    $found = $null
                    $importParams = @{
                        ErrorAction = 'Stop'
                    }
                    if ($plugin.Arguments) {
                        $importParams['ArgumentList'] = $plugin.Arguments
                    }
                    foreach ($plugPath in $this.PluginPaths) {
                        $fullPath = [System.IO.Path]::Combine($plugPath,"$($plugin.Name).ps1")
                        $this._log(
                            "'$($plugin.Name)' Checking path: $fullPath",
                            'LoadPlugins',
                            'Debug'
                        )
                        if (Test-Path $fullPath) {
                            $sb = [scriptblock]::Create($this._globalize(([System.IO.File]::ReadAllText($fullPath))))
                            if ($plugin.Arguments) {
                                .$sb($plugin.Arguments)
                            }
                            else {
                                .$sb
                            }
                            $found = $fullPath
                            break
                        }
                    }
                    if ($null -ne $found) {
                        $this._log(
                            "'$($plugin.Name)' plugin loaded from path: $found",
                            'LoadPlugins'
                        )
                    }
                    else {
                        if ($null -ne (Get-Module $plugin.Name -ListAvailable -ErrorAction SilentlyContinue)) {
                            Import-Module $plugin.Name @importParams
                            $this._log(
                                "'$($plugin.Name)' plugin loaded from PSModulePath!",
                                'LoadPlugins'
                            )
                        }
                        else {
                            $this._log(
                                "'$($plugin.Name)' plugin not found!",
                                'LoadPlugins',
                                'Warning'
                            )
                        }
                    }
                }
                catch {
                    throw
                }
            })
        }
        else {
            $this._log(
                "No plugins specified to load!",
                'LoadPlugins',
                'Debug'
            )
        }
        $this._log(
            "SECTION END",
            'LoadPlugins',
            'Debug'
        )
    }
    hidden [void] _log([string]$message,[string]$section,[PSProfileLogLevel]$logLevel) {
        $dt = Get-Date
        $shortMessage = "[$($dt.ToString('HH:mm:ss'))] $message"

        $lastCommand = if ($this.Log.Count) {
            $dt - $this.Log[-1].Time
        }
        else {
            New-TimeSpan
        }
        $this.Log.Add(
            [PSProfileEvent]::new(
                $dt,
                $lastCommand,
                ($dt - $this._internal.ProfileLoadStart),
                $logLevel,
                $section,
                $message
            )
        )
        switch ($logLevel) {
            Information {
                Write-Host $shortMessage
            }
            Verbose {
                Write-Verbose $shortMessage
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
    hidden [void] _log([string]$message,[string]$section) {
        $this._log($message,$section,'Quiet')
    }
}
