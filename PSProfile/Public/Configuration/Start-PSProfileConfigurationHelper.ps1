function Start-PSProfileConfigurationHelper {
    [CmdletBinding()]
    Param ()
    Begin {
        Write-Verbose "Starting PSProfile Configuration Helper..."
        $private:color = @{
            Tip = "Green"
            Command = "Cyan"
            Warning = "Yellow"
            Current = "Magenta"
        }
        $private:header = {
            param([string]$title)
            @(
                "----------------------------------"
                "| $($title.ToUpper())"
                "----------------------------------"
            ) -join "`n"
        }
        $private:choices = [System.Collections.Generic.List[string]]::new()
        $private:tip = {
            param([string]$text)
            "TIP: $text" | Write-Host -ForegroundColor $private:color['Tip']
        }
        $private:command = {
            param([string]$text)
            "COMMAND: $text" | Write-Host -ForegroundColor $private:color['Command']
        }
        $private:warning = {
            param([string]$text)
            "WARNING: $text" | Write-Host -ForegroundColor $private:color['Warning']
        }
        $private:current = {
            param([string]$text)
            "CURRENT: $text" | Write-Host -ForegroundColor $private:color['Current']
        }
        $private:multi = {
            .$private:tip("This accepts multiple answers as comma-separated values, e.g. 1,2,5")
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
        $private:legend = {
            "" | Write-Host
            .$private:header("Legend") | Write-Host
            .$private:tip("$($private:color['Tip']) - Helpful tips and tricks")
            .$private:command("$($private:color['Command']) - Commands to run to replicate the configuration update made")
            .$private:warning("$($private:color['Warning']) - Any warnings to be aware of")
            .$private:current("$($private:color['Current']) - Any existing configuration values for this section")
            "" | Write-Host
        }
        .$private:legend
    }
}
