function Import-PSProfileConfiguration {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [String]
        $Path,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        $Path = (Resolve-Path $Path).Path
        Write-Verbose "Loading PSProfile configuration from path: $Path"
        $Global:PSProfile._loadAdditionalConfiguration($Path)
        if ($Save) {
            Save-PSProfile
        }
    }
}
