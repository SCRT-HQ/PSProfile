function Get-PSProfileSecret {
    <#
    .SYNOPSIS
    Gets a Secret from the $PSProfile.Vault.

    .DESCRIPTION
    Gets a Secret from the $PSProfile.Vault.

    .PARAMETER Name
    The name of the Secret you would like to retrieve from the Vault.

    .EXAMPLE
    Get-PSProfileSecret -Name MyApiKey

    Gets the Secret named 'MyApiKey' from the $PSProfile.Vault.
    #>
    [CmdletBinding()]
    Param(
        [parameter(Mandatory,Position = 0)]
        [String]
        $Name
    )
    Process {
        Write-Verbose "Getting Secret '$Name' from `$PSProfile.Vault"
        $global:PSProfile.Vault.GetSecret($Name)
    }
}

Register-ArgumentCompleter -CommandName Get-PSProfileSecret -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $Global:PSProfile.Vault._secrets.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
