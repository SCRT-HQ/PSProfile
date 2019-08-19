# Add-PSProfileCommandAlias

## SYNOPSIS
Adds a command alias to your PSProfile configuration to set during PSProfile import.

## SYNTAX

```
Add-PSProfileCommandAlias [-Alias] <String> [-Command] <String> [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a command alias to your PSProfile configuration to set during PSProfile import.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfileCommandAlias -Alias code -Command Open-Code -Save
```

Adds the command alias 'code' targeting the command 'Open-Code' and saves your PSProfile configuration.

## PARAMETERS

### -Alias
The alias to set for the command.

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

### -Command
The name of the command to set the alias for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
