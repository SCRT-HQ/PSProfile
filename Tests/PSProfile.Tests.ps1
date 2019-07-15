$ModuleName = 'PSProfile'
$SourceModuleManifestPath = (Resolve-Path "$env:BHProjectPath\$($ModuleName)\$($ModuleName).psd1").Path
$TargetModuleManifestPath = (Resolve-Path "$env:BHProjectPath\BuildOutput\$($ModuleName)\*\$($ModuleName).psd1").Path

Describe 'Module Manifest Tests' {
    $testCases = $SourceModuleManifestPath,$TargetModuleManifestPath | ForEach-Object {
        @{
            Path = $_
        }
    }
    It 'Passes Test-ModuleManifest: <Path>' -TestCases $testCases {
        Param ($Path)
        Test-ModuleManifest -Path $Path | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}
