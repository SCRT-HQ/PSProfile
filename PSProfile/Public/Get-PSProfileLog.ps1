function Get-PSProfileLog {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [Switch]
        $Summary
    )
    if ($Summary) {
        $PSProfile.Log | Group-Object Section | % {
            [PSCustomObject]@{
                Section = $_.Name
                Start = $_.Group[0].Time
                End = $_.Group[-1].Time
                Duration = "$([Math]::Round(($_.Group[-1].Time - $_.Group[0].Time).TotalMilliseconds))ms"
            }
        }
    }
    else {
        $PSProfile.Log
    }
}
