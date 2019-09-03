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
    Process {
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
        $exit = {
            "" | Write-Host
            .$header("Changes made to configuration")
            if ($changes.Count) {
                $changes | Write-Host
                "" | Write-Host
                "Would you like to save your updated PSProfile configuration?" | Write-Host
                $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                switch -Regex ($decision) {
                    "[Yy]" {
                        Save-PSProfile -Verbose
                    }
                }
            }
            else {
                "None!" | Write-Host
            }
            "`nExiting Configuration Helper`n" | Write-Host -ForegroundColor Yellow
            return
        }
        $legend = {
            "" | Write-Host
            .$header("Legend") | Write-Host
            .$tip("$($color['Tip']) - Helpful tips and tricks")
            .$command("$($color['Command']) - Commands to run to replicate the configuration update made")
            .$warning("$($color['Warning']) - Any warnings to be aware of")
            .$current("$($color['Current']) - Any existing configuration values for this section")
            "" | Write-Host
        }
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
                "[*]  All concepts (Default)"
                "[H]  Hide Help Topics"
                ""
                "[X]  Exit"
                ""
            )
            $options | Write-Host
            .$multi
            "" | Write-Host
            Read-Host -Prompt "Enter your choice(s) (Default: *)"
        }

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
        .$legend
        $choices = .$menu
        if ([string]::IsNullOrEmpty($choices)) {
            $choices = '*'
        }
        $hideHelpTopics = if ($choices -match "[Hh]") {
            $true
        }
        else {
            $false
        }
        if ($choices -match "[Xx]") {
            .$exit
            return
        }
        else {
            "`nChoices:" | Write-Host
            if ($choices -match '\*') {
                $options | Select-String "^\[\*\]\s+" | Write-Host
                $resolved = @(1..15)
                if ($hideHelpTopics) {
                    $resolved += 'H'
                }
            }
            else {
                $resolved = $choices.Split(',').Trim() | Where-Object { -not [string]::IsNullOrEmpty($_) }
                $resolved | ForEach-Object {
                    $item = $_
                    $options | Select-String "^\[$item\]\s+" | Write-Host
                }
            }
            foreach ($choice in $resolved | Where-Object {$_ -ne 'H'}) {
                "" | Write-Host
                $topic = (($options | Select-String "^\[$choice\]\s+") -replace "^\[$choice\]\s+(.*$)",'$1').Trim()
                $helpTopic = 'about_PSProfile_' + ($topic -replace ' ','_')
                .$header($topic)
                if (-not $hideHelpTopics) {
                    "Getting the HelpTopic for this concept: $helpTopic" | Write-Host
                    Get-Help $helpTopic -Category HelpFile
                    .$tip("To view this conceptual HelpTopic at any time, run the following command:")
                    .$command("Get-Help $helpTopic")
                }
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
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    2 {
                        if ($Global:PSProfile.ModulesToImport.Count) {
                            .$current("`n- $((($Global:PSProfile.ModulesToImport|ForEach-Object{if($_ -is [hashtable]){$_.Name}else{$_}} | Sort-Object) -join "`n- "))")
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
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    3 {
                        if ($Global:PSProfile.ModulesToInstall.Count) {
                            .$current("`n- $((($Global:PSProfile.ModulesToInstall|ForEach-Object{if($_ -is [hashtable]){$_.Name}else{$_}} | Sort-Object) -join "`n- "))")
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
                                    .$exit
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
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    5 {
                        if ($Global:PSProfile.PluginPaths.Count) {
                            .$current("`n- $(($Global:PSProfile.PluginPaths | Sort-Object) -join "`n- ")")
                        }
                        Write-Host "Would you like to add an additional Plugin Path to your PSProfile?"
                        .$tip("This is only needed if you have PSProfile plugins in a path outside of your normal PSModulePath")
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the path to the additional plugin folder"
                                    if ($null -eq (Get-PSProfilePluginPath -Path $item1)) {
                                        if (-not $changeHash.ContainsKey('Plugin Paths')) {
                                            $changes.Add("Plugin Paths:")
                                            $changeHash['Plugin Paths'] = @()
                                        }
                                        .$command("Add-PSProfilePluginPath -Path '$item1'")
                                        Add-PSProfilePluginPath -Path $item1 -NoRefresh -Verbose
                                        $changes.Add("  - $item1")
                                        $changeHash['Plugin Paths'] += $item1
                                    }
                                    else {
                                        .$warning("Plugin Path '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfilePluginPath -Path '$item1' -Force")
                                    }
                                    "`nWould you like to add another Plugin Path to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    6 {
                        if ($Global:PSProfile.Plugins.Count) {
                            .$current("`n- $(($Global:PSProfile.Plugins.Name | Sort-Object) -join "`n- ")")
                        }
                        Write-Host "Would you like to add a Plugin to your PSProfile?"
                        .$tip("Plugins can be either scripts or modules.")
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
                                        Add-PSProfilePlugin -Name $item1 -NoRefresh -Verbose
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
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    7 {
                        if ($Global:PSProfile.ProjectPaths.Count) {
                            .$current("`n- $(($Global:PSProfile.ProjectPaths | Sort-Object) -join "`n- ")")
                        }
                        Write-Host "Would you like to add a Project Path to your PSProfile?"
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the path to the additional project folder"
                                    if ($null -eq (Get-PSProfileProjectPath -Path $item1)) {
                                        if (-not $changeHash.ContainsKey('Project Paths')) {
                                            $changes.Add("Project Paths:")
                                            $changeHash['Project Paths'] = @()
                                        }
                                        .$command("Add-PSProfileProjectPath -Path '$item1'")
                                        Add-PSProfileProjectPath -Path $item1 -NoRefresh -Verbose
                                        $changes.Add("  - $item1")
                                        $changeHash['Project Paths'] += $item1
                                    }
                                    else {
                                        .$warning("Project Path '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfileProjectPath -Path '$item1' -Force")
                                    }
                                    "`nWould you like to add another Project Path to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    8 {
                        if ($Global:PSProfile.Prompts.Count) {
                            .$current("`n- $(($Global:PSProfile.Prompts.Keys | Sort-Object) -join "`n- ")")
                        }
                        if ($function:prompt -notmatch [Regex]::Escape('# https://go.microsoft.com/fwlink/?LinkID=225750')) {
                            "It looks like you are using a custom prompt! Would you like to save it to your PSProfile?" | Write-Host
                            $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                            $promptSaved = $false
                            do {
                                switch -Regex ($decision) {
                                    "[Yy]" {
                                        $item1 = Read-Host "Please enter a friendly name to save this prompt as (ex: MyPrompt)"
                                        if ($null -eq (Get-PSProfilePrompt -Name $item1)) {
                                            if (-not $changeHash.ContainsKey('Prompts')) {
                                                $changes.Add("Prompts:")
                                                $changeHash['Prompts'] = @()
                                            }
                                            .$command("Add-PSProfilePrompt -Name '$item1'")
                                            Add-PSProfilePrompt -Name $item1 -Verbose
                                            $changes.Add("  - $item1")
                                            $changeHash['Prompts'] += $item1
                                            $promptSaved = $true
                                        }
                                        else {
                                            .$warning("Prompt '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                            .$command("Add-PSProfilePrompt -Name '$item1' -Force")
                                            "`nWould you like to save your prompt as a different name?" | Write-Host
                                            $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                        }
                                    }
                                    "[Xx]" {
                                        .$exit
                                        return
                                    }
                                }
                            }
                            until ($promptSaved -or $decision -notmatch "[Yy]")
                        }
                        else {
                            "It looks like you are using the default prompt! Skipping prompt configuration for now." | Write-Host
                        }
                    }
                    9 {
                        if ($Global:PSProfile.ScriptPaths.Count) {
                            .$current("`n- $(($Global:PSProfile.ScriptPaths | Sort-Object) -join "`n- ")")
                        }
                        Write-Host "Would you like to add a Script Path to your PSProfile?"
                        .$tip("Script paths are invoked during PSProfile load. If you are running any external scripts from your current profile script, this is where you would add them.")
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the path of the additional script to add"
                                    if ($null -eq (Get-PSProfileScriptPath -Path $item1)) {
                                        if (-not $changeHash.ContainsKey('Script Paths')) {
                                            $changes.Add("Script Paths:")
                                            $changeHash['Script Paths'] = @()
                                        }
                                        .$command("Add-PSProfileScriptPath -Path '$item1'")
                                        Add-PSProfileScriptPath -Path $item1 -Verbose
                                        $changes.Add("  - $item1")
                                        $changeHash['Script Paths'] += $item1
                                    }
                                    else {
                                        .$warning("Script Path '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfileScriptPath -Path '$item1' -Force")
                                    }
                                    "`nWould you like to add another Script Path to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    10 {
                        if (($Global:PSProfile.Vault._secrets.GetEnumerator() | Where-Object {$_.Key -ne 'GitCredentials'}).Count) {
                            .$current("`n- $((($Global:PSProfile.Vault._secrets.GetEnumerator() | Where-Object {$_.Key -ne 'GitCredentials'}).Key | Sort-Object) -join "`n- ")")
                        }
                        Write-Host "Would you like to add a Secret to your PSProfile Vault?"
                        .$tip("Vault Secrets can be either a PSCredential object or a SecureString such as an API key stored with a friendly name to recall them with.")
                        .$warning("Vault Secrets are encrypted using the Data Protection API, which is not as secure on non-Windows machines and unsupported in PowerShell 6.0-6.1. For more details, please see the Pull Request covering the topic where support was re-added in PowerShell Core: https://github.com/PowerShell/PowerShell/pull/9199")
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    do {
                                        "What type of Secret would you like to add?" | Write-Host
                                        $secretType = Read-Host "[P] PSCredential [S] SecureString [C] Cancel"
                                    }
                                    until ($secretType -match "[Pp|Ss|Cc]")
                                    if ($secretType -match "[Pp]") {
                                        "Please enter the credentials you would like to store in the Secrets Vault" | Write-Host
                                        $creds = Get-Credential
                                        if ($null -eq (Get-PSProfileSecret -Name $creds.UserName)) {
                                            if (-not $changeHash.ContainsKey('Secrets')) {
                                                $changes.Add("Secrets:")
                                                $changeHash['Secrets'] = @()
                                            }
                                            .$command("Add-PSProfileSecret -Credential (Get-Credential)")
                                            Add-PSProfileSecret -Credential $creds -Verbose
                                            $changes.Add("  - $($creds.UserName)")
                                            $changeHash['Secrets'] += $creds.UserName
                                        }
                                        else {
                                            .$warning("Secret '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                            .$command("Add-PSProfileSecret -Credential (Get-Credential) -Force")
                                        }
                                        "`nWould you like to add another Secret to your PSProfile Fault?" | Write-Host
                                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                    }
                                    elseif ($secretType -match "[Ss]") {
                                        $item1 = Read-Host "Please enter the name you would like to store the secret as (ex: SecretAPIKey)"
                                        $item2 = Read-Host -AsSecureString "Please enter the secret to store as a SecureString"
                                        if ($null -eq (Get-PSProfileSecret -Name $item1)) {
                                            if (-not $changeHash.ContainsKey('Secrets')) {
                                                $changes.Add("Secrets:")
                                                $changeHash['Secrets'] = @()
                                            }
                                            .$command("Add-PSProfileSecret -Name '$item1' -SecureString (Read-Host -AsSecureString 'Enter SecureString')")
                                            Add-PSProfileSecret -Name $item1 -SecureString $item2 -Verbose
                                            $changes.Add("  - $item1")
                                            $changeHash['Secrets'] += $item1
                                        }
                                        else {
                                            .$warning("Secret '$item1' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                            .$command("Add-PSProfileSecret -Name '$item1' -SecureString (Read-Host -AsSecureString 'Enter SecureString') -Force")
                                        }
                                        "`nWould you like to add another Secret to your PSProfile Fault?" | Write-Host
                                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                    }
                                    else {
                                        $decision = $secretType
                                    }
                                }
                                "[Xx]" {
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    11 {
                        if ($Global:PSProfile.SymbolicLinks.Keys.Count) {
                            .$current("`n$(($Global:PSProfile.SymbolicLinks | Out-String).Trim())")
                        }
                        Write-Host "Would you like to add a Symbolic Link to your PSProfile?"
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    $item1 = Read-Host "Please enter the path you would like to add an symbolic link for (ex: C:\Users\$env:USERNAME)"
                                    $item2 = Read-Host "Please enter the path of the symbolic link you would like to target the previous path with (ex: C:\Home)"
                                    if ($null -eq (Get-PSProfileSymbolicLink -LinkPath $item2)) {
                                        if (-not $changeHash.ContainsKey('Symbolic Links')) {
                                            $changes.Add("Symbolic Links:")
                                            $changeHash['Symbolic Links'] = @{ }
                                        }
                                        .$command("Add-PSProfileSymbolicLink -ActualPath '$item1' -LinkPath '$item2'")
                                        Add-PSProfileSymbolicLink -ActualPath $item1 -LinkPath $item2 -Verbose
                                        $changes.Add("  - ActualPath: $item1")
                                        $changes.Add("    LinkPath: $item2")
                                        $changeHash['Symbolic Links'][$item1] = $item2
                                    }
                                    else {
                                        .$warning("Symbolic Link '$item2' already exists on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfileSymbolicLink -ActualPath '$item1' -LinkPath '$item2' -Force")
                                    }
                                    "`nWould you like to add another Symbolic Link to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    12 {
                        if ($Global:PSProfile.Variables.Environment.Keys.Count -or $Global:PSProfile.Variables.Global.Keys.Count) {
                            .$current("`n`n~~ ENVIRONMENT ~~`n$(($Global:PSProfile.Variables.Environment | Out-String).Trim())`n`n~~ GLOBAL ~~`n$(($Global:PSProfile.Variables.Global | Out-String).Trim())")
                        }
                        Write-Host "Would you like to add a Variable to your PSProfile?"
                        $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                        do {
                            switch -Regex ($decision) {
                                "[Yy]" {
                                    "Please enter the scope of the Variable to add" | Write-Host
                                    $s = Read-Host "[E] Environment [G] Global"
                                    $scope = switch -RegEx ($s) {
                                        "[Ee]" {
                                            'Environment'
                                        }
                                        "[Gg]" {
                                            'Global'
                                        }
                                    }
                                    $item1 = Read-Host "Please enter the name of the variable to add (ex: AWS_PROFILE)"
                                    $item2 = Read-Host "Please enter the value to set for variable '$item1' (ex: production)"
                                    if ($null -eq (Get-PSProfileVariable -Scope $scope -Name $item1)) {
                                        if (-not $changeHash.ContainsKey('Variables')) {
                                            $changes.Add("Variables:")
                                            $changeHash['Variables'] = @{
                                                Environment = @{}
                                                Global = @{}
                                            }
                                        }
                                        .$command("Add-PSProfileVariable -Scope '$scope' -Name '$item1' -Value '$item2'")
                                        Add-PSProfileVariable -Scope $scope -Name $item1 -Value $item2 -Verbose
                                        $changes.Add("  - Scope: $scope")
                                        $changes.Add("    Name: $item1")
                                        $changes.Add("    Value: $item2")
                                        $changeHash['Variables'][$scope][$item1] = $item2
                                    }
                                    else {
                                        .$warning("Variable '$item1' already exists at scope '$scope' on your PSProfile configuration! If you would like to overwrite it, run the following command:")
                                        .$command("Add-PSProfileVariable -Scope '$scope' -Name '$item1' -Value '$item2' -Force")
                                    }
                                    "`nWould you like to add another Variable to your PSProfile?" | Write-Host
                                    $decision = Read-Host "[Y] Yes [N] No [X] Exit"
                                }
                                "[Xx]" {
                                    .$exit
                                    return
                                }
                            }
                        }
                        until ($decision -notmatch "[Yy]")
                    }
                    13 {
                        "Configuration functions are meant to interact with the PSProfile configuration directly, so there is nothing to configure with this Helper! Please see the HelpTopic '$helpTopic' for more info:" | Write-Host
                        .$command("Get-Help $helpTopic")
                        "" | Write-Host
                        Read-Host "Press [Enter] to continue"
                    }
                    14 {
                        "Helper functions are meant to interact for use within prompts or add Log Events to PSProfile, so there is nothing to configure with this Helper! Please see the HelpTopic '$helpTopic' for more info:" | Write-Host
                        .$command("Get-Help $helpTopic")
                        "" | Write-Host
                        Read-Host "Press [Enter] to continue"
                    }
                    15 {
                        "Meta functions are meant to provide information about PSProfile itself, so there is nothing to configure with this Helper! Please see the HelpTopic '$helpTopic' for more info:" | Write-Host
                        .$command("Get-Help $helpTopic")
                        "" | Write-Host
                        Read-Host "Press [Enter] to continue"
                    }
                }
            }
            .$exit
        }
    }
}
