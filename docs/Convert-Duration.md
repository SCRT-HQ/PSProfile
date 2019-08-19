# Convert-Duration

## SYNOPSIS
Converts a TimeSpan or ISO8601 duration string to the desired output type.

## SYNTAX

```
Convert-Duration [-Duration] <Object> [[-Output] <String>] [<CommonParameters>]
```

## DESCRIPTION
Converts a TimeSpan or ISO8601 duration string to the desired output type.

More info on ISO8601 duration strings: https://en.wikipedia.org/wiki/ISO_8601#Durations

## EXAMPLES

### EXAMPLE 1
```
Convert-Duration 'PT1H32M15S'
```

Days              : 0
Hours             : 1
Minutes           : 32
Seconds           : 15
Milliseconds      : 0
Ticks             : 55350000000
TotalDays         : 0.0640625
TotalHours        : 1.5375
TotalMinutes      : 92.25
TotalSeconds      : 5535
TotalMilliseconds : 5535000

### EXAMPLE 2
```
Start-Sleep -Seconds (Convert-Duration 'PT5M35S' -Output TotalSeconds)
```

# Sleeps for 5 minutes and 35 seconds

### EXAMPLE 3
```
$date = Get-Date
```

$duration = $date.AddMinutes(37) - $date
Convert-Duration $duration -Output ISO8601

PT37M

## PARAMETERS

### -Duration
The TimeSpan object or ISO8601 string to convert.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Output
The desired Output type.

Defaults to TimeSpan.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: TimeSpan
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
