$ModuleName = 'PSProfile'
$ProjectRoot = Resolve-Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path
$SourceModulePath = Resolve-Path "$ProjectRoot\$ModuleName" | Select-Object -ExpandProperty Path
$TargetModulePath = Get-ChildItem "$ProjectRoot\BuildOutput\$($ModuleName)" | Sort-Object { [Version]$_.Name } | Select-Object -Last 1 -ExpandProperty FullName

Describe "Function contents" -Tag 'Module' {
    $scripts = Get-ChildItem "$SourceModulePath\Public" -Include *.ps1 -Recurse | Where-Object {$_.FullName -notlike "*Helpers*"}
    $addFunctions = $scripts | Where-Object {$_.BaseName -match '^Add'}
    $removeFunctions = $scripts | Where-Object {$_.BaseName -match '^Remove'}
    Context "All non-helper public functions should use Write-Verbose" {
        $testCase = $scripts | Foreach-Object {@{file = $_;Name = $_.BaseName}}
        It "Function <Name> should contain verbose output" -TestCases $testCase {
            param($file,$Name)
            $file.fullname | Should -FileContentMatch 'Write-Verbose'
        }
    }
    Context "All 'Add' functions should have a corresponding 'Remove' function" {
        $testCase = $addFunctions | Foreach-Object {@{file = $_;Name = $_.BaseName;RemName = ($_.BaseName -replace '^Add','Remove')}}
        It "Function <Name> should be paired with <RemName>" -TestCases $testCase {
            param($file,$Name,$RemName)
            $removeFunctions.BaseName | Should -Contain $RemName
        }
    }
    Context "All 'Remove' functions should SupportsShouldProcess" {
        $testCase = $removeFunctions | Foreach-Object {@{file = $_;Name = $_.BaseName}}
        It "Function <Name> should contain SupportsShouldProcess" -TestCases $testCase {
            param($file,$Name)
            $file.fullname | Should -FileContentMatch 'SupportsShouldProcess'
        }
    }
    Context "All 'Remove' functions should contain 'PSCmdlet.ShouldProcess'" {
        $testCase = $removeFunctions | Foreach-Object {@{file = $_;Name = $_.BaseName}}
        It "Function <Name> should contain PSCmdlet.ShouldProcess" -TestCases $testCase {
            param($file,$Name)
            $file.fullname | Should -FileContentMatch '\$PSCmdlet.ShouldProcess'
        }
    }
    Context "All 'Remove' functions should contain valid ArgumentCompleters" {
        $testCase = $removeFunctions | Foreach-Object {@{file = $_;Name = $_.BaseName}}
        It "Function <Name> should contain valid ArgumentCompleters" -TestCases $testCase {
            param($file,$Name)
            $file.fullname | Should -FileContentMatch ([regex]::Escape("Register-ArgumentCompleter -CommandName $Name -ParameterName"))
        }
    }
}
