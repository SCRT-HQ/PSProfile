# Write-PSProfileLog

## SYNOPSIS
Adds a log entry to the current PSProfile Log.

## SYNTAX

```
Write-PSProfileLog [-Message] <String> [-Section] <String> [[-LogLevel] <PSProfileLogLevel>]
 [<CommonParameters>]
```

## DESCRIPTION
Adds a log entry to the current PSProfile Log.
Used for external plugins to hook into the existing log so items like Plugin load logging are contained in one place.

## EXAMPLES

### EXAMPLE 1
```
Write-PSProfileLog -Message "Hunting for missing KBs" -Section 'KBUpdate' -LogLevel 'Verbose'
```

## PARAMETERS

### -Message
The message to log.

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

### -Section
The name of the section you are logging for, e.g.
the name of the plugin or overall what action is being done.

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

### -LogLevel
The Level of the Log event.
Defaults to Debug.

```yaml
Type: PSProfileLogLevel
Parameter Sets: (All)
Aliases:
Accepted values: Information, Warning, Error, Debug, Verbose, Quiet

Required: False
Position: 3
Default value: Debug
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
