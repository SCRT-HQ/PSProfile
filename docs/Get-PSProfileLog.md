# Get-PSProfileLog

## SYNOPSIS
Gets the PSProfile Log events.

## SYNTAX

### Full (Default)
```
Get-PSProfileLog [[-Section] <String[]>] [[-LogLevel] <PSProfileLogLevel[]>] [-Raw] [<CommonParameters>]
```

### Summary
```
Get-PSProfileLog [-Summary] [<CommonParameters>]
```

## DESCRIPTION
Gets the PSProfile Log events.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileLog
```

Gets the current Log in full.

### EXAMPLE 2
```
Get-PSProfileLog -Summary
```

Gets the Log summary.

### EXAMPLE 3
```
Get-PSProfileLog -Section InvokeScripts,LoadPlugins -Raw
```

Gets the Log Events for only sections 'InvokeScripts' and 'LoadPlugins' and returns the raw Event objects.

## PARAMETERS

### -Section
Limit results to only a specific section.

```yaml
Type: String[]
Parameter Sets: Full
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogLevel
Limit results to only a specific LogLevel.

```yaml
Type: PSProfileLogLevel[]
Parameter Sets: Full
Aliases:
Accepted values: Information, Warning, Error, Debug, Verbose, Quiet

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Summary
Get a high-level summary of the PSProfile Log.

```yaml
Type: SwitchParameter
Parameter Sets: Summary
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Raw
Return the raw PSProfile Events.
Returns the results via Format-Table for readability otherwise.

```yaml
Type: SwitchParameter
Parameter Sets: Full
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
