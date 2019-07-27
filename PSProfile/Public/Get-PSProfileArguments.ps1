function Get-PSProfileArguments {
    param(
        $subKey,
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameter
    )
    process {
        $global:PSProfile.$subKey.Keys | Where-Object {$_ -like "$wordToComplete*"} | Sort-Object | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

Register-ArgumentCompleter -CommandName 'Get-PSProfileArguments' -ParameterName subKey -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    ($global:PSProfile | Get-Member -MemberType Property | Where-Object {$_.Definition -match 'hashtable ' -and $_.Name -notmatch '^_'}).Name | Where-Object {$_ -like "$wordToComplete*"} | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
