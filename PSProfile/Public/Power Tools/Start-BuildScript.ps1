function Start-BuildScript {
    <#
    .SYNOPSIS
    For those using the typical build.ps1 build scripts for PowerShell projects, this will allow invoking the build script quickly from wherever folder you are currently in using a child process.

    .DESCRIPTION
    For those using the typical build.ps1 build scripts for PowerShell projects, this will allow invoking the build script quickly from wherever folder you are currently in using a child process. Any projects in the ProjectPaths list that were discovered during PSProfile load and have a build.ps1 file will be able to be tab-completed for convenience. Temporarily sets the path to the build folder, invokes the build.ps1 file, then returns to the original path that it was invoked from.

    .PARAMETER Project
    The path of the project to build. Allows tab-completion of PSBuildPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

    You can also pass the path to a folder containing a build.ps1 script, or a full path to another script entirely.

    .PARAMETER Task
    The list of Tasks to specify to the Build script.

    .PARAMETER Engine
    The engine to open the clean environment with between powershell, pwsh, and pwsh-preview. Defaults to the current engine the clean environment is opened from.

    .PARAMETER NoExit
    If $true, does not exit the child process once build.ps1 has completed and imports the built module in BuildOutput (if present to allow testing of the built project in a clean environment.

    .EXAMPLE
    Start-BuildScript MyModule -NoExit

    Changes directories to the repo root of MyModule, invokes build.ps1, imports the compiled module in a clean child process and stops before exiting to allow testing of the newly compiled module.

    .EXAMPLE
    bld MyModule -ne

    Same experience as Example 1 but uses the shorter alias 'bld' to call. Also uses the parameter alias `-ne` instead of `-NoExit`
    #>
    [CmdletBinding(PositionalBinding = $false)]
    Param (
        [Parameter(Position = 0)]
        [Alias('p')]
        [String]
        $Project,
        [Parameter(Position = 1)]
        [Alias('t')]
        [String[]]
        $Task,
        [Parameter(Position = 2)]
        [ValidateSet('powershell','pwsh','pwsh-preview')]
        [Alias('e')]
        [String]
        $Engine = $(if ($PSVersionTable.PSVersion.ToString() -match 'preview') {
            'pwsh-preview'
        }
        elseif ($PSVersionTable.PSVersion.Major -ge 6) {
            'pwsh'
        }
        else {
            'powershell'
        }),
        [parameter()]
        [Alias('ne','noe')]
        [Switch]
        $NoExit
    )
    DynamicParam {
        $bldFolder = if ([String]::IsNullOrEmpty($PSBoundParameters['Project']) -or $PSBoundParameters['Project'] -eq '.') {
            $PWD.Path
        }
        elseif ($Global:PSProfile.PSBuildPathMap.ContainsKey($PSBoundParameters['Project'])) {
            Get-LongPath -Path $PSBoundParameters['Project']
        }
        else {
            (Resolve-Path $PSBoundParameters['Project']).Path
        }
        $bldFile = if ($bldFolder -like '*.ps1') {
            $bldFolder
        }
        else {
            Join-Path $bldFolder "build.ps1"
        }
        Copy-Parameters -From $bldFile -Exclude Project,Task,Engine,NoExit
    }
    Process {
        if (-not $PSBoundParameters.ContainsKey('Project')) {
            $PSBoundParameters['Project'] = '.'
        }
        $parent = switch ($PSBoundParameters['Project']) {
            '.' {
                $PWD.Path
            }
            default {
                $global:PSProfile.PSBuildPathMap[$PSBoundParameters['Project']]
            }
        }
        $command = "$Engine -NoProfile -C `""
        $command += "Set-Location '$parent'; . .\build.ps1"
        $PSBoundParameters.Keys | Where-Object {$_ -notin @('Project','Engine','NoExit','Debug','ErrorAction','ErrorVariable','InformationAction','InformationVariable','OutBuffer','OutVariable','PipelineVariable','WarningAction','WarningVariable','Verbose','Confirm','WhatIf')} | ForEach-Object {
            if ($PSBoundParameters[$_].ToString() -in @('True','False')) {
                $command += " -$($_):```$$($PSBoundParameters[$_].ToString())"
            }
            else {
                $command += " -$($_) '$($PSBoundParameters[$_] -join "','")'"
            }
        }
        $command += '"'
        Write-Verbose "Invoking expression: $command"
        Invoke-Expression $command
        if ($NoExit) {
            Push-Location $parent
            Enter-CleanEnvironment -Engine $Engine -ImportModule
            Pop-Location
        }
    }
}

Register-ArgumentCompleter -CommandName Start-BuildScript -ParameterName Project -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    Get-PSProfileArguments -WordToComplete "PSBuildPathMap.$wordToComplete" -FinalKeyOnly
}

Register-ArgumentCompleter -CommandName Start-BuildScript -ParameterName Task -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $bldFolder = if ([String]::IsNullOrEmpty($fakeBoundParameter.Project) -or $fakeBoundParameter.Project -eq '.') {
        $PWD.Path
    }
    elseif ($Global:PSProfile.PSBuildPathMap.ContainsKey($fakeBoundParameter.Project)) {
        Get-LongPath -Path $fakeBoundParameter.Project
    }
    else {
        (Resolve-Path $fakeBoundParameter.Project).Path
    }
    $bldFile = if ($bldFolder -like '*.ps1') {
        $bldFolder
    }
    else {
        Join-Path $bldFolder "build.ps1"
    }
    $set = if (Test-Path $bldFile) {
        ((([System.Management.Automation.Language.Parser]::ParseFile(
            $bldFile, [ref]$null, [ref]$null
        )).ParamBlock.Parameters | Where-Object { $_.Name.VariablePath.UserPath -eq 'Task' }).Attributes | Where-Object { $_.TypeName.Name -eq 'ValidateSet' }).PositionalArguments.Value
    }
    else {
        @('Clean','Build','Import','Test','Deploy')
    }
    $set | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
