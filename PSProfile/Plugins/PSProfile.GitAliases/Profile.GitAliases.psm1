[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [hashtable]
    $Options
)
# Async function by use of runspace jobs.
# Async is perfect for this since we don't need the result of this function to be something available in the session it's invoked from.
function Update-GitAliases {
    Param (
        [Parameter(Mandatory,Position = 0)]
        [hashtable]
        $Options
    )
    $null = $Options.GetEnumerator() | Start-RSJob -Name "_PSProfile_GitAliases_$($_.Key)" {
        Write-Verbose "Updating git alias '$($_.Key)' with value '$($_.Value)'"
        Invoke-Expression $("git config --global alias.{0} `"{1}`"" -f $_.Key,$_.Value)
    }
}
Export-ModuleMember -Function 'Update-GitAliases'

# Make sure to invoke the function if the module was imported with arguments passed.
# This ensures that the function is ran during profile load.
# If you don't need to run this during profile load, then exclude the function invocation!
if ($Options) {
    Update-GitAliases $Options
}
