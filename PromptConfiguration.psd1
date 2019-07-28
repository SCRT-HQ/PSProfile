@{
    Prompts          = @{
        Basic     = '
            "PS $($executionContext.SessionState.Path.CurrentLocation)$(''>'' * ($nestedPromptLevel + 1)) ";
            # .Link
            # https://go.microsoft.com/fwlink/?LinkID=225750
            # .ExternalHelp System.Management.Automation.dll-help.xml
        '
        BasicPlus = '
            -join @(
                ''<# PS {0} | '' -f (Get-PSVersion)
                Get-PathAlias
                '' #> ''
            )
        '
        Detailed  = '    $lastStatus = $?
        $lastColor = if ($lastStatus -eq $true) {
        ''Green''
        }
        else {
        "Red"
        }
        if ($PSVersionTable.PSVersion.Major -le 5 -or $IsWindows) {
          $os = ''WIN''
          $idCol = ''Cyan''
        }
        elseif ($IsLinux) {
          $os = ''LIN''
          $idCol = ''Green''
        }
        elseif ($IsMacOS) {
          $os = ''MAC''
          $idCol = ''Yellow''
        }
        else {
          $os = ''''
          $idCol = ''White''
        }
        Write-Host "[" -NoNewline
        Write-Host -ForegroundColor $idCol "$($os)#$($MyInvocation.HistoryId)" -NoNewline
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
}
