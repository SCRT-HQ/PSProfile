# Push-Path

## SYNOPSIS
Pushes your current location to the path specified.
Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

## SYNTAX

```
Push-Path [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Pushes your current location to the path specified.
Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

## EXAMPLES

### EXAMPLE 1
```
Push-Path MyWorkRepo
```

Changes your current directory to your Git Repo named 'MyWorkRepo'.

### EXAMPLE 2
```
push MyWorkRepo
```

Same as the first example but using the shorter alias.

## PARAMETERS

### -Path
The path you would like to push your location to.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Since Push-Location is being called from a function, Pop-Location doesn't have any actual effect after :-(.
This is effectively Set-Location, given that caveat.

## RELATED LINKS
