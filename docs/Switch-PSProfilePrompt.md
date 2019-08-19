# Switch-PSProfilePrompt

## SYNOPSIS
Sets the prompt to the desired prompt by either the Name of the prompt as stored in $PSProfile.Prompts or the provided prompt content.

## SYNTAX

### Name (Default)
```
Switch-PSProfilePrompt [-Name] <String> [-Temporary] [<CommonParameters>]
```

### Content
```
Switch-PSProfilePrompt -Content <Object> [<CommonParameters>]
```

## DESCRIPTION
Sets the prompt to the desired prompt by either the Name of the prompt as stored in $PSProfile.Prompts or the provided prompt content.

## EXAMPLES

### EXAMPLE 1
```
Switch-PSProfilePrompt -Name Demo
```

Sets the active prompt to the prompt named 'Demo' from $PSProfile.Prompts and saves it as the Default prompt for session persistence.

## PARAMETERS

### -Name
The Name of the prompt to set as active from $PSProfile.Prompts.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Temporary
If $true, does not update $PSProfile.Settings.DefaultPrompt with the selected prompt so that prompt selection does not persist after the current session.

```yaml
Type: SwitchParameter
Parameter Sets: Name
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Content
If Content is provided as either a ScriptBlock or String, sets the current prompt to that.
Equivalent to passing \`function prompt {$Content}\`

```yaml
Type: Object
Parameter Sets: Content
Aliases:

Required: True
Position: Named
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
