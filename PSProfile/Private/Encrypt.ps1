function Encrypt {
    param($Item)
    if ($Item -is [System.Security.SecureString]) {
        $Item
    }
    elseif ($Item -is [System.String] -and -not [System.String]::IsNullOrWhiteSpace($Item)) {
        ConvertTo-SecureString -String $Item -AsPlainText -Force
    }
}
