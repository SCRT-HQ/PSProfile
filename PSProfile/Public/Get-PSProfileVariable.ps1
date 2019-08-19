function Get-PSProfileVariable {
    <#
    .SYNOPSIS
    Gets a global or environment variable from your PSProfile configuration.

    .DESCRIPTION
    Gets a global or environment variable from your PSProfile configuration.

    .PARAMETER Scope
    The scope of the variable to get the variable from between Environment or Global.

    .PARAMETER Name
    The name of the variable to get.

    .EXAMPLE
    Get-PSProfileVariable -Name HomeBase

    Gets the environment variable named 'HomeBase' and its value from $PSProfile.Variables.

    .EXAMPLE
    Get-PSProfileVariable

    Gets the list of environment variables from $PSProfile.Variables.

    .EXAMPLE
    Get-PSProfileVariable -Scope Global

    Gets the list of Global variables from $PSProfile.Variables.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('Environment','Global')]
        [String]
        $Scope,
        [Parameter(Position = 1)]
        [String]
        $Name
    )
    Process {
        if ($Global:PSProfile.Variables.ContainsKey($Scope)) {
            if ($PSBoundParameters.ContainsKey('Name')) {
                Write-Verbose "Getting $Scope variable '$Name' from PSProfile"
                $Global:PSProfile.Variables[$Scope].GetEnumerator() | Where-Object {$_.Key -in $Name}
            }
            else {
                Write-Verbose "Getting $Scope variable list from PSProfile"
                $Global:PSProfile.Variables[$Scope]
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileVariable -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Variables[$fakeBoundParameter.Scope].Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
