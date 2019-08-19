function Add-PSProfileProjectPath {
    <#
    .SYNOPSIS
    Adds a ProjectPath to your PSProfile to find Git project folders under during PSProfile refresh. These will be available via tab-completion

    .DESCRIPTION
    Adds a ProjectPath to your PSProfile to find Git project folders under during PSProfile refresh.

    .PARAMETER Path
    The path of the folder to add to your $PSProfile.ProjectPaths. This path should contain Git repo folders underneath it.

    .PARAMETER NoRefresh
    If $true, skips refreshing your PSProfile after updating project paths.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileProjectPath -Path ~\GitRepos -Save

    Adds the folder ~\GitRepos to $PSProfile.ProjectPaths and saves the configuration after updating.

    .EXAMPLE
    Add-PSProfileProjectPath C:\Git -Verbose

    Adds the path C:\Git to your $PSProfile.ProjectPaths, refreshes your PathDict but does not save. Call Save-PSProfile after if satisfied with the results.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateScript({if (-not (Get-Item $_).PSIsContainer){throw "$_ is not a folder! Please add only folders to this PSProfile property. If you would like to add a script, use Add-PSProfileScriptPath instead."}})]
        [Alias('FullName')]
        [String[]]
        $Path,
        [Parameter()]
        [Switch]
        $NoRefresh,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($p in $Path) {
            $fP = (Resolve-Path $p).Path
            if ($Global:PSProfile.ProjectPaths -notcontains $fP) {
                Write-Verbose "Adding ProjectPath to PSProfile: $fP"
                $Global:PSProfile.ProjectPaths += $fP
            }
            else {
                Write-Verbose "ProjectPath already in PSProfile: $fP"
            }
        }
        if (-not $NoRefresh) {
            Update-PSProfileConfig
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}
