# Add-PSProfilePathAlias

## SYNOPSIS
Adds a path alias to your PSProfile configuration.
Path aliases are used for path shortening in prompts via Get-PathAlias.

## SYNTAX

```
Add-PSProfilePathAlias [-Alias] <String> [-Path] <String> [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a path alias to your PSProfile configuration.
Path aliases are used for path shortening in prompts via Get-PathAlias.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfilePathAlias -Alias ~ -Path $env:USERPROFILE -Save
```

Adds a path alias of ~ for the current UserProfile folder and saves your PSProfile configuration.

## PARAMETERS

### -Alias
The alias to substitute the full path for in prompts via Get-PathAlias.

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

### -Path
The full path to be substituted.

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
