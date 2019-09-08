function Copy-Parameters {
    <#
    .SYNOPSIS
    Copies parameters from a file or function and returns a RuntimeDefinedParameterDictionary with the copied parameters. Used in DynamicParam blocks.

    .DESCRIPTION
    Copies parameters from a file or function and returns a RuntimeDefinedParameterDictionary with the copied parameters. Used in DynamicParam blocks.

    .PARAMETER From
    The file or function to copy parameters from.

    .PARAMETER Exclude
    The parameter or list of parameters to exclude from replicating into the returned Dictionary.

    .EXAMPLE
    function Start-Build {
        [CmdletBinding()]
        Param ()
        DynamicParam {
            Copy-Parameters -From ".\build.ps1"
        }
        Process {
            #Function logic
        }
    }

    Replicates the parameters from the build.ps1 script into the Start-Build function.
    #>
    [OutputType('System.Management.Automation.RuntimeDefinedParameterDictionary')]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [Alias('File','Function')]
        [String]
        $From,
        [Parameter()]
        [Alias('ExcludeParameter')]
        [String[]]
        $Exclude = @()
    )
    try {
        $targetCmd = Get-Command $From
        $params = @($targetCmd.Parameters.GetEnumerator() | Where-Object { $_.Key -notin $Exclude })
        if ($params.Length -gt 0) {
            $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
            foreach ($param in $params) {
                try {
                    if (-not $MyInvocation.MyCommand.Parameters.ContainsKey($param.Key)) {
                        Write-Verbose "Copying parameter: $($param.Key)"
                        $paramVal = $param.Value
                        $dynParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
                            $paramVal.Name,
                            $paramVal.ParameterType,
                            $paramVal.Attributes
                        )
                        $paramDictionary.Add($paramVal.Name, $dynParam)
                    }
                }
                catch {
                    $Global:Error.Remove($Global:Error[0])
                }
            }
            return $paramDictionary
        }
    }
    catch {
        $Global:Error.Remove($Global:Error[0])
    }
}

Register-ArgumentCompleter -CommandName Copy-Parameters -ParameterName Exclude -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $set = if (-not [String]::IsNullOrEmpty($fakeBoundParameter.From)) {
        ([System.Management.Automation.Language.Parser]::ParseInput(
            (Get-Command $fakeBoundParameter.From).Definition, [ref]$null, [ref]$null
        )).ParamBlock.Parameters.Name.VariablePath.UserPath
    }
    else {
        @()
    }
    $set | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
