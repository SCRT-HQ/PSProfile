function New-PSProfilePlugin {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,ValueFromPipeline,Position = 0)]
        [String[]]
        $Name,
        [Parameter(Position = 1)]
        [String]
        $Path = $PWD.Path,
        [Parameter()]
        [Switch]
        $Force
    )
    Process {
        foreach ($profileName in $Name) {
            try {
                $targetPath = Join-Path $Path $profileName
                if (Test-Path $targetPath) {
                    if (-not $Force) {
                        throw "Target path exists and Force was not specified! Target path: $targetPath"
                    }
                    else {
                        Remove-Item -Path $targetPath -Recurse -Force
                    }
                }
                New-Item $targetPath -ItemType Directory -Force
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
}
