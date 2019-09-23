function Add-PSProfileInitScript {
    <#
    .SYNOPSIS
    Adds script contents to your PSProfile configuration directly. Contents will be invoked during PSProfile import. Useful for scripts that you want to include directly on your configuration for portability instead of calling as an external script via $PSProfile.ScriptPaths.

    .DESCRIPTION
    Adds script contents to your PSProfile configuration directly. Contents will be invoked during PSProfile import. Useful for scripts that you want to include directly on your configuration for portability instead of calling as an external script via $PSProfile.ScriptPaths.

    .PARAMETER Name
    The friendly name to reference the script block by.

    .PARAMETER Content
    The content of the script as a string, i.e. if using `Get-Content` against another file to pass as the value here.

    .PARAMETER ScriptBlock
    The content of the script as a scriptblock. Useful if you are adding as script manually

    .PARAMETER Path
    The path to an external PS1 file to import the contents to your $PSProfile.InitScripts directly. When using Path, the file's BaseName becomes the Name value.

    .PARAMETER State
    Whether the InitScript should be Enabled or Disabled. Defaults to Enabled.

    .PARAMETER RemoveDuplicateScriptPaths
    If a specified Path is also in $PSProfile.ScriptPaths, remove it from there to prevent duplicate scripts from being invoked during PSProfile import.

    .PARAMETER Force
    If the InitScript name already exists in $PSProfile.InitScripts, use -Force to overwrite the existing value.

    .PARAMETER Save
    If $true, saves the updated PSProfile after updating.

    .EXAMPLE
    Get-PSProfileScriptPath | Add-PSProfileInitScript
    #>

    [CmdletBinding(DefaultParameterSetName = 'Content')]
    Param(
        [Parameter(Mandatory,Position = 0,ParameterSetName = 'Content')]
        [Parameter(Mandatory,Position = 0,ParameterSetName = 'ScriptBlock')]
        [String]
        $Name,
        [Parameter(Mandatory,Position = 1,ParameterSetName = 'Content')]
        [String[]]
        $Content,
        [Parameter(Mandatory,Position = 1,ParameterSetName = 'ScriptBlock')]
        [ScriptBlock]
        $ScriptBlock,
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName = 'Path')]
        [Alias('FullName')]
        [String[]]
        $Path,
        [Parameter()]
        [ValidateSet('Enabled','Disabled')]
        [String]
        $State = 'Enabled',
        [Parameter(ParameterSetName = 'Path')]
        [Switch]
        $RemoveDuplicateScriptPaths,
        [Parameter()]
        [Switch]
        $Force,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            Content {
                if (-not $Force -and $Global:PSProfile.InitScripts.Contains($Name)) {
                    Write-Error "Unable to add Init Script '$Name' to `$PSProfile.InitScripts as it already exists. Use -Force to overwrite the existing value if desired."
                }
                else {
                    Write-Verbose "Adding InitScript '$Name' from Contents to PSProfile configuration"
                    $Global:PSProfile.InitScripts[$Name] = @{
                        Enabled = ($State -eq 'Enabled')
                        ScriptBlock = ($Content -join "`n").Trim()
                    }
                }
            }
            ScriptBlock {
                if (-not $Force -and $Global:PSProfile.InitScripts.Contains($Name)) {
                    Write-Error "Unable to add Init Script '$Name' to `$PSProfile.InitScripts as it already exists. Use -Force to overwrite the existing value if desired."
                }
                else {
                    Write-Verbose "Adding InitScript '$Name' from ScriptBlock to PSProfile configuration"
                    $Global:PSProfile.InitScripts[$Name] = @{
                        Enabled = ($State -eq 'Enabled')
                        ScriptBlock = $ScriptBlock.ToString().Trim()
                    }
                }
            }
            Path {
                $Path | Where-Object {$_ -match '\.ps1$'} | ForEach-Object {
                    $item = Get-Item $_
                    $N = $item.BaseName
                    if (-not $Force -and $Global:PSProfile.InitScripts.Contains($N)) {
                        Write-Error "Unable to add Init Script '$N' to `$PSProfile.InitScripts as it already exists. Use -Force to overwrite the existing value if desired."
                    }
                    else {
                        Write-Verbose "Adding InitScript '$N' from Path '$($item.FullName)' to PSProfile configuration"
                        $Global:PSProfile.InitScripts[$N] = @{
                            Enabled = ($State -eq 'Enabled')
                            ScriptBlock = ((Get-Content $_) -join "`n").Trim()
                        }
                        if ($RemoveDuplicateScriptPaths -and (Get-PSProfileScriptPath) -contains $item.FullName) {
                            Remove-PSProfileScriptPath -Path $item.FullName -Confirm:$false
                        }
                    }
                }
            }
        }
    }
    End {
        if ($Save) {
            Save-PSProfile
        }
    }
}
