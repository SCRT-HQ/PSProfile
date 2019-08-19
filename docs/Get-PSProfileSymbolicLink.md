# Get-PSProfileSymbolicLink

## SYNOPSIS
Gets a module from $PSProfile.SymbolicLinks.

## SYNTAX

```
Get-PSProfileSymbolicLink [[-LinkPath] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets a module from $PSProfile.SymbolicLinks.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileSymbolicLink -LinkPath C:\workstation
```

Gets the LinkPath 'C:\workstation' from $PSProfile.SymbolicLinks

### EXAMPLE 2
```
Get-PSProfileSymbolicLink
```

Gets the list of LinkPaths from $PSProfile.SymbolicLinks

## PARAMETERS

### -LinkPath
The LinkPath to get from $PSProfile.SymbolicLinks.

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
