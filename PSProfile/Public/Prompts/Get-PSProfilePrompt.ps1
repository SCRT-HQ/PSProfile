function Get-PSProfilePrompt {
    <#
    .SYNOPSIS
    Gets the current prompt's definition as a string. Useful for inspection of the prompt in use. If PSScriptAnalyzer is installed, formats the prompt for readability before returning the prompt function string.

    .DESCRIPTION
    Gets the current prompt's definition as a string. Useful for inspection of the prompt in use. If PSScriptAnalyzer is installed, formats the prompt for readability before returning the prompt function string.

    .PARAMETER Name
    The Name of the prompt from $PSProfile.Prompts to get. If excluded, gets the current prompt.

    .PARAMETER Global
    If $true, adds the global scope to the returned prompt, e.g. `function global:prompt`

    .PARAMETER Raw
    If $true, returns only the prompt definition and does not add the `function prompt {...}` enclosure.

    .EXAMPLE
    Get-PSProfilePrompt
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [String]
        $Name,
        [Parameter()]
        [Switch]
        $Global,
        [Parameter()]
        [Switch]
        $Raw
    )
    Begin {
        $pssa = if ($null -eq (Get-Module PSScriptAnalyzer* -ListAvailable)) {
            $false
        }
        else {
            $true
            Import-Module PSScriptAnalyzer
        }
        $pContents = if ($PSBoundParameters.ContainsKey('Name')) {
            $Global:PSProfile.Prompts[$Name]
        }
        else {
            (Get-Command prompt).Definition
        }
    }
    Process {
        Write-Verbose "Getting current prompt"
        $i = 0
        $leadingWhiteSpace = $null
        $g = if ($Global) {
            'global:prompt'
        }
        else {
            'prompt'
        }
        $p = $(if ($Raw) {
                ''
            }
            else {
                "function $g {`n"
            }) + $($pContents -split "`n" | ForEach-Object {
            if (-not [String]::IsNullOrWhiteSpace($_)) {
                if ($null -eq $leadingWhiteSpace) {
                    $lws = ($_ | Select-String -Pattern '^\s+')
                    $leadingWhiteSpace = if ($lws) {
                        $lws.Matches[0].Value + ' '
                    }
                    else {
                        $null
                    }
                }
                $_ -replace "^$leadingWhiteSpace",'    '
                "`n"
            }
            elseif ($i) {
                $_
                "`n"
            }
            $i++
        }) + $(if ($Raw) {
            ''
        }
        else {
            "}"
        })
        if ($pssa) {
            Invoke-Formatter $p -Verbose:$false
        }
        else {
            $p
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfilePrompt -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments -WordToComplete "Prompts.$wordToComplete" -FinalKeyOnly
}
