# Get-PSProfileImportedCommand

## SYNOPSIS
Gets the list of commands imported from scripts and plugins that are not part of PSProfile itself.

## SYNTAX

```
Get-PSProfileImportedCommand [[-Command] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets the list of commands imported from scripts and plugins that are not part of PSProfile itself.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileImportedCommand
```

Gets the full list of commands imported during PSProfile load.

## PARAMETERS

### -Command
The command to get from the list of imported commands.

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

### System.Management.Automation.FunctionInfo
## NOTES

## RELATED LINKS
