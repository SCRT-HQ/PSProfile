Param(
    [Parameter(Mandatory,Position = 0)]
    [String]
    $ModuleName,
    [Parameter()]
    [String]
    $NextModuleVersion,
    [Parameter()]
    [String]
    $GalleryVersion,
    [Parameter()]
    [String]
    $ManifestVersion,
    [Parameter()]
    [String]
    $SourceModuleDirectory,
    [Parameter()]
    [String]
    $SourceManifestPath,
    [Parameter()]
    [String]
    $TargetDirectory,
    [Parameter()]
    [String]
    $TargetManifestPath,
    [Parameter()]
    [String]
    $TargetPSM1Path,
    [Parameter()]
    [String]
    $TargetModuleDirectory,
    [Parameter()]
    [String]
    $TargetVersionDirectory
)

task . Build

task Init {
    Import-Module Configuration
    $Script:SourceModuleDirectory = [System.IO.Path]::Combine($BuildRoot,$ModuleName)
    $Script:GalleryVersion = (Get-PSGalleryVersion $ModuleName).Version
    $Script:SourceManifestPath = Join-Path $SourceModuleDirectory "$($ModuleName).psd1"
    $Script:ManifestVersion = (Import-Metadata -Path $SourceManifestPath).ModuleVersion
    $Script:NextModuleVersion = Get-NextModuleVersion -GalleryVersion $GalleryVersion -ManifestVersion $ManifestVersion
    $Script:TargetDirectory = [System.IO.Path]::Combine($BuildRoot,'BuildOutput')
    $Script:TargetModuleDirectory = [System.IO.Path]::Combine($TargetDirectory,$ModuleName)
    $Script:TargetVersionDirectory = [System.IO.Path]::Combine($TargetModuleDirectory,$NextModuleVersion)
    $Script:TargetManifestPath = [System.IO.Path]::Combine($TargetVersionDirectory,"$($ModuleName).psd1")
    $Script:TargetPSM1Path = [System.IO.Path]::Combine($TargetVersionDirectory,"$($ModuleName).psm1")
    Write-BuildLog "Build System Details:"
    @(
        ""
        "~~~~~ Summary ~~~~~"
        "In CI?              : $($IsCI -or (Test-Path Env:\TF_BUILD))"
        "Project             : $ModuleName"
        "Manifest Version    : $ManifestVersion"
        "Gallery Version     : $GalleryVersion"
        "Next Module Version : $NextModuleVersion"
        "Engine              : PowerShell $($PSVersionTable.PSVersion.ToString())"
        "Host OS             : $(if($PSVersionTable.PSVersion.Major -le 5 -or $IsWindows){"Windows"}elseif($IsLinux){"Linux"}elseif($IsMacOS){"macOS"}else{"[UNKNOWN]"})"
        "PWD                 : $PWD"
        ""
        "~~~~~ Directories ~~~~~"
        "SourceModuleDirectory  : $SourceModuleDirectory"
        "TargetDirectory        : $TargetDirectory"
        "TargetModuleDirectory  : $TargetModuleDirectory"
        "TargetVersionDirectory : $TargetVersionDirectory"
        "TargetManifestPath     : $TargetManifestPath"
        "TargetPSM1Path         : $TargetPSM1Path"
        ""
        "~~~~~ Environment ~~~~~"
        ) | Write-BuildLog
        Write-BuildLog "$((Get-ChildItem Env: | Where-Object {$_.Name -match "^(BUILD_|BH)"} | Sort-Object Name | Format-Table Name,Value -AutoSize | Out-String).Trim())"
}

task Clean Init,{
    remove 'BuildOutput'
}

task Build Clean,{
    $functionsToExport = @()
    $aliasesToExport = @()
    Write-BuildLog 'Creating psm1...'
    $psm1 = New-Item -Path $TargetPSM1Path -ItemType File -Force

    $psm1Header = @(
        '[CmdletBinding()]'
        'Param ('
        '    [parameter(Position = 0)]'
        '    [bool]'
        '    $ShowLoadTime = $true'
        ')'
        '$env:ShowPSProfileLoadTime = $ShowLoadTime'
    ) -join "`n"
    $psm1Header | Add-Content -Path $psm1 -Encoding UTF8

    foreach ($scope in @('Classes','Private','Public')) {
        $gciPath = Join-Path $SourceModuleDirectory $scope
        if (Test-Path $gciPath) {
            Write-BuildLog "Copying contents from files in source folder to PSM1: $($scope)"
            Get-ChildItem -Path $gciPath -Filter "*.ps1" -Recurse -File | ForEach-Object {
                Write-BuildLog "Working on: $($_.FullName.Replace("$gciPath\",''))"
                "$(Get-Content $_.FullName -Raw)`n" | Add-Content -Path $psm1 -Encoding UTF8
                if ($scope -eq 'Public') {
                    $functionsToExport += $_.BaseName
                    "Export-ModuleMember -Function '$($_.BaseName)'`n" | Add-Content -Path $psm1 -Encoding UTF8
                }
            }
        }
    }
    $aliasPath = [System.IO.Path]::Combine($SourceModuleDirectory,"$($ModuleName).Aliases.ps1")
    if (Test-Path $aliasPath) {
        Write-BuildLog "Copying aliases to PSM1"
        $aliasHash = . $aliasPath
        $aliasHash.GetEnumerator() | ForEach-Object {
            $aliasesToExport += $_.Key
            "New-Alias -Name '$($_.Key)' -Value '$($_.Value)' -Scope Global -Force" | Add-Content -Path $psm1 -Encoding UTF8
            "Export-ModuleMember -Alias '$($_.Key)'" | Add-Content -Path $psm1 -Encoding UTF8
        }
    }
    Write-BuildLog "Adding content from source PSM1 to footer of target PSM1"
    Get-Content (Join-Path $SourceModuleDirectory "$($ModuleName).psm1") -Raw  | Add-Content -Path $psm1 -Encoding UTF8

    Get-ChildItem -Path $SourceModuleDirectory -Directory | Where-Object {$_.BaseName -notin @('Classes','Private','Public')} | ForEach-Object {
        Write-BuildLog "Copying source folder to target: $($_.BaseName)"
        Copy-Item $_.FullName -Destination $TargetVersionDirectory -Container -Recurse
    }

    if ($ManifestVersion -ne $NextModuleVersion) {
        Write-BuildLog "Bumping source manifest version from '$ManifestVersion' to '$NextModuleVersion' to prevent errors"
        Update-Metadata -Path $SourceManifestPath -PropertyName ModuleVersion -Value $NextModuleVersion
        ([System.IO.File]::ReadAllText($SourceManifestPath)).Trim() | Set-Content $SourceManifestPath
    }

    # Copy over manifest
    Write-BuildLog "Copying source manifest to target folder"
    Copy-Item -Path $SourceManifestPath -Destination $TargetVersionDirectory

    # Update FunctionsToExport and AliasesToExport on manifest
    $params = @{
        Path = $TargetManifestPath
        FunctionsToExport = ($functionsToExport | Sort-Object)
    }
    if ($aliasesToExport.Count) {
        $params['AliasesToExport'] = ($aliasesToExport | Sort-Object)
    }
    Write-BuildLog "Updating target manifest file with exports"
    Update-ModuleManifest @params

    if ($ManifestVersion -ne $NextModuleVersion) {
        Write-BuildLog "Reverting bumped source manifest version from '$NextModuleVersion' to '$ManifestVersion'"
        Update-Metadata -Path $SourceManifestPath -PropertyName ModuleVersion -Value $ManifestVersion
        ([System.IO.File]::ReadAllText($SourceManifestPath)).Trim() | Set-Content $SourceManifestPath
    }

    Write-BuildLog "Created compiled module at [$TargetVersionDirectory]"
    Write-BuildLog "Output version directory contents:"
    Get-ChildItem $TargetVersionDirectory | Format-Table -Autosize
}

task Import -If {Test-Path $TargetManifestPath} Build,{
    Import-Module -Name $TargetModuleDirectory -ErrorAction Stop
}

task Test Init,{
    if ($module = Get-Module $ModuleName) {
        Write-BuildLog "$ModuleName is currently imported. Removing module and cleaning up any leftover aliases"
        $module | Remove-Module -Force
        $aliases = @{}
        $aliasPath = [System.IO.Path]::Combine($BuildRoot,$ModuleName,"$ModuleName.Aliases.ps1")
        if (Test-Path $aliasPath) {
            (. $aliasPath).Keys | ForEach-Object {
                if (Get-Alias "$_*") {
                    Remove-Alias -Name $_ -Force
                }
            }
        }
    }
    $parameters = @{
        Name           = 'Pester'
        MinimumVersion = '4.8.1'
        MaximumVersion = '4.99.99'
    }
    Write-BuildLog "[$($parameters.Name)] Resolving"
    try {
        if ($imported = Get-Module $($parameters.Name)) {
            Write-BuildLog "[$($parameters.Name)] Removing imported module"
            $imported | Remove-Module
        }
        Import-Module @parameters
    }
    catch {
        Write-BuildLog "[$($parameters.Name)] Installing missing module"
        Install-Module @parameters
        Import-Module @parameters
    }
    Push-Location
    Set-Location -PassThru $TargetModuleDirectory
    Get-Module $ModuleName | Remove-Module $ModuleName -ErrorAction SilentlyContinue -Verbose:$false
    Import-Module -Name $TargetModuleDirectory -Force -Verbose:$false
    $pesterParams = @{
        OutputFormat = 'NUnitXml'
        OutputFile   = Join-Path $TargetDirectory "TestResults.xml"
        PassThru     = $true
        Path         = Join-Path $BuildRoot "Tests"
    }
    if ($global:ExcludeTag) {
        $pesterParams['ExcludeTag'] = $global:ExcludeTag
        Write-BuildLog "Invoking Pester and excluding tag(s) [$($global:ExcludeTag -join ', ')]..."
    }
    else {
        Write-BuildLog 'Invoking Pester...'
    }
    $testResults = Invoke-Pester @pesterParams
    Write-BuildLog 'Pester invocation complete!'
    if ($testResults.FailedCount -gt 0) {
        $testResults | Format-List
        Write-BuildError 'One or more Pester tests failed. Build cannot continue!'
    }
}

$psGalleryConditions = {
    -not [String]::IsNullOrEmpty($env:NugetApiKey) -and
    -not [String]::IsNullOrEmpty($NextModuleVersion) -and
    $env:BHBuildSystem -eq 'VSTS' -and
    $env:BHCommitMessage -match '!deploy' -and
    $env:BHBranchName -in @('master','main')
}
$gitHubConditions = {
    -not [String]::IsNullOrEmpty($env:GitHubPAT) -and
    -not [String]::IsNullOrEmpty($NextModuleVersion) -and
    $env:BHBuildSystem -eq 'VSTS' -and
    $env:BHCommitMessage -match '!deploy' -and
    $env:BHBranchName -in @('master','main')
}
$tweetConditions = {
    -not [String]::IsNullOrEmpty($env:TwitterAccessSecret) -and
    -not [String]::IsNullOrEmpty($env:TwitterAccessToken) -and
    -not [String]::IsNullOrEmpty($env:TwitterConsumerKey) -and
    -not [String]::IsNullOrEmpty($env:TwitterConsumerSecret) -and
    -not [String]::IsNullOrEmpty($NextModuleVersion) -and
    $env:BHBuildSystem -eq 'VSTS' -and
    $env:BHCommitMessage -match '!deploy' -and
    $env:BHBranchName -in @('master','main')
}

task PublishToPSGallery -If $psGalleryConditions {
    Write-BuildLog "Publishing version [$($NextModuleVersion)] to PSGallery"
    Publish-Module -Path $TargetVersionDirectory -NuGetApiKey $env:NugetApiKey -Repository PSGallery
    Write-BuildLog "Deployment successful!"
}

task PublishToGitHub -If $gitHubConditions {
    Write-BuildLog "Creating Release ZIP..."
    $commitId = git rev-parse --verify HEAD
    $ReleaseNotes = . .\ci\GitHubReleaseNotes.ps1
    $zipPath = [System.IO.Path]::Combine($BuildRoot,"$($ModuleName).zip")
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    Add-Type -Assembly System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($TargetModuleDirectory,$zipPath)
    Write-BuildLog "Publishing Release v$($NextModuleVersion) @ commit Id [$($commitId)] to GitHub..."


    $gitHubParams = @{
        VersionNumber    = $NextModuleVersion.ToString()
        CommitId         = $commitId
        ReleaseNotes     = $ReleaseNotes
        ArtifactPath     = $zipPath
        GitHubUsername   = 'SCRT-HQ'
        GitHubRepository = $ModuleName
        GitHubApiKey     = $env:GitHubPAT
        Draft            = $false
    }
    Publish-GitHubRelease @gitHubParams
    Write-BuildLog "Release creation successful!"
}

task PublishToTwitter -If $tweetConditions {
    if ($null -eq (Get-Module PoshTwit -ListAvailable)) {
        Write-BuildLog "Installing PoshTwit module"
        Install-Module PoshTwit -Scope CurrentUser -SkipPublisherCheck -AllowClobber -Repository PSGallery -Force
    }
    Import-Module PoshTwit -Verbose:$false
    Write-BuildLog "Publishing tweet about new release..."
    $manifest = Import-PowerShellDataFile -Path $TargetManifestPath
    $text = "#$($ModuleName) v$($NextModuleVersion) is now available on the #PSGallery! https://www.powershellgallery.com/packages/$($ModuleName)/$NextModuleVersion #PowerShell"
    $manifest.PrivateData.PSData.Tags | Foreach-Object {
        $text += " #$($_)"
    }
    if ($text.Length -gt 280) {
        Write-BuildLog "Trimming [$($text.Length - 280)] extra characters from tweet text to get to 280 character limit..."
        $text = $text.Substring(0,280)
    }
    Write-BuildLog "Tweet text: $text"
    $publishTweetSplat = @{
        Tweet          = $text
        ConsumerSecret = $env:TwitterConsumerSecret
        ConsumerKey    = $env:TwitterConsumerKey
        AccessToken    = $env:TwitterAccessToken
        AccessSecret   = $env:TwitterAccessSecret
    }
    Publish-Tweet @publishTweetSplat
    Write-BuildLog "Tweet successful!"
}

task Deploy Init,PublishToPSGallery,PublishToGitHub,PublishToTwitter
