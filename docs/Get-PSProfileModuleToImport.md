# Get-PSProfileModuleToImport

## SYNOPSIS
Gets a module from $PSProfile.ModulesToImport.

## SYNTAX

```
Get-PSProfileModuleToImport [[-Name] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets a module from $PSProfile.ModulesToImport.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileModuleToImport -Name posh-git
```

Gets posh-git from $PSProfile.ModulesToImport

### EXAMPLE 2
```
Get-PSProfileModuleToImport
```

Gets the list of modules to import from $PSProfile.ModulesToImport

## PARAMETERS

### -Name
The name of the module to get from $PSProfile.ModulesToImport.

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
