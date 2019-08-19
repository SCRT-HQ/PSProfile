function Get-PSProfileLog {
    <#
    .SYNOPSIS
    Gets the PSProfile Log events.

    .DESCRIPTION
    Gets the PSProfile Log events.

    .PARAMETER Section
    Limit results to only a specific section.

    .PARAMETER LogLevel
    Limit results to only a specific LogLevel.

    .PARAMETER Summary
    Get a high-level summary of the PSProfile Log.

    .PARAMETER Raw
    Return the raw PSProfile Events. Returns the results via Format-Table for readability otherwise.

    .EXAMPLE
    Get-PSProfileLog

    Gets the current Log in full.

    .EXAMPLE
    Get-PSProfileLog -Summary

    Gets the Log summary.

    .EXAMPLE
    Get-PSProfileLog -Section InvokeScripts,LoadPlugins -Raw

    Gets the Log Events for only sections 'InvokeScripts' and 'LoadPlugins' and returns the raw Event objects.
    #>
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
    Process {
        if ($Summary) {
            Write-Verbose "Getting PSProfile Log summary"
            $Global:PSProfile.Log | Group-Object Section | ForEach-Object {
                $sectName = $_.Name
                $Group = $_.Group
                $sectCaps = $Group | Where-Object {$_.Message -match '^SECTION (START|END)$'}
                [PSCustomObject]@{
                    Name = $sectName
                    Start = $sectCaps[0].Time.ToString('HH:mm:ss.fff')
                    SectionDuration = "$([Math]::Round(($sectCaps[-1].Time - $sectCaps[0].Time).TotalMilliseconds))ms"
                    FullDuration = "$([Math]::Round(($Group[-1].Time - $Group[0].Time).TotalMilliseconds))ms"
                    RunningJobs = Get-RSJob -State Running | Where-Object {$_.Name -match $sectName} | Select-Object -ExpandProperty Name
                }
            } | Sort-Object Start | Format-Table -AutoSize
        }
        else {
            Write-Verbose "Getting PSProfile Log"
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
            else {
                $items
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileLog -ParameterName 'Section' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Log.Section | Sort-Object -Unique | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
