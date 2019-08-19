# Enter-CleanEnvironment

## SYNOPSIS
Enters a clean environment with -NoProfile and sets a couple helpers, e.g.
a prompt to advise you are in a clean environment and some PSReadline helper settings for convenience.

## SYNTAX

```
Enter-CleanEnvironment [[-Engine] <String>] [-ImportModule] [<CommonParameters>]
```

## DESCRIPTION
Enters a clean environment with -NoProfile and sets a couple helpers, e.g.
a prompt to advise you are in a clean environment and some PSReadline helper settings for convenience.

## EXAMPLES

### EXAMPLE 1
```
Enter-CleanEnvironment
```

Opens a clean environment from the current path.

### EXAMPLE 2
```
cln
```

Does the same as Example 1, but using the shorter alias 'cln'.

### EXAMPLE 3
```
cln -ipmo
```

Enters the clean environment and imports the built module in the BuildOutput folder, if present.

## PARAMETERS

### -Engine
The engine to open the clean environment with between powershell, pwsh, and pwsh-preview.
Defaults to the current engine the clean environment is opened from.

```yaml
Type: String
Parameter Sets: (All)
Aliases: E

Required: False
Position: 1
Default value: $(if ($PSVersionTable.PSVersion.ToString() -match 'preview') {
                'pwsh-preview'
            }
            elseif ($PSVersionTable.PSVersion.Major -ge 6) {
                'pwsh'
            }
            else {
                'powershell'
            })
Accept pipeline input: False
Accept wildcard characters: False
```

### -ImportModule
If $true, imports the module found in the BuildOutput folder if present.
Useful for quickly testing compiled modules after building in a clean environment to avoid assembly locking and other gotchas.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ipmo, Import

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
