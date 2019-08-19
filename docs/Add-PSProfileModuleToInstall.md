# Add-PSProfileModuleToInstall

## SYNOPSIS
Adds a module to ensure is installed in the CurrentUser scope.
Module installations are handled via background job during PSProfile import.

## SYNTAX

```
Add-PSProfileModuleToInstall [-Name] <String> [-Repository <String>] [-MinimumVersion <String>]
 [-RequiredVersion <String>] [-AcceptLicense] [-AllowPrerelease] [-Force] [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a module to ensure is installed in the CurrentUser scope.
Module installations are handled via background job during PSProfile import.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfileModuleToInstall -Name posh-git -RequiredVersion '0.7.3' -Save
```

Specifies to install posh-git version 0.7.3 during PSProfile import if missing then saves the updated configuration.

## PARAMETERS

### -Name
The name of the module to install.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Repository
The repository to install the module from.
Defaults to the PowerShell Gallery.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinimumVersion
The minimum version of the module to install.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequiredVersion
The required version of the module to install.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AcceptLicense
If $true, accepts the license for the module if necessary.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AllowPrerelease
If $true, allows installation of prerelease versions of the module.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
If the module already exists in $PSProfile.ModulesToInstall, use -Force to overwrite the existing value.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Save
If $true, saves the updated PSProfile after updating.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
