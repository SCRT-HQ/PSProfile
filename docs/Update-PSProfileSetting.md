# Update-PSProfileSetting

## SYNOPSIS
Update a PSProfile property's value by tab-completing the available keys.

## SYNTAX

```
Update-PSProfileSetting [-Path] <String> [-Value] <Object> [-Add] [-Save] [<CommonParameters>]
```

## DESCRIPTION
Update a PSProfile property's value by tab-completing the available keys.

## EXAMPLES

### EXAMPLE 1
```
Update-PSProfileSetting -Path Settings.PSVersionStringLength -Value 3 -Save
```

Updates the PSVersionStringLength setting to 3 and saves the configuration.

### EXAMPLE 2
```
Update-PSProfileSetting -Path ScriptPaths -Value ~\ProfileLoad.ps1 -Add -Save
```

*Adds* the 'ProfileLoad.ps1' script to the $PSProfile.ScriptPaths array of scripts to invoke during profile load, then saves the configuration.

## PARAMETERS

### -Path
The property path you would like to update, e.g.
Settings.PSVersionStringLength

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Value
The value you would like to update for the specified setting path.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Add
If $true, adds the value to the specified PSProfile setting value array instead of overwriting the current value.

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
