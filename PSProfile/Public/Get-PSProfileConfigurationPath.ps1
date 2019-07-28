function Get-PSProfileConfigurationPath {
    [CmdletBinding()]
    Param()
    Process {
        (Join-Path (Get-ConfigurationPath -CompanyName 'SCRT HQ' -Name PSProfile) 'Configuration.psd1')
    }
}
