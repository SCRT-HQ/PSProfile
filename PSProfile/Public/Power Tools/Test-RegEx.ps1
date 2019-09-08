function Test-RegEx {
    <#
    .SYNOPSIS
    Tests a RegEx pattern against a string and returns the results.

    .DESCRIPTION
    Tests a RegEx pattern against a string and returns the results.

    .PARAMETER Pattern
    The RegEx pattern to test against the string.

    .PARAMETER String
    The string to test.

    .EXAMPLE
    Test-RegEx -Pattern '^\w+' -String 'no spaces','  spaces in front'

    Matched Pattern Matches String
    ------- ------- ------- ------
       True ^\w+    {no}    no spaces
      False ^\w+              spaces in front
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory,Position = 0)]
        [RegEx]
        $Pattern,
        [parameter(Mandatory,Position = 1,ValueFromPipeline)]
        [String[]]
        $String
    )
    Process {
        foreach ($S in $String) {
            Write-Verbose "Testing RegEx pattern '$Pattern' against string '$S'"
            $Matches = $null
            [PSCustomObject][Ordered]@{
                Matched = $($S -match $Pattern)
                Pattern = $Pattern
                Matches = $Matches.Values
                String  = $S
            }
        }
    }
}
