function Confirm-ScriptIsValid {
    <#
    .SYNOPSIS
    Uses the PSParser to check for any errors in a script file.

    .DESCRIPTION
    Uses the PSParser to check for any errors in a script file.

    .PARAMETER Path
    The path of the script to check for errors.

    .EXAMPLE
    Confirm-ScriptIsValid MyScript.ps1

    .EXAMPLE
    Get-ChildItem .\Scripts | Confirm-ScriptIsValid
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias("FullName")]
        [ValidateScript( { Test-Path $_ })]
        [String[]]
        $Path
    )
    Begin {
        $errorColl = @()
        $analyzed = 0
        $lenAnalyzed = 0
    }
    Process {
        foreach ($p in $Path | Where-Object { $_ -like '*.ps1' }) {
            $analyzed++
            $item = Get-Item $p
            $lenAnalyzed += $item.Length
            $contents = Get-Content -Path $item.FullName -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $obj = [PSCustomObject][Ordered]@{
                Name       = $item.Name
                FullName   = $item.FullName
                Length     = $item.Length
                ErrorCount = $errors.Count
                Errors     = $errors
            }
            $obj
            if ($errors.Count) {
                $errorColl += $obj
            }
        }
    }
    End {
        Write-Verbose "Total files analyzed: $analyzed"
        Write-Verbose "Total size of files analyzed: $lenAnalyzed ($([Math]::Round(($lenAnalyzed/1MB),2)) MB)"
        Write-Verbose "Files with errors:`n$($errorColl | Sort-Object FullName | Out-String)"
    }
}
