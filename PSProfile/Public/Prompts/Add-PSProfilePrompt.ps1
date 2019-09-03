function Add-PSProfilePrompt {
    <#
    .SYNOPSIS
    Saves the Content to $PSProfile.Prompts as the Name provided for recall later.

    .DESCRIPTION
    Saves the Content to $PSProfile.Prompts as the Name provided for recall later.

    .PARAMETER Name
    The Name to save the prompt as.

    .PARAMETER Content
    The prompt content itself.

    .PARAMETER SetAsDefault
    If $true, sets the prompt as default by updated $PSProfile.Settings.DefaultPrompt.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Add-PSProfilePrompt -Name Demo -Content '"PS > "'

    Saves a prompt named 'Demo' with the provided content.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [String]
        $Name = $global:PSProfile.Settings.DefaultPrompt,
        [Parameter()]
        [object]
        $Content,
        [Parameter()]
        [switch]
        $SetAsDefault,
        [Parameter()]
        [switch]
        $Save
    )
    Process {
        if ($null -eq $Name) {
            throw "No value set for the Name parameter or resolved from PSProfile!"
        }
        else {
            Write-Verbose "Saving prompt '$Name' to `$PSProfile.Prompts"
            $tempContent = if ($Content) {
                $Content.ToString()
            }
            else {
                Get-PSProfilePrompt -Raw
            }
            $cleanContent = (($tempContent -split "[\r\n]" | Where-Object {$_}) -join "`n").Trim()
            $global:PSProfile.Prompts[$Name] = $cleanContent
            if ($SetAsDefault) {
                $global:PSProfile.Settings.DefaultPrompt = $Name
            }
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}
