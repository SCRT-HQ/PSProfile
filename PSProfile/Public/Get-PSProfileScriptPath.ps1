function Get-PSProfileScriptPath {
    <#
    .SYNOPSIS
    Gets a script path from $PSProfile.ScriptPaths.

    .DESCRIPTION
    Gets a script path from $PSProfile.ScriptPaths.

    .PARAMETER Path
    The script path to get from $PSProfile.ScriptPaths.

    .EXAMPLE
    Get-PSProfileScriptPath -Path E:\Git\MyProfileScript.ps1

    Gets the path 'E:\Git\MyProfileScript.ps1' from $PSProfile.ScriptPaths

    .EXAMPLE
    Get-PSProfileScriptPath

    Gets the list of script paths from $PSProfile.ScriptPaths
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Path
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Path')) {
            Write-Verbose "Getting script path '$Path' from `$PSProfile.ScriptPaths"
            $Global:PSProfile.ScriptPaths | Where-Object {$_ -in $Path}
        }
        else {
            Write-Verbose "Getting all script paths from `$PSProfile.ScriptPaths"
            $Global:PSProfile.ScriptPaths
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileScriptPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.ScriptPaths | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
