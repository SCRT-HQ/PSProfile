[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [String]
    $Prompt
)

function Get-Prompt {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [Switch]
        $Global,
        [Parameter()]
        [Switch]
        $Raw
    )
    $i = 0
    $leadingWhiteSpace = $null
    $g = if ($Global) {
        'global:prompt'
    }
    else {
        'prompt'
    }
    $(if ($Raw) {
            ''
        }
        else {
            "function $g {`n"
        }) + $((Get-Command prompt).Definition -split "`n" | ForEach-Object {
            if (-not [String]::IsNullOrWhiteSpace($_)) {
                if ($null -eq $leadingWhiteSpace) {
                    $leadingWhiteSpace = ($_ | Select-String -Pattern '^\s+').Matches[0].Value
                }
                $_ -replace "^$leadingWhiteSpace",'    '
                "`n"
            }
            elseif ($i) {
                $_
                "`n"
            }
            $i++
        }) + $(if ($Raw) {
            ''
        }
        else {
            "}"
        })
}

function Get-PSVersion {
    [OutputType('System.String')]
    [CmdletBinding()]
    Param (
        [parameter(Position = 0)]
        [AllowNull()]
        [int]
        $Places = $global:PSProfile.Settings.PSVersionStringLength
    )
    Process {
        $version = $PSVersionTable.PSVersion.ToString()
        if ($null -ne $Places) {
            $split = ($version -split '\.')[0..($Places - 1)]
            if ("$($split[-1])".Length -gt 1) {
                $split[-1] = "$($split[-1])".Substring(0,1)
            }
            $joined = $split -join '.'
            if ($version -match '[a-zA-Z]+') {
                $joined += "-$(($Matches[0]).Substring(0,1))"
                if ($version -match '\d+$') {
                    $joined += $Matches[0]
                }
            }
            $joined
        }
        else {
            $version
        }
    }
}

function Test-IfGit {
    [CmdletBinding()]
    Param ()
    Process {
        try {
            $topLevel = git rev-parse --show-toplevel *>&1
            if ($topLevel -like 'fatal: *') {
                $Global:Error.Remove($Global:Error[0])
                $false
            }
            else {
                $origin = git remote get-url origin
                $repo = Split-Path -Leaf $origin
                [PSCustomObject]@{
                    TopLevel = (Resolve-Path $topLevel).Path
                    Origin   = $origin
                    Repo     = $(if ($repo -notmatch '(\.git|\.ssh|\.tfs)$') {
                            $repo
                        }
                        else {
                            $repo.Substring(0,($repo.LastIndexOf('.')))
                        })
                }
            }
        }
        catch {
            $false
            $Global:Error.Remove($Global:Error[0])
        }
    }
}

function Get-PathAlias {
    [CmdletBinding()]
    Param (
        [parameter(Position = 0)]
        [string]
        $Path = $PWD.Path,
        [parameter(Position = 1)]
        [string]
        $DirectorySeparator = $(if ($null -ne $global:PathAliasDirectorySeparator) {
                $global:PathAliasDirectorySeparator
            }
            else {
                [System.IO.Path]::DirectorySeparatorChar
            })
    )
    Begin {
        try {
            $origPath = $Path
            if ($null -eq $global:PSProfile) {
                $global:PSProfile = @{
                    Settings     = @{
                        PSVersionStringLength = 3
                    }
                    PathAliasMap = @{
                        '~' = $env:USERPROFILE
                    }
                }
            }
            elseif ($null -eq $global:PSProfile._internal) {
                $global:PSProfile._internal = @{
                    PathAliasMap = @{
                        '~' = $env:USERPROFILE
                    }
                }
            }
            elseif ($null -eq $global:PSProfile._internal.PathAliasMap) {
                $global:PSProfile._internal.PathAliasMap = @{
                    '~' = $env:USERPROFILE
                }
            }
            if ($gitRepo = Test-IfGit) {
                $gitIcon = [char]0xe0a0
                $key = $gitIcon + $gitRepo.Repo
                if (-not $global:PSProfile._internal.PathAliasMap.ContainsKey($key)) {
                    $global:PSProfile._internal.PathAliasMap[$key] = $gitRepo.TopLevel
                }
            }
            $leaf = Split-Path $Path -Leaf
            if (-not $global:PSProfile._internal.PathAliasMap.ContainsKey('~')) {
                $global:PSProfile._internal.PathAliasMap['~'] = $env:USERPROFILE
            }
            Write-Verbose "Alias map => JSON: $($global:PSProfile._internal.PathAliasMap | ConvertTo-Json -Depth 5)"
            $aliasKey = $null
            $aliasValue = $null
            foreach ($hash in $global:PSProfile._internal.PathAliasMap.GetEnumerator() | Sort-Object { $_.Value.Length } -Descending) {
                if ($Path -like "$($hash.Value)*") {
                    $Path = $Path.Replace($hash.Value,$hash.Key)
                    $aliasKey = $hash.Key
                    $aliasValue = $hash.Value
                    Write-Verbose "AliasKey [$aliasKey] || AliasValue [$aliasValue]"
                    break
                }
            }
        }
        catch {
            Write-Error $_
            return $origPath
        }
    }
    Process {
        try {
            if ($null -ne $aliasKey -and $origPath -eq $aliasValue) {
                Write-Verbose "Matched original path! Returning alias base path"
                $finalPath = $Path
            }
            elseif ($null -ne $aliasKey) {
                Write-Verbose "Matched alias key [$aliasKey]! Returning path alias with leaf"
                $drive = "$($aliasKey)\"
                $finalPath = if ((Split-Path $origPath -Parent) -eq $aliasValue) {
                    "$($drive)$($leaf)"
                }
                else {
                    "$($drive)$([char]0x2026)\$($leaf)"
                }
            }
            else {
                $drive = (Get-Location).Drive.Name + ':\'
                Write-Verbose "Matched base drive [$drive]! Returning base path"
                $finalPath = if ($Path -eq $drive) {
                    $drive
                }
                elseif ((Split-Path $Path -Parent) -eq $drive) {
                    "$($drive)$($leaf)"
                }
                else {
                    "$($drive)..\$($leaf)"
                }
            }
            if ($DirectorySeparator -notin @($null,([System.IO.Path]::DirectorySeparatorChar))) {
                $finalPath.Replace(([System.IO.Path]::DirectorySeparatorChar),$DirectorySeparator)
            }
            else {
                $finalPath
            }
        }
        catch {
            Write-Error $_
            return $origPath
        }
    }
}

function Get-Elapsed {
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]
        $Id,
        [Parameter()]
        [string]
        $Format = "{0:h\:mm\:ss\.ffff}"
    )
    $null = $PSBoundParameters.Remove("Format")
    $LastCommand = Get-History -Count 1 @PSBoundParameters
    if (!$LastCommand) {
        return "0:00:00.0000"
    }
    elseif ($null -ne $LastCommand.Duration) {
        $Format -f $LastCommand.Duration
    }
    else {
        $Duration = $LastCommand.EndExecutionTime - $LastCommand.StartExecutionTime
        $Format -f $Duration
    }
}

function Set-Prompt {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    Param(
        [Parameter(Mandatory,Position = 0,ParameterSetName = 'Name')]
        [String]
        $Name,
        [Parameter(ParameterSetName = 'Name')]
        [switch]
        $Temporary,
        [Parameter(Mandatory,ParameterSetName = 'Content')]
        [object]
        $Content
    )
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            Name {
                if ($global:PSProfile.Prompts.ContainsKey($Name)) {
                    $function:prompt = $global:PSProfile.Prompts[$Name]
                    if (-not $Temporary) {
                        $global:PSProfile.Settings.DefaultPrompt = $Name
                        $global:PSProfile.Save()
                    }
                }
                else {
                    Write-Warning "Falling back to default prompt -- '$Name' not found in Configuration prompts!"
                    $function:prompt = '
                        "PS $($executionContext.SessionState.Path.CurrentLocation)$(''>'' * ($nestedPromptLevel + 1)) ";
                        # .Link
                        # https://go.microsoft.com/fwlink/?LinkID=225750
                        # .ExternalHelp System.Management.Automation.dll-help.xml
                    '
                }
            }
            Content {
                $function:prompt = $Content
            }
        }
    }
}

function Save-Prompt {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [String]
        $Name = $global:PSProfile.Settings.DefaultPrompt,
        [Parameter()]
        [object]
        $Content,
        [Parameter()]
        [switch]
        $SetAsDefault
    )
    Process {
        if ($null -eq $Name) {
            throw "No value set for the Name parameter or resolved from PSProfile!"
        }
        else {
            if ($Content) {
                $global:PSProfile.Prompts[$Name] = $Content.ToString()
            }
            else {
                $global:PSProfile.Prompts[$Name] = Get-Prompt -Raw
            }
            if ($SetAsDefault) {
                $global:PSProfile.Settings.DefaultPrompt = $Name
            }
            $global:PSProfile.Save()
        }
    }
}

function Edit-Prompt {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [String]
        $EditorString = '{0} | code -',
        [Parameter()]
        [Switch]
        $Temporary
    )
    Process {
        $in = @{
            StdIn   = Get-Prompt -Global
            TmpFile = [System.IO.Path]::Combine(([System.IO.Path]::GetTempPath()),"ps-prompt-$(-join ((97..(97+25)|%{[char]$_}) | Get-Random -Count 3)).ps1")
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
                    Invoke-Expression ([System.IO.File]::ReadAllText($in.TmpFile))
                    Remove-Item $in.TmpFile -Force
                }
            }
        }
        Write-Verbose "Opening prompt in VS Code"
        .$handler($in)
        if (-not $Temporary) {
            Save-Prompt
        }
    }
}

Export-ModuleMember -Function '*-*'

if (
    $null -ne $global:PSProfile -and
    $null -eq $global:PSProfile.Prompts
) {
    $global:PSProfile.Settings.DefaultPrompt = 'Default'
    $global:PSProfile.Prompts = @{
        Default = $function:prompt.ToString()
    }
    $global:PSProfile.Save()
}

if ($null -ne (Get-Command Get-PSProfileArguments*)) {
    Register-ArgumentCompleter -CommandName 'Set-Prompt' -ParameterName 'Name' -ScriptBlock {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
        Get-PSProfileArguments -WordToComplete "Prompts.$wordToComplete" -FinalKeyOnly
    }
}

if (
    $null -ne $global:PSProfile -and
    $null -ne $global:PSProfile.Settings.DefaultPrompt
) {
    Set-Prompt -Name $global:PSProfile.Settings.DefaultPrompt
}
