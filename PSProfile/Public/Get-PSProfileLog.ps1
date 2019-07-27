function Get-PSProfileLog {
    [CmdletBinding()]
    Param(
        [Parameter()]
        [Switch]
        $Summary,
        [Parameter()]
        [Switch]
        $SectionOnly
    )
    if ($Summary) {
        $sections = $Global:PSProfile.Log | Group-Object Section
        $sections | ForEach-Object {
            $Group = $_.Group
            if ($SectionOnly) {
                $Group = $Group | Where-Object {$_.Message -match '^SECTION (START|END)$'}
            }
            [PSCustomObject]@{
                Section = $_.Name
                Start = $Group[0].Time
                End = $Group[-1].Time
                Duration = "$([Math]::Round(($Group[-1].Time - $Group[0].Time).TotalMilliseconds))ms"
            }
        }
    }
    else {
        if ($SectionOnly) {
            $Global:PSProfile.Log | Where-Object {$_.Message -match '^SECTION (START|END)$'}
        }
        else {
            $Global:PSProfile.Log
        }
    }
}
