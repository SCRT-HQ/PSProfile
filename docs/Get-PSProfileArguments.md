# Get-PSProfileArguments

## SYNOPSIS
Used for PSProfile Plugins to provide easy Argument Completers using PSProfile constructs.

## SYNTAX

```
Get-PSProfileArguments [-FinalKeyOnly] [[-WordToComplete] <String>] [[-CommandName] <Object>]
 [[-ParameterName] <Object>] [[-CommandAst] <Object>] [[-FakeBoundParameter] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Used for PSProfile Plugins to provide easy Argument Completers using PSProfile constructs.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileArguments -WordToComplete "Prompts.$wordToComplete" -FinalKeyOnly
```

Gets the list of prompt names under the Prompts PSProfile primary key.

### EXAMPLE 2
```
Get-PSProfileArguments -WordToComplete "GitPathMap.$wordToComplete" -FinalKeyOnly
```

Gets the list of Git Path short names under the GitPathMap PSProfile primary key.

## PARAMETERS

### -FinalKeyOnly
Returns only the final key of the completed argument to the list of completers.
If $false, returns the full path.

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

### -WordToComplete
The word to complete, typically passed in from the scriptblock arguments.

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

### -CommandName
Here to allow passing @PSBoundParameters directly to this function from Register-ArgumentCompleter

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParameterName
Here to allow passing @PSBoundParameters directly to this function from Register-ArgumentCompleter

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandAst
Here to allow passing @PSBoundParameters directly to this function from Register-ArgumentCompleter

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FakeBoundParameter
Here to allow passing @PSBoundParameters directly to this function from Register-ArgumentCompleter

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.CompletionResult
## NOTES

## RELATED LINKS
