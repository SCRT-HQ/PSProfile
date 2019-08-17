[CmdletBinding()]
Param(
    # Process-specific parameters
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
    #region: Invoke-Build parameters
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
    #endregion: Invoke-Build parameters
)
Write-Host -ForegroundColor Cyan "##[section] IMPORTING AZURE PIPELINE HELPERS FROM GIST"
#region: Import Azure Pipeline Helper functions from Gist
$helperUri = @(
    'https://gist.githubusercontent.com'
    'scrthq'                                    # User
    'a99cc06e75eb31769d01b2adddc6d200'          # Gist Id
    'raw'
    '1aaa51f85b72f783c40de813b3bbd521bcc3b0f2'  # Commit Id
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
$moduleDependencies = @()
foreach ($module in $Dependencies.Keys) {
    $moduleDependencies += @{
        Name           = $module
        MinimumVersion = $Dependencies[$module]
    }
}
(Import-PowerShellDataFile ([System.IO.Path]::Combine($PSScriptRoot,$ModuleName,"$ModuleName.psd1"))).RequiredModules | ForEach-Object {
    if ($_ -is [hashtable]) {
        $moduleDependencies += $_
    }
    else {
        $moduleDependencies += @{
            Name = $_
        }
    }
}
foreach ($item in $moduleDependencies) {
    Write-BuildLog "[$($item['Name'])] Resolving"
    try {
        if ($imported = Get-Module $item['Name']) {
            Write-BuildLog "[$($item['Name'])] Removing imported module"
            $imported | Remove-Module
        }
        Import-Module @item
    }
    catch {
        Write-BuildLog "[$($item['Name'])] Installing missing module"
        Install-Module @item
        Import-Module @item
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
