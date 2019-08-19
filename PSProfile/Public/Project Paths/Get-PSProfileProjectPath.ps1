function Get-PSProfileProjectPath {
    <#
    .SYNOPSIS
    Gets a project path from $PSProfile.ProjectPaths.

    .DESCRIPTION
    Gets a project path from $PSProfile.ProjectPaths.

    .PARAMETER Path
    The project path to get from $PSProfile.ProjectPaths.

    .EXAMPLE
    Get-PSProfileProjectPath -Path E:\Git

    Gets the path 'E:\Git' from $PSProfile.ProjectPaths

    .EXAMPLE
    Get-PSProfileProjectPath

    Gets the list of project paths from $PSProfile.ProjectPaths
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $Path
    )
    Process {
        if ($PSBoundParameters.ContainsKey('Path')) {
            Write-Verbose "Getting project path '$Path' from `$PSProfile.ProjectPaths"
            $Global:PSProfile.ProjectPaths | Where-Object {$_ -in $Path}
        }
        else {
            Write-Verbose "Getting all project paths from `$PSProfile.ProjectPaths"
            $Global:PSProfile.ProjectPaths
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileProjectPath -ParameterName Path -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.ProjectPaths | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
