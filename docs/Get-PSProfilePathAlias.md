# Get-PSProfilePathAlias

## SYNOPSIS
Gets a module from $PSProfile.PathAliases.

## SYNTAX

```
Get-PSProfilePathAlias [[-Alias] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets a module from $PSProfile.PathAliases.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfilePathAlias -Alias ~
```

Gets the alias '~' from $PSProfile.PathAliases

### EXAMPLE 2
```
Get-PSProfilePathAlias
```

Gets the list of path aliases from $PSProfile.PathAliases

## PARAMETERS

### -Alias
The Alias to get from $PSProfile.PathAliases.

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
