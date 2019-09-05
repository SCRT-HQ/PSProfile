function Install-LatestModule {
    <#
    .SYNOPSIS
    A helper function to uninstall any existing versions of the target module before installing the latest one.

    .DESCRIPTION
    A helper function to uninstall any existing versions of the target module before installing the latest one. Defaults to CurrentUser scope when installing the latest module version from the desired repository.

    .PARAMETER Name
    The name of the module to install the latest version of

    .PARAMETER Repository
    The PowerShell repository to install the latest module from. Defaults to the PowerShell Gallery.

    .PARAMETER ConfirmNotImported
    If $true, safeguards module removal if the module you are trying to update is currently imported by throwing a terminating error.

    .EXAMPLE
    Install-LatestModule PSProfile
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [String[]]
        $Name,
        [Parameter()]
        [String]
        $Repository = 'PSGallery',
        [Parameter()]
        [Switch]
        $ConfirmNotImported
    )
    Process {
        foreach ($module in $Name) {
            if ($ConfirmNotImported -and (Get-Module $module)) {
                throw "$module cannot be loaded if trying to install!"
            }
            else {
                try {
                    Write-Verbose "Uninstalling all version of module: $module"
                    Get-Module $module -ListAvailable | Uninstall-Module
                    Write-Verbose "Installing latest module version from PowerShell Gallery"
                    Install-Module $module -Repository $Repository -Scope CurrentUser -AllowClobber -SkipPublisherCheck -AcceptLicense
                }
                catch {
                    throw
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Install-LatestModule -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    (Get-Module "$wordToComplete*" -ListAvailable).Name | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
