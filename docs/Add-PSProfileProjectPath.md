# Add-PSProfileProjectPath

## SYNOPSIS
Adds a ProjectPath to your PSProfile to find Git project folders under during PSProfile refresh.
These will be available via tab-completion

## SYNTAX

```
Add-PSProfileProjectPath [-Path] <String[]> [-NoRefresh] [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a ProjectPath to your PSProfile to find Git project folders under during PSProfile refresh.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfileProjectPath -Path ~\GitRepos -Save
```

Adds the folder ~\GitRepos to $PSProfile.ProjectPaths and saves the configuration after updating.

### EXAMPLE 2
```
Add-PSProfileProjectPath C:\Git -Verbose
```

Adds the path C:\Git to your $PSProfile.ProjectPaths, refreshes your PathDict but does not save.
Call Save-PSProfile after if satisfied with the results.

## PARAMETERS

### -Path
The path of the folder to add to your $PSProfile.ProjectPaths.
This path should contain Git repo folders underneath it.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -NoRefresh
If $true, skips refreshing your PSProfile after updating project paths.

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
