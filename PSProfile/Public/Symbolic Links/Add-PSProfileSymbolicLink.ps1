function Add-PSProfileSymbolicLink {
    <#
    .SYNOPSIS
    Adds a SymbolicLink to set if missing during profile load via background task.

    .DESCRIPTION
    Adds a SymbolicLink to set if missing during profile load via background task.

    .PARAMETER LinkPath
    The path of the symbolic link to create if missing.

    .PARAMETER ActualPath
    The actual target path of the symbolic link to set.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileSymbolicLink -LinkPath C:\workstation -ActualPath E:\Git\workstation -Save

    Adds a symbolic link at path 'C:\workstation' targeting the actual path 'E:\Git\workstation' and saves your PSProfile configuration.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [Alias('Path','Name')]
        [String]
        $LinkPath,
        [Parameter(Mandatory,Position = 1)]
        [Alias('Target','Value')]
        [String]
        $ActualPath,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        Write-Verbose "Adding SymbolicLink '$LinkPath' pointing at ActualPath '$ActualPath'"
        $Global:PSProfile.SymbolicLinks[$LinkPath] = $ActualPath
        if ($Save) {
            Save-PSProfile
        }
    }
}
