$ModuleName = 'PSProfile'
$ProjectRoot = Resolve-Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path
$SourceModulePath = Resolve-Path "$ProjectRoot\$ModuleName" | Select-Object -ExpandProperty Path
$TargetModulePath = Get-ChildItem "$ProjectRoot\BuildOutput\$($ModuleName)" | Sort-Object { [Version]$_.Name } | Select-Object -Last 1 -ExpandProperty FullName

Describe 'Module Manifest Tests' {
    $testCases = "$SourceModulePath\$($ModuleName).psd1","$TargetModulePath\$($ModuleName).psd1" | ForEach-Object {
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

Describe "Module tests: $ModuleName" {
    Context "Confirm source module files are valid Powershell syntax" {
        $testCase = Get-ChildItem $SourceModulePath -Include *.ps1,*.psm1,*.psd1 -Recurse | Foreach-Object { @{file = $_ } }

        It "Script <file> should be valid Powershell" -TestCases $testCase {
            param($file)

            $file.fullname | Should Exist

            $contents = Get-Content -Path $file.fullname -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }
    Context "Confirm compiled module files are valid Powershell syntax" {
        $testCase = Get-ChildItem $TargetModulePath -Include *.ps1,*.psm1,*.psd1 -Recurse | Foreach-Object { @{file = $_ } }

        It "Script <file> should be valid Powershell" -TestCases $testCase {
            param($file)

            $file.fullname | Should Exist

            $contents = Get-Content -Path $file.fullname -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }
    }
    Context "Confirm private functions are not exported on module import" {
        Import-Module "$TargetModulePath\$($ModuleName).psd1" -Force
        $testCase = Get-ChildItem "$SourceModulePath\Private" -Recurse -Include *.ps1 | Foreach-Object { @{item = $_.BaseName } }
        It "Should throw when checking for '<item>' in the module commands" -TestCases $testCase {
            param($item)
            { Get-Command -Name $item -Module $ModuleName -ErrorAction Stop } | Should -Throw
        }
    }
    Context "Confirm all aliases are created" {
        $aliasHash = . "$SourceModulePath\$($ModuleName).Aliases.ps1"

        $testCase = $aliasHash.Keys | ForEach-Object { @{Name = $_;Value = $aliasHash[$_] } }

        It "Alias <Name> should exist for command <Value>" -TestCases $testCase {
            param($Name,$Value)

            { Get-Alias $Name -ErrorAction Stop } | Should -Not -Throw
            (Get-Alias $Name).ReferencedCommand.Name | Should -Be $Value
        }
    }
    Context "Confirm there are no duplicate function names in private and public folders" {
        It 'Should have no duplicate functions' {
            $functions = @('Public','Private') | ForEach-Object {
                $path = "$SourceModulePath\$_"
                if (Test-Path $path) {
                    Get-ChildItem $path -Recurse -Include *.ps1 | Select-Object -ExpandProperty BaseName
                }
            }
            ($functions | Group-Object | Where-Object { $_.Count -gt 1 }).Count | Should -BeExactly 0
        }
    }
}
