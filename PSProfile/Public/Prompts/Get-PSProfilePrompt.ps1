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

    .PARAMETER NoPSSA
    If $true, does not use PowerShell Script Analyzer's Invoke-Formatter to format the resulting prompt definition.

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
        $NoPSSA,
        [Parameter()]
        [Switch]
        $Raw
    )
    Begin {
        $pssa = if ($NoPSSA -or $null -eq (Get-Module PSScriptAnalyzer* -ListAvailable)) {
            $false
        }
        else {
            $true
            Import-Module PSScriptAnalyzer -Verbose:$false
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
        $lws = $null
        $g = if ($Global) {
            'global:prompt'
        }
        else {
            'prompt'
        }
        $header = if ($Raw) {
            ''
        }
        else {
            "function $g {`n"
        }
        $content = $pContents -split "`n" | ForEach-Object {
            if (-not [String]::IsNullOrWhiteSpace($_)) {
                if ($null -eq $lws) {
                    $lws = if ($_ -match '^\s+') {
                        $Matches.Values[0].Length
                    }
                    else {
                        $null
                    }
                }
                $_ -replace "^\s{0,$lws}",'    '
                "`n"
            }
            elseif ($i) {
                $_
                "`n"
            }
            $i++
        }
        $footer = if ($Raw) {
            ''
        }
        else {
            "}"
        }
        $p = ((@($header,(($content | Where-Object {"$_".Trim()}) -join "`n"),$footer) -split "[\r\n]") | Where-Object {"$_".Trim()}) -join "`n"
        if (-not $NoPSSA -and $pssa) {
            Write-Verbose "Formatting prompt with Invoke-Formatter"
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
