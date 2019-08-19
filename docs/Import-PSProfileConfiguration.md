# Import-PSProfileConfiguration

## SYNOPSIS
Imports a Configuration.psd1 file from a specific path and overwrites differing values on the PSProfile, if any.

## SYNTAX

```
Import-PSProfileConfiguration [-Path] <String> [-Save] [<CommonParameters>]
```

## DESCRIPTION
Imports a Configuration.psd1 file from a specific path and overwrites differing values on the PSProfile, if any.

## EXAMPLES

### EXAMPLE 1
```
Import-PSProfileConfiguration -Path ~\MyProfile.psd1 -Save
```

## PARAMETERS

### -Path
The path to the PSD1 file you would like to import.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Save
If $true, saves the updated PSProfile after importing.

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
