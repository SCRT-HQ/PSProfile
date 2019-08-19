# Add-PSProfileModuleToImport

## SYNOPSIS
Adds a module to import during PSProfile import.

## SYNTAX

```
Add-PSProfileModuleToImport [-Name] <String> [-Prefix <String>] [-MinimumVersion <String>]
 [-RequiredVersion <String>] [-ArgumentList <Object[]>] [-Force] [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a module to import during PSProfile import.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfileModuleToImport -Name posh-git -RequiredVersion '0.7.3' -Save
```

Specifies to import posh-git version 0.7.3 during PSProfile import then saves the updated configuration.

## PARAMETERS

### -Name
The name of the module to import.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Prefix
Add the specified prefix to the nouns in the names of imported module members.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinimumVersion
Import only a version of the module that is greater than or equal to the specified value.
If no version qualifies, Import-Module generates an error.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequiredVersion
Import only the specified version of the module.
If the version is not installed, Import-Module generates an error.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ArgumentList
Specifies arguments (parameter values) that are passed to a script module during the Import-Module command.
Valid only when importing a script module.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
If the module already exists in $PSProfile.ModulesToImport, use -Force to overwrite the existing value.

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
