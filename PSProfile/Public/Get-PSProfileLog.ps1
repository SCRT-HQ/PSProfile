function Get-PSProfileLog {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [String]
        $Section,
        [Parameter()]
        [Switch]
        $Summary
    )
    if ($Summary) {
        $sections = $Global:PSProfile.Log | Group-Object Section
        $sections | ForEach-Object {
            $Group = $_.Group
            $sectCaps = $Group | Where-Object {$_.Message -match '^SECTION (START|END)$'}
            [PSCustomObject]@{
                Name = $_.Name
                Start = $sectCaps[0].Time.ToString('HH:mm:ss.fff')
                Section = "$([Math]::Round(($sectCaps[-1].Time - $sectCaps[0].Time).TotalMilliseconds))ms"
                Full = "$([Math]::Round(($Group[-1].Time - $Group[0].Time).TotalMilliseconds))ms"
            }
        } | Sort-Object Start
    }
    else {
        if ($Section) {
            $Global:PSProfile.Log | Where-Object {$_.Section -eq $Section}
        }
        else {
            $Global:PSProfile.Log
        }
    }
}

Register-ArgumentCompleter -CommandName 'Get-PSProfileLog' -ParameterName 'Section' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Log.Section | Sort-Object -Unique | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
