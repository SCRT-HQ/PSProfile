function Set-PSProfileSetting {
    [CmdletBinding(DefaultParameterSetName = "KeyValue")]
    Param(
        [Parameter(Mandatory,Position = 0,ParameterSetName = "KeyValue")]
        [String]
        $Key,
        [Parameter(Mandatory,Position = 1,ParameterSetName = "KeyValue")]
        [String]
        $Value,
        [Parameter(Mandatory,ParameterSetName = "Hashtable")]
        [Hashtable]
        $Hashtable
    )
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            KeyValue {
                Write-Verbose "Updating PSProfile Setting '$Key' to '$Value'"
                $Global:PSProfile.Settings[$Key] = $Value
            }
            Hashtable {
                $Hashtable.GetEnumerator() | ForEach-Object {
                    Write-Verbose "Updating PSProfile Setting '$($_.Key)' to '$($_.Value)'"
                    $Global:PSProfile.Settings[$_.Key] = $_.Value
                }
            }
        }
    }
}
