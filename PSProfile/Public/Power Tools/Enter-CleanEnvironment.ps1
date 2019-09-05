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
    Begin {
        $parsedEngine = if ($Engine -eq 'pwsh-preview' -and ($PSVersionTable.PSVersion.Major -le 5 -or $IsWindows)) {
            "& '{0}'" -f (Resolve-Path ([System.IO.Path]::Combine((Split-Path (Get-Command pwsh-preview).Source -Parent),'..','pwsh.exe'))).Path
        }
        else {
            $Engine
        }
    }
    Process {
        $verboseMessage = "Creating clean environment...`n           Engine  : $Engine"
        $command = "$parsedEngine -NoProfile -NoExit -C `"```$global:CleanNumber = 0;if (```$null -ne (Get-Module PSReadline)) {Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete;Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward;Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward;Set-PSReadLineKeyHandler -Chord 'Ctrl+W' -Function BackwardKillWord;Set-PSReadLineKeyHandler -Chord 'Ctrl+z' -Function MenuComplete;Set-PSReadLineKeyHandler -Chord 'Ctrl+D' -Function KillWord};"
        if ($ImportModule) {
            if (($modName = (Get-ChildItem .\BuildOutput -Directory).BaseName)) {
                $modPath = '.\BuildOutput\' + $modName
                $verboseMessage += "`n           Module  : $modName"
                $command += "Import-Module '$modPath' -Verbose:```$false;Get-Module $modName;"
            }
        }
        $newline = '`n'
        $command += "function global:prompt {```$global:CleanNumber++;'[CLN#' + ```$global:CleanNumber + '] [' + [Math]::Round((Get-History -Count 1).Duration.TotalMilliseconds,0) + 'ms] ' + (Get-Location).Path.Replace(```$env:Home,'~') + '$newline[PS ' + ```$PSVersionTable.PSVersion.ToString() + ']>> '}`""
        $verboseMessage += "`n           Command : $command"
        Write-Verbose $verboseMessage
        Invoke-Expression $command
    }
}
