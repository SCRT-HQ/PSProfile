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
            Tip     = "Green"
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
        $changeHash = @{ }
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
                "[1]  Command Aliases"
                "[2]  Modules to Import"
                "[3]  Modules to Install"
                "[4]  Path Aliases"
                "[5]  Plugin Paths"
                "[6]  Plugins"
                "[7]  Project Paths"
                "[8]  Prompts"
                "[9]  Script Paths"
                "[10] Secrets"
                "[11] Symbolic Links"
                "[12] Variables"
                ""
                "[13] Configuration"
                "[14] Helpers"
                "[15] Meta"
                ""
                "[*]  All concepts"
                ""
                "[X]  Exit"
                ""
            )
            $options | Write-Host
            .$multi
            "" | Write-Host
            Read-Host -Prompt "Enter your choice(s)"
        }
        $choices = .$menu
        if ($choices -match "[Xx]") {
            "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
            return
        }
        else {
            "`nConcepts chosen:" | Write-Host
            if ($choices -match '\*') {
                $options | Select-String "^\[\*\]\s+" | Write-Host
                $resolved = @(1..15)
            }
            else {
                $resolved = $choices.Split(',').Trim() | Where-Object { -not [string]::IsNullOrEmpty($_) }
                $resolved | ForEach-Object {
                    $item = $_
                    $options | Select-String "^\[$item\]\s+" | Write-Host
                }
            }
            foreach ($choice in $resolved) {
                "" | Write-Host
                $topic = (($options | Select-String "^\[$choice\]\s+") -replace "^\[$choice\]\s+(.*$)",'$1').Trim()
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
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the command you would like to add an alias for (ex: Test-Path)"
                                    $item2 = Read-Host "Please enter the alias that you would like to set for the command (ex: tp)"
                                    if ($null -eq (Get-PSProfileCommandAlias -Alias $item2)) {
                                        if (-not $changeHash.ContainsKey('Command Aliases')) {
                                            $changes.Add("Command Aliases:")
                                            $changeHash['Command Aliases'] = @{ }
                                        }
                                        .$command("Add-PSProfileCommandAlias -Command '$item1' -Alias '$item2'")
                                        Add-PSProfileCommandAlias -Command $item1 -Alias $item2 -Verbose
                                        $changes.Add("  - Command: $item1")
                                        $changes.Add("    Alias: $item2")
                                        $changeHash['Command Aliases'][$item1] = $item2
                                    }
                                    else {
                                        .$warning("Command Alias '$item2' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfileCommandAlias -Command '$item1' -Alias '$item2' -Force")
                                    }
                                    "`nWould you like to add another Command Alias to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    2 {
                        if ($Global:PSProfile.ModulesToImport.Count) {
                            .$current(
                                (
                                    (
                                        $Global:PSProfile.ModulesToImport | ForEach-Object {
                                            if ($_ -is [hashtable]) {
                                                $_.Name
                                            }
                                            else {
                                                $_
                                            }
                                        }
                                    ) -join ", "
                                )
                            )
                        }
                        Write-Host "Would you like to add a Module to Import to your PSProfile?"
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the name of the module you would like to import during PSProfile load"
                                    if ($null -eq (Get-PSProfileModuleToImport -Name $item1)) {
                                        if (-not $changeHash.ContainsKey('Modules to Import')) {
                                            $changes.Add("Modules to Import:")
                                            $changeHash['Modules to Import'] = @()
                                        }
                                        .$command("Add-PSProfileModuleToImport -Name '$item1'")
                                        Add-PSProfileModuleToImport -Name $item1 -Verbose
                                        $changes.Add("  - $item1")
                                        $changeHash['Modules to Import'] += $item1
                                    }
                                    else {
                                        .$warning("Module to Import '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfileModuleToImport -Name '$item1' -Force")
                                    }
                                    "`nWould you like to add another Module to Import to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    3 {
                        if ($Global:PSProfile.ModulesToInstall.Count) {
                            .$current(
                                (
                                    (
                                        $Global:PSProfile.ModulesToInstall | ForEach-Object {
                                            if ($_ -is [hashtable]) {
                                                $_.Name
                                            }
                                            else {
                                                $_
                                            }
                                        }
                                    ) -join ", "
                                )
                            )
                        }
                        Write-Host "Would you like to add a Module to Install to your PSProfile?"
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the name of the module you would like to install via background job during PSProfile load"
                                    if ($null -eq (Get-PSProfileModuleToInstall -Name $item1)) {
                                        if (-not $changeHash.ContainsKey('Modules to Install')) {
                                            $changes.Add("Modules to Install:")
                                            $changeHash['Modules to Install'] = @()
                                        }
                                        .$command("Add-PSProfileModuleToInstall -Name '$item1'")
                                        Add-PSProfileModuleToInstall -Name $item1 -Verbose
                                        $changes.Add("  - $item1")
                                        $changeHash['Modules to Install'] += $item1
                                    }
                                    else {
                                        .$warning("Module to Install '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfileModuleToInstall -Name '$item1' -Force")
                                    }
                                    "`nWould you like to add another Module to Install to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    4 {
                        if ($Global:PSProfile.PathAliases.Keys.Count) {
                            .$current("`n$(([PSCustomObject]$Global:PSProfile.PathAliases | Format-List | Out-String).Trim())")
                        }
                        Write-Host "Would you like to add a Path Alias to your PSProfile?"
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the path you would like to add an alias for (ex: C:\Users\$env:USERNAME)"
                                    $item2 = Read-Host "Please enter the alias that you would like to set for the path (ex: ~)"
                                    if ($null -eq (Get-PSProfilePathAlias -Alias $item2)) {
                                        if (-not $changeHash.ContainsKey('Path Aliases')) {
                                            $changes.Add("Path Aliases:")
                                            $changeHash['Path Aliases'] = @{ }
                                        }
                                        .$command("Add-PSProfilePathAlias -Path '$item1' -Alias '$item2'")
                                        Add-PSProfilePathAlias -Path $item1 -Alias $item2 -Verbose
                                        $changes.Add("  - Path: $item1")
                                        $changes.Add("    Alias: $item2")
                                        $changeHash['Path Aliases'][$item1] = $item2
                                    }
                                    else {
                                        .$warning("Path Alias '$item2' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfilePathAlias -Path '$item1' -Alias '$item2' -Force")
                                    }
                                    "`nWould you like to add another Path Alias to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    5 {
                        if ($Global:PSProfile.PluginPaths.Count) {
                            .$current(($Global:PSProfile.PluginPaths -join ", "))
                        }
                        Write-Host "Would you like to add an additional Plugin Path to your PSProfile?"
                        .$tip("This is only needed if you have PSProfile plugins in a path outside of your normal PSModulePath")
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the path to the additional plugin folder"
                                    if ($null -eq (Get-PSProfilePluginPath -Name $item1)) {
                                        if (-not $changeHash.ContainsKey('Plugin Paths')) {
                                            $changes.Add("Plugin Paths:")
                                            $changeHash['Plugin Paths'] = @()
                                        }
                                        .$command("Add-PSProfilePluginPath -Name '$item1'")
                                        Add-PSProfilePluginPath -Name $item1 -Verbose
                                        $changes.Add("  - $item1")
                                        $changeHash['Plugin Paths'] += $item1
                                    }
                                    else {
                                        .$warning("Plugin Path '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfilePluginPath -Name '$item1' -Force")
                                    }
                                    "`nWould you like to add another Plugin Path to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    6 {
                        if ($Global:PSProfile.Plugins.Count) {
                            .$current(($Global:PSProfile.Plugins.Name -join ", "))
                        }
                        Write-Host "Would you like to add a Plugin to your PSProfile?"
                        .$tip("Plugins can be either scripts or modules.)")
                        .$tip("Use AD cmdlets? Try adding the plugin 'PSProfile.ADCompleters' to get tab-completion for the Properties parameter on Get-ADUser, Get-ADGroup, and Get-ADComputer!")
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the name of the plugin you would like to add (ex: PSProfile.ADCompleters)"
                                    if ($null -eq (Get-PSProfilePlugin -Name $item1)) {
                                        if (-not $changeHash.ContainsKey('Plugins')) {
                                            $changes.Add("Plugins:")
                                            $changeHash['Plugins'] = @()
                                        }
                                        .$command("Add-PSProfilePlugin -Name '$item1'")
                                        Add-PSProfilePlugin -Name $item1 -Verbose
                                        $changes.Add("  - $item1")
                                        $changeHash['Plugins'] += $item1
                                    }
                                    else {
                                        .$warning("Plugin '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfilePlugin -Name '$item1' -Force")
                                    }
                                    "`nWould you like to add another Plugin to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    7 {
                        if ($Global:PSProfile.ProjectPaths.Count) {
                            .$current(($Global:PSProfile.ProjectPaths -join ", "))
                        }
                        Write-Host "Would you like to add an additional Project Path to your PSProfile?"
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the path to the additional project folder"
                                    if ($null -eq (Get-PSProfileProjectPath -Name $item1)) {
                                        if (-not $changeHash.ContainsKey('Project Paths')) {
                                            $changes.Add("Project Paths:")
                                            $changeHash['Project Paths'] = @()
                                        }
                                        .$command("Add-PSProfileProjectPath -Name '$item1'")
                                        Add-PSProfileProjectPath -Name $item1 -Verbose
                                        $changes.Add("  - $item1")
                                        $changeHash['Project Paths'] += $item1
                                    }
                                    else {
                                        .$warning("Project Path '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfileProjectPath -Name '$item1' -Force")
                                    }
                                    "`nWould you like to add another Project Path to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    "`nExiting Configuration Helper!`n" | Write-Host -ForegroundColor Yellow
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
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
            .$header("Changes made to configuration")
            $changes | Write-Host
            "" | Write-Host
            "Would you like to save your PSProfile configuration?" | Write-Host
            $decision = Read-Host "[Y] Yes [N] No [X] Exit"
            switch -Regex ($decision) {
                "[Yy]" {
                    Save-PSProfile -Verbose
                }
            }
            "`nConfiguration Helper complete! Exiting`n" | Write-Host -ForegroundColor Yellow
            return
        }
    }
}
