# Remove-PSProfilePathAlias

## SYNOPSIS
Removes an alias from $PSProfile.PathAliases.

## SYNTAX

```
Remove-PSProfilePathAlias [-Alias] <String> [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes an alias from $PSProfile.PathAliases.

## EXAMPLES

### EXAMPLE 1
```
Remove-PSProfilePathAlias -Alias Workplace -Save
```

Removes the alias 'Workplace' from $PSProfile.PathAliases then saves the updated configuration.

## PARAMETERS

### -Alias
The alias to remove from $PSProfile.PathAliases.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
