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

function Add-PSProfileGitAlias {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Alias,
        [Parameter(Mandatory,Position = 1)]
        [String]
        $Value,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        $plugin = $Global:PSProfile.Plugins | Where-Object {$_.Name -eq 'PSProfile.GitAliases'}
        Write-Verbose "Adding GitAlias '$Alias' with value '$Value' to ArgumentList for PSProfile.GitAliases"
        if (-not $plugin.ContainsKey('ArgumentList')) {
            $plugin['ArgumentList'] = @{
                $Alias = $Value
            }
        }
        else {
            $plugin['ArgumentList'][$Alias] = $Value
        }
        Add-PSProfilePlugin -Name 'PSProfile.GitAliases' -ArgumentList $plugin['ArgumentList'] -Save:$Save
    }
}

function Remove-PSProfileGitAlias {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = "Medium")]
    Param (
        [Parameter(Mandatory,Position = 0)]
        [String]
        $Alias,
        [Parameter()]
        [Switch]
        $Save
    )
    Process {
        $plugin = $Global:PSProfile.Plugins | Where-Object {$_.Name -eq 'PSProfile.GitAliases'}
        if (-not $plugin.ContainsKey('ArgumentList')) {
            Write-Verbose "There are no GitAliases currently on your PSProfile, unable to remove alias '$Alias'"
        }
        elseif ($plugin['ArgumentList'].ContainsKey($Alias)) {
            if ($PSCmdlet.ShouldProcess("Removing Git alias '$Alias'")) {
                Write-Verbose "Removing Git alias '$Alias' from the ArgumentList for PSProfile.GitAliases"
                $plugin['ArgumentList'].Remove($Alias)
                Add-PSProfilePlugin -Name 'PSProfile.GitAliases' -ArgumentList $plugin['ArgumentList'] -Save:$Save
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-PSProfileGitAlias -ParameterName Alias -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    if ($argList = ($Global:PSProfile.Plugins | Where-Object {$_.Name -eq 'PSProfile.GitAliases'})['ArgumentList']){
        $argList.Keys | Where-Object {$_ -like "$wordToComplete*"} | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# Make sure to invoke the function if the module was imported with arguments passed.
# This ensures that the function is ran during profile load.
# If you don't need to run this during profile load, then exclude the function invocation!
if ($AliasHash) {
    Update-GitAliases $AliasHash
}
