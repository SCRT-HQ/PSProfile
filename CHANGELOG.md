* [PSProfile - ChangeLog](#psprofile---changelog)
  * [0.1.3 - 2019-08-20](#013---2019-08-20)
  * [0.1.2 - 2019-08-20](#012---2019-08-20)
  * [0.1.1 - 2019-08-19](#011---2019-08-19)
  * [0.1.0 - 2019-08-19](#010---2019-08-19)

***

# PSProfile - ChangeLog

## 0.1.3 - 2019-08-20

* Added `Confirm-ScriptIsValid` to `PSProfile.PowerTools`
* Added `Test-RegEx` to `PSProfile.PowerTools`
* Changed `ErrorAction` on `New-Alias` call in `$PSProfile._setCommandAliases()` method.
* Removed `ForEach-Object` alias from `Open-Code`
* Added `pwsh-preview` exe resolver to `Enter-CleanEnvironment` as the wrapper cmd file does not handle the arguments correctly (throws non-terminated string error).

## 0.1.2 - 2019-08-20

* Added `*-PSProfilePluginPath` functions to manage PluginPaths
* Cleaned up PluginPath logic to remove old module versions from the search path.
* Cleaned up `Get-PSProfilePrompt` and added a `-NoPSSA` switch to prevent usage of `Invoke-Formatter` regardless is PSScriptAnalyzer is installed.
* Updated `PSProfile.PowerTools` included plugin.
* Fixed issue with `Add-PSProfileModuleToInstall` and `Add-PSProfileModuleToImport` where it wouldn't rebuild the hashtable array correctly when adding modules to the PSProfile.
* Added additional logic to build script.
* Made `PSProfile.PowerTools` included in Plugins by default due to utility.
* Cleaned up docs folder as it belongs in the Wiki, not the main repo.

## 0.1.1 - 2019-08-19

* [Issue #3](https://github.com/scrthq/PSProfile/issues/3)
  * Fixed: `$PSProfile.Refresh()` only uses `Trim()` to clean up the Prompts now due to Invoke-Formatter hanging.

## 0.1.0 - 2019-08-19

* Initial release to the PowerShell Gallery
* Included functions:
  * `Add-PSProfileCommandAlias`
  * `Add-PSProfileModuleToImport`
  * `Add-PSProfileModuleToInstall`
  * `Add-PSProfilePathAlias`
  * `Add-PSProfilePlugin`
  * `Add-PSProfileProjectPath`
  * `Add-PSProfilePrompt`
  * `Add-PSProfileScriptPath`
  * `Add-PSProfileSecret`
  * `Add-PSProfileSymbolicLink`
  * `Add-PSProfileVariable`
  * `Edit-PSProfilePrompt`
  * `Get-LastCommandDuration`
  * `Get-MyCreds`
  * `Get-PathAlias`
  * `Get-PSProfileArguments`
  * `Get-PSProfileCommand`
  * `Get-PSProfileCommandAlias`
  * `Get-PSProfileImportedCommand`
  * `Get-PSProfileLog`
  * `Get-PSProfileModuleToImport`
  * `Get-PSProfileModuleToInstall`
  * `Get-PSProfilePathAlias`
  * `Get-PSProfilePlugin`
  * `Get-PSProfileProjectPath`
  * `Get-PSProfilePrompt`
  * `Get-PSProfileScriptPath`
  * `Get-PSProfileSecret`
  * `Get-PSProfileSymbolicLink`
  * `Get-PSProfileVariable`
  * `Get-PSVersion`
  * `Import-PSProfile`
  * `Import-PSProfileConfiguration`
  * `Remove-PSProfileCommandAlias`
  * `Remove-PSProfileModuleToImport`
  * `Remove-PSProfileModuleToInstall`
  * `Remove-PSProfilePathAlias`
  * `Remove-PSProfilePlugin`
  * `Remove-PSProfileProjectPath`
  * `Remove-PSProfilePrompt`
  * `Remove-PSProfileScriptPath`
  * `Remove-PSProfileSecret`
  * `Remove-PSProfileSymbolicLink`
  * `Remove-PSProfileVariable`
  * `Save-PSProfile`
  * `Switch-PSProfilePrompt`
  * `Test-IfGit`
  * `Update-PSProfileConfig`
  * `Update-PSProfileRefreshFrequency`
  * `Update-PSProfileSetting`
  * `Write-PSProfileLog`
* Included aliases:
  * `Creds` >> `Get-MyCreds`
  * `Edit-Prompt` >> `Edit-PSProfilePrompt`
  * `Get-Prompt` >> `Get-PSProfilePrompt`
  * `Load-PSProfile` >> `Import-PSProfile`
  * `Refresh-PSProfile` >> `Update-PSProfileConfig`
  * `Remove-Prompt` >> `Remove-PSProfilePrompt`
  * `Save-Prompt` >> `Add-PSProfilePrompt`
  * `Set-Prompt` >> `Switch-PSProfilePrompt`
  * `Switch-Prompt` >> `Switch-PSProfilePrompt`
