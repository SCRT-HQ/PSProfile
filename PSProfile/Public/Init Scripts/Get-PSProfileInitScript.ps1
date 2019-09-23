function Get-PSProfileInitScript {
    <#
    .SYNOPSIS
    Gets an InitScript from $PSProfile.InitScripts.

    .DESCRIPTION
    Gets an InitScript from $PSProfile.InitScripts.

    .PARAMETER Name
    The name of the InitScript to get from $PSProfile.InitScripts.

    .PARAMETER Full
    If $true, gets the compiled InitScript from $PSProfile.InitScripts. This only includes Enabled InitScripts. Each InitScript includes the name in a comment at the top of it for easy identification.

    .EXAMPLE
    Get-PSProfileInitScript -Name PSReadlineSettings,DevOpsTools

    Returns the information for the InitScripts 'PSReadlineSettings' and 'DevOpsTools' from $PSProfile.InitScripts

    .EXAMPLE
    Get-PSProfileInitScript -Full

    Gets the compiled InitScript from $PSProfile.InitScripts. This only includes Enabled InitScripts.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    Param (
        [Parameter(Position = 0,ValueFromPipeline,ParameterSetName = 'Name')]
        [String[]]
        $Name,
        [Parameter(ParameterSetName = 'Full')]
        [Switch]
        $Full
    )
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            Name {
                if ($PSBoundParameters.ContainsKey('Name')) {
                    Write-Verbose "Getting InitScript [ $($Name -join ', ') ] from `$PSProfile.InitScripts"
                    $Global:PSProfile.InitScripts.GetEnumerator() | Where-Object {$_.Key -in $Name} | ForEach-Object {
                        [PSCustomObject]@{
                            Name = $_.Key
                            Enabled = $_.Value.Enabled
                            ScriptBlock = ([scriptblock]::Create($_.Value.ScriptBlock))
                        }
                    }
                }
                else {
                    Write-Verbose "Getting all InitScripts from `$PSProfile.InitScripts"
                    $Global:PSProfile.InitScripts.GetEnumerator() | ForEach-Object {
                        [PSCustomObject]@{
                            Name = $_.Key
                            Enabled = $_.Value.Enabled
                            ScriptBlock = ([scriptblock]::Create($_.Value.ScriptBlock))
                        }
                    }
                }
            }
            Full {
                Write-Verbose "Getting the full InitScript from `$PSProfile.InitScripts"
                $f = $Global:PSProfile.InitScripts.GetEnumerator() | Where-Object {$_.Value.Enabled} | ForEach-Object {
                    "# From InitScript: $($_.Key)"
                    $_.Value.ScriptBlock
                    ""
                }
                if ($f) {
                    [scriptblock]::Create(($f -join "`n").Trim())
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileInitScript -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.InitScripts.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
