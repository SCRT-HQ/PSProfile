# Get-PSProfileScriptPath

## SYNOPSIS
Gets a script path from $PSProfile.ScriptPaths.

## SYNTAX

```
Get-PSProfileScriptPath [[-Path] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets a script path from $PSProfile.ScriptPaths.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileScriptPath -Path E:\Git\MyProfileScript.ps1
```

Gets the path 'E:\Git\MyProfileScript.ps1' from $PSProfile.ScriptPaths

### EXAMPLE 2
```
Get-PSProfileScriptPath
```

Gets the list of script paths from $PSProfile.ScriptPaths

## PARAMETERS

### -Path
The script path to get from $PSProfile.ScriptPaths.

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
