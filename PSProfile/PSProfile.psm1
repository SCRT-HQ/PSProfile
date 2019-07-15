<# #Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$ModuleRoot = $PSScriptRoot
$ConfigScope = "User"

#Dot source the files
foreach ($file in @($Public + $Private)) {
    $ExecutionContext.InvokeCommand.InvokeScript(
        $false,
        (
            [scriptblock]::Create(
                [io.file]::ReadAllText(
                    $file.FullName,
                    [Text.Encoding]::UTF8
                )
            )
        ),
        $null,
        $null
    )
}
Get-MyConfig
if ($script:PSProfile) {
    Write-Host -ForegroundColor Black -BackgroundColor Green "Config imported successfully"
}
Export-ModuleMember -Function $Public.Basename #>
