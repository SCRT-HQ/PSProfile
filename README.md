# PSProfile

_PSProfile is a cross-platform PowerShell module built for profile customization. It uses PoshCode's Configuration module to handle the layered Configuration._

<div align="center">
  <!-- Azure Pipelines -->
  <a href="https://dev.azure.com/scrthq/SCRT%20HQ/_build/latest?definitionId=8">
    <img src="https://dev.azure.com/scrthq/SCRT%20HQ/_apis/build/status/scrthq.PSProfile"
      alt="Azure Pipelines" title="Azure Pipelines" />
  </a>&nbsp;&nbsp;&nbsp;&nbsp;
  <!-- Discord -->
  <a href="https://discord.gg/G66zVG7">
    <img src="https://img.shields.io/discord/235574673155293194.svg?style=flat&label=Discord&logo=discord&color=purple"
      alt="Discord - Chat" title="Discord - Chat" />
  </a>&nbsp;&nbsp;&nbsp;&nbsp;
  <!-- Slack -->
  <a href="https://scrthq-slack-invite.herokuapp.com/">
    <img src="https://img.shields.io/badge/chat-on%20slack-orange.svg?style=flat&logo=slack"
      alt="Slack - Chat" title="Slack - Chat" />
  </a>&nbsp;&nbsp;&nbsp;&nbsp;
  <!-- Codacy -->
  <a href="https://www.codacy.com/app/scrthq/PSProfile?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=scrthq/PSProfile&amp;utm_campaign=Badge_Grade">
    <img src="https://api.codacy.com/project/badge/Grade/7756b60eb1c64baab17770a3cf02faa9"
      alt="Codacy" title="Codacy" />
  </a>
  </br>
  </br>
  <!-- PS Gallery -->
  <a href="https://www.PowerShellGallery.com/packages/PSProfile">
    <img src="https://img.shields.io/powershellgallery/dt/PSProfile.svg?style=flat&logo=powershell&color=blue"
      alt="PowerShell Gallery" title="PowerShell Gallery" />
  </a>&nbsp;&nbsp;&nbsp;&nbsp;
  <!-- GitHub Releases -->
  <a href="https://github.com/scrthq/PSProfile/releases/latest">
    <img src="https://img.shields.io/github/downloads/scrthq/PSProfile/total.svg?logo=github&color=blue"
      alt="GitHub Releases" title="GitHub Releases" />
  </a>&nbsp;&nbsp;&nbsp;&nbsp;
  <!-- GitHub Releases -->
  <a href="https://github.com/scrthq/PSProfile/releases/latest">
    <img src="https://img.shields.io/github/release/scrthq/PSProfile.svg?label=version&logo=github"
      alt="GitHub Releases" title="GitHub Releases" />
  </a>
</div>
<br />

## Background

I do a LOT of profile customization, including loading in various custom functions I wrote, setting certain variables, invoking external profile scripts, etc, to make everyday tasks more efficient. I checked out the PowerShell Gallery for other Profile management modules but none seemed to satisfy all of the goals I had:

1. Minimize my profile script to be as small as I can be.
   * PSProfile only needs one line: `Import-Module PSProfile`.
2. Enable easy storage and recall of secrets, typically my own PSCredential object, for programmatic use. This would eliminate the use of BetterCredentials (overriding `Get-Credential` sometimes yielded unwanted results) and my own `MyConfig` module that I was using locally.
   * PSProfile includes a Vault to store PSCredential objects and named SecureStrings, e.g. API keys. Saving personal credentials? `Set-PSProfileSecret (Get-Credential) -Save`. Recalling later? `Invoke-Command -Credential (Get-MyCreds)`
3. Enable common prompt storage and quick prompt switching.
   * PSProfile has the ability to store prompts in its configuration with easy-to-remember names. Need to switch to your Demo prompt? `Switch-Prompt Demo`
4. Be extensible.
   * PSProfile includes Plugin support. A PSProfile Plugin can be a simple script or a full module. You can also include an `ArgumentList` to pass to the script/module during invocation.
5. Maintain my PowerShell environment's desired state.
   * PSProfile includes additional configuration options to specify modules you'd like to ensure are installed or are imported during profile load, scripts to invoke, Symbolic Links to create, etc.

I hope that you enjoy PSProfile as much as I do! It includes a TON of convenience features and is built to run cross-platform and tested in Azure Pipelines with Windows PowerShell, PowerShell 6+ on Windows, PowerShell 6+ on Linux, and PowerShell 6+ on MacOS.

## Quick Start

1. Install the module and its dependencies from the PowerShell Gallery:

    ```powershell
    Install-Module PSProfile -Repository PSGallery -Scope CurrentUser
    ```
2. Add `Import-Module PSProfile` to your PowerShell profile (`$profile`) so that PSProfile is imported whenever you start a new session:

    ```powershell
    if (-not (Test-Path $profile)) { New-Item -ItemType File $profile -Force }
    'Import-Module PSProfile' | Add-Content $profile
    ```
3. Restart your session or run `Import-Module PSProfile` to start working with it directly.
4. Explore the new `$PSProfile` variable containing the current PSProfile configuration.

## Tips & Tricks

### ProjectPaths

```powershell
Add-PSProfileProjectPath C:\WorkProjects,~\PersonalGit -Save
```

This adds the two folders to your ProjectPaths and refreshes your PSProfile to import any projects immediately to the internal GitPathMap. If any `build.ps1` files are found, those are added to another special dictionary in PSProfile as well for tab-completion.

Adding a ProjectPath provides tab completion of project folder names for the included PowerTools plugin functions, such as...

 * `Push-Path` (Alias: `push`) - Like Set-Location, but now with tab-completion goodness for your project folders.
 * `Open-Item` (Alias: `open`) - Runs `Invoke-Item` underneath but allows tab-completed project folder names as input that is expanded to the full path in the function body.
 * `Open-Code` - Adds convenience wrappers to the `code` CLI tool for Visual Studio Code, allowing you to specify the language of the content you are passing via pipeline to `stdin` to display in VS Code, as well as tab completion of project folder names to open quickly as well.
   * > Pro-tip: `Open-Code` is designed as a replacement for the normal `code` CLI tool. I recommend adding an alias. You can do this directly with PSProfile for persistence by running `Add-PSProfileCommandAlias -Alias code -Command Open-Code -Save`
 * `Start-BuildScript` (Alias: `bld`) - Use `build.ps1` scripts often for building projects? This function will invoke your build script in a new child process with `-NoProfile` included to prevent any false flags that may happen while your profile is loaded as well as prevent file-locking.
 * `Enter-CleanEnvironment` (Alias: `cln`) - Opens a child process up in the current directory with `-NoProfile` and a custom prompt to let you know you're in a _clean_ environment. Use the `-ImportModule` switch to import a compiled module in the `BuildOutput` folder of your current directly if found.
 * `Get-LongPath` (Alias: `path`) - Want to leverage tab-completion of project folder names for other commands? Use this to expand the long path of a project folder name like so, `Get-ChildItem (path PSProfile)`

### ScriptPaths

```powershell
Add-PSProfileScriptPath ~\PowerShell\Profile\FunTools.ps1 -Save
```

This adds the script specified to `$PSProfile.ScriptPaths`. Any scripts here will be invoked during PSProfile load. Include the `-Invoke` switch to also invoke the script immediately without needing to reload your session or re-import PSProfile.

***

_More info / tips here soon! View the [PSProfile wiki](https://github.com/scrthq/PSProfile/wiki) for full function help and other topics._
