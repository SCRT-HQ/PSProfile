[CmdletBinding()]
Param()
function Get-Definition {
    <#
    .SYNOPSIS
    Convenience function to easily get the defition of a function

    .DESCRIPTION
    Convenience function to easily get the defition of a function

    .PARAMETER Command
    The command or function to get the definition for

    .EXAMPLE
    Get-Definition Open-Code

    .EXAMPLE
    def Open-Code

    Uses the shorter alias to get the definition of the Open-Code function
    #>
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
    <#
    .SYNOPSIS
    A drop-in replacement for the Visual Studio Code CLI `code`. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .DESCRIPTION
    A drop-in replacement for the Visual Studio Code CLI `code`. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .PARAMETER Path
    The path of the file or folder to open with Code. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .PARAMETER Cookbook
    If you are using Chef and have your chef-repo folder in your GitPaths, this will allow you to specify a cookbook path to open from the Cookbooks subfolder.

    .PARAMETER AddToWorkspace
    If $true, adds the folder to the current Code workspace.

    .PARAMETER InputObject
    Pipeline input to display as a temporary file in Code. Temp files are automatically cleaned up after the file is closed in Code. No need to add the `-` after `code` to specify that pipeline input is expected.

    .PARAMETER Language
    The language or extension of the temporary file created from the pipeline input. This allows specifying a file type like 'powershell' or 'csv' or an extension like 'ps1', enabling opening of the temp file with the editor file language already set correctly.

    .PARAMETER Wait
    If $true, waits for the file to be closed in Code before returning to the prompt. If $false, opens the file using a background job to allow immediately returning to the prompt. Defaults to $false.

    .PARAMETER Arguments
    Any additional arguments to be passed directly to the Code CLI command, e.g. `Open-Code --list-extensions` or `code --list-extensions` will still work the same as expected.

    .EXAMPLE
    Get-Process | ConvertTo-Csv | Open-Code -Language csv

    Gets the current running processes, converts to CSV format and opens it in Code via background job as a CSV. Easy Out-GridView!

    .EXAMPLE
    def Update-PSProfileSetting | code -l ps1

    Using shorter aliases, gets the current function definition of the Update-PSProfileSetting function and opens it in Code as a PowerShell file to take advantage of immediate syntax highlighting.
    #>
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
                txt        = 'txt'
                powershell = 'ps1'
                csv        = 'csv'
                sql        = 'sql'
                xml        = 'xml'
                json       = 'json'
                yml        = 'yml'
                csharp     = 'cs'
                fsharp     = 'fs'
                ruby       = 'rb'
                html       = 'html'
                css        = 'css'
                go         = 'go'
                jsonc      = 'jsonc'
                javascript = 'js'
                typescript = 'ts'
                less       = 'less'
                log        = 'log'
                python     = 'py'
                razor      = 'cshtml'
                markdown   = 'md'
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
            }
            else {
                $Language
            }
            $in = @{
                StdIn   = $collection
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

if ($null -ne (Get-Command Get-PSProfileArguments*)) {
    Register-ArgumentCompleter -CommandName 'Open-Code' -ParameterName 'Path' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly
    }
}

Register-ArgumentCompleter -CommandName 'Open-Code' -ParameterName 'Language' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    'txt','powershell','csv','sql','xml','json','yml','csharp','fsharp','ruby','html','css','go','jsonc','javascript','typescript','less','log','python','razor','markdown' | Sort-Object | Where-Object { $_ -like "$wordToComplete*" } | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function Install-LatestModule {
    <#
    .SYNOPSIS
    A helper function to uninstall any existing versions of the target module before installing the latest one.

    .DESCRIPTION
    A helper function to uninstall any existing versions of the target module before installing the latest one. Defaults to CurrentUser scope when installing the latest module version from the desired repository.

    .PARAMETER Name
    The name of the module to install the latest version of

    .PARAMETER Repository
    The PowerShell repository to install the latest module from. Defaults to the PowerShell Gallery.

    .PARAMETER ConfirmNotImported
    If $true, safeguards module removal if the module you are trying to update is currently imported by throwing a terminating error.

    .EXAMPLE
    Install-LatestModule PSProfile
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]
        $Name,
        [Parameter()]
        [String]
        $Repository = 'PSGallery',
        [Parameter()]
        [Switch]
        $ConfirmNotImported
    )
    Process {
        foreach ($module in $Name) {
            if ($ConfirmNotImported -and (Get-Module $module)) {
                throw "$module cannot be loaded if trying to install!"
            }
            else {
                try {
                    Write-Verbose "Uninstalling all version of module: $module"
                    Get-Module $module -ListAvailable | Uninstall-Module
                    Write-Verbose "Installing latest module version from PowerShell Gallery"
                    Install-Module $module -Repository $Repository -Scope CurrentUser -AllowClobber -SkipPublisherCheck -AcceptLicense
                }
                catch {
                    throw
                }
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
    <#
    .SYNOPSIS
    Opens the item specified using Invoke-Item. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .DESCRIPTION
    Opens the item specified using Invoke-Item. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .PARAMETER Path
    The path you would like to open. Supports anything that Invoke-Item normally supports, i.e. files, folders, URIs.

    .PARAMETER Cookbook
    If you are using Chef and have your chef-repo folder in your GitPaths, this will allow you to specify a cookbook path to open from the Cookbooks subfolder.

    .EXAMPLE
    Open-Item

    Opens the current path in Explorer/Finder/etc.

    .EXAMPLE
    open

    Uses the shorter alias to open the current path

    .EXAMPLE
    open MyWorkRepo

    Opens the folder for the Git Repo 'MyWorkRepo' in Explorer/Finder/etc.
    #>

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

if ($null -ne (Get-Command Get-PSProfileArguments*)) {
    Register-ArgumentCompleter -CommandName 'Open-Item' -ParameterName 'Path' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly
    }
}

New-Alias -Name open -Value 'Open-Item' -Scope Global -Option AllScope -Force


function Push-Path {
    <#
    .SYNOPSIS
    Pushes your current location to the path specified. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .DESCRIPTION
    Pushes your current location to the path specified. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .PARAMETER Path
    The path you would like to push your location to.

    .PARAMETER Cookbook
    If you are using Chef and have your chef-repo folder in your GitPaths, this will allow you to specify a cookbook path to push your location to from the Cookbooks subfolder.

    .EXAMPLE
    Push-Path MyWorkRepo

    Changes your current directory to your Git Repo named 'MyWorkRepo'.

    .EXAMPLE
    push MyWorkRepo

    Same as the first example but using the shorter alias.

    .NOTES
    Since Push-Location is being called from a function, Pop-Location doesn't have any actual effect after :-(. This is effectively Set-Location, given that caveat.
    #>

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

if ($null -ne (Get-Command Get-PSProfileArguments*)) {
    Register-ArgumentCompleter -CommandName 'Push-Path' -ParameterName 'Path' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly
    }
}

function Get-Gist {
    <#
    .SYNOPSIS
    Gets a GitHub Gist's contents using the public API

    .DESCRIPTION
    Gets a GitHub Gist's contents using the public API

    .PARAMETER Id
    The ID of the Gist to get

    .PARAMETER File
    The specific file from the Gist to get. If excluded, gets all of the files as an array of objects.

    .PARAMETER Sha
    The SHA of the specific Gist to get, if desired.

    .PARAMETER Metadata
    Any additional metadata you want to include on the resulting object, e.g. for identifying what the Gist is, add notes, etc.

    .PARAMETER Invoke
    If $true, invokes the Gist contents. If the Gist contains any PowerShell functions, it will adjust the scope to Global before invoking so the function remains available in the session after Get-Gist finishes. Useful for loading functions directly from a Gist.

    .EXAMPLE
    Get-Gist -Id f784228937183a1cf8105351872d2f8a -Invoke

    Gets the Update-Release and Test-GetGist functions from the following Gist URL and loads them into the current session for subsequent use: https://gist.github.com/scrthq/f784228937183a1cf8105351872d2f8a
    #>

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
        [parameter(ValueFromPipelineByPropertyName)]
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
                File     = $fileName
                Sha      = $Sha
                Lines    = $lines
                Metadata = $Metadata
                Content  = $content -join "`n"
            }
        }
    }
}

function Enter-CleanEnvironment {
    <#
    .SYNOPSIS
    Enters a clean environment with -NoProfile and sets a couple helpers, e.g. a prompt to advise you are in a clean environment and some PSReadline helper settings for convenience.

    .DESCRIPTION
    Enters a clean environment with -NoProfile and sets a couple helpers, e.g. a prompt to advise you are in a clean environment and some PSReadline helper settings for convenience.

    .PARAMETER Engine
    The engine to open the clean environment with between powershell, pwsh, and pwsh-preview. Defaults to the current engine the clean environment is opened from.

    .PARAMETER ImportModule
    If $true, imports the module found in the BuildOutput folder if present. Useful for quickly testing compiled modules after building in a clean environment to avoid assembly locking and other gotchas.

    .EXAMPLE
    Enter-CleanEnvironment

    Opens a clean environment from the current path.

    .EXAMPLE
    cln

    Does the same as Example 1, but using the shorter alias 'cln'.

    .EXAMPLE
    cln -ipmo

    Enters the clean environment and imports the built module in the BuildOutput folder, if present.
    #>
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
    <#
    .SYNOPSIS
    For those using the typical build.ps1 build scripts for PowerShell projects, this will allow invoking the build script quickly from wherever folder you are currently in using a child process.

    .DESCRIPTION
    For those using the typical build.ps1 build scripts for PowerShell projects, this will allow invoking the build script quickly from wherever folder you are currently in using a child process. Any projects in the ProjectPaths list that were discovered during PSProfile load and have a build.ps1 file will be able to be tab-completed for convenience. Temporarily sets the path to the build folder, invokes the build.ps1 file, then returns to the original path that it was invoked from.

    .PARAMETER Project
    The path of the project to build. Allows tab-completion of PSBuildPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .PARAMETER Task
    The list of Tasks to specify to the build.ps1 script.

    .PARAMETER Engine
    The engine to open the clean environment with between powershell, pwsh, and pwsh-preview. Defaults to the current engine the clean environment is opened from.

    .PARAMETER NoExit
    If $true, does not exit the child process once build.ps1 has completed and imports the built module in BuildOutput (if present to allow testing of the built project in a clean environment.

    .PARAMETER NoRestore
    If $true, sets $env:NoNugetRestore to $false to prevent NuGet package restoration (if applicable).

    .EXAMPLE
    Start-BuildScript MyModule -NoExit

    Changes directories to the repo root of MyModule, invokes build.ps1, imports the compiled module in a clean child process and stops before exiting to allow testing of the newly compiled module.

    .EXAMPLE
    bld MyModule -ne

    Same experience as Example 1 but uses the shorter alias 'bld' to call. Also uses the parameter alias `-ne` instead of `-NoExit`
    #>
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

if ($null -ne (Get-Command Get-PSProfileArguments*)) {
    Register-ArgumentCompleter -CommandName 'Start-BuildScript' -ParameterName 'Project' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-PSProfileArguments -WordToComplete "PSBuildPathMap.$wordToComplete" -FinalKeyOnly
    }
}

New-Alias -Name bld -Value Start-BuildScript -Option AllScope -Scope Global -Force

function Format-Syntax {
    <#
    .SYNOPSIS
    Formats a command's syntax in an easy-to-read view.

    .DESCRIPTION
    Formats a command's syntax in an easy-to-read view.

    .PARAMETER Command
    The command to get the syntax of.

    .EXAMPLE
    Format-Syntax Get-Process

    Gets the formatted syntax by parameter set for Get-Process

    .EXAMPLE
    syntax Get-Process

    Same as Example 1, but uses the alias 'syntax' instead.
    #>
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

New-Alias -Name syntax -Value Format-Syntax -Option AllScope -Scope Global -Force

function Get-LongPath {
    <#
    .SYNOPSIS
    Expands a short-alias from the GitPathMap to the full path

    .DESCRIPTION
    Expands a short-alias from the GitPathMap to the full path

    .PARAMETER Path
    The short path to expand

    .PARAMETER Subpaths
    Any subpaths to join to the main path before resolving.

    .EXAMPLE
    Get-LongPath MyWorkRepo

    Gets the full path to MyWorkRepo

    .EXAMPLE
    path MyWorkRepo

    Same as Example 1, but uses the short-alias 'path' instead.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    Param (
        [parameter(Position = 0,ParameterSetName = 'Path')]
        [String]
        $Path = $PWD.Path,
        [parameter(ValueFromRemainingArguments,Position = 1,ParameterSetName = 'Path')]
        [String[]]
        $Subpaths
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
        if ($Subpaths) {
            Join-Path $target ($Subpaths -join [System.IO.Path]::DirectorySeparatorChar)
        }
        else {
            $target
        }
    }
}

if ($null -ne (Get-Command Get-PSProfileArguments*)) {
    Register-ArgumentCompleter -CommandName 'Get-LongPath' -ParameterName 'Path' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly
    }
}

New-Alias -Name path -Value 'Get-LongPath' -Scope Global -Option AllScope -Force
