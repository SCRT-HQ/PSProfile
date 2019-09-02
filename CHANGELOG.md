* [PSProfile - ChangeLog](#psprofile---changelog)
  * [0.2.0 - 2019-09-01](#020---2019-09-01)
  * [0.1.9 - 2019-08-26](#019---2019-08-26)
  * [0.1.8 - 2019-08-26](#018---2019-08-26)
  * [0.1.7 - 2019-08-25](#017---2019-08-25)
  * [0.1.6 - 2019-08-24](#016---2019-08-24)
  * [0.1.5 - 2019-08-22](#015---2019-08-22)
  * [0.1.4 - 2019-08-22](#014---2019-08-22)
  * [0.1.3 - 2019-08-20](#013---2019-08-20)
  * [0.1.2 - 2019-08-20](#012---2019-08-20)
  * [0.1.1 - 2019-08-19](#011---2019-08-19)
  * [0.1.0 - 2019-08-19](#010---2019-08-19)

***

# PSProfile - ChangeLog

## 0.2.0 - 2019-09-01

* Added `Start-PSProfileConfigurationHelper` to provide a way
* Added support for multiple Aliases to be removed at once on `Remove-PSProfileCommandAlias`.
* Updated default `SCRTHQ` prompt that comes with the module.
* Added support for NerdFonts and PowerLine switches on the prompts to switch char sets depending on the FontType.
* Added `IncludeVault` switch parameter to `Export-PSProfileConfiguration` to prevent exporting the Secrets Vault by default when creating portable configurations.
* Added `_cleanModules()` method to PSProfile class to remove any null or empty values hanging over and convert any string values to the full hashtable value instead.
* Added special module import process when the `ModuleToImport` is `EditorServicesCommandSuite` so it also automatically registers the available editor commands.
* Cleaned up logic and fixed bugs in the following functions:
  * `Add-PSProfileModuleToImport`
  * `Remove-PSProfileModuleToImport`
  * `Add-PSProfileModuleToInstall`
  * `Remove-PSProfileModuleToInstall`
  * `Add-PSProfilePlugin`

## 0.1.9 - 2019-08-26

* Renamed `Copy-DynamicParameters` to `Copy-Parameters` for correctness and cleaned up approach for building the ParameterDictionary.
* Updated Dockerfile to not run the Build task again since it should only run after module has been built.
* Updated `azure-pipelines.yml` to break out Docker tasks

## 0.1.8 - 2019-08-26

* Fixed issue with `$PSProfile.ModulesToImport` where an empty string was added to the array, resulting in a Warning during profile load about the module failing to import.

## 0.1.7 - 2019-08-25

* Fixed `Task` parameter type on `Start-BuildScript` to allow an array of strings.

## 0.1.6 - 2019-08-24

* Added `Copy-DynamicParameters` to clone DynamicParams from another file or function.
* Updated `Start-BuildScript` in `PSProfile.PowerTools` with better argument completers to enable listing available Tasks and other parameters directly from the build script you are executing.
* Added `Dockerfile` to enable testing in an Ubuntu container.

## 0.1.5 - 2019-08-22

* Added `Export-PSProfileConfiguration` to export your configuration to a portable file.
* Fixed bug with `Edit-PSProfilePrompt` that tried to run a non-existent function after editing was finished.
* Swapped the `Temporary` switch parameter with `Save` on `Edit-PSProfilePrompt` to align with the rest of the functions.
* Updated the `_loadPrompt()` method on the `$PSProfile` object to not force load a default prompt if a default prompt name has not been specified yet.
* Updated README with better details.
* Updated Wiki content.
* Updated CONTRIBUTING.md.

## 0.1.4 - 2019-08-22

* Added conceptual HelpFiles. Run `Get-Help about_PSProfile*` for more info!
* Added argument completer for `Add-PSProfilePlugin`.
* Updated Wiki content.

## 0.1.3 - 2019-08-20

* Added `Pop-Path` to fix scope issues with `Push-Path` that effectively turned it into `Set-Location`
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
