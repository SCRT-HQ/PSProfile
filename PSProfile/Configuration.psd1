@{
    Settings         = @{}
    ModulesToImport  = @()
    ModulesToInstall = @()
    PathAliases      = @{}
    Plugins = @(
        @{
            Name = 'PSProfile.GitAliases'
            Arguments = @{
                a = "!git add . && git status"
                aa = "!git add . && git add -u . && git status"
                ac = "!git add . && git commit"
                acm = "!git add . && git commit -m"
                alias = "!git config --get-regexp '^alias\.' | sort"
                amend = "!git add -A && git commit --amend --no-edit"
                au = "!git add -u . && git status"
                b = "branch"
                ba = "branch --all"
                c = "commit"
                ca = "commit --amend # careful"
                cam = "commit -am"
                cm = "commit -m"
                co = "checkout"
                con = "!git --no-pager config --list"
                conl = "!git --no-pager config --local --list"
                conls = "!git --no-pager config --local --list --show-origin"
                cons = "!git --no-pager config --list --show-origin"
                current = "!git branch | grep \* | cut -d ' ' -f2"
                d = "!git --no-pager diff"
                dev = "checkout dev"
                f = "fetch --all"
                fp = "fetch --all --prune"
                l = "log --graph --all --pretty=format:'%C(yellow)%h%C(cyan)%d%Creset %s %C(white)- %an, %ar%Creset'"
                lg = "log --color --graph --pretty=format:'%C(bold white)%h%Creset -%C(bold green)%d%Creset %s %C(bold green)(%cr)%Creset %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"
                ll = "log --stat --abbrev-commit"
                llg = "log --color --graph --pretty=format:'%C(bold white)%H %d%Creset%n%s%n%+b%C(bold blue)%an <%ae>%Creset %C(bold green)%cr (%ci)' --abbrev-commit"
                master = "checkout master"
                n = "checkout -b"
                p = "!git push"
                pf = "!git push -f"
                pu = "!git push -u origin ```$(git branch | grep \* | cut -d ' ' -f2)"
                s = "status"
                ss = "status -s"
                stg = "checkout stg"
            }
        }
    )
    PluginPaths      = @()
    ProjectPaths     = @()
    SymbolicLinks    = @{}
    Variables        = @{}
}
