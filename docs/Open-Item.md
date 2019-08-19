# Open-Item

## SYNOPSIS
Opens the item specified using Invoke-Item.
Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

## SYNTAX

```
Open-Item [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Opens the item specified using Invoke-Item.
Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

## EXAMPLES

### EXAMPLE 1
```
Open-Item
```

Opens the current path in Explorer/Finder/etc.

### EXAMPLE 2
```
open
```

Uses the shorter alias to open the current path

### EXAMPLE 3
```
open MyWorkRepo
```

Opens the folder for the Git Repo 'MyWorkRepo' in Explorer/Finder/etc.

## PARAMETERS

### -Path
The path you would like to open.
Supports anything that Invoke-Item normally supports, i.e.
files, folders, URIs.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $PWD.Path
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
