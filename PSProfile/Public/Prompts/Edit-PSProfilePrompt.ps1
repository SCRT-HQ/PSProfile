function Edit-PSProfilePrompt {
    <#
    .SYNOPSIS
    Enables editing the prompt from the desired editor. Once temporary file is saved, the prompt is updated in $PSProfile.Prompts.

    .DESCRIPTION
    Enables editing the prompt from the desired editor. Once temporary file is saved, the prompt is updated in $PSProfile.Prompts.

    .PARAMETER Temporary
    If $true, does not save the PSProfile after updating the prompt.

    .EXAMPLE
    Edit-PSProfilePrompt

    Opens the current prompt as a temporary file in Visual Studio Code to edit. Once the file is saved and closed, the prompt is updated with the changes and saved back to $PSProfile.
    #>
    [CmdletBinding()]
    Param(
        [Parameter()]
        [Switch]
        $Temporary
    )
    Process {
        $in = @{
            StdIn   = Get-PSProfilePrompt -Global
            TmpFile = [System.IO.Path]::Combine(([System.IO.Path]::GetTempPath()),"ps-prompt-$(-join ((97..(97+25)|%{[char]$_}) | Get-Random -Count 3)).ps1")
        }
        $handler = {
            Param(
                [hashtable]
                $in
            )
            try {
                $code = (Get-Command code -All | Where-Object { $_.CommandType -notin @('Function','Alias') })[0].Source
                $in.StdIn | Set-Content $in.TmpFile -Force
                & $code $in.TmpFile --wait
            }
            catch {
                throw
            }
            finally {
                if (Test-Path $in.TmpFile -ErrorAction SilentlyContinue) {
                    Invoke-Expression ([System.IO.File]::ReadAllText($in.TmpFile))
                    Remove-Item $in.TmpFile -Force
                }
            }
        }
        Write-Verbose "Opening prompt in VS Code"
        .$handler($in)
        if (-not $Temporary) {
            Save-PSProfilePrompt
        }
    }
}
