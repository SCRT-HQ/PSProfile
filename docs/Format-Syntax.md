# Format-Syntax

## SYNOPSIS
Formats a command's syntax in an easy-to-read view.

## SYNTAX

```
Format-Syntax [[-Command] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Formats a command's syntax in an easy-to-read view.

## EXAMPLES

### EXAMPLE 1
```
Format-Syntax Get-Process
```

Gets the formatted syntax by parameter set for Get-Process

### EXAMPLE 2
```
syntax Get-Process
```

Same as Example 1, but uses the alias 'syntax' instead.

## PARAMETERS

### -Command
The command to get the syntax of.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
