# Remove-PSProfileSecret

## SYNOPSIS
Removes a Secret from $PSProfile.Vault.

## SYNTAX

```
Remove-PSProfileSecret [-Name] <String> [-Save] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes a Secret from $PSProfile.Vault.

## EXAMPLES

### EXAMPLE 1
```
Remove-PSProfileSecret -Name $env:USERNAME -Save
```

Removes the current user's stored credentials from the $PSProfile.Vault, then saves the configuration after updating.

## PARAMETERS

### -Name
The Secret's Name or UserName to remove from the Vault.

```yaml
Type: String
Parameter Sets: (All)
Aliases: UserName

Required: True
Position: 1
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
