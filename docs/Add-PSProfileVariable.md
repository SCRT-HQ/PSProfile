# Add-PSProfileVariable

## SYNOPSIS
Adds a global or environment variable to your PSProfile configuration.
Variables added to PSProfile will be set during profile load.

## SYNTAX

```
Add-PSProfileVariable [-Name] <String> [-Value] <Object> [[-Scope] <String>] [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a global or environment variable to your PSProfile configuration.
Variables added to PSProfile will be set during profile load.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfileVariable -Name HomeBase -Value C:\HomeBase -Save
```

Adds the environment variable named 'HomeBase' to be set to the path 'C:\HomeBase' during profile load and saves your PSProfile configuration.

## PARAMETERS

### -Name
The name of the variable.

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

### -Value
The value to set the variable to.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
The scope of the variable to set between Environment or Global.
Defaults to Environment.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Environment
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
