function Add-PSProfileToProfile {
    <#
    .SYNOPSIS
    Adds `Import-Module PSProfile` to the desired PowerShell profile file if not already present.

    .DESCRIPTION
    Adds `Import-Module PSProfile` to the desired PowerShell profile file if not already present.

    .PARAMETER Scope
    The profile scope to add the module import to. Defaults to CurrentUserCurrentHost (same as bare $profile).

    .PARAMETER DisableLoadTimeMessage
    If $true, adds `-ArgumentList $false` to the Import-Module call to hide the Module Load Time message.

    .EXAMPLE
    Add-PSProfileToProfile -Scope CurrentUserAllHosts

    Adds `Import-Module PSProfile` to the $profile.CurrentUserAllHosts file. Creates the parent folder if missing.
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position = 0)]
        [ValidateSet('AllUsersAllHosts','AllUsersCurrentHost','CurrentUserAllHosts','CurrentUserCurrentHost')]
        [String]
        $Scope = 'CurrentUserCurrentHost',
        [Parameter()]
        [Switch]
        $DisableLoadTimeMessage
    )
    Process {
        $exists = $false
        foreach ($s in @('AllUsersAllHosts','AllUsersCurrentHost','CurrentUserAllHosts','CurrentUserCurrentHost')) {
            $sPath = $profile | Select-Object -ExpandProperty $s
            if ((Test-Path $sPath) -and (Select-String -Path $sPath -Pattern ([Regex]::Escape('Import-Module PSProfile')))) {
                Write-Warning "'Import-Module PSProfile' already exists @ profile scope '$s' ($sPath)! Skipping addition @ scope '$Scope' to prevent duplicate module imports."
                $exists = $true
            }
        }
        if (-not $exists) {
            $profilePath = $profile | Select-Object -ExpandProperty $Scope
            $profileFolder = Split-Path $profilePath
            if (-not (Test-Path $profileFolder)) {
                Write-Verbose "Creating parent folder: $profileFolder"
                New-Item $profileFolder -ItemType Directory -Force
            }
            if (-not (Test-Path $profilePath)) {
                Write-Verbose "Creating profile file: $profilePath"
                New-Item $profilePath -ItemType File -Force
            }
            $string = 'Import-Module PSProfile'
            if ($DisableLoadTimeMessage) {
                $string += ' -ArgumentList $false'
            }
            Write-Verbose "Adding line to profile @ scope '$Scope': $string"
            Add-Content -Path $profilePath -Value $string
        }
    }
}
