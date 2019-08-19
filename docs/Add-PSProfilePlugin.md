# Add-PSProfilePlugin

## SYNOPSIS
Adds a PSProfile Plugin to the list of plugins.
If the plugin already exists, it will overwrite it.
Re-imports your PSProfile once done to load any newly added plugins.

## SYNTAX

```
Add-PSProfilePlugin [-Name] <String[]> [[-ArgumentList] <Object>] [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a PSProfile Plugin to the list of plugins.
If the plugin already exists, it will overwrite it.
Re-imports your PSProfile once done to load any newly added plugins.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfilePlugin -Name 'PSProfile.PowerTools' -Save
```

Adds the included plugin 'PSProfile.PowerTools' to your PSProfile and saves it so it persists.

## PARAMETERS

### -Name
The name of the Plugin to add, e.g.
'PSProfile.PowerTools'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ArgumentList
Any arguments that need to be passed to the plugin on import, such as a hashtable to process.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
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
