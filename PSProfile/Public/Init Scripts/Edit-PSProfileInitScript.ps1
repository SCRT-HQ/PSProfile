function Edit-PSProfileInitScript {
    <#
    .SYNOPSIS
    Edit an InitScript from $PSProfile.InitScripts in Visual Studio Code.

    .DESCRIPTION
    Edit an InitScript from $PSProfile.InitScripts in Visual Studio Code.

    .PARAMETER Name
    The name of the InitScript to edit from $PSProfile.InitScripts.

    .PARAMETER WithInsiders
    If $true, looks for VS Code Insiders to load. If $true and code-insiders cannot be found, opens the file using VS Code stable. If $false, opens the file using VS Code stable. Defaults to $false.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Remove-PSProfileInitScript -Name PSReadlineSettings,DevOpsTools

    Removes the InitScripts 'PSReadlineSettings' and 'DevOpsTools' from $PSProfile.InitScripts.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]
        $Name,
        [Alias('wi')]
        [Alias('insiders')]
        [Switch]
        $WithInsiders,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        $code = $null
        $codeCommand = if($WithInsiders) {
            @('code-insiders','code')
        }
        else {
            @('code','code-insiders')
        }
        foreach ($cmd in $codeCommand) {
            try {
                if ($found = (Get-Command $cmd -All -ErrorAction Stop | Where-Object { $_.CommandType -notin @('Function','Alias') } | Select-Object -First 1 -ExpandProperty Source)) {
                    $code = $found
                    break
                }
            }
            catch {
                $Global:Error.Remove($Global:Error[0])
            }
        }
        if ($null -eq $code){
            throw "Editor not found!"
        }
        foreach ($initScript in $Name) {
            if ($Global:PSProfile.InitScripts.Contains($initScript)) {
                $in = @{
                    StdIn   = $Global:PSProfile.InitScripts[$initScript].ScriptBlock
                    TmpFile = [System.IO.Path]::Combine(([System.IO.Path]::GetTempPath()),"InitScript-$($initScript)-$(-join ((97..(97+25)|%{[char]$_}) | Get-Random -Count 3)).ps1")
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
                            [System.IO.File]::ReadAllText($in.TmpFile)
                            Remove-Item $in.TmpFile -Force
                        }
                    }
                }
                Write-Verbose "Editing InitScript '$initScript' in Visual Studio Code, waiting for file to close"
                if ($updated = .$handler($in)) {
                    $Global:PSProfile.InitScripts[$initScript].ScriptBlock = $updated
                }
            }
        }
        if ($Save) {
            Save-PSProfile
        }
    }
}

Register-ArgumentCompleter -CommandName Edit-PSProfileInitScript -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.InitScripts.Keys | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
