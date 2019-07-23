# PSProfile

_PSProfile is a cross-platform PowerShell module built for profile customization. It uses PoshCode's Configuration module to handle the layered Configuration._

## Building from source

```powershell
# 1: Clone the repo
git clone https://github.com/scrthq/PSProfile.git
cd PSProfile

# 2: Install dependencies
'PoshRSJob','Configuration' | ForEach-Object {
    if ($null -eq (Get-Module $_ -ListAvailable)) {
        Install-Module $_ -Scope CurrentUser -Repository PSGallery -SkipPublisherCheck -AllowClobber
    }
}

# 3: Build the module and import once done
. .\build.ps1
Import-Module .\BuildOutput\PSProfile
```

_**More docs coming soon!**_
