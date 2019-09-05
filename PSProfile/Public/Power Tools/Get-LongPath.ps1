function Get-LongPath {
    <#
    .SYNOPSIS
    Expands a short-alias from the GitPathMap to the full path

    .DESCRIPTION
    Expands a short-alias from the GitPathMap to the full path

    .PARAMETER Path
    The short path to expand

    .PARAMETER Subpaths
    Any subpaths to join to the main path before resolving.

    .EXAMPLE
    Get-LongPath MyWorkRepo

    Gets the full path to MyWorkRepo

    .EXAMPLE
    path MyWorkRepo

    Same as Example 1, but uses the short-alias 'path' instead.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    Param (
        [parameter(Position = 0,ParameterSetName = 'Path')]
        [String]
        $Path = $PWD.Path,
        [parameter(ValueFromRemainingArguments,Position = 1,ParameterSetName = 'Path')]
        [String[]]
        $Subpaths
    )
    DynamicParam {
        if ($global:PSProfile.GitPathMap.ContainsKey('chef-repo')) {
            $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
            $ParamAttrib.Mandatory = $true
            $ParamAttrib.ParameterSetName = 'Cookbook'
            $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $AttribColl.Add($ParamAttrib)
            $set = (Get-ChildItem (Join-Path $global:PSProfile.GitPathMap['chef-repo'] 'cookbooks') -Directory).Name
            $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($set)))
            $AttribColl.Add((New-Object System.Management.Automation.AliasAttribute('c')))
            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Cookbook',  [string], $AttribColl)
            $RuntimeParamDic.Add('Cookbook',  $RuntimeParam)
        }
        return  $RuntimeParamDic
    }
    Begin {
        if (-not $PSBoundParameters.ContainsKey('Path')) {
            $PSBoundParameters['Path'] = $PWD.Path
        }
    }
    Process {
        $target = switch ($PSCmdlet.ParameterSetName) {
            Path {
                if ($PSBoundParameters['Path'] -eq '.') {
                    $PWD.Path
                }
                elseif ($null -ne $global:PSProfile.GitPathMap.Keys) {
                    if ($global:PSProfile.GitPathMap.ContainsKey($PSBoundParameters['Path'])) {
                        $global:PSProfile.GitPathMap[$PSBoundParameters['Path']]
                    }
                    else {
                        (Resolve-Path $PSBoundParameters['Path']).Path
                    }
                }
                else {
                    (Resolve-Path $PSBoundParameters['Path']).Path
                }
            }
            Cookbook {
                [System.IO.Path]::Combine($global:PSProfile.GitPathMap['chef-repo'],'cookbooks',$PSBoundParameters['Cookbook'])
            }
        }
        if ($Subpaths) {
            $target = Join-Path $target ($Subpaths -join [System.IO.Path]::DirectorySeparatorChar)
        }
        Write-Verbose "Resolved long path: $target"
    }
}

Register-ArgumentCompleter -CommandName Get-LongPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly
}
