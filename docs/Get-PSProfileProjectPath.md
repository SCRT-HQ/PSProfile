# Get-PSProfileProjectPath

## SYNOPSIS
Gets a project path from $PSProfile.ProjectPaths.

## SYNTAX

```
Get-PSProfileProjectPath [[-Path] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets a project path from $PSProfile.ProjectPaths.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileProjectPath -Path E:\Git
```

Gets the path 'E:\Git' from $PSProfile.ProjectPaths

### EXAMPLE 2
```
Get-PSProfileProjectPath
```

Gets the list of project paths from $PSProfile.ProjectPaths

## PARAMETERS

### -Path
The project path to get from $PSProfile.ProjectPaths.

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
