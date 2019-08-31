function Show-Menu {
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory,Position = 0)]
        [string]
        $Title,
        [Parameter(Mandatory,Position = 1)]
        [string]
        $Menu,
        [Parameter(Position = 2)]
        [string]
        $Prompt = "Please choose the desired option(s)",
        [Parameter()]
        [System.ConsoleColor]
        $TitleColor = $Host.UI.RawUI.ForegroundColor,
        [Parameter()]
        [string]
        $Header,
        [Parameter()]
        [System.ConsoleColor]
        $HeaderColor = $Host.UI.RawUI.ForegroundColor,
        [Parameter()]
        [switch]
        $Clear
    )
    if ($Clear) {
        Clear-Host
        $script:HostHeader = $true
    }
    if ($Header) {
        Write-Host -ForegroundColor $HeaderColor $Header
    }
    Write-Host -ForegroundColor $TitleColor "$title`n$("-" * $title.Length)`n"
    Write-Host "$($Menu.Trim())`n"
    Read-Host -Prompt $Prompt
}
