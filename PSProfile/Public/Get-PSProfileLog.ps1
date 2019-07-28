function Get-PSProfileLog {
    [CmdletBinding(DefaultParameterSetName = 'Full')]
    Param(
        [Parameter(Position = 0,ParameterSetName = 'Full')]
        [String[]]
        $Section,
        [Parameter(Position = 1,ParameterSetName = 'Full')]
        [PSProfileLogLevel[]]
        $LogLevel,
        [Parameter(ParameterSetName = 'Summary')]
        [Switch]
        $Summary,
        [Parameter(ParameterSetName = 'Full')]
        [Switch]
        $Raw
    )
    if ($Summary) {
        $Global:PSProfile.Log | Group-Object Section | ForEach-Object {
            $section = $_[0].Name
            $Group = $_.Group
            $sectCaps = $Group | Where-Object {$_.Message -match '^SECTION (START|END)$'}
            [PSCustomObject]@{
                Name = $section
                Start = $sectCaps[0].Time.ToString('HH:mm:ss.fff')
                Section = "$([Math]::Round(($sectCaps[-1].Time - $sectCaps[0].Time).TotalMilliseconds))ms"
                Full = "$([Math]::Round(($Group[-1].Time - $Group[0].Time).TotalMilliseconds))ms"
                RunningJobs = Get-RSJob -State Running | Where-Object {$_.Name -match $Section} | Select-Object -ExpandProperty Name
            }
        } | Sort-Object Start | Format-Table -AutoSize
    }
    else {
        $items = if ($Section) {
            $Global:PSProfile.Log | Where-Object {$_.Section -in $Section}
        }
        else {
            $Global:PSProfile.Log
        }
        if ($LogLevel) {
            $items = $items | Where-Object {$_.LogLevel -in $LogLevel}
        }
        if (-not $Raw) {
            $items | Format-Table -AutoSize
        }
    }
}

Register-ArgumentCompleter -CommandName 'Get-PSProfileLog' -ParameterName 'Section' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Log.Section | Sort-Object -Unique | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
