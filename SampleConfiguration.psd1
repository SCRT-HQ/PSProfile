@{
    Vault            = @{
        _secrets = @{ }
    }
    PathAliases      = @{}
    Prompts          = @{
        Basic     = '
            "PS $($executionContext.SessionState.Path.CurrentLocation)$(''>'' * ($nestedPromptLevel + 1)) ";
            # .Link
            # https://go.microsoft.com/fwlink/?LinkID=225750
            # .ExternalHelp System.Management.Automation.dll-help.xml
        '
        Fast      = '
            $lastStatus = $?
            $lastColor = if ($lastStatus -eq $true) {
                ''Green''
            }
            else {
                "Red"
            }
            Write-Host "[" -NoNewline
            Write-Host -ForegroundColor Cyan "#$($MyInvocation.HistoryId)" -NoNewline
            Write-Host "] " -NoNewline
            Write-Host "[" -NoNewline
            Write-Host -ForegroundColor $lastColor ("{0}" -f (Get-Elapsed)) -NoNewline
            Write-Host "] [" -NoNewline
            Write-Host ("{0}" -f $(Get-PathAlias)) -NoNewline -ForegroundColor DarkYellow
            Write-Host "]" -NoNewline
            if ($PWD.Path -notlike "\\*" -and (Test-IfGit)) {
                Write-VcsStatus
                $GitPromptSettings.EnableWindowTitle =  ''PS {0} @'' -f (Get-PSVersion)
            }
            else {
                $Host.UI.RawUI.WindowTitle = ''PS {0}'' -f (Get-PSVersion)
            }
            Write-Host "`n[" -NoNewLine
            $verColor = @{
                ForegroundColor = if ($PSVersionTable.PSVersion.Major -eq 7) {
                    ''Yellow''
                }
                elseif ($PSVersionTable.PSVersion.Major -eq 6) {
                    ''Magenta''
                }
                else {
                    ''Cyan''
                }
            }
            Write-Host @verColor ("PS {0}" -f (Get-PSVersion)) -NoNewline
            Write-Host "]" -NoNewLine
            $(''>'' * ($nestedPromptLevel + 1) + '' '')
        '
        BasicPlus = '
            -join @(
                ''<# PS {0} | '' -f (Get-PSVersion)
                Get-PathAlias
                '' #> ''
            )
        '
        Demo      = '
            $lastStatus = $?
            Write-Host "CMD# " -NoNewline
            Write-Host -ForegroundColor Green "[$($MyInvocation.HistoryId)] " -NoNewline
            #Write-Host -ForegroundColor Cyan "[$((Get-Location).Path.Replace($env:HOME,''~''))] " -NoNewline
            $lastColor = if ($lastStatus -eq $true) {
                "Yellow"
            }
            else {
                "Red"
            }
            Write-Host "| Dir: " -NoNewLine
            Write-Host -ForegroundColor Cyan "[$(Get-PathAlias)] " -NoNewline
            Write-Host "| Last: " -NoNewLine
            Write-Host -ForegroundColor $lastColor "[$(Get-Elapsed)] " -NoNewline
            if ($PWD.Path -notlike "\\*" -and (Test-IfGit)) {
                Write-Host "| Git:" -NoNewLine
                Write-VcsStatus
                $GitPromptSettings.EnableWindowTitle =  ''PS {0} @'' -f (Get-PSVersion)
            }
            else {
                $Host.UI.RawUI.WindowTitle = ''PS {0}'' -f (Get-PSVersion)
            }
            Write-Host "`nPS " -NoNewline
            $verColor = if ($PSVersionTable.PSVersion.Major -lt 6) {
                @{
                    ForegroundColor = ''Cyan''
                    BackgroundColor = $host.UI.RawUI.BackgroundColor
                }
            }
            elseif ($PSVersionTable.PSVersion.Major -eq 6) {
                @{
                    ForegroundColor = $host.UI.RawUI.BackgroundColor
                    BackgroundColor = ''Cyan''
                }
            }
            elseif ($PSVersionTable.PSVersion.Major -eq 7) {
                @{
                    ForegroundColor = $host.UI.RawUI.BackgroundColor
                    BackgroundColor = ''Yellow''
                }
            }
            Write-Host @verColor ("[{0}]" -f (Get-PSVersion)) -NoNewline
            (''>'' * ($nestedPromptLevel + 1)) + '' ''
        '
        Original  = '
            $ra = [char]0xe0b0
            $fg = @{
                ForegroundColor = $Host.UI.RawUI.BackgroundColor
            }
            $cons = if ($psEditor) {
                ''Code''
            }
            elseif ($env:ConEmuPID) {
                ''ConEmu''
            }
            else {
                ''PS''
            }
            switch ($PSVersionTable.PSVersion.Major) {
                5 {
                    $idColor = ''Green''
                    $verColor = ''Cyan''
                }
                6 {
                    $idColor = ''Cyan''
                    $verColor = ''Green''
                }
                7 {
                    $idColor = ''Cyan''
                    $verColor = ''Yellow''
                }
            }
            Write-Host @fg -BackgroundColor $idColor "$ra[$($MyInvocation.HistoryId)]" -NoNewline
            Write-Host -ForegroundColor $idColor $ra -NoNewline
            Write-Host @fg -BackgroundColor $verColor "$ra[$("PS {0}" -f (Get-PSVersion))]" -NoNewline
            Write-Host -ForegroundColor $verColor $ra -NoNewline
            if ($PWD.Path -notlike "\\*" -and (Test-IfGit)) {
                Write-Host @fg -BackgroundColor Yellow "$ra[$(Get-Elapsed) @ $(Get-Date -Format T)]" -NoNewline
                Write-Host -ForegroundColor Yellow $ra -NoNewline
                Write-VcsStatus
                Write-Host ""
                $GitPromptSettings.EnableWindowTitle =  ''PS {0} @'' -f (Get-PSVersion)
            }
            else {
                $Host.UI.RawUI.WindowTitle = ''PS {0}'' -f (Get-PSVersion)
                Write-Host @fg -BackgroundColor Yellow "$ra[$(Get-Elapsed) @ $(Get-Date -Format T)]" -NoNewline
                Write-Host -ForegroundColor Yellow $ra
            }
            Write-Host @fg -BackgroundColor Magenta "$ra[$(Get-PathAlias)]" -NoNewline
            Write-Host -ForegroundColor Magenta $ra -NoNewline
            Write-Host "`n[I " -NoNewline
            Write-Host -ForegroundColor Red "$([char]9829)" -NoNewline
            " $cons]$(''>'' * ($nestedPromptLevel + 1)) "
        '
        Slim      = '
            $lastStatus = $?
            $lastColor = if ($lastStatus -eq $true) {
                ''Green''
            }
            else {
                "Red"
            }
            Write-Host "[" -NoNewline
            Write-Host -ForegroundColor Cyan "#$($MyInvocation.HistoryId)" -NoNewline
            Write-Host "] " -NoNewline
            Write-Host "[" -NoNewline
            Write-Host -ForegroundColor $lastColor ("{0}" -f (Get-Elapsed)) -NoNewline
            Write-Host "] [" -NoNewline
            Write-Host ("{0}" -f $(Get-PathAlias)) -NoNewline -ForegroundColor DarkYellow
            Write-Host "]" -NoNewline
            if ($PWD.Path -notlike "G:\GDrive\GoogleApps*" -and $env:DisablePoshGit -ne $true -and $global:_useGit -and (Test-IfGit)) {
                Write-VcsStatus
                $GitPromptSettings.EnableWindowTitle =  ''PS {0} @'' -f (Get-PSVersion)
            }
            else {
                $Host.UI.RawUI.WindowTitle = ''PS {0}'' -f (Get-PSVersion)
            }
            Write-Host "`n[" -NoNewLine
            $verColor = @{
                ForegroundColor = if ($PSVersionTable.PSVersion.Major -eq 7) {
                    ''Yellow''
                }
                elseif ($PSVersionTable.PSVersion.Major -eq 6) {
                    ''Magenta''
                }
                else {
                    ''Cyan''
                }
            }
            Write-Host @verColor ("PS {0}" -f (Get-PSVersion)) -NoNewline
            Write-Host "]" -NoNewLine
            $(''>'' * ($nestedPromptLevel + 1) + '' '')
        '
        SlimDrop  = '    $lastStatus = $?
            $lastColor = if ($lastStatus -eq $true) {
            ''Green''
            }
            else {
            "Red"
            }
            Write-Host "[" -NoNewline
            Write-Host -ForegroundColor Cyan "PSP#$($MyInvocation.HistoryId)" -NoNewline
            Write-Host "] " -NoNewline
            Write-Host "[" -NoNewLine
            $verColor = @{
            ForegroundColor = if ($PSVersionTable.PSVersion.Major -eq 7) {
            ''Yellow''
            }
            elseif ($PSVersionTable.PSVersion.Major -eq 6) {
            ''Magenta''
            }
            else {
            ''Cyan''
            }
            }
            Write-Host @verColor ("PS {0}" -f (Get-PSVersion)) -NoNewline
            Write-Host "] " -NoNewline
            Write-Host "[" -NoNewline
            Write-Host -ForegroundColor $lastColor ("{0}" -f (Get-Elapsed)) -NoNewline
            Write-Host "] [" -NoNewline
            Write-Host ("{0}" -f $(Get-PathAlias)) -NoNewline -ForegroundColor DarkYellow
            Write-Host "]" -NoNewline
            if ($PWD.Path -notlike "\\*" -and $env:DisablePoshGit -ne $true -and (Test-IfGit)) {
            Write-VcsStatus
            $GitPromptSettings.EnableWindowTitle = ''PS {0} @'' -f (Get-PSVersion)
            }
            else {
            $Host.UI.RawUI.WindowTitle = ''PS {0}'' -f (Get-PSVersion)
            }
            "`n>> "
        '
        Rayner    = '
            $global:errorStatus = if ($?) {
                22
            }
            else {
                1
            }
            $global:platform = if ($isWindows) {
                11
            }
            else {
                117
            }
            $global:lArrow = [char]0xe0b2
            $global:rArrow = [char]0xe0b0
            $escape = "$([char]27)"
            $foreground = "$escape[38;5"
            $background = "$escape[48;5"
            $prompt = ''''

            $gitTest = $PWD.Path -notlike "\\*" -and (Test-IfGit)
            if ($gitTest) {
                $branch = git symbolic-ref --short -q HEAD
                $aheadbehind = git status -sb
                $distance = ''''
                if (-not [string]::IsNullOrEmpty($(git diff --staged))) {
                    $branchbg = 3
                }
                else {
                    $branchbg = 5
                }
                if (-not [string]::IsNullOrEmpty($(git status -s))) {
                    $arrowfg = 3
                }
                else {
                    $arrowfg = 5
                }
                if ($aheadbehind -match ''\[\w+.*\w+\]$'') {
                    $ahead = [regex]::matches($aheadbehind, ''(?<=ahead\s)\d+'').value
                    $behind = [regex]::matches($aheadbehind, ''(?<=behind\s)\d+'').value
                    $distance = "$background;15m$foreground;${arrowfg}m{0}$escape[0m" -f $rArrow
                    if ($ahead) {
                        $distance += "$background;15m$foreground;${forePromptColor}m{0}$escape[0m" -f "a$ahead"
                    }
                    if ($behind) {
                        $distance += "$background;15m$foreground;${forePromptColor}m{0}$escape[0m" -f "b$behind"
                    }
                    $distance += "$foreground;15m{0}$escape[0m" -f $rArrow
                }
                else {
                    $distance = "$foreground;${arrowfg}m{0}$escape[0m" -f $rArrow
                }
                [System.Collections.Generic.List[ScriptBlock]]$gitPrompt = @(
                    { "$background;${branchbg}m$foreground;14m{0}$escape[0m" -f $rArrow }
                    { "$background;${branchbg}m$foreground;${forePromptColor}m{0}$escape[0m" -f $branch }
                    { "{0}$escape[0m" -f $distance }
                )
                $prompt = -join @($global:PromptLeft + $gitPrompt + { " " }).Invoke()
            }
            else {
                $prompt = -join @($global:PromptLeft + { "$foreground;14m{0}$escape[0m" -f $rArrow } + { " " }).Invoke()
            }
            $rightPromptString = -join ($global:promptRight).Invoke()
            $offset = $global:host.UI.RawUI.BufferSize.Width - 24
            $returnedPrompt = -join @($prompt, "$escape[${offset}G", $rightPromptString, "$escape[0m" + ("`n`r`PS {0}.{1}> " -f $PSVersionTable.PSVersion.Major,$PSVersionTable.PSVersion.Minor))
            $returnedPrompt
        '
        Clean     = '
            $global:CleanNumber++
            -join @(
                ''[CLN#''
                $global:CleanNumber
                ''] [''
                [Math]::Round((Get-History -Count 1).Duration.TotalMilliseconds,0)
                ''ms] ''
                $(Get-PathAlias)
                ("`n[PS {0}" -f (Get-PSVersion))
                '']>> ''
            )
        '
    }
    SymbolicLinks    = @{}
    ScriptPaths      = @()
    ModulesToImport  = @('posh-git')
    Variables        = @{
        Environment = @{}
        Global      = @{
            AltPathAliasDirectorySeparator = ''
            PathAliasDirectorySeparator    = '\'
        }
    }
    Plugins          = @(@{
            Arguments = @{
                amend   = '!git add -A && git commit --amend --no-edit'
                stg     = 'checkout stg'
                a       = '!git add . && git status'
                dev     = 'checkout dev'
                conl    = '!git --no-pager config --local --list'
                con     = '!git --no-pager config --list'
                pu      = '!git push -u origin `$(git branch | grep \* | cut -d '' '' -f2)'
                cons    = '!git --no-pager config --list --show-origin'
                s       = 'status'
                cm      = 'commit -m'
                b       = 'branch'
                master  = 'checkout master'
                cam     = 'commit -am'
                f       = 'fetch --all'
                ba      = 'branch --all'
                d       = '!git --no-pager diff'
                c       = 'commit'
                ss      = 'status -s'
                alias   = '!git config --get-regexp ''^alias\.'' | sort'
                aa      = '!git add . && git add -u . && git status'
                current = '!git branch | grep \* | cut -d '' '' -f2'
                p       = '!git push'
                co      = 'checkout'
                pf      = '!git push -f'
                llg     = 'log --color --graph --pretty=format:''%C(bold white)%H %d%Creset%n%s%n%+b%C(bold blue)%an <%ae>%Creset %C(bold green)%cr (%ci)'' --abbrev-commit'
                n       = 'checkout -b'
                fp      = 'fetch --all --prune'
                au      = '!git add -u . && git status'
                lg      = 'log --color --graph --pretty=format:''%C(bold white)%h%Creset -%C(bold green)%d%Creset %s %C(bold green)(%cr)%Creset %C(bold blue)<%an>%Creset'' --abbrev-commit --date=relative'
                l       = 'log --graph --all --pretty=format:''%C(yellow)%h%C(cyan)%d%Creset %s %C(white)- %an, %ar%Creset'''
                conls   = '!git --no-pager config --local --list --show-origin'
                ll      = 'log --stat --abbrev-commit'
                acm     = '!git add . && git commit -m'
                ca      = 'commit --amend # careful'
                ac      = '!git add . && git commit'
            }
            Name      = 'PSProfile.GitAliases'
        },@{
            Name = 'PSProfile.Prompt'
        },@{
            Name = 'PSProfile.PowerTools'
        })
    GitPathMap       = @{}
    PSBuildPathMap   = @{}
    ProjectPaths     = @()
    PluginPaths      = @()
    Settings         = @{
        DefaultPrompt         = 'SlimDrop'
        PSVersionStringLength = 3
    }
    ModulesToInstall = @('')
}
