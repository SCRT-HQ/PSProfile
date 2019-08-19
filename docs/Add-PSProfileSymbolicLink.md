# Add-PSProfileSymbolicLink

## SYNOPSIS
Adds a SymbolicLink to set if missing during profile load via background task.

## SYNTAX

```
Add-PSProfileSymbolicLink [-LinkPath] <String> [-ActualPath] <String> [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a SymbolicLink to set if missing during profile load via background task.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfileSymbolicLink -LinkPath C:\workstation -ActualPath E:\Git\workstation -Save
```

Adds a symbolic link at path 'C:\workstation' targeting the actual path 'E:\Git\workstation' and saves your PSProfile configuration.

## PARAMETERS

### -LinkPath
The path of the symbolic link to create if missing.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path, Name

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ActualPath
The actual target path of the symbolic link to set.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Target, Value

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
