function Update-PSProfileSetting {
    <#
    .SYNOPSIS
    Update a PSProfile property's value by tab-completing the available keys.

    .DESCRIPTION
    Update a PSProfile property's value by tab-completing the available keys.

    .PARAMETER Path
    The property path you would like to update, e.g. Settings.PSVersionStringLength

    .PARAMETER Value
    The value you would like to update for the specified setting path.

    .PARAMETER Add
    If $true, adds the value to the specified PSProfile setting value array instead of overwriting the current value.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Update-PSProfileSetting -Path Settings.PSVersionStringLength -Value 3 -Save

    Updates the PSVersionStringLength setting to 3 and saves the configuration.

    .EXAMPLE
    Update-PSProfileSetting -Path ScriptPaths -Value ~\ProfileLoad.ps1 -Add -Save

    *Adds* the 'ProfileLoad.ps1' script to the $PSProfile.ScriptPaths array of scripts to invoke during profile load, then saves the configuration.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Path,
        [Parameter(Mandatory,Position = 1)]
        [object]
        $Value,
        [Parameter()]
        [switch]
        $Add,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        Write-Verbose "Updating PSProfile.$Path with value '$Value'"
        $split = $Path.Split('.')
        switch ($split.Count) {
            5 {
                if ($Add) {
                    $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"."$($split[3])"."$($split[4])" += $Value
                }
                else {
                    $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"."$($split[3])"."$($split[4])" = $Value
                }
            }
            4 {
                if ($Add) {
                    $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"."$($split[3])" += $Value
                }
                else{
                    $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])"."$($split[3])" = $Value
                }
            }
            3 {
                if ($Add) {
                    $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])" += $Value
                }
                else{
                    $Global:PSProfile."$($split[0])"."$($split[1])"."$($split[2])" = $Value
                }
            }
            2 {
                if ($Add) {
                    $Global:PSProfile."$($split[0])"."$($split[1])" += $Value
                }
                else{
                    $Global:PSProfile."$($split[0])"."$($split[1])" = $Value
                }
            }
            1 {
                if ($Add) {
                    $Global:PSProfile.$Path += $Value
                }
                else{
                    $Global:PSProfile.$Path = $Value
                }
            }
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}

Register-ArgumentCompleter -CommandName 'Update-PSProfileSetting' -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments @PSBoundParameters
}
