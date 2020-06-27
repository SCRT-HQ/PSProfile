function Add-PSProfileScriptPath {
    <#
    .SYNOPSIS
    Adds a ScriptPath to your PSProfile to invoke during profile load.

    .DESCRIPTION
    Adds a ScriptPath to your PSProfile to invoke during profile load.

    .PARAMETER Path
    The path of the script to add to your $PSProfile.ScriptPaths.

    .PARAMETER Invoke
    If $true, invokes the script path after adding to $PSProfile.ScriptPaths to make it immediately available in the current session.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfileScriptPath -Path ~\MyProfileScript.ps1 -Save

    Adds the script 'MyProfileScript.ps1' to $PSProfile.ScriptPaths and saves the configuration after updating.

    .EXAMPLE
    Get-ChildItem .\MyProfileScripts -Recurse -File | Add-PSProfileScriptPath -Verbose

    Adds all scripts under the MyProfileScripts folder to $PSProfile.ScriptPaths but does not save to allow inspection. Call Save-PSProfile after to save the results if satisfied.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [String[]]
        $Path,
        [Parameter()]
        [Switch]
        $Invoke,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($p in $Path) {
            if ($p -match '\.ps1$') {
                $fP = (Resolve-Path $p).Path
                if ($Global:PSProfile.ScriptPaths -notcontains $fP) {
                    Write-Verbose "Adding ScriptPath to PSProfile: $fP"
                    $Global:PSProfile.ScriptPaths += $fP
                }
                else {
                    Write-Verbose "ScriptPath already in PSProfile: $fP"
                }
                if ($Invoke) {
                    . $fp
                }
            }
            else {
                Write-Verbose "Skipping non-ps1 file: $fP"
            }
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}
