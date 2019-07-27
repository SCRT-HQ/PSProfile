function Get-PSProfileArguments {
    param(
        [Switch]$FinalKeyOnly,
        [object]$CommandName,
        [object]$ParameterName,
        [string]$WordToComplete,
        [object]$CommandAst,
        [object]$FakeBoundParameter
    )
    process {
        $split = $WordToComplete.Split('.')
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
            1 {
                $setting = $Global:PSProfile
                $base = $null
            }
        }
        $final = $split | Select-Object -Last 1
        $props = if ($setting.PSTypeNames -match 'Hashtable') {
            $setting.Keys | Where-Object {$_ -notmatch '^_' -and $_ -like "$final*"} | Sort-Object
        }
        else {
            ($setting | Get-Member -MemberType Property).Name | Where-Object {$_ -notmatch '^_' -and $_ -like "$final*"} | Sort-Object
        }
        $props | ForEach-Object {
            $result = if (-not $FinalKeyOnly -and $null -ne $base) {
                @($base,$_) -join "."
            }
            else {
                $_
            }
            [System.Management.Automation.CompletionResult]::new($result, $result, 'ParameterValue', $result)
        }
    }
}

Register-ArgumentCompleter -CommandName 'Get-PSProfileArguments' -ParameterName WordToComplete -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments @PSBoundParameters
}
