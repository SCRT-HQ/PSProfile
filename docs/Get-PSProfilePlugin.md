# Get-PSProfilePlugin

## SYNOPSIS
Gets a Plugin from $PSProfile.Plugins.

## SYNTAX

```
Get-PSProfilePlugin [[-Name] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets a Plugin from $PSProfile.Plugins.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfilePlugin -Name PSProfile.Prompt
```

Gets PSProfile.Prompt from $PSProfile.Plugins

### EXAMPLE 2
```
Get-PSProfilePlugin
```

Gets the list of Plugins from $PSProfile.Plugins

## PARAMETERS

### -Name
The name of the Plugin to get from $PSProfile.Plugins.

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
