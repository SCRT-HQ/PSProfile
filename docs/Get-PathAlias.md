# Get-PathAlias

## SYNOPSIS
Gets the Path alias using either the short name from $PSProfile.GitPathMap or a path alias stored in $PSProfile.PathAliases, falls back to using a shortened version of the root drive + current directory.

## SYNTAX

```
Get-PathAlias [[-Path] <String>] [[-DirectorySeparator] <String>] [<CommonParameters>]
```

## DESCRIPTION
Gets the Path alias using either the short name from $PSProfile.GitPathMap or a path alias stored in $PSProfile.PathAliases, falls back to using a shortened version of the root drive + current directory.

## EXAMPLES

### EXAMPLE 1
```
Get-PathAlias
```

## PARAMETERS

### -Path
The full path to get the PathAlias for.
Defaults to $PWD.Path

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

### -DirectorySeparator
The desired DirectorySeparator character.
Defaults to $global:PathAliasDirectorySeparator if present, falls back to \[System.IO.Path\]::DirectorySeparatorChar if not.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: $(if ($null -ne $global:PathAliasDirectorySeparator) {
                $global:PathAliasDirectorySeparator
            }
            else {
                [System.IO.Path]::DirectorySeparatorChar
            })
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
