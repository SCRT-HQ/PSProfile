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

## Documentation

1. Add `Import-Module PSProfile` to your PowerShell profile (`$profile`) so that PSProfile is imported whenever you start a new session:

   ```powershell
   if (-not (Test-Path $profile)) { New-Item -ItemType File $profile -Force }
   'Import-Module PSProfile' | Add-Content $profile
   ```
2. Restart your session or run `Import-Module PSProfile` to start working with it directly.
3. Explore the new `$PSProfile` variable containing the current PSProfile configuration.

More info / tips here soon! View the [PSProfile wiki](https://github.com/scrthq/PSProfile/wiki) for full function help and other topics.
