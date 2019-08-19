# Get-PSProfileModuleToInstall

## SYNOPSIS
Gets a module from $PSProfile.ModulesToInstall.

## SYNTAX

```
Get-PSProfileModuleToInstall [[-Name] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets a module from $PSProfile.ModulesToInstall.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileModuleToInstall -Name posh-git
```

Gets posh-git from $PSProfile.ModulesToInstall

### EXAMPLE 2
```
Get-PSProfileModuleToInstall
```

Gets the list of modules to install from $PSProfile.ModulesToInstall

## PARAMETERS

### -Name
The name of the module to get from $PSProfile.ModulesToInstall.

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
