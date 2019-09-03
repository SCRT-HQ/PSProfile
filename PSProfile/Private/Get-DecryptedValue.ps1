function Get-DecryptedValue {
    param($Item)
    if ($Item -is [System.Security.SecureString]) {
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(
                $Item
            )
        )
    }
    else {
        $Item
    }
}
