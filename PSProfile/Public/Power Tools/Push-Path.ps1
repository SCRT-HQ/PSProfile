function Push-Path {
    <#
    .SYNOPSIS
    Pushes your current location to the path specified. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked. Use Pop-Path to return to the location pushed from, as locations pushed from this function are within the module scope.

    .DESCRIPTION
    Pushes your current location to the path specified. Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked. Use Pop-Path to return to the location pushed from, as locations pushed from this function are within the module scope.

    .PARAMETER Path
    The path you would like to push your location to.

    .PARAMETER Cookbook
    If you are using Chef and have your chef-repo folder in your GitPaths, this will allow you to specify a cookbook path to push your location to from the Cookbooks subfolder.

    .EXAMPLE
    Push-Path MyWorkRepo

    Changes your current directory to your Git Repo named 'MyWorkRepo'.

    .EXAMPLE
    push MyWorkRepo

    Same as the first example but using the shorter alias.
    #>

    [CmdletBinding()]
    Param(
        [parameter(Mandatory,Position = 0,ParameterSetName = 'Path')]
        [String]
        $Path
    )
    DynamicParam {
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        if ($global:PSProfile.GitPathMap.ContainsKey('chef-repo')) {
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
    Process {
        $target = switch ($PSCmdlet.ParameterSetName) {
            Path {
                if ($global:PSProfile.GitPathMap.ContainsKey($PSBoundParameters['Path'])) {
                    $global:PSProfile.GitPathMap[$PSBoundParameters['Path']]
                }
                else {
                    $PSBoundParameters['Path']
                }
            }
            Cookbook {
                [System.IO.Path]::Combine($global:PSProfile.GitPathMap['chef-repo'],'cookbooks',$PSBoundParameters['Cookbook'])
            }
        }
        Write-Verbose "Pushing location to: $($target.Replace($env:HOME,'~'))"
        Push-Location $target
    }
}

Register-ArgumentCompleter -CommandName Push-Path -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly
}
