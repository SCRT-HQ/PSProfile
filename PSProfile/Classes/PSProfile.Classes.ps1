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
    [object[]] $ModulesToImport
    [object[]] $ModulesToInstall
    [hashtable] $PathAliases
    [hashtable] $CommandAliases
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
        $this._internal = @{ }
        $this.GitPathMap = @{
            PSProfileConfiguration = (Join-Path (Get-ConfigurationPath -CompanyName 'SCRT HQ' -Name PSProfile) 'Configuration.psd1')
        }
        $this.PSBuildPathMap = @{ }
        $this.SymbolicLinks = @{ }
        $this.Prompts = @{
            Default = '"PS $($executionContext.SessionState.Path.CurrentLocation)$(">" * ($nestedPromptLevel + 1)) ";
            # .Link
            # https://go.microsoft.com/fwlink/?LinkID=225750
            # .ExternalHelp System.Management.Automation.dll-help.xml'
            SCRTHQ = '$lastStatus = $?
            $lastColor = if ($lastStatus -eq $true) {
                "Green"
            }
            else {
                "Red"
            }
            Write-Host "[" -NoNewline
            Write-Host -ForegroundColor Cyan "#$($MyInvocation.HistoryId)" -NoNewline
            Write-Host "] " -NoNewline
            Write-Host "[" -NoNewLine
            $verColor = @{
                ForegroundColor = if ($PSVersionTable.PSVersion.Major -eq 7) {
                    "Yellow"
                }
                elseif ($PSVersionTable.PSVersion.Major -eq 6) {
                    "Magenta"
                }
                else {
                    "Cyan"
                }
            }
            Write-Host @verColor ("PS {0}" -f (Get-PSVersion)) -NoNewline
            Write-Host "] " -NoNewline
            Write-Host "[" -NoNewline
            Write-Host -ForegroundColor $lastColor ("{0}" -f (Get-LastCommandDuration)) -NoNewline
            Write-Host "] [" -NoNewline
            Write-Host ("{0}" -f $(Get-PathAlias)) -NoNewline -ForegroundColor DarkYellow
            Write-Host "]" -NoNewline
            if ($PWD.Path -notlike "\\*" -and $env:DisablePoshGit -ne $true -and (Test-IfGit)) {
                Write-VcsStatus
                $GitPromptSettings.EnableWindowTitle = "PS {0} @" -f (Get-PSVersion)
            }
            else {
                $Host.UI.RawUI.WindowTitle = "PS {0}" -f (Get-PSVersion)
            }
            "`n>> "'
        }
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
        $this.ProjectPaths = @()
        $this.PluginPaths = @(
            (Join-Path $PSScriptRoot "Plugins")
        )
        $this.ScriptPaths = @()
        $this.PathAliases = @{
            '~' = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
        }
        $this.CommandAliases = @{}
    }
    [void] Load() {
        $this._internal['ProfileLoadStart'] = [datetime]::Now
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
                "Verbose"
            )
        }
        if ($Global:PSDefaultParameterValues.Keys.Count) {
            $Global:PSDefaultParameterValues['Import-Module:Global'] = $true
            $Global:PSDefaultParameterValues['Import-Module:Force'] = $true
            $Global:PSDefaultParameterValues['Import-Module:Verbose'] = $false
        }
        else {
            $Global:PSDefaultParameterValues = @{
                'Import-Module:Global'  = $true
                'Import-Module:Force'   = $true
                'Import-Module:Verbose' = $false
            }
        }
        $this._importModules()
        $this._loadPlugins()
        $this._invokeScripts()
        $this._setVariables()
        $this._setCommandAliases()
        $this._loadPrompt()
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
            "Verbose"
        )
        $this._findProjects()
        $this._installModules()
        $this._createSymbolicLinks()
        $this._formatPrompts()
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
    hidden [void] _loadPrompt() {
        $this._log(
            "SECTION START",
            "LoadPrompt",
            "Debug"
        )
        if ($null -ne $global:PSProfile.Settings.DefaultPrompt) {
            Switch-PSProfilePrompt -Name $global:PSProfile.Settings.DefaultPrompt
        }
        $this._log(
            "SECTION END",
            "LoadPrompt",
            "Debug"
        )
    }
    hidden [void] _formatPrompts() {
        $this._log(
            "SECTION START",
            "FormatPrompts",
            "Debug"
        )
        $final = @{}
        $Global:PSProfile.Prompts.GetEnumerator() | ForEach-Object {
            $this._log(
                "Formatting prompt '$($_.Key)' via Trim() (PSScriptAnalyzer not found)",
                "FormatPrompts",
                "Verbose"
            )
            $updated = ($_.Value -split "[\r\n]" | Where-Object {$_}).Trim() -join "`n"
            $final[$_.Key] = $updated
        }
        $Global:PSProfile.Prompts = $final
        $this._log(
            "SECTION END",
            "FormatPrompts",
            "Debug"
        )
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
            "Verbose"
        )
        $additional = Import-Metadata -Path $configurationPath
        $this._log(
            "Adding additional configuration to PSProfile object",
            "AddlConfiguration",
            "Verbose"
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
            "Verbose"
        )
        $conf = Import-Configuration -Name PSProfile -CompanyName 'SCRT HQ' -DefaultPath (Join-Path $PSScriptRoot "Configuration.psd1")
        $this._log(
            "Adding layered configuration to PSProfile object",
            "Configuration",
            "Verbose"
        )
        $this | Update-Object $conf
        $this._log(
            "SECTION END",
            "Configuration",
            "Debug"
        )
    }
    hidden [void] _setCommandAliases() {
        $this._log(
            "SECTION START",
            'SetCommandAliases',
            'Debug'
        )
        $this.CommandAliases.GetEnumerator() | ForEach-Object {
            try {
                $Name = $_.Key
                $Value = $_.Value
                if ($null -eq (Get-Alias "$Name*")) {
                    New-Alias -Name $Name -Value $Value -Scope Global -Option AllScope -ErrorAction Stop
                    $this._log(
                        "Set command alias: $Name > $Value",
                        'SetCommandAliases',
                        'Verbose'
                    )
                }
                else {
                    $this._log(
                        "Alias already in use, skipping: $Name",
                        'SetCommandAliases',
                        'Verbose'
                    )
                }
            }
            catch {
                $this._log(
                    "Failed to set command alias: $Name > $Value :: $($_)",
                    'SetCommandAliases',
                    'Warning'
                )
            }
        }
        $this._log(
            "SECTION END",
            'SetCommandAliases',
            'Debug'
        )
    }
    hidden [void] _createSymbolicLinks() {
        $this._log(
            "SECTION START",
            'CreateSymbolicLinks',
            'Debug'
        )
        if ($null -ne $this.SymbolicLinks.Keys) {
            $null = $this.SymbolicLinks.GetEnumerator() | Start-RSJob -Name { "_PSProfile_SymbolicLinks_" + $_.Key } -ScriptBlock {
                if (-not (Test-Path $_.Key) -or ((Get-Item $_.Key).LinkType -eq 'SymbolicLink' -and (Get-Item $_.Key).Target -ne $_.Value)) {
                    New-Item -ItemType SymbolicLink -Path $_.Key -Value $_.Value -Force
                }
            }
        }
        else {
            $this._log(
                "No symbolic links specified!",
                'CreateSymbolicLinks',
                'Verbose'
            )
        }
        $this._log(
            "SECTION END",
            'CreateSymbolicLinks',
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
                                'Verbose'
                            )
                            Set-Item "Env:\$($_.Key)" -Value $_.Value -Force
                        }
                    }
                    default {
                        $this.Variables.Global.GetEnumerator() | ForEach-Object {
                            $this._log(
                                "`$global:$($_.Key) = '$($_.Value)'",
                                'SetVariables',
                                'Verbose'
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
                'Verbose'
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
            $this.GitPathMap = @{ }
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
                        'Verbose'
                    )
                    $g = 0
                    $b = 0
                    $pInfo.EnumerateDirectories('.git',[System.IO.SearchOption]::AllDirectories) | ForEach-Object {
                        $g++
                        $this._log(
                            "Found git project @ $($_.Parent.FullName)",
                            'FindProjects',
                            'Verbose'
                        )
                        $this.GitPathMap[$_.Parent.BaseName] = $_.Parent.FullName
                        $bldPath = [System.IO.Path]::Combine($_.Parent.FullName,'build.ps1')
                        if ([System.IO.File]::Exists($bldPath)) {
                            $b++
                            $this._log(
                                "Found build script @ $($_.FullName)",
                                'FindProjects',
                                'Verbose'
                            )
                            $this.PSBuildPathMap[$_.Parent.BaseName] = $_.Parent.FullName
                        }
                    }
                    $this._log(
                        "$p :: Found: $g git | $b build",
                        'FindProjects',
                        'Verbose'
                    )
                }
                else {
                    $this._log(
                        "'$p' Unable to resolve path!",
                        'FindProjects',
                        'Verbose'
                    )
                }
            }
        }
        else {
            $this._log(
                "No project paths specified to search in!",
                'FindProjects',
                'Verbose'
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
                                'Verbose'
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
                                    'Verbose'
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
                        'Verbose'
                    )
                }
            }
        }
        else {
            $this._log(
                "No script paths specified to invoke!",
                'InvokeScripts',
                'Verbose'
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
                    [object]
                    $Module
                )
                $params = if ($Module -is [string]) {
                    @{Name = $Module }
                }
                elseif ($Module -is [hashtable]) {
                    $Module
                }
                else {
                    $null
                }
                $this._log(
                    "Checking if module is installed already: $($params | ConvertTo-Json -Compress)",
                    'InstallModules',
                    'Verbose'
                )
                if ($null -eq (Get-Module $params['Name'] -ListAvailable)) {
                    $this._log(
                        "Installing missing module to CurrentUser scope: $($params | ConvertTo-Json -Compress)",
                        'InstallModules',
                        'Verbose'
                    )
                    Install-Module -Name @params -Scope CurrentUser -AllowClobber -SkipPublisherCheck
                }
                else {
                    $this._log(
                        "Module already installed, skipping: $($params | ConvertTo-Json -Compress)",
                        'InstallModules',
                        'Verbose'
                    )
                }
            }
        }
        else {
            $this._log(
                "No modules specified to install!",
                'InstallModules',
                'Verbose'
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
                try {
                    $params = if ($_ -is [string]) {
                        @{Name = $_ }
                    }
                    elseif ($_ -is [hashtable]) {
                        $_
                    }
                    else {
                        $null
                    }
                    if ($null -ne $params) {
                        @('ErrorAction','Verbose') | ForEach-Object {
                            if ($params.ContainsKey($_)) {
                                $params.Remove($_)
                            }
                        }
                        Import-Module @params -Global -ErrorAction SilentlyContinue -Verbose:$false
                        $this._log(
                            "Module imported: $($params | ConvertTo-Json -Compress)",
                            'ImportModules',
                            'Verbose'
                        )
                    }
                    else {
                        $this._log(
                            "Module must be either a string or a hashtable!",
                            'ImportModules',
                            'Verbose'
                        )
                    }
                }
                catch {
                    $this._log(
                        "'$($params['Name'])' Error importing module: $($Error[0].Exception.Message)",
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
                'Verbose'
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
                        'Verbose'
                    )
                    try {
                        $found = $null
                        $importParams = @{
                            ErrorAction = 'Stop'
                        }
                        if ($plugin.ArgumentList) {
                            $importParams['ArgumentList'] = $plugin.ArgumentList
                        }
                        foreach ($plugPath in $this.PluginPaths) {
                            $fullPath = [System.IO.Path]::Combine($plugPath,"$($plugin.Name).ps1")
                            $this._log(
                                "'$($plugin.Name)' Checking path: $fullPath",
                                'LoadPlugins',
                                'Verbose'
                            )
                            if (Test-Path $fullPath) {
                                $sb = [scriptblock]::Create($this._globalize(([System.IO.File]::ReadAllText($fullPath))))
                                if ($plugin.ArgumentList) {
                                    .$sb($plugin.ArgumentList)
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
                            if ($null -ne $plugin.Name -and $null -ne (Get-Module $plugin.Name -ListAvailable -ErrorAction SilentlyContinue)) {
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
                'Verbose'
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
