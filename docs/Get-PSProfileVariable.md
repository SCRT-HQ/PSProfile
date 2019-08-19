# Get-PSProfileVariable

## SYNOPSIS
Gets a global or environment variable from your PSProfile configuration.

## SYNTAX

```
Get-PSProfileVariable [-Scope] <String> [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets a global or environment variable from your PSProfile configuration.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileVariable -Name HomeBase
```

Gets the environment variable named 'HomeBase' and its value from $PSProfile.Variables.

### EXAMPLE 2
```
Get-PSProfileVariable
```

Gets the list of environment variables from $PSProfile.Variables.

### EXAMPLE 3
```
Get-PSProfileVariable -Scope Global
```

Gets the list of Global variables from $PSProfile.Variables.

## PARAMETERS

### -Scope
The scope of the variable to get the variable from between Environment or Global.

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

### -Name
The name of the variable to get.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
