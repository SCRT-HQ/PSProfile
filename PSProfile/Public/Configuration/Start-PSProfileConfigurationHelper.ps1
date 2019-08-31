function Start-PSProfileConfigurationHelper {
    [CmdletBinding()]
    Param ()
    Begin {
        Write-Verbose "Starting PSProfile Configuration Helper..."
        $_color = @{
            Tip = "Green"
            Command = "Cyan"
            Warning = "Yellow"
            Current = "Magenta"
        }
        $_header = {
            param([string]$title)
            @(
                "----------------------------------"
                "| $($title.ToUpper())"
                "----------------------------------"
            ) -join "`n"
        }
        $_changes = [System.Collections.Generic.List[string]]::new()
        $_tip = {
            param([string]$text)
            "TIP: $text" | Write-Host -ForegroundColor $_color['Tip']
        }
        $_command = {
            param([string]$text)
            "COMMAND: $text" | Write-Host -ForegroundColor $_color['Command']
        }
        $_warning = {
            param([string]$text)
            "WARNING: $text" | Write-Host -ForegroundColor $_color['Warning']
        }
        $_current = {
            param([string]$text)
            "CURRENT: $text" | Write-Host -ForegroundColor $_color['Current']
        }
        $_multi = {
            .$_tip("This accepts multiple answers as comma-separated values, e.g. 1,2,5")
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
        $_legend = {
            "" | Write-Host
            .$_header("Legend") | Write-Host
            .$_tip("$($_color['Tip']) - Helpful tips and tricks")
            .$_command("$($_color['Command']) - Commands to run to replicate the configuration update made")
            .$_warning("$($_color['Warning']) - Any warnings to be aware of")
            .$_current("$($_color['Current']) - Any existing configuration values for this section")
            "" | Write-Host
        }
        .$_legend

        $_menu = {
            "" | Write-Host
            .$_header("Menu") | Write-Host
            $_options = @(
                "Choose a PSProfile concept below to learn more and optionally update"
                "the configuration for it as well:"
                ""
                "1  - Command Aliases"
                "2  - Modules to Import"
                "3  - Modules to Install"
                "4  - Path Aliases"
                "5  - Plugins"
                "6  - Project Paths"
                "7  - Prompts"
                "8  - Script Paths"
                "9  - Secrets"
                "10 - Symbolic Links"
                "11 - Variables"
                ""
                "Addtional options:"
                "12 - Configuration Functions"
                "13 - Helper Functions"
                "14 - Meta Functions"
                ""
                "*  - All concepts"
                ""
                "X  - Exit"
            )
            $_options | Write-Host
            .$_multi
            "" | Write-Host
            Read-Host -Prompt "Enter your choice(s)"
        }
        $_choices = .$_menu
        "Concepts chosen:" | Write-Host
        if ($_choices -match '\*') {
            "*  - All concepts" | Write-Host
        }
        else {
            $_choices.Split(',').Trim() | Where-Object {-not [string]::IsNullOrEmpty($_.Trim())} | ForEach-Object {
                $item = $_
                $_options | Select-String "^$item\s+\-\s"
            }
        }
    }
}
