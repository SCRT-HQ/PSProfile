[CmdletBinding()]
Param (
    [Parameter(Position = 0)]
    [hashtable]
    $AliasHash
)
# Async function by use of runspace jobs.
# Async is perfect for this since we don't need the result of this function to be something available in the session it's invoked from.
function Update-GitAliases {
    Param (
        [Parameter(Mandatory,Position = 0)]
        [hashtable]
        $AliasHash
    )
    $null = $AliasHash.GetEnumerator() | Start-RSJob -Name {"_PSProfile_GitAliases_" + $_.Key} -ScriptBlock {
        Write-Output "Updating git alias '$($_.Key)' with value '$($_.Value)'"
        $i = 0
        $passed = $false
        do {
            $i++
            try {
                Invoke-Expression $("git config --global alias.{0} `"{1}`"" -f $_.Key,$_.Value)
                $passed = $true
            }
            catch {}
        }
        until ($i -ge 5 -or $passed)
    }
}
Export-ModuleMember -Function 'Update-GitAliases'

# Make sure to invoke the function if the module was imported with arguments passed.
# This ensures that the function is ran during profile load.
# If you don't need to run this during profile load, then exclude the function invocation!
if ($AliasHash) {
    Update-GitAliases $AliasHash
}
