function Open-Item {
    <#
    .SYNOPSIS
    Opens the item specified using Invoke-Item. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .DESCRIPTION
    Opens the item specified using Invoke-Item. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    .PARAMETER Path
    The path you would like to open. Supports anything that Invoke-Item normally supports, i.e. files, folders, URIs.

    .PARAMETER Cookbook
    If you are using Chef and have your chef-repo folder in your GitPaths, this will allow you to specify a cookbook path to open from the Cookbooks subfolder.

    .EXAMPLE
    Open-Item

    Opens the current path in Explorer/Finder/etc.

    .EXAMPLE
    open

    Uses the shorter alias to open the current path

    .EXAMPLE
    open MyWorkRepo

    Opens the folder for the Git Repo 'MyWorkRepo' in Explorer/Finder/etc.
    #>

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    Param (
        [parameter(Position = 0,ParameterSetName = 'Path')]
        [String]
        $Path = $PWD.Path
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
                        $PSBoundParameters['Path']
                    }
                }
                else {
                    $PSBoundParameters['Path']
                }
            }
            Cookbook {
                [System.IO.Path]::Combine($global:PSProfile.GitPathMap['chef-repo'],'cookbooks',$PSBoundParameters['Cookbook'])
            }
        }
        Write-Verbose "Running command: Invoke-Item $($PSBoundParameters[$PSCmdlet.ParameterSetName])"
        Invoke-Item $target
    }
}


Register-ArgumentCompleter -CommandName Open-Item -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly
}
