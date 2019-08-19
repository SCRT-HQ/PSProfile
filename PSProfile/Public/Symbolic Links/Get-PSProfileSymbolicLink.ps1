function Get-PSProfileSymbolicLink {
    <#
    .SYNOPSIS
    Gets a module from $PSProfile.SymbolicLinks.

    .DESCRIPTION
    Gets a module from $PSProfile.SymbolicLinks.

    .PARAMETER LinkPath
    The LinkPath to get from $PSProfile.SymbolicLinks.

    .EXAMPLE
    Get-PSProfileSymbolicLink -LinkPath C:\workstation

    Gets the LinkPath 'C:\workstation' from $PSProfile.SymbolicLinks

    .EXAMPLE
    Get-PSProfileSymbolicLink

    Gets the list of LinkPaths from $PSProfile.SymbolicLinks
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0,ValueFromPipeline)]
        [String[]]
        $LinkPath
    )
    Process {
        if ($PSBoundParameters.ContainsKey('LinkPath')) {
            Write-Verbose "Getting Path LinkPath '$LinkPath' from `$PSProfile.SymbolicLinks"
            $Global:PSProfile.SymbolicLinks.GetEnumerator() | Where-Object {$_.Key -in $LinkPath}
        }
        else {
            Write-Verbose "Getting all command aliases from `$PSProfile.SymbolicLinks"
            $Global:PSProfile.SymbolicLinks
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileSymbolicLink -ParameterName LinkPath -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.SymbolicLinks.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
