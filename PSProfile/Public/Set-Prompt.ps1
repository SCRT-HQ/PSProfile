function Set-Prompt {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    Param(
        [Parameter(Mandatory,Position = 0,ParameterSetName = 'Name')]
        [String]
        $Name,
        [Parameter(Mandatory,ParameterSetName = 'ScriptBlock')]
        [ScriptBlock]
        $ScriptBlock
    )
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            Name {
                $function:prompt = $global:PSProfile.Prompts[$Name]
            }
            ScriptBlock {
                $function:prompt = $ScriptBlock
            }
        }
    }
}