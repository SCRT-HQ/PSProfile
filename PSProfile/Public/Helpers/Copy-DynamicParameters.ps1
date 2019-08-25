function Copy-DynamicParameters {
    <#
    .SYNOPSIS
    Copies parameters from a file or function and returns a RuntimeDefinedParameterDictionary with the parameters replicated. Used in DynamicParam blocks.

    .DESCRIPTION
    Copies parameters from a file or function and returns a RuntimeDefinedParameterDictionary with the parameters replicated. Used in DynamicParam blocks.

    .PARAMETER File
    The file to replicate parameters from.

    .PARAMETER Function
    The function to replicate parameters from.

    .PARAMETER ExcludeParameter
    The parameter or list of parameters to exclude from replicating into the returned Dictionary.

    .EXAMPLE
    function Start-Build {
        [CmdletBinding()]
        Param ()
        DynamicParam {
            Copy-DynamicParameters -File ".\build.ps1"
        }
        Process {
            #Function logic
        }
    }

    Replicates the parameters from the build.ps1 script into the Start-Build function.
    #>
    [OutputType('System.Management.Automation.RuntimeDefinedParameterDictionary')]
    [CmdletBinding(DefaultParameterSetName = "File")]
    Param (
        [Parameter(Mandatory,Position = 0,ParameterSetName = "File")]
        [String]
        $File,
        [Parameter(Mandatory,ParameterSetName = "Function")]
        [String]
        $Function,
        [Parameter()]
        [String[]]
        $ExcludeParameter = @()
    )
    Begin {
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $ast = switch ($PSCmdlet.ParameterSetName) {
            File {
                [System.Management.Automation.Language.Parser]::ParseFile($PSBoundParameters['File'],[ref]$null,[ref]$null)
            }
            Function {
                [System.Management.Automation.Language.Parser]::ParseInput((Get-Command $PSBoundParameters['Function']).Definition,[ref]$null,[ref]$null)
            }
        }
    }
    Process {
        foreach ($parameter in $ast.ParamBlock.Parameters | Where-Object {$_.Name.VariablePath.UserPath -notin $ExcludeParameter}) {
            $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            foreach ($paramAtt in $parameter.Attributes) {
                switch ($paramAtt.TypeName.FullName) {
                    Parameter {
                        $attribute = New-Object System.Management.Automation.ParameterAttribute
                        foreach ($boolParam in @('Mandatory','DontShow','ValueFromPipeline','ValueFromPipelineByPropertyName','ValueFromRemainingArguments')) {
                            $attribute.$boolParam = ($null -ne ($paramAtt.NamedArguments | Where-Object {$_.ArgumentName -eq $boolParam -and $_.Argument.Value -eq $true}))
                        }
                        foreach ($otherParam in @('Position','HelpMessage','HelpMessageBaseName','HelpMessageResourceId','ParameterSetName')) {
                            if ($item = $paramAtt.NamedArguments | Where-Object {$_.ArgumentName -eq $otherParam}) {
                                $attribute.$otherParam = $item.Argument.Value
                            }
                        }
                        $AttribColl.Add($attribute)
                    }
                    Alias {
                        $AttribColl.Add((New-Object System.Management.Automation.AliasAttribute($paramAtt.PositionalArguments.SafeGetValue())))
                    }
                    ValidateScript {
                        $AttribColl.Add((New-Object System.Management.Automation.ValidateScriptAttribute($paramAtt.PositionalArguments.ScriptBlock.GetScriptBlock())))
                    }
                    ValidateRange {
                        $AttribColl.Add((New-Object System.Management.Automation.ValidateRangeAttribute($paramAtt.PositionalArguments.SafeGetValue())))
                    }
                    ValidateCount {
                        $AttribColl.Add((New-Object System.Management.Automation.ValidateCountAttribute($paramAtt.PositionalArguments.SafeGetValue())))
                    }
                    ValidatePattern {
                        $AttribColl.Add((New-Object System.Management.Automation.ValidatePatternAttribute($paramAtt.PositionalArguments.SafeGetValue())))
                    }
                    ValidateSet {
                        $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($paramAtt.PositionalArguments.SafeGetValue())))
                    }
                    ValidateLength {
                        $AttribColl.Add((New-Object System.Management.Automation.ValidateLengthAttribute($paramAtt.PositionalArguments.SafeGetValue())))
                    }
                }
            }
            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter(
                $parameter.Name.VariablePath.UserPath,
                $parameter.StaticType,
                $AttribColl
            )
            $RuntimeParamDic.Add($parameter.Name.VariablePath.UserPath,$RuntimeParam)
        }
    }
    End {
        return $RuntimeParamDic
    }
}

Register-ArgumentCompleter -CommandName Copy-DynamicParameters -ParameterName ExcludeParameter -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $set = if (-not [String]::IsNullOrEmpty($fakeBoundParameter.File)) {
        ([System.Management.Automation.Language.Parser]::ParseFile(
            $fakeBoundParameter.File, [ref]$null, [ref]$null
        )).ParamBlock.Parameters.Name.VariablePath.UserPath
    }
    elseif (-not [String]::IsNullOrEmpty($fakeBoundParameter.Function)) {
        ([System.Management.Automation.Language.Parser]::ParseInput(
            (Get-Command $fakeBoundParameter.Function).Definition, [ref]$null, [ref]$null
        )).ParamBlock.Parameters.Name.VariablePath.UserPath
    }
    else {
        @()
    }
    $set | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

Register-ArgumentCompleter -CommandName Copy-DynamicParameters -ParameterName Function -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Command "$wordToComplete*").Name | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
