# Add-PSProfilePrompt

## SYNOPSIS
Saves the Content to $PSProfile.Prompts as the Name provided for recall later.

## SYNTAX

```
Add-PSProfilePrompt [[-Name] <String>] [-Content <Object>] [-SetAsDefault] [<CommonParameters>]
```

## DESCRIPTION
Saves the Content to $PSProfile.Prompts as the Name provided for recall later.

## EXAMPLES

### EXAMPLE 1
```
"'
```

Saves a prompt named 'Demo' with the provided content.

## PARAMETERS

### -Name
The Name to save the prompt as.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $global:PSProfile.Settings.DefaultPrompt
Accept pipeline input: False
Accept wildcard characters: False
```

### -Content
The prompt content itself.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SetAsDefault
If $true, sets the prompt as default by updated $PSProfile.Settings.DefaultPrompt.

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
