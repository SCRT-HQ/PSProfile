function Remove-PSProfilePrompt {
    <#
    .SYNOPSIS
    Removes a Prompt from $PSProfile.Prompts.

    .DESCRIPTION
    Removes a Prompt from $PSProfile.Prompts.

    .PARAMETER Name
    The name of the prompt to remove from $PSProfile.Prompts.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfilePrompt -Name Demo -Save

    Removes the Prompt named 'Demo' from $PSProfile.Prompts then saves the updated configuration.
    #>
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "High")]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Name,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        if ($PSCmdlet.ShouldProcess("Removing prompt '$Name' from `$PSProfile.Prompts")) {
            Write-Verbose "Removing prompt '$Name' from `$PSProfile.Prompts"
            if ($Global:PSProfile.Prompts.ContainsKey($Name)) {
                $Global:PSProfile.Prompts.Remove($Name)
            }
            if ($Save) {
                Save-PSProfile
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfilePrompt -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Prompts.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
