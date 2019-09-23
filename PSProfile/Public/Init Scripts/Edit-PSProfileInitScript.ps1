function Edit-PSProfileInitScript {
    <#
    .SYNOPSIS
    Edit an InitScript from $PSProfile.InitScripts in Visual Studio Code.

    .DESCRIPTION
    Edit an InitScript from $PSProfile.InitScripts in Visual Studio Code.

    .PARAMETER Name
    The name of the InitScript to edit from $PSProfile.InitScripts.

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
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        foreach ($initScript in $Name) {
            if ($Global:PSProfile.InitScripts.Contains($initScript)) {
                $in = @{
                    StdIn   = $Global:PSProfile.InitScripts[$initScript].ScriptBlock
                    TmpFile = [System.IO.Path]::Combine(([System.IO.Path]::GetTempPath()),"InitScript-$($initScript)-$(-join ((97..(97+25)|%{[char]$_}) | Get-Random -Count 3)).ps1")
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
    $Global:PSProfile.InitScripts.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
