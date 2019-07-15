@{
    _internal        = @{
        GitPathMap       = @{ }
        ProfileLoadStart = Get-Date
        Vault            = @{
            Secrets     = @{ }
            Credentials = @{ }
        }
    }
    GistsToInvoke    = @()
    ModulesToImport  = @()
    ModulesToInstall = @()
    PathAliases      = @(
        @{
            Alias = '~'
            Path  = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
        }
    )
    ProjectPaths     = @(
        '~\WorkGit'
        '~\ScrtGit'
        'E:\Git'
    )
    Settings         = @{
        DefaultPrompt          = 'Default'
        ProjectPathSearchDepth = 4
        PSVersionStringLength  = 3
    }
    SymbolicLinks    = @{
        'C:\workstation' = 'E:\Git\workstation'
    }
    Variables        = @{
        Environment = @{
            Home     = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
            UserName = [System.Environment]::UserName
        }
        Global      = @{
            PathAliasDirectorySeparator    = [System.IO.Path]::DirectorySeparatorChar
            AltPathAliasDirectorySeparator = [char]0xe0b1
        }
    }
}
