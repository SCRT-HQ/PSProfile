function Test-IfGit {
    <#
    .SYNOPSIS
    Tests if the current path is in a Git repo folder and returns the basic details as an object if so. Useful in prompts when determining current folder's Git status

    .DESCRIPTION
    Tests if the current path is in a Git repo folder and returns the basic details as an object if so. Useful in prompts when determining current folder's Git status

    .EXAMPLE
    Test-IfGit
    #>
    [CmdletBinding()]
    Param ()
    Process {
        try {
            $topLevel = git rev-parse --show-toplevel *>&1
            if ($topLevel -like 'fatal: *') {
                $Global:Error.Remove($Global:Error[0])
                $false
            }
            else {
                $origin = git remote get-url origin
                $repo = Split-Path -Leaf $origin
                [PSCustomObject]@{
                    TopLevel = (Resolve-Path $topLevel).Path
                    Origin   = $origin
                    Repo     = $(if ($repo -notmatch '(\.git|\.ssh|\.tfs)$') {
                            $repo
                        }
                        else {
                            $repo.Substring(0,($repo.LastIndexOf('.')))
                        })
                }
            }
        }
        catch {
            $false
            $Global:Error.Remove($Global:Error[0])
        }
    }
}
