function Save-PSPrompt {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Name
    )
    Process {
        $global:PSProfile.Prompts[$Name] = $function:prompt.ToString()
        $global:PSProfile.Save()
    }
}