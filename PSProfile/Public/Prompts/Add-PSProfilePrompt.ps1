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
        $SetAsDefault
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
                Get-Prompt -Raw
            }
            $cleanContent = (($tempContent -split "[\r\n]" | Where-Object {$_}) -join "`n").Trim()
            $global:PSProfile.Prompts[$Name] = $cleanContent
            if ($SetAsDefault) {
                $global:PSProfile.Settings.DefaultPrompt = $Name
            }
            Save-PSProfile
        }
    }
}
