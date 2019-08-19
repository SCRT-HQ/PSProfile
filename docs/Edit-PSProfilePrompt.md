# Edit-PSProfilePrompt

## SYNOPSIS
Enables editing the prompt from the desired editor.
Once temporary file is saved, the prompt is updated in $PSProfile.Prompts.

## SYNTAX

```
Edit-PSProfilePrompt [-Temporary] [<CommonParameters>]
```

## DESCRIPTION
Enables editing the prompt from the desired editor.
Once temporary file is saved, the prompt is updated in $PSProfile.Prompts.

## EXAMPLES

### EXAMPLE 1
```
Edit-PSProfilePrompt
```

Opens the current prompt as a temporary file in Visual Studio Code to edit.
Once the file is saved and closed, the prompt is updated with the changes and saved back to $PSProfile.

## PARAMETERS

### -Temporary
If $true, does not save the PSProfile after updating the prompt.

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
