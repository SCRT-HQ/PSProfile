function Show-Menu {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0,Mandatory = $True,HelpMessage = "Enter your menu text")]
        [ValidateNotNullOrEmpty()]
        [string]$Menu,
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Title = "My Menu",
        [Alias("cls")]
        [switch]$ClearScreen
    )

    #clear the screen if requested
    if ($ClearScreen) {
        Clear-Host
    }

    #build the menu prompt
    $menuPrompt = $title
    #add a return
    $menuprompt += "`n"
    #add an underline
    $menuprompt += "-" * $title.Length
    #add another return
    $menuprompt += "`n"
    #add the menu
    $menuPrompt += $menu

    Read-Host -Prompt $menuprompt

}
