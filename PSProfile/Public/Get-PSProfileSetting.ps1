function Get-PSProfileSetting {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Path
    )
    Process {
        $split = $Path.Split('.')
        switch ($split.Count) {
            5 {
                $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"."$($split[3])"."$($split[4])"
            }
            4 {
                $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"."$($split[3])"
            }
            3 {
                $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"
            }
            2 {
                $Global:PSProfile."$($split[0])"."$($split[1])"
            }
            1 {
                $Global:PSProfile.$Path
            }
        }
    }
}

Register-ArgumentCompleter -CommandName 'Get-PSProfileSetting' -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $split = $wordToComplete.Split('.')
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
    $props = switch ($setting.GetType().Name) {
        Hashtable {
            $setting.Keys | Where-Object {$_ -notmatch '^_' -and $_ -like "$final*"} | Sort-Object
        }
        default {
            ($setting | Get-Member -MemberType Property).Name | Where-Object {$_ -notmatch '^_' -and $_ -like "$final*"} | Sort-Object
        }
    }
    $props | ForEach-Object {
        $result = if ($null -ne $base) {
            @($base,$_) -join "."
        }
        else {
            $_
        }
        [System.Management.Automation.CompletionResult]::new($result, $result, 'ParameterValue', $result)
    }
}
