# Remove-PSProfileSymbolicLink

## SYNOPSIS
Removes a Symbolic Link from $PSProfile.SymbolicLinks.

## SYNTAX

```
Remove-PSProfileSymbolicLink [-LinkPath] <String> [-Force] [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes a PSProfile Plugin from $PSProfile.SymbolicLinks.

## EXAMPLES

### EXAMPLE 1
```
Remove-PSProfileSymbolicLink -LinkPath 'C:\workstation' -Force -Save
```

Removes the SymbolicLink 'C:\workstation' from $PSProfile.SymbolicLinks, removes the  then saves the updated configuration.

## PARAMETERS

### -LinkPath
The path of the symbolic link to remove from $PSProfile.SymbolicLinks.

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

### -Force
If $true, also removes the SymbolicLink itself from the OS if it exists.

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
