Param(
    [Parameter(Position = 0)]
    [String]
    $ModuleName = $Script:ModuleName,
    [Parameter(Position = 1)]
    [String]
    $ModuleVersion = $Script:ModuleVersion,
    [Parameter()]
    [String[]]
    $Dependencies = @(
        '[Configuration](https://github.com/poshcode/Configuration)',
        '[PoshRSJob](https://github.com/proxb/PoshRSJob)',
        '[posh-git](https://github.com/dahlbyk/posh-git)'
    )
)
@"
# Changelog

$((git log -1 --pretty=%B | Select-Object -Skip 2) -join "`n")

***

# Instructions

**IMPORTANT: You MUST have the following modules installed as a prerequisite to using this module, otherwise the module will fail to import! Installing the module from the repo source or the release page does not automatically install dependencies!!**

Module Dependencies:

* $($Dependencies -join "`n* ")

1. [Click here](https://github.com/scrthq/$($ModuleName)/releases/download/v$($ModuleVersion)/$($ModuleName).zip) to download the *$($ModuleName).zip* file attached to the release.
2. **If on Windows**: Right-click the downloaded zip, select Properties, then unblock the file.
    > _This is to prevent having to unblock each file individually after unzipping._
3. Unzip the archive.
4. (Optional) Place the module folder somewhere in your ``PSModulePath``.
    > _You can view the paths listed by running the environment variable ```$env:PSModulePath``_
5. Import the module, using the full path to the PSD1 file in place of ``$($ModuleName)`` if the unzipped module folder is not in your ``PSModulePath``:
    ``````powershell
    # In `$env:PSModulePath
    Import-Module $($ModuleName)

    # Otherwise, provide the path to the manifest:
    Import-Module -Path C:\MyPSModules\$($ModuleName)\$($ModuleVersion)\$($ModuleName).psd1
    ``````
"@
