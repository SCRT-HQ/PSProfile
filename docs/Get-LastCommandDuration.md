# Get-LastCommandDuration

## SYNOPSIS
Gets the elapsed time of the last command via Get-History.
Intended to be used in prompts.

## SYNTAX

```
Get-LastCommandDuration [[-Id] <Int32>] [[-Format] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets the elapsed time of the last command via Get-History.
Intended to be used in prompts.

## EXAMPLES

### EXAMPLE 1
```
Get-LastCommandDuration
```

## PARAMETERS

### -Id
The Id of the command to get from the history.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Format
The format string for the resulting timestamp.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: {0:h\:mm\:ss\.ffff}
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
