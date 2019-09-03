function Get-PathAlias {
    <#
    .SYNOPSIS
    Gets the Path alias using either the short name from $PSProfile.GitPathMap or a path alias stored in $PSProfile.PathAliases, falls back to using a shortened version of the root drive + current directory.

    .DESCRIPTION
    Gets the Path alias using either the short name from $PSProfile.GitPathMap or a path alias stored in $PSProfile.PathAliases, falls back to using a shortened version of the root drive + current directory.

    .PARAMETER Path
    The full path to get the PathAlias for. Defaults to $PWD.Path

    .PARAMETER DirectorySeparator
    The desired DirectorySeparator character. Defaults to $global:PathAliasDirectorySeparator if present, falls back to [System.IO.Path]::DirectorySeparatorChar if not.

    .EXAMPLE
    Get-PathAlias
    #>
    [CmdletBinding()]
    Param (
        [parameter(Position = 0)]
        [string]
        $Path = $PWD.Path,
        [parameter(Position = 1)]
        [string]
        $DirectorySeparator = $(if ($null -ne $global:PathAliasDirectorySeparator) {
            $global:PathAliasDirectorySeparator
        }
        else {
            [System.IO.Path]::DirectorySeparatorChar
        })
    )
    Begin {
        try {
            $origPath = $Path
            if ($null -eq $global:PSProfile) {
                $global:PSProfile = @{
                    Settings     = @{
                        PSVersionStringLength = 3
                    }
                    PathAliasMap = @{
                        '~' = $env:USERPROFILE
                    }
                }
            }
            elseif ($null -eq $global:PSProfile._internal) {
                $global:PSProfile._internal = @{
                    PathAliasMap = @{
                        '~' = $env:USERPROFILE
                    }
                }
            }
            elseif ($null -eq $global:PSProfile._internal.PathAliasMap) {
                $global:PSProfile._internal.PathAliasMap = @{
                    '~' = $env:USERPROFILE
                }
            }
            if ($gitRepo = Test-IfGit) {
                $gitIcon = if ($global:PSProfile.Settings.ContainsKey('FontType')) {
                    $global:PSProfile.Settings.PromptCharacters.GitRepo[$global:PSProfile.Settings.FontType]
                }
                else {
                    '@'
                }
                if ([String]::IsNullOrEmpty($gitIcon)) {
                    $gitIcon = '@'
                }
                $key = $gitIcon + $gitRepo.Repo
                if (-not $global:PSProfile._internal.PathAliasMap.ContainsKey($key)) {
                    $global:PSProfile._internal.PathAliasMap[$key] = $gitRepo.TopLevel
                }
            }
            $leaf = Split-Path $Path -Leaf
            if (-not $global:PSProfile._internal.PathAliasMap.ContainsKey('~')) {
                $global:PSProfile._internal.PathAliasMap['~'] = $env:USERPROFILE
            }
            Write-Verbose "Alias map => JSON: $($global:PSProfile._internal.PathAliasMap | ConvertTo-Json -Depth 5)"
            $aliasKey = $null
            $aliasValue = $null
            foreach ($hash in $global:PSProfile._internal.PathAliasMap.GetEnumerator() | Sort-Object { $_.Value.Length } -Descending) {
                if ($Path -like "$($hash.Value)*") {
                    $Path = $Path.Replace($hash.Value,$hash.Key)
                    $aliasKey = $hash.Key
                    $aliasValue = $hash.Value
                    Write-Verbose "AliasKey [$aliasKey] || AliasValue [$aliasValue]"
                    break
                }
            }
        }
        catch {
            Write-Error $_
            return $origPath
        }
    }
    Process {
        try {
            if ($null -ne $aliasKey -and $origPath -eq $aliasValue) {
                Write-Verbose "Matched original path! Returning alias base path"
                $finalPath = $Path
            }
            elseif ($null -ne $aliasKey) {
                Write-Verbose "Matched alias key [$aliasKey]! Returning path alias with leaf"
                $drive = "$($aliasKey)\"
                $finalPath = if ((Split-Path $origPath -Parent) -eq $aliasValue) {
                    "$($drive)$($leaf)"
                }
                else {
                    "$($drive)$([char]0x2026)\$($leaf)"
                }
            }
            else {
                $drive = (Get-Location).Drive.Name + ':\'
                Write-Verbose "Matched base drive [$drive]! Returning base path"
                $finalPath = if ($Path -eq $drive) {
                    $drive
                }
                elseif ((Split-Path $Path -Parent) -eq $drive) {
                    "$($drive)$($leaf)"
                }
                else {
                    "$($drive)..\$($leaf)"
                }
            }
            if ($DirectorySeparator -notin @($null,([System.IO.Path]::DirectorySeparatorChar))) {
                $finalPath.Replace(([System.IO.Path]::DirectorySeparatorChar),$DirectorySeparator)
            }
            else {
                $finalPath
            }
        }
        catch {
            Write-Error $_
            return $origPath
        }
    }
}
