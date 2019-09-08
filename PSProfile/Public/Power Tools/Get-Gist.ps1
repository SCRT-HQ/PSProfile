function Get-Gist {
    <#
    .SYNOPSIS
    Gets a GitHub Gist's contents using the public API

    .DESCRIPTION
    Gets a GitHub Gist's contents using the public API

    .PARAMETER Id
    The ID of the Gist to get

    .PARAMETER File
    The specific file from the Gist to get. If excluded, gets all of the files as an array of objects.

    .PARAMETER Sha
    The SHA of the specific Gist to get, if desired.

    .PARAMETER Metadata
    Any additional metadata you want to include on the resulting object, e.g. for identifying what the Gist is, add notes, etc.

    .PARAMETER Invoke
    If $true, invokes the Gist contents. If the Gist contains any PowerShell functions, it will adjust the scope to Global before invoking so the function remains available in the session after Get-Gist finishes. Useful for loading functions directly from a Gist.

    .EXAMPLE
    Get-Gist -Id f784228937183a1cf8105351872d2f8a -Invoke

    Gets the Update-Release and Test-GetGist functions from the following Gist URL and loads them into the current session for subsequent use: https://gist.github.com/scrthq/f784228937183a1cf8105351872d2f8a
    #>

    [CmdletBinding()]
    Param (
        [parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,Position = 0)]
        [String]
        $Id,
        [parameter(ValueFromPipelineByPropertyName)]
        [Alias('Files')]
        [String[]]
        $File,
        [parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Sha,
        [parameter(ValueFromPipelineByPropertyName)]
        [Object]
        $Metadata,
        [parameter()]
        [Switch]
        $Invoke
    )
    Process {
        $Uri = [System.Collections.Generic.List[string]]@(
            'https://api.github.com'
            '/gists/'
            $PSBoundParameters['Id']
        )
        if ($PSBoundParameters.ContainsKey('Sha')) {
            $Uri.Add("/$($PSBoundParameters['Sha'])")
            Write-Verbose "[$($PSBoundParameters['Id'])] Getting gist info @ SHA '$($PSBoundParameters['Sha'])'"
        }
        else {
            Write-Verbose "[$($PSBoundParameters['Id'])] Getting gist info"
        }
        $gistInfo = Invoke-RestMethod -Uri ([Uri](-join $Uri)) -Verbose:$false
        $fileNames = if ($PSBoundParameters.ContainsKey('File')) {
            $PSBoundParameters['File']
        }
        else {
            $gistInfo.files.PSObject.Properties.Name
        }
        foreach ($fileName in $fileNames) {
            Write-Verbose "[$fileName] Getting gist file content"
            $fileInfo = $gistInfo.files.$fileName
            $content = if ($fileInfo.truncated) {
                (Invoke-WebRequest -Uri ([Uri]$fileInfo.raw_url)).Content
            }
            else {
                $fileInfo.content
            }
            $lines = ($content -split "`n").Count
            if ($Invoke) {
                Write-Verbose "[$fileName] Parsing gist file content ($lines lines)"
                $noScopePattern = '^function\s+(?<Name>[\w+_-]{1,})\s+\{'
                $globalScopePattern = '^function\s+global\:'
                $noScope = [RegEx]::Matches($content, $noScopePattern, "Multiline, IgnoreCase")
                $globalScope = [RegEx]::Matches($content,$globalScopePattern,"Multiline, IgnoreCase")
                if ($noScope.Count -ge $globalScope.Count) {
                    foreach ($match in $noScope) {
                        $fullValue = ($match.Groups | Where-Object { $_.Name -eq 0 }).Value
                        $funcName = ($match.Groups | Where-Object { $_.Name -eq 'Name' }).Value
                        Write-Verbose "[$fileName::$funcName] Updating function to global scope to ensure it imports correctly."
                        $content = $content.Replace($fullValue, "function global:$funcName {")
                    }
                }
                Write-Verbose "[$fileName] Invoking gist file content"
                $ExecutionContext.InvokeCommand.InvokeScript(
                    $false,
                    ([scriptblock]::Create($content)),
                    $null,
                    $null
                )
            }
            [PSCustomObject]@{
                File     = $fileName
                Sha      = $Sha
                Lines    = $lines
                Metadata = $Metadata
                Content  = $content -join "`n"
            }
        }
    }
}
