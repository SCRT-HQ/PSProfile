[CmdletBinding()]
Param(
    # Process-specific parameters
    [Parameter()]
    [string]
    $ModuleName = 'PSProfile',
    [Parameter()]
    [hashtable]
    $Dependencies = @{
        Configuration     = '1.3.1'
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
#region: Import Azure Pipeline Helper functions from Gist or cached version if already pulled.
# Gist is specified via Commit SHA so future Gist updates cannot introduce breaking changes to
# scripts pinned to the specific commit.
$helperUri = @(
    'https://gist.githubusercontent.com'
    'scrthq'                                    # User
    'a99cc06e75eb31769d01b2adddc6d200'          # Gist ID
    'raw'
    '10d6ab6de6aa3f35c94acb7707970fe0ee755aa6'  # Commit SHA
    'AzurePipelineHelpers.ps1'                  # Filename
) -join '/'
$fileUri = $helperUri -replace "[$([RegEx]::Escape("$(([System.IO.Path]::GetInvalidFileNameChars() + [System.IO.Path]::GetInvalidPathChars()) -join '')"))]","_"
$ciPath = [System.IO.Path]::Combine($PSScriptRoot,'ci')
$localGistPath = [System.IO.Path]::Combine($ciPath,$fileUri)
if (Test-Path $localGistPath) {
    Write-Host -ForegroundColor Cyan "##[section] Importing Azure Pipelines Helper from Cached Gist: $localGistPath"
    $helperContent = Get-Content $localGistPath -Raw
}
else {
    Write-Host -ForegroundColor Cyan "##[section] Cleaning out stale Gist scripts from the CI Path"
    Get-ChildItem $ciPath -Filter 'https___gist.githubusercontent.com_scrthq*.ps1' | Remove-Item -Force
    Write-Host -ForegroundColor Cyan "##[section] Importing Azure Pipelines Helper from Gist: $helperUri"
    $helperContent = Invoke-RestMethod -Uri $helperUri
    $helperContent | Set-Content $localGistPath -Force
}
.([scriptblock]::Create($helperContent))($ModuleName)
Set-BuildVariables
#endregion

Add-Heading "Setting PSGallery InstallationPolicy to 'Trusted'"
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -Verbose:$false
}
Add-Heading "Setting `$PSDefaultParameterValues for *-Module functions"
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
    $item = $_
    if ($item -is [hashtable]) {
        $hash = @{
            Name = $item['ModuleName']
        }
        if ($_.ContainsKey('ModuleVersion')) {
            $hash['RequiredVersion'] = $item['ModuleVersion']
        }
        $moduleDependencies += $hash
    }
    else {
        if ($Dependencies.Keys -notcontains $item) {
            $moduleDependencies += @{
                Name = $item
            }
        }
    }
}
try {
    $null = Get-PackageProvider -Name Nuget -ForceBootstrap -Verbose:$false -ErrorAction Stop
}
catch {
    throw
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

Add-Heading "Executing Invoke-Build"
Invoke-Build -ModuleName $ModuleName @PSBoundParameters
