function Edit-PSProfilePrompt {
    <#
    .SYNOPSIS
    Enables editing the prompt from the desired editor. Once temporary file is saved, the prompt is updated in $PSProfile.Prompts.

    .DESCRIPTION
    Enables editing the prompt from the desired editor. Once temporary file is saved, the prompt is updated in $PSProfile.Prompts.

    .PARAMETER WithInsiders
    If $true, looks for VS Code Insiders to load. If $true and code-insiders cannot be found, opens the file using VS Code stable. If $false, opens the file using VS Code stable. Defaults to $false.

    .PARAMETER Save
    If $true, saves prompt back to your PSProfile after updating.

    .EXAMPLE
    Edit-PSProfilePrompt

    Opens the current prompt as a temporary file in Visual Studio Code to edit. Once the file is saved and closed, the active prompt is updated with the changes.
    #>
    [CmdletBinding()]
    Param(
        [Alias('wi')]
        [Alias('insiders')]
        [Switch]
        $WithInsiders,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        $codeCommand = @('code','code-insiders')
        if ($WithInsiders) {
            $codeCommand = @('code-insiders','code')
        }
        $code = (Get-Command $codeCommand -All | Where-Object { $_.CommandType -notin @('Function','Alias') })[0].Source
        $in = @{
            StdIn   = Get-PSProfilePrompt -Global
            TmpFile = [System.IO.Path]::Combine(([System.IO.Path]::GetTempPath()),"ps-prompt-$(-join ((97..(97+25)|%{[char]$_}) | Get-Random -Count 3)).ps1")
            Editor  = $code
        }
        $handler = {
            Param(
                [hashtable]
                $in
            )
            try {
                $in.StdIn | Set-Content $in.TmpFile -Force
                & $in.Editor $in.TmpFile --wait
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
        if ($Save) {
            Add-PSProfilePrompt -Save
        }
    }
}
