[CmdletBinding()]
Param()
function Get-Definition {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory,Position = 0)]
        [String]
        $Command
    )
    Process {
        try {
            $Definition = (Get-Command $Command -ErrorAction Stop).Definition
            "function $Command {$Definition}"
        }
        catch {
            throw
        }
    }
}

Set-Alias -Name def -Value Get-Definition -Option AllScope -Scope Global

Register-ArgumentCompleter -CommandName 'Get-Definition' -ParameterName 'Command' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Command "$wordToComplete*").Name | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function Open-Code {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    Param (
        [parameter(Mandatory,Position = 0,ParameterSetName = 'Path')]
        [parameter(Position = 0,ParameterSetName = 'InputObject')]
        [String]
        $Path,
        [parameter(ParameterSetName = 'Path')]
        [parameter(ParameterSetName = 'Cookbook')]
        [Alias('add','a')]
        [Switch]
        $AddToWorkspace,
        [parameter(ValueFromPipeline,ParameterSetName = 'InputObject')]
        [Object]
        $InputObject,
        [parameter(ParameterSetName = 'InputObject')]
        [Alias('l','lang','Extension')]
        [String]
        $Language = 'txt',
        [parameter(ValueFromPipeline,ParameterSetName = 'InputObject')]
        [Alias('w')]
        [Switch]
        $Wait,
        [parameter(ValueFromRemainingArguments)]
        [Object]
        $Arguments
    )
    DynamicParam {
        if ($global:PSProfile.GitPathMap.ContainsKey('chef-repo')) {
            $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
            $ParamAttrib.Mandatory = $true
            $ParamAttrib.ParameterSetName = 'Cookbook'
            $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttribColl.Add($ParamAttrib)
            $set = (Get-ChildItem (Join-Path $global:PSProfile.GitPathMap['chef-repo'] 'cookbooks') -Directory).Name
            $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($set)))
            $AttribColl.Add((New-Object System.Management.Automation.AliasAttribute('c')))
            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Cookbook',  [string], $AttribColl)
            $RuntimeParamDic.Add('Cookbook',  $RuntimeParam)
        }
        return  $RuntimeParamDic
    }
    Begin {
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            $collection = New-Object System.Collections.Generic.List[object]
            $extDict = @{
                txt = 'txt'
                powershell = 'ps1'
                csv = 'csv'
                sql = 'sql'
                xml = 'xml'
                json = 'json'
                yml = 'yml'
                csharp = 'cs'
                fsharp = 'fs'
                ruby = 'rb'
                html = 'html'
                css = 'css'
                go = 'go'
                jsonc = 'jsonc'
                javascript = 'js'
                typescript = 'ts'
                less = 'less'
                log = 'log'
                python = 'py'
                razor = 'cshtml'
                markdown = 'md'
            }
        }
    }
    Process {
        $code = (Get-Command code -All | Where-Object { $_.CommandType -notin @('Function','Alias') })[0].Source
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            $collection.Add($InputObject)
        }
        else {
            $target = switch ($PSCmdlet.ParameterSetName) {
                Path {
                    if ($PSBoundParameters['Path'] -eq '.') {
                        $PWD.Path
                    }
                    elseif ($null -ne $global:PSProfile.GitPathMap.Keys) {
                        if ($global:PSProfile.GitPathMap.ContainsKey($PSBoundParameters['Path'])) {
                            $global:PSProfile.GitPathMap[$PSBoundParameters['Path']]
                        }
                        else {
                            $PSBoundParameters['Path']
                        }
                    }
                    else {
                        $PSBoundParameters['Path']
                    }
                }
                Cookbook {
                    [System.IO.Path]::Combine($global:PSProfile.GitPathMap['chef-repo'],'cookbooks',$PSBoundParameters['Cookbook'])
                }
            }
            if ($AddToWorkspace) {
                Write-Verbose "Running command: code --add $($PSBoundParameters[$PSCmdlet.ParameterSetName]) $Arguments"
                & $code --add $target $Arguments
            }
            else {
                Write-Verbose "Running command: code $($PSBoundParameters[$PSCmdlet.ParameterSetName]) $Arguments"
                & $code $target $Arguments
            }
        }
    }
    End {
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            $ext = if ($extDict.ContainsKey($Language)) {
                $extDict[$Language]
            } else {
                $Language
            }
            $in = @{
                StdIn = $collection
                TmpFile = [System.IO.Path]::Combine(([System.IO.Path]::GetTempPath()),"code-stdin-$(-join ((97..(97+25)|%{[char]$_}) | Get-Random -Count 3)).$ext")
            }
            $handler = {
                Param(
                    [hashtable]
                    $in
                )
                try {
                    $code = (Get-Command code -All | Where-Object { $_.CommandType -notin @('Function','Alias') })[0].Source
                    $in.StdIn | Set-Content $in.TmpFile -Force
                    & $code $in.TmpFile --wait
                }
                catch {
                    throw
                }
                finally {
                    if (Test-Path $in.TmpFile -ErrorAction SilentlyContinue) {
                        Remove-Item $in.TmpFile -Force
                    }
                }
            }
            if (-not $Wait) {
                Write-Verbose "Piping input to Code: `$in | Start-Job {code -}"
                Start-Job -ScriptBlock $handler -ArgumentList $in
            }
            else {
                Write-Verbose "Piping input to Code: `$in | code -"
                .$handler($in)
            }
        }
    }
}

New-Alias -Name code -Value 'Open-Code' -Scope Global -Option AllScope -Force

if ($null -ne $global:PSProfile -and $null -ne $global:PSProfile.GitPathMap.Keys) {
    Register-ArgumentCompleter -CommandName 'Open-Code' -ParameterName 'Path' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $global:PSProfile.GitPathMap.Keys| Where-Object {$_ -like "$wordToComplete*"} | Sort-Object | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

Register-ArgumentCompleter -CommandName 'Open-Code' -ParameterName 'Language' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    'txt','powershell','csv','sql','xml','json','yml','csharp','fsharp','ruby','html','css','go','jsonc','javascript','typescript','less','log','python','razor','markdown' | Sort-Object | Where-Object {$_ -like "$wordToComplete*"} | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function Install-LatestModule {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String]
        $Name,
        [Parameter()]
        [Switch]
        $ConfirmNotImported
    )
    Process {
        if ($ConfirmNotImported -and (Get-Module $Name)) {
            throw "$Name cannot be loaded if trying to install!"
        }
        else {
            try {
                # Uninstall all installed versions
                Get-Module $Name -ListAvailable | Uninstall-Module -Verbose

                # Install the latest module from the PowerShell Gallery
                Install-Module $Name -Repository PSGallery -Scope CurrentUser -Verbose -AllowClobber -SkipPublisherCheck -AcceptLicense

                # Import the freshly installed module
                Import-Module $Name

                # Test that everything still works as expected
                Get-GSUser | Select-Object @{N="ModuleVersion";E={(Get-Module $Name).Version}},PrimaryEmail,OrgUnitPath
            } catch {
                throw
            }
        }
    }
}

Register-ArgumentCompleter -CommandName 'Install-LatestModule' -ParameterName 'Name' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Module "$wordToComplete*" -ListAvailable).Name | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function Open-Item {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    Param (
        [parameter(Position = 0,ParameterSetName = 'Path')]
        [String]
        $Path = $PWD.Path
    )
    DynamicParam {
        if ($global:PSProfile.GitPathMap.ContainsKey('chef-repo')) {
            $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
            $ParamAttrib.Mandatory = $true
            $ParamAttrib.ParameterSetName = 'Cookbook'
            $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttribColl.Add($ParamAttrib)
            $set = (Get-ChildItem (Join-Path $global:PSProfile.GitPathMap['chef-repo'] 'cookbooks') -Directory).Name
            $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($set)))
            $AttribColl.Add((New-Object System.Management.Automation.AliasAttribute('c')))
            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Cookbook',  [string], $AttribColl)
            $RuntimeParamDic.Add('Cookbook',  $RuntimeParam)
        }
        return  $RuntimeParamDic
    }
    Begin {
        if (-not $PSBoundParameters.ContainsKey('Path')) {
            $PSBoundParameters['Path'] = $PWD.Path
        }
    }
    Process {
        $target = switch ($PSCmdlet.ParameterSetName) {
            Path {
                if ($PSBoundParameters['Path'] -eq '.') {
                    $PWD.Path
                }
                elseif ($null -ne $global:PSProfile.GitPathMap.Keys) {
                    if ($global:PSProfile.GitPathMap.ContainsKey($PSBoundParameters['Path'])) {
                        $global:PSProfile.GitPathMap[$PSBoundParameters['Path']]
                    }
                    else {
                        $PSBoundParameters['Path']
                    }
                }
                else {
                    $PSBoundParameters['Path']
                }
            }
            Cookbook {
                [System.IO.Path]::Combine($global:PSProfile.GitPathMap['chef-repo'],'cookbooks',$PSBoundParameters['Cookbook'])
            }
        }
        Write-Verbose "Running command: Invoke-Item $($PSBoundParameters[$PSCmdlet.ParameterSetName])"
        Invoke-Item $target
    }
}

if ($null -ne $global:PSProfile -and $null -ne $global:PSProfile.GitPathMap.Keys) {
    Register-ArgumentCompleter -CommandName 'Open-Item' -ParameterName 'Path' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $global:PSProfile.GitPathMap.Keys| Where-Object {$_ -like "$wordToComplete*"} | Sort-Object | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

New-Alias -Name open -Value 'Open-Item' -Scope Global -Option AllScope -Force


function Push-Path {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory,Position = 0,ParameterSetName = 'Path')]
        [String]
        $Path
    )
    DynamicParam {
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        if ($global:PSProfile.GitPathMap.ContainsKey('chef-repo')) {
            $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
            $ParamAttrib.Mandatory = $true
            $ParamAttrib.ParameterSetName = 'Cookbook'
            $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttribColl.Add($ParamAttrib)
            $set = (Get-ChildItem (Join-Path $global:PSProfile.GitPathMap['chef-repo'] 'cookbooks') -Directory).Name
            $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($set)))
            $AttribColl.Add((New-Object System.Management.Automation.AliasAttribute('c')))
            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Cookbook',  [string], $AttribColl)
            $RuntimeParamDic.Add('Cookbook',  $RuntimeParam)
        }
        return  $RuntimeParamDic
    }
    Process {
        $target = switch ($PSCmdlet.ParameterSetName) {
            Path {
                if ($global:PSProfile.GitPathMap.ContainsKey($PSBoundParameters['Path'])) {
                    $global:PSProfile.GitPathMap[$PSBoundParameters['Path']]
                }
                else {
                    $PSBoundParameters['Path']
                }
            }
            Cookbook {
                [System.IO.Path]::Combine($global:PSProfile.GitPathMap['chef-repo'],'cookbooks',$PSBoundParameters['Cookbook'])
            }
        }
        Write-Verbose "Pushing location to: $($target.Replace($env:HOME,'~'))"
        Push-Location $target
    }
}

New-Alias -Name push -Value Push-Path -Option AllScope -Scope Global -Force
New-Alias -Name pop -Value Pop-Location -Option AllScope -Scope Global -Force

if ($null -ne $global:PSProfile -and $null -ne $global:PSProfile.GitPathMap.Keys) {
    Register-ArgumentCompleter -CommandName 'Push-Path' -ParameterName 'Path' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $global:PSProfile.GitPathMap.Keys| Where-Object {$_ -like "$wordToComplete*"} | Sort-Object | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

function Get-Gist {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position = 0)]
        [String]
        $Id,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('Files')]
        [String[]]
        $File,
        [parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Sha,
        [parameter(ValueFromPipelineByPropertyName,ValueFromRemainingArguments)]
        [Object]
        $Metadata,
        [parameter()]
        [Switch]
        $Invoke
    )
    Process {
        $Uri = [System.Collections.Generic.List[string]]@(
            'https://api.github.com'
            '/gists/'
            $PSBoundParameters['Id']
        )
        if ($PSBoundParameters.ContainsKey('Sha')) {
            $Uri.Add("/$($PSBoundParameters['Sha'])")
            Write-Verbose "[$($PSBoundParameters['Id'])] Getting gist info @ SHA '$($PSBoundParameters['Sha'])'"
        }
        else {
            Write-Verbose "[$($PSBoundParameters['Id'])] Getting gist info"
        }
        $gistInfo = Invoke-RestMethod -Uri ([Uri](-join $Uri)) -Verbose:$false
        $fileNames = if ($PSBoundParameters.ContainsKey('File')) {
            $PSBoundParameters['File']
        }
        else {
            $gistInfo.files.PSObject.Properties.Name
        }
        foreach ($fileName in $fileNames) {
            Write-Verbose "[$fileName] Getting gist file content"
            $fileInfo = $gistInfo.files.$fileName
            $content = if ($fileInfo.truncated) {
                (Invoke-WebRequest -Uri ([Uri]$fileInfo.raw_url)).Content
            }
            else {
                $fileInfo.content
            }
            $lines = ($content -split "`n").Count
            if ($Invoke) {
                Write-Verbose "[$fileName] Parsing gist file content ($lines lines)"
                $noScopePattern = '^function\s+(?<Name>[\w+_-]{1,})\s+\{'
                $globalScopePattern = '^function\s+global\:'
                $noScope = [RegEx]::Matches($content, $noScopePattern, "Multiline, IgnoreCase")
                $globalScope = [RegEx]::Matches($content,$globalScopePattern,"Multiline, IgnoreCase")
                if ($noScope.Count -ge $globalScope.Count) {
                    foreach ($match in $noScope) {
                        $fullValue = ($match.Groups | Where-Object { $_.Name -eq 0 }).Value
                        $funcName = ($match.Groups | Where-Object { $_.Name -eq 'Name' }).Value
                        Write-Verbose "[$fileName::$funcName] Updating function to global scope to ensure it imports correctly."
                        $content = $content.Replace($fullValue, "function global:$funcName {")
                    }
                }
                Write-Verbose "[$fileName] Invoking gist file content"
                $ExecutionContext.InvokeCommand.InvokeScript(
                    $false,
                    ([scriptblock]::Create($content)),
                    $null,
                    $null
                )
            }
            [PSCustomObject]@{
                File    = $fileName
                Sha     = $Sha
                Count   = $lines
                Content = $content -join "`n"
            }
        }
    }
}

function Enter-CleanEnvironment {
    [CmdletBinding()]
    Param (
        [parameter(Position = 0)]
        [ValidateSet('powershell','pwsh','pwsh-preview')]
        [Alias('E')]
        [String]
        $Engine = $(if ($PSVersionTable.PSVersion.ToString() -match 'preview') {
            'pwsh-preview'
        }
        elseif ($PSVersionTable.PSVersion.Major -ge 6) {
            'pwsh'
        }
        else {
            'powershell'
        }),
        [Parameter()]
        [Alias('ipmo','Import')]
        [Switch]
        $ImportModule
    )
    Process {
        $verboseMessage = "Creating clean environment...`n           Engine : $Engine"
        $command = "$Engine -NoProfile -NoExit -C `"```$global:CleanNumber = 0;if (```$null -ne (Get-Module PSReadline)) {Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete;Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward;Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward;Set-PSReadLineKeyHandler -Chord 'Ctrl+W' -Function BackwardKillWord;Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function MenuComplete;Set-PSReadLineKeyHandler -Chord 'Ctrl+D' -Function KillWord;};function global:prompt {```$global:CleanNumber++;'[CLN#' + ```$global:CleanNumber + '] [' + [Math]::Round((Get-History -Count 1).Duration.TotalMilliseconds,0) + 'ms] ' + ```$((Get-Location).Path.Replace(```$env:Home,'~')) + '```n[PS ' + ```$PSVersionTable.PSVersion.ToString() + ']>> '};"
        if ($ImportModule) {
            if (($modName = (Get-ChildItem .\BuildOutput -Directory).BaseName)) {
                $modPath = '.\BuildOutput\' + $modName
                $verboseMessage += "`n           Module : $modName"
                $command += "Import-Module '$modPath' -Verbose:```$false;Get-Module $modName"
            }
        }
        $command += '"'
        Write-Verbose $verboseMessage
        Invoke-Expression $command
    }
}

New-Alias -Name cln -Value Enter-CleanEnvironment -Option AllScope -Scope Global -Force

function Start-BuildScript {
    [CmdletBinding(PositionalBinding = $false)]
    Param (
        [parameter()]
        [Alias('ne')]
        [Switch]
        $NoExit,
        [parameter()]
        [Alias('nr')]
        [Switch]
        $NoRestore
    )
    DynamicParam {
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory = $false
        $ParamAttrib.Position = 0
        $AttribColl.Add($ParamAttrib)
        $set = @()
        $set += $global:PSProfile.PSBuildPathMap.Keys
        $set += '.'
        $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($set)))
        $AttribColl.Add((New-Object System.Management.Automation.AliasAttribute('p')))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Project',  [string], $AttribColl)
        $RuntimeParamDic.Add('Project',  $RuntimeParam)

        $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory = $false
        $ParamAttrib.Position = 1
        $AttribColl.Add($ParamAttrib)
        $bldFile = Join-Path $PWD.Path "build.ps1"
        $set = if (Test-Path $bldFile) {
            ((([System.Management.Automation.Language.Parser]::ParseFile($bldFile, [ref]$null, [ref]$null)).ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'Task' }).Attributes | Where-Object { $_.TypeName.Name -eq 'ValidateSet' }).PositionalArguments.Value
        }
        else {
            @('Clean','Build','Import','Test','Deploy')
        }
        $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($set)))
        $AttribColl.Add((New-Object System.Management.Automation.AliasAttribute('t')))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Task',  [string[]], $AttribColl)
        $RuntimeParamDic.Add('Task',  $RuntimeParam)

        $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Mandatory = $false
        $ParamAttrib.Position = 2
        $AttribColl.Add($ParamAttrib)
        $set = @('powershell','pwsh','pwsh-preview')
        $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($set)))
        $AttribColl.Add((New-Object System.Management.Automation.AliasAttribute('e')))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Engine',  [string], $AttribColl)
        $RuntimeParamDic.Add('Engine',  $RuntimeParam)

        return  $RuntimeParamDic
    }
    Process {
        if (-not $PSBoundParameters.ContainsKey('Project')) {
            $PSBoundParameters['Project'] = '.'
        }
        if (-not $PSBoundParameters.ContainsKey('Engine')) {
            $PSBoundParameters['Engine'] = switch ($PSVersionTable.PSVersion.Major) {
                5 {
                    'powershell'
                }
                default {
                    if ($PSVersionTable.PSVersion.PreReleaseLabel) {
                        'pwsh-preview'
                    }
                    else {
                        'pwsh'
                    }
                }
            }
        }
        $parent = switch ($PSBoundParameters['Project']) {
            '.' {
                $PWD.Path
            }
            default {
                $global:PSProfile.PSBuildPathMap[$PSBoundParameters['Project']]
            }
        }
        $command = "$($PSBoundParameters['Engine']) -NoProfile -C `"```$env:NoNugetRestore = "
        if ($NoRestore) {
            $command += "```$true;"
        }
        else {
            $command += "```$false;"
        }
        $command += "Set-Location '$parent'; . .\build.ps1"
        if ($PSBoundParameters.ContainsKey('Task')) {
            $command += " -Task '$($PSBoundParameters['Task'] -join "','")'"
        }
        $command += '"'
        Write-Verbose "Invoking expression: $command"
        Invoke-Expression $command
        if ($NoExit) {
            Push-Location $parent
            Enter-CleanEnvironment -Engine $PSBoundParameters['Engine'] -ImportModule
            Pop-Location
        }
    }
}

if ($null -ne $global:PSProfile -and $null -ne $global:PSProfile.PSBuildPathMap.Keys) {
    Register-ArgumentCompleter -CommandName 'Start-BuildScript' -ParameterName 'Project' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        $global:PSProfile.PSBuildPathMap.Keys | Where-Object {$_ -like "$wordToComplete*"} | Sort-Object | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

New-Alias -Name bld -Value Start-BuildScript -Option AllScope -Scope Global -Force

function Format-Syntax {
    [CmdletBinding()]
    param (
        $Command
    )
    $check = Get-Command -Name $Command
    $params = @{
        Name   = if ($check.CommandType -eq 'Alias') {
            Get-Command -Name $check.Definition
        }
        else {
            $Command
        }
        Syntax = $true
    }
    (Get-Command @params) -replace '(\s(?=\[)|\s(?=-))', "`r`n "
}

New-Alias -Name Syntax -Value Format-Syntax -Option AllScope -Scope Global -Force
