function Get-PSProfileArguments {
    <#
    .SYNOPSIS
    Used for PSProfile Plugins to provide easy Argument Completers using PSProfile constructs.

    .DESCRIPTION
    Used for PSProfile Plugins to provide easy Argument Completers using PSProfile constructs.

    .PARAMETER FinalKeyOnly
    Returns only the final key of the completed argument to the list of completers. If $false, returns the full path.

    .PARAMETER WordToComplete
    The word to complete, typically passed in from the scriptblock arguments.

    .PARAMETER CommandName
    Here to allow passing @PSBoundParameters directly to this function from Register-ArgumentCompleter

    .PARAMETER ParameterName
    Here to allow passing @PSBoundParameters directly to this function from Register-ArgumentCompleter

    .PARAMETER CommandAst
    Here to allow passing @PSBoundParameters directly to this function from Register-ArgumentCompleter

    .PARAMETER FakeBoundParameter
    Here to allow passing @PSBoundParameters directly to this function from Register-ArgumentCompleter

    .EXAMPLE
    Get-PSProfileArguments -WordToComplete "Prompts.$wordToComplete" -FinalKeyOnly

    Gets the list of prompt names under the Prompts PSProfile primary key.

    .EXAMPLE
    Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly

    Gets the list of Git Path short names under the GitPathMap PSProfile primary key.
    #>
    [OutputType('System.Management.Automation.CompletionResult')]
    [CmdletBinding()]
    Param(
        [switch]
        $FinalKeyOnly,
        [string]
        $WordToComplete,
        [object]
        $CommandName,
        [object]
        $ParameterName,
        [object]
        $CommandAst,
        [object]
        $FakeBoundParameter
    )
    Process {
        Write-Verbose "Getting PSProfile command argument completions"
        $split = $WordToComplete.Split('.')
        $setting = $null
        switch ($split.Count) {
            5 {
                $setting = $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"."$($split[3])"
                $base = "$($split[0])"."$($split[1])"."$($split[2])"."$($split[3])"
            }
            4 {
                $setting = $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"
                $base = "$($split[0])"."$($split[1])"."$($split[2])"
            }
            3 {
                $setting = $Global:PSProfile."$($split[0])"."$($split[1])"
                $base = "$($split[0])"."$($split[1])"
            }
            2 {
                $setting = $Global:PSProfile."$($split[0])"
                $base = $split[0]
            }
        }
        if ($null -eq $setting) {
            $setting = $Global:PSProfile
            $base = $null
            $final = $WordToComplete
        }
        else {
            $final = $split | Select-Object -Last 1
        }
        if ($setting.GetType() -notin @([string],[int],[long],[version],[timespan],[datetime],[bool])) {
            $props = if ($setting.PSTypeNames -match 'Hashtable') {
                $setting.Keys | Where-Object {$_ -ne '_internal' -and $_ -like "$final*"} | Sort-Object
            }
            else {
                ($setting | Get-Member -MemberType Property,NoteProperty).Name | Where-Object {$_ -notmatch '^_' -and $_ -like "$final*"} | Sort-Object
            }
            $props | ForEach-Object {
                $result = if (-not $FinalKeyOnly -and $null -ne $base) {
                    @($base,$_) -join "."
                }
                else {
                    $_
                }
                $completionText = if ($result -match '[\s,]') {
                    "'$result'"
                }
                 else {
                     $result
                 }
                [System.Management.Automation.CompletionResult]::new($completionText, $result, 'ParameterValue', $result)
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileArguments -ParameterName WordToComplete -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments @PSBoundParameters
}
