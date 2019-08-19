# Get-PSProfileCommandAlias

## SYNOPSIS
Gets an alias from $PSProfile.CommandAliases.

## SYNTAX

```
Get-PSProfileCommandAlias [[-Alias] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets an alias from $PSProfile.CommandAliases.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileCommandAlias -Alias code
```

Gets the alias 'code' from $PSProfile.CommandAliases.

### EXAMPLE 2
```
Get-PSProfileCommandAlias
```

Gets the list of command aliases from $PSProfile.CommandAliases.

## PARAMETERS

### -Alias
The alias to get from $PSProfile.CommandAliases.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
