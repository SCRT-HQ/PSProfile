function Pop-Path {
    <#
    .SYNOPSIS
    Pops your location back the path you Push-Path'd from.

    .DESCRIPTION
    Pops your location back the path you Push-Path'd from.

    .EXAMPLE
    Pop-Path
    #>
    [CmdletBinding()]
    Param ()
    Process {
        Write-Verbose "Popping back to previous location"
        Pop-Location
    }
}
