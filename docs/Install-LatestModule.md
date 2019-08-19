# Install-LatestModule

## SYNOPSIS
A helper function to uninstall any existing versions of the target module before installing the latest one.

## SYNTAX

```
Install-LatestModule [-Name] <String[]> [-Repository <String>] [-ConfirmNotImported] [<CommonParameters>]
```

## DESCRIPTION
A helper function to uninstall any existing versions of the target module before installing the latest one.
Defaults to CurrentUser scope when installing the latest module version from the desired repository.

## EXAMPLES

### EXAMPLE 1
```
Install-LatestModule PSProfile
```

## PARAMETERS

### -Name
The name of the module to install the latest version of

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Repository
The PowerShell repository to install the latest module from.
Defaults to the PowerShell Gallery.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PSGallery
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfirmNotImported
If $true, safeguards module removal if the module you are trying to update is currently imported by throwing a terminating error.

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
