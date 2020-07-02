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

class PSProfile {
    hidden [System.Collections.Generic.List[PSProfileEvent]] $Log
    [hashtable] $_internal
    [hashtable] $Settings
    [datetime] $LastRefresh
    [datetime] $LastSave
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
    [hashtable] $InitScripts
    [string[]] $ScriptPaths
    [string[]] $ConfigurationPaths
    [hashtable] $SymbolicLinks
    [hashtable] $Variables
    [hashtable] $Vault

    PSProfile() {
        $this.Log = [System.Collections.Generic.List[PSProfileEvent]]::new()
        $this.Vault = @{_secrets = @{}}
        $this._internal = @{ }
        $this.GitPathMap = @{ }
        $this.PSBuildPathMap = @{ }
        $this.SymbolicLinks = @{ }
        $this.Prompts = @{ }
        $this.Variables = @{
            Environment = @{}
            Global      = @{
                PathAliasDirectorySeparator    = "$([System.IO.Path]::DirectorySeparatorChar)"
                AltPathAliasDirectorySeparator = "$([char]0xe0b1)"
            }
        }
        $this.Settings = @{
            DefaultPrompt         = $null
            PSVersionStringLength = 3
            ConfigurationPath     = (Join-Path (Get-ConfigurationPath -CompanyName 'SCRT HQ' -Name PSProfile) 'Configuration.psd1')
            FontType              = 'Default'
            PromptCharacters      = @{
                GitRepo = @{
                    NerdFonts = "$([char]0xf418)"
                    PowerLine = "$([char]0xe0a0)"
                    Default   = "@"
                }
                AWS     = @{
                    NerdFonts = "$([char]0xf270)"
                    PowerLine = "$([char]0xf0e7)"
                    Default   = "AWS: "
                }
            }
            PSReadline            = @{
                Options     = @{ }
                KeyHandlers = @{ }
            }
        }
        $this.RefreshFrequency = (New-TimeSpan -Hours 1).ToString()
        $this.LastRefresh = [datetime]::Now.AddHours(-2)
        $this.LastSave = [datetime]::Now
        $this.ProjectPaths = @()
        $this.PluginPaths = @()
        $this.InitScripts = @{ }
        $this.ScriptPaths = @()
        $this.ConfigurationPaths = @()
        $this.PathAliases = @{
            '~' = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
        }
        $this.CommandAliases = @{ }
        $this.Plugins = @()
    }
    [void] Load() {
        $this._internal['ProfileLoadStart'] = [datetime]::Now
        $this._log(
            "SECTION START",
            "MAIN",
            "Debug"
        )
        $this._loadConfiguration()
        $this.Prompts['SCRTHQ'] = '$lastStatus = $?
$lastColor = if ($lastStatus -eq $true) {
    "Green"
}
else {
    "Red"
}
$isAdmin = $false
$isDesktop = ($PSVersionTable.PSVersion.Major -eq 5)
if ($isDesktop -or $IsWindows) {
    $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object "System.Security.Principal.WindowsPrincipal" $windowsIdentity
    $isAdmin = $windowsPrincipal.IsInRole("Administrators") -eq 1
} else {
    $isAdmin = ((& id -u) -eq 0)
}
if ($isAdmin) {
    $idColor = "Magenta"
}
else {
    $idColor = "Cyan"
}
Write-Host "[" -NoNewline
Write-Host -ForegroundColor $idColor "#$($MyInvocation.HistoryId)" -NoNewline
Write-Host "] [" -NoNewline
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
Write-Host "] [" -NoNewline
Write-Host -ForegroundColor $lastColor ("{0}" -f (Get-LastCommandDuration)) -NoNewline
Write-Host "] [" -NoNewline
Write-Host ("{0}" -f $(Get-PathAlias)) -NoNewline -ForegroundColor DarkYellow
if ((Get-Location -Stack).Count -gt 0) {
    Write-Host (("+" * ((Get-Location -Stack).Count))) -NoNewLine -ForegroundColor Cyan
}
Write-Host "]" -NoNewline
if ($PWD.Path -notlike "\\*" -and $env:DisablePoshGit -ne $true) {
    Write-VcsStatus
    $GitPromptSettings.EnableWindowTitle = "PS {0} @" -f (Get-PSVersion)
}
else {
    $Host.UI.RawUI.WindowTitle = "PS {0}" -f (Get-PSVersion)
}
if ($env:AWS_PROFILE) {
    Write-Host "`n[" -NoNewline
    $awsIcon = if ($global:PSProfile.Settings.ContainsKey("FontType")) {
        $global:PSProfile.Settings.PromptCharacters.AWS[$global:PSProfile.Settings.FontType]
    }
    else {
        "AWS:"
    }
    if ([String]::IsNullOrEmpty($awsIcon)) {
        $awsIcon = "AWS:"
    }
    Write-Host -ForegroundColor Yellow "$($awsIcon) $($env:AWS_PROFILE)$(if($env:AWS_DEFAULT_REGION){" @ $env:AWS_DEFAULT_REGION"})" -NoNewline
    Write-Host "]" -NoNewline
}
"`n>> "'
        $plugPaths = @((Join-Path $PSScriptRoot "Plugins"))
        $curVer = (Import-Metadata (Join-Path $PSScriptRoot "PSProfile.psd1")).ModuleVersion
        $this.PluginPaths | Where-Object { -not [string]::IsNullOrEmpty($_) -and ($_ -match "[\/\\](Modules|BuildOutput)[\/\\]PSProfile[\/\\]$curVer" -or $_ -notmatch "[\/\\](Modules|BuildOutput)[\/\\]PSProfile[\/\\]\d+\.\d+\.\d+") } | ForEach-Object {
            $plugPaths += $_
        }
        $this.PluginPaths = $plugPaths | Select-Object -Unique
        $plugs = @()
        $this.Plugins | Where-Object { $_.Name -ne 'PSProfile.PowerTools' } | ForEach-Object {
            $plugs += $_
        }
        if ($plugs.Count) {
            $this.Plugins = $plugs
        }
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
        $this._invokeInitScripts()
        $this._importModules()
        $this._loadPlugins()
        $this._invokeScripts()
        $this._setVariables()
        $this._setCommandAliases()
        $this._loadPrompt()

        $this.Variables['Environment']['Home'] = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
        $this.Variables['Environment']['UserName'] = [System.Environment]::UserName
        $this.Variables['Environment']['ComputerName'] = [System.Environment]::MachineName

        $this._internal['ProfileLoadEnd'] = [datetime]::Now
        $this._internal['ProfileLoadDuration'] = $this._internal.ProfileLoadEnd - $this._internal.ProfileLoadStart
        $this._log(
            "SECTION END",
            "MAIN",
            "Debug"
        )
        if ($env:ShowPSProfileLoadTime -ne $false) {
            Write-Host "Loading PSProfile alone took $([Math]::Round($this._internal.ProfileLoadDuration.TotalMilliseconds))ms$withRefresh"
        }
    }
    [void] Refresh() {
        $this._log(
            "Refreshing project map, checking for modules to install and creating symbolic links",
            "MAIN",
            "Verbose"
        )
        $this._cleanConfig()
        $this._findProjects()
        $this._installModules()
        $this._createSymbolicLinks()
        $this._formatPrompts()
        $this._formatInitScripts()
        $this.LastRefresh = [datetime]::Now
        $this.Save()
        $this._log(
            "Refresh complete",
            "MAIN",
            "Verbose"
        )
    }
    [void] Save() {
        $this._log(
            "Saving PSProfile configuration",
            "MAIN",
            "Debug"
        )
        $out = @{ }
        $this.LastSave = [DateTime]::Now
        $this.PSObject.Properties.Name | Where-Object { $_ -ne '_internal' } | ForEach-Object {
            $out[$_] = $this.$_
        }
        $out | Export-Configuration -Name PSProfile -CompanyName 'SCRT HQ'
        $this._log(
            "PSProfile configuration has been saved.",
            "MAIN",
            "Debug"
        )
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
        $content = $content -replace '\$PSDefaultParameterValues','$global:PSDefaultParameterValues'
        return $content
    }
    hidden [void] _cleanConfig() {
        $this._log(
            "SECTION START",
            "CleanConfig",
            "Debug"
        )
        foreach ($section in @('ModulesToImport','ModulesToInstall')) {
            $this._log(
                "[$section] Cleaning section",
                "CleanConfig",
                "Verbose"
            )
            [hashtable[]]$final = @()
            $this.$section | Where-Object { $_ -is [hashtable] -and $_.Name } | ForEach-Object {
                $final += $_
            }
            $this.$section | Where-Object { $_ -is [string] } | ForEach-Object {
                $this._log(
                    "[$section] Converting module string to hashtable: $_",
                    "CleanConfig",
                    "Verbose"
                )
                $final += @{Name = $_ }
            }
            $this.$section = $final
        }
        foreach ($section in @('ScriptPaths','PluginPaths','ProjectPaths')) {
            $this._log(
                "[$section] Cleaning section",
                "CleanConfig",
                "Verbose"
            )
            [string[]]$final = @()
            $this.$section | Where-Object { -not [string]::IsNullOrEmpty($_) } | ForEach-Object {
                $final += $_
            }
            $this.$section = $final
        }
        $this._log(
            "SECTION END",
            "CleanConfig",
            "Debug"
        )
    }
    hidden [void] _loadPrompt() {
        $this._log(
            "SECTION START",
            "LoadPrompt",
            "Debug"
        )
        if (-not [String]::IsNullOrEmpty($this.Settings.DefaultPrompt)) {
            $this._log(
                "Loading default prompt: $($this.Settings.DefaultPrompt)",
                "LoadPrompt",
                "Verbose"
            )
            $function:prompt = $this.Prompts[$this.Settings.DefaultPrompt]
        }
        else {
            $this._log(
                "No default prompt name found on PSProfile. Retaining current prompt.",
                "LoadPrompt",
                "Verbose"
            )
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
        $final = @{ }
        $this.Prompts.GetEnumerator() | ForEach-Object {
            $this._log(
                "Formatting prompt '$($_.Key)'",
                "FormatPrompts",
                "Verbose"
            )
            $updated = ($_.Value -split "[\r\n]" | Where-Object { $_ }).Trim() -join "`n"
            $final[$_.Key] = $updated
        }
        $this.Prompts = $final
        $this._log(
            "SECTION END",
            "FormatPrompts",
            "Debug"
        )
    }
    hidden [void] _formatInitScripts() {
        $this._log(
            "SECTION START",
            "FormatInitScripts",
            "Debug"
        )
        $final = $this.InitScripts
        $this.InitScripts.GetEnumerator() | ForEach-Object {
            $this._log(
                "Formatting InitScript '$($_.Key)'",
                "FormatInitScripts",
                "Verbose"
            )
            $updated = ($_.Value.ScriptBlock -split "[\r\n]" | Where-Object { $_ }).Trim() -join "`n"
            $final[$_.Key]['ScriptBlock'] = $updated
        }
        $this.InitScripts = $final
        $this._log(
            "SECTION END",
            "FormatInitScripts",
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
        if ($this.ConfigurationPaths.Count) {
            $this.ConfigurationPaths | ForEach-Object {
                if (Test-Path $_) {
                    $this._loadAdditionalConfiguration($_)
                }
            }
        }
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
                    New-Alias -Name $Name -Value $Value -Scope Global -Option AllScope -ErrorAction SilentlyContinue
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
                        $PathName = $_.Parent.Name
                        $FullPathName = $_.Parent.FullName
                        $g++
                        $this._log(
                            "Found git project @ $($FullPathName)",
                            'FindProjects',
                            'Verbose'
                        )
                        $currPath = $_
                        while ($this.GitPathMap.ContainsKey($PathName)) {
                            $currPath = $currPath.Parent
                            $doublePath = [System.IO.DirectoryInfo]::new($this.GitPathMap[$PathName])
                            $this.GitPathMap["$($doublePath.Parent.Name)$([System.IO.Path]::DirectorySeparatorChar)$($doublePath.Name)"] = $doublePath.FullName
                            $this.GitPathMap.Remove($PathName)
                            if ($this.PSBuildPathMap.ContainsKey($PathName)) {
                                $PSBuildPath = [System.IO.DirectoryInfo]::new($this.PSBuildPathMap[$PathName])
                                $this.PSBuildPathMap["$($PSBuildPath.Parent.Name)$([System.IO.Path]::DirectorySeparatorChar)$($PSBuildPath.Name)"] = $doublePath.FullName
                                $this.PSBuildPathMap.Remove($PathName)
                            }
                            $PathName = "$($currPath.Parent.BaseName)$([System.IO.Path]::DirectorySeparatorChar)$PathName"
                        }
                        $this.GitPathMap[$PathName] = $FullPathName
                        $bldPath = [System.IO.Path]::Combine($FullPathName,'build.ps1')
                        if ([System.IO.File]::Exists($bldPath)) {
                            $b++
                            $this._log(
                                "Found build script @ $($bldPath)",
                                'FindProjects',
                                'Verbose'
                            )
                            $this.PSBuildPathMap[$PathName] = $FullPathName
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
                            $newModuleArgs = @{
                                Name = "PSProfile.ScriptPath.$($i.BaseName)"
                                ScriptBlock = $sb
                                ReturnResult = $true
                            }
                            $this._log(
                                "'$($i.Name)' Importing dynamic ScriptPath module: $($newModuleArgs.Name)",
                                'InvokeScripts',
                                'Verbose'
                            )
                            New-Module @newModuleArgs | Import-Module -Global
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
    hidden [void] _invokeInitScripts() {
        $this._log(
            "SECTION START",
            "InvokeInitScripts",
            "Debug"
        )
        $this.InitScripts.GetEnumerator() | ForEach-Object {
            $s = $_
            if ($_.Value.Enabled) {
                $this._log(
                    "Invoking Init Script: $($s.Key)",
                    "InvokeInitScripts",
                    "Verbose"
                )
                try {
                    $sb = [scriptblock]::Create($this._globalize($s.Value.ScriptBlock))
                    $newModuleArgs = @{
                        Name = "PSProfile.InitScript.$($s.Key)"
                        ScriptBlock = $sb
                        ReturnResult = $true
                    }
                    $this._log(
                        "'$($s.Key)' Importing dynamic InitScript module: $($newModuleArgs.Name)",
                        'InvokeInitScripts',
                        'Verbose'
                    )
                    New-Module @newModuleArgs | Import-Module -Global
                }
                catch {
                    $this._log(
                        "Error while invoking InitScript '$($s.Key)': $($_.Exception.Message)",
                        "InvokeInitScripts",
                        "Warning"
                    )
                }
            }
            else {
                $this._log(
                    "Skipping disabled Init Script: $($_.Key)",
                    "InvokeInitScripts",
                    "Verbose"
                )
            }
        }
        $this._log(
            "SECTION END",
            "InvokeInitScripts",
            "Debug"
        )
    }
    hidden [void] _installModules() {
        $this._log(
            "SECTION START",
            'InstallModules',
            'Debug'
        )
        if (-not [string]::IsNullOrEmpty((-join $this.ModulesToInstall))) {
            $null = $this.ModulesToInstall | Where-Object { ($_ -is [hashtable] -and $_.Name) -or ($_ -is [string] -and -not [string]::IsNullOrEmpty($_.Trim())) } | Start-RSJob -Name { "_PSProfile_InstallModule_$($_)" } -VariablesToImport this -ScriptBlock {
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
            $this.ModulesToImport | Where-Object { ($_ -is [hashtable] -and $_.Name) -or ($_ -is [string] -and -not [string]::IsNullOrEmpty($_.Trim())) } | ForEach-Object {
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
                        if ($params.Name -ne 'EditorServicesCommandSuite') {
                            Import-Module @params -Global -ErrorAction SilentlyContinue -Verbose:$false
                            $this._log(
                                "Module imported: $($params | ConvertTo-Json -Compress)",
                                'ImportModules',
                                'Verbose'
                            )
                        }
                        elseif ($params.Name -eq 'EditorServicesCommandSuite' -and $psEditor) {
                            Import-Module EditorServicesCommandSuite -ErrorAction SilentlyContinue -Global -Force -Verbose:$false
                            # Twice because: https://github.com/SeeminglyScience/EditorServicesCommandSuite/issues/40
                            Import-Module EditorServicesCommandSuite -ErrorAction SilentlyContinue -Global -Force -Verbose:$false
                            Import-EditorCommand -Module EditorServicesCommandSuite -Force -Verbose:$false
                            $this._log(
                                "Module imported: $($params | ConvertTo-Json -Compress)",
                                'ImportModules',
                                'Verbose'
                            )
                        }
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
                        "'$($params['Name'])' Error importing module: $($_.Exception.Message)",
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
                    if ($_.Name -ne 'PSProfile.PowerTools') {
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
                                Global      = $true
                            }
                            if ($plugin.ArgumentList) {
                                $importParams['ArgumentList'] = $plugin.ArgumentList
                            }
                            [string[]]$pathsToSearch = @($this.PluginPaths)
                            $env:PSModulePath.Split([System.IO.Path]::PathSeparator) | ForEach-Object {
                                $pathsToSearch += $_
                            }
                            foreach ($plugPath in $pathsToSearch) {
                                $fullPath = [System.IO.Path]::Combine($plugPath,"$($plugin.Name).ps1")
                                $paths = Get-ChildItem $plugPath -Filter "$($plugin.Name)*" | Where-Object {$_.Name -match "$($plugin.Name)\.psm*1$"}
                                if ($paths.Count -gt 1) {
                                    $fullPath = $paths.FullName | Where-Object {$_ -match 'psm1$'} | Select-Object -First 1
                                }
                                else {
                                    $fullPath = $paths.FullName | Select-Object -First 1
                                }
                                $this._log(
                                    "'$($plugin.Name)' Checking path: $fullPath",
                                    'LoadPlugins',
                                    'Debug'
                                )
                                if (Test-Path $fullPath) {
                                    $sb = [scriptblock]::Create($this._globalize(([System.IO.File]::ReadAllText($fullPath))))
                                    $newModuleArgs = @{
                                        Name = "PSProfile.Plugin.$($plugin.Name -replace '^PSProfile\.')"
                                        ScriptBlock = $sb
                                        ReturnResult = $true
                                    }
                                    if ($plugin.ArgumentList) {
                                        $newModuleArgs['ArgumentList'] = $plugin.ArgumentList
                                    }
                                    $this._log(
                                        "'$($plugin.Name)' Importing dynamic Plugin module: $($newModuleArgs.Name)",
                                        'LoadPlugins',
                                        'Verbose'
                                    )
                                    New-Module @newModuleArgs | Import-Module -Global
                                    $found = $fullPath
                                    break
                                }
                            }
                            if ($null -ne $found) {
                                $this._log(
                                    "'$($plugin.Name)' plugin loaded from path: $found",
                                    'LoadPlugins',
                                    'Verbose'
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
                                        "'$($plugin.Name)' plugin not found! To remove this plugin from your profile, run 'Remove-PSProfilePlugin $($plugin.Name)'",
                                        'LoadPlugins',
                                        'Warning'
                                    )
                                }
                            }
                        }
                        catch {
                            throw
                        }
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
