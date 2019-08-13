function Set-PSProfileSetting {
    <#
    .SYNOPSIS
    Enables setting a PSProfile key's value by tab-completing the available keys.

    .DESCRIPTION
    Enables setting a PSProfile key's value by tab-completing the available keys.

    .PARAMETER Path
    The path of the key you would like to set or update.

    .PARAMETER Value
    The value you would like to set for the specified setting path.

    .PARAMETER Add
    If $true, adds the value to the specified PSProfile setting value array instead of overwriting the current value.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Set-PSProfileSetting

    .NOTES
    General notes
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

Register-ArgumentCompleter -CommandName 'Set-PSProfileSetting' -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments @PSBoundParameters
}
