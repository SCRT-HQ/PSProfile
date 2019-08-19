function Switch-PSProfilePrompt {
    <#
    .SYNOPSIS
    Sets the prompt to the desired prompt by either the Name of the prompt as stored in $PSProfile.Prompts or the provided prompt content.

    .DESCRIPTION
    Sets the prompt to the desired prompt by either the Name of the prompt as stored in $PSProfile.Prompts or the provided prompt content.

    .PARAMETER Name
    The Name of the prompt to set as active from $PSProfile.Prompts.

    .PARAMETER Temporary
    If $true, does not update $PSProfile.Settings.DefaultPrompt with the selected prompt so that prompt selection does not persist after the current session.

    .PARAMETER Content
    If Content is provided as either a ScriptBlock or String, sets the current prompt to that. Equivalent to passing `function prompt {$Content}`

    .EXAMPLE
    Switch-PSProfilePrompt -Name Demo

    Sets the active prompt to the prompt named 'Demo' from $PSProfile.Prompts and saves it as the Default prompt for session persistence.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    Param(
        [Parameter(Mandatory,Position = 0,ParameterSetName = 'Name')]
        [String]
        $Name,
        [Parameter(ParameterSetName = 'Name')]
        [switch]
        $Temporary,
        [Parameter(Mandatory,ParameterSetName = 'Content')]
        [object]
        $Content
    )
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            Name {
                if ($global:PSProfile.Prompts.ContainsKey($Name)) {
                    Write-Verbose "Setting active prompt to '$Name'"
                    $function:prompt = $global:PSProfile.Prompts[$Name]
                    if (-not $Temporary) {
                        $global:PSProfile.Settings.DefaultPrompt = $Name
                        Save-PSProfile
                    }
                }
                else {
                    Write-Warning "Falling back to default prompt -- '$Name' not found in Configuration prompts!"
                    $function:prompt = '
                    "PS $($executionContext.SessionState.Path.CurrentLocation)$(''>'' * ($nestedPromptLevel + 1)) ";
                    # .Link
                    # https://go.microsoft.com/fwlink/?LinkID=225750
                    # .ExternalHelp System.Management.Automation.dll-help.xml
                    '
                }
            }
            Content {
                Write-Verbose "Setting active prompt to provided content directly"
                $function:prompt = $Content
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Switch-PSProfilePrompt -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments -WordToComplete "Prompts.$wordToComplete" -FinalKeyOnly
}
