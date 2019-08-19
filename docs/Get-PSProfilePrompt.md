# Get-PSProfilePrompt

## SYNOPSIS
Gets the current prompt's definition as a string.
Useful for inspection of the prompt in use.
If PSScriptAnalyzer is installed, formats the prompt for readability before returning the prompt function string.

## SYNTAX

```
Get-PSProfilePrompt [[-Name] <String>] [-Global] [-Raw] [<CommonParameters>]
```

## DESCRIPTION
Gets the current prompt's definition as a string.
Useful for inspection of the prompt in use.
If PSScriptAnalyzer is installed, formats the prompt for readability before returning the prompt function string.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfilePrompt
```

## PARAMETERS

### -Name
The Name of the prompt from $PSProfile.Prompts to get.
If excluded, gets the current prompt.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Global
If $true, adds the global scope to the returned prompt, e.g.
\`function global:prompt\`

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

### -Raw
If $true, returns only the prompt definition and does not add the \`function prompt {...}\` enclosure.

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
