[CmdletBinding()]
Param(
    [Parameter()]
    [string]
    $ModuleName = 'PSProfile',
    [Parameter()]
    [hashtable]
    $Dependencies = @{
        PackageManagement = '1.3.1'
        PowerShellGet     = '2.1.2'
        InvokeBuild       = '5.5.2'
    },

    [Parameter()]
    [ValidateSet('Init','Clean','Build','Test','Deploy')]
    [string[]]
    $Task,
    [Parameter()]
    [object]
    $File,
    [Parameter()]
    [switch]
    $Safe,
    [Parameter()]
    [switch]
    $Summary
)

#region: Import Azure Pipeline Helper functions from Gist
$helperUri = @(
    'https://gist.githubusercontent.com'
    'scrthq'                                    # User
    'a99cc06e75eb31769d01b2adddc6d200'          # Gist Id
    'raw'
    '1ed720232df2779896c960bf282b54ab73bf63d0'  # Commit Id
    'AzurePipelineHelpers.ps1'                  # Filename
) -join '/'
$helperContent = Invoke-RestMethod -Uri $helperUri
.([scriptblock]::Create($helperContent))($ModuleName)
#endregion

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose:$false
$PSDefaultParameterValues = @{
    '*-Module:Verbose'                  = $false
    '*-Module:Force'                    = $true
    'Import-Module:ErrorAction'         = 'Stop'
    'Install-Module:AcceptLicense'      = $true
    'Install-Module:AllowClobber'       = $true
    'Install-Module:Confirm'            = $false
    'Install-Module:ErrorAction'        = 'Stop'
    'Install-Module:Repository'         = 'PSGallery'
    'Install-Module:Scope'              = 'CurrentUser'
    'Install-Module:SkipPublisherCheck' = $true
}
Add-Heading "Resolving module dependencies"
foreach ($dependency in $Dependencies.Keys) {
    $parameters = @{
        Name           = $dependency
        MinimumVersion = $Dependencies[$dependency]
    }
    Write-BuildLog "[$dependency] Resolving"
    try {
        if ($imported = Get-Module $dependency) {
            Write-BuildLog "[$dependency] Removing imported module"
            $imported | Remove-Module
        }
        Import-Module @parameters
    }
    catch {
        Write-BuildLog "[$dependency] Installing missing module"
        Install-Module @parameters
        Import-Module @parameters
    }
}
try {
    $null = Get-PackageProvider -Name Nuget -ForceBootstrap -Verbose:$false -ErrorAction Stop
}
catch {
    throw
}

Add-Heading "Executing Invoke-Build"
Invoke-Build -ModuleName $ModuleName @PSBoundParameters
