# Add-PSProfileScriptPath

## SYNOPSIS
Adds a ScriptPath to your PSProfile to invoke during profile load.

## SYNTAX

```
Add-PSProfileScriptPath [-Path] <String[]> [-Invoke] [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a ScriptPath to your PSProfile to invoke during profile load.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfileScriptPath -Path ~\MyProfileScript.ps1 -Save
```

Adds the script 'MyProfileScript.ps1' to $PSProfile.ScriptPaths and saves the configuration after updating.

### EXAMPLE 2
```
Get-ChildItem .\MyProfileScripts -Recurse -File | Add-PSProfileScriptPath -Verbose
```

Adds all scripts under the MyProfileScripts folder to $PSProfile.ScriptPaths but does not save to allow inspection.
Call Save-PSProfile after to save the results if satisfied.

## PARAMETERS

### -Path
The path of the script to add to your $PSProfile.ScriptPaths.

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

### -Invoke
If $true, invokes the script path after adding to $PSProfile.ScriptPaths to make it immediately available in the current session.

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
