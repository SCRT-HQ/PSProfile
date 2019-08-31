function Start-PSProfileConfigurationHelper {
    <#
    .SYNOPSIS
    Starts the PSProfile Configuration Helper.

    .DESCRIPTION
    Starts the PSProfile Configuration Helper.

    .EXAMPLE
    Start-PSProfileConfigurationHelper
    #>
    [CmdletBinding()]
    Param ()
    Begin {
        Write-Verbose "Starting PSProfile Configuration Helper..."
        $color = @{
            Tip = "Green"
            Command = "Cyan"
            Warning = "Yellow"
            Current = "Magenta"
        }
        $header = {
            param([string]$title)
            @(
                "----------------------------------"
                "| $($title.ToUpper())"
                "----------------------------------"
            ) -join "`n"
        }
        $changes = [System.Collections.Generic.List[string]]::new()
        $tip = {
            param([string]$text)
            "TIP: $text" | Write-Host -ForegroundColor $color['Tip']
        }
        $command = {
            param([string]$text)
            "COMMAND: $text" | Write-Host -ForegroundColor $color['Command']
        }
        $warning = {
            param([string]$text)
            Write-Warning -Message $text
        }
        $current = {
            param([string]$item)
            "EXISTING : $item" | Write-Host -ForegroundColor $color['Current']
        }
        $multi = {
            .$tip("This accepts multiple answers as comma-separated values, e.g. 1,2,5")
        }
    }
    Process {
        @(
            ""
            "Welcome to PSProfile! This Configuration Helper serves as a way to jump-start"
            "your PSProfile configuration and increase your workflow productivity quickly."
            ""
            "You'll be asked a few questions to help with setting up your PSProfile,"
            "including being provided information around performing the same configuration"
            "tasks using the included functions after your initial setup is complete."
            ""
            "If you have any questions, comments or find any bugs, please open an issue"
            "on the PSProfile repo: https://github.com/scrthq/PSProfile/issues/new"
        ) | Write-Host
        $legend = {
            "" | Write-Host
            .$header("Legend") | Write-Host
            .$tip("$($color['Tip']) - Helpful tips and tricks")
            .$command("$($color['Command']) - Commands to run to replicate the configuration update made")
            .$warning("$($color['Warning']) - Any warnings to be aware of")
            .$current("$($color['Current']) - Any existing configuration values for this section")
            "" | Write-Host
        }
        .$legend

        $menu = {
            "" | Write-Host
            .$header("Menu") | Write-Host
            $options = @(
                "Choose a PSProfile concept below to learn more and optionally update"
                "the configuration for it as well:"
                ""
                "1  - Command Aliases"
                "2  - Modules to Import"
                "3  - Modules to Install"
                "4  - Path Aliases"
                "5  - Plugin Paths"
                "6  - Plugins"
                "7  - Project Paths"
                "8  - Prompts"
                "9  - Script Paths"
                "10 - Secrets"
                "11 - Symbolic Links"
                "12 - Variables"
                ""
                "Addtional options:"
                "13 - Configuration"
                "14 - Helpers"
                "15 - Meta"
                ""
                "*  - All concepts"
                ""
                "X  - Exit"
                ""
            )
            $options | Write-Host
            .$multi
            "" | Write-Host
            Read-Host -Prompt "Enter your choice(s)"
        }
        $choices = .$menu
        if ($choices -match "X") {
            "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
            return
        }
        else {
            "Concepts chosen:" | Write-Host
            if ($choices -match '\*') {
                $options | Select-String "^\*\s+\-\s" | Write-Host
                $resolved = @(1..15)
            }
            else {
                $resolved = $choices.Split(',').Trim() | Where-Object {-not [string]::IsNullOrEmpty($_)}
                $resolved | ForEach-Object {
                    $item = $_
                    $options | Select-String "^$item\s+\-\s" | Write-Host
                }
            }
            foreach ($choice in $resolved) {
                "" | Write-Host
                $topic = (($options | Select-String "^$choice\s+\-\s") -replace "^$choice\s+\-\s(.*$)",'$1').Trim()
                .$header($topic)
                $helpTopic = 'about_PSProfile_' + ($topic -replace ' ','_')
                "Getting the HelpTopic for this concept: $helpTopic" | Write-Host
                Get-Help $helpTopic -Category HelpFile
                .$tip("To view this conceptual HelpTopic at any time, run the following command:")
                .$command("Get-Help $helpTopic")
                "" | Write-Host
                switch ($choice) {
                    1 {
                        if ($Global:PSProfile.CommandAliases.Keys.Count) {
                            .$current("`n$(([PSCustomObject]$Global:PSProfile.CommandAliases | Format-List | Out-String).Trim())")
                        }
                        Write-Host "Would you like to add a Command Alias to your PSProfile?"
                        $decision = Read-Host "[Y]es | [N]o"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the command you would like to add an alias for (ex: Test-Path)"
                                    $item2 = Read-Host "Please enter the alias that you would like to set for the command (ex: tp)"
                                    .$command("Add-PSProfileCommandAlias -Command '$item1' -Alias '$item2'")
                                    Add-PSProfileCommandAlias -Command $item1 -Alias $item2 -Verbose
                                    $changes.Add("Command Aliases:")
                                    $changes.Add("  - Comman")
                                }
                            }
                            "`nWould you like to add another $topic to your PSProfile?" | Write-Host
                            $decision = Read-Host "[Y]es | [N]o"
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    2 {

                    }
                    3 {

                    }
                    4 {

                    }
                    5 {

                    }
                    6 {

                    }
                    7 {

                    }
                    8 {

                    }
                    9 {

                    }
                    10 {

                    }
                    11 {

                    }
                    12 {

                    }
                    13 {

                    }
                    14 {

                    }
                }
            }
        }
    }
}
