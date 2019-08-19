# Get-PSVersion

## SYNOPSIS
Gets the short formatted PSVersion string for use in a prompt or wherever else desired.

## SYNTAX

```
Get-PSVersion [[-Places] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Gets the short formatted PSVersion string for use in a prompt or wherever else desired.

## EXAMPLES

### EXAMPLE 1
```
Get-PSVersion -Places 2
```

Returns \`6.2\` when using PowerShell 6.2.2, or \`5.1\` when using Windows PowerShell 5.1.18362.10000

## PARAMETERS

### -Places
How many decimal places you would like the returned version string to be.
Defaults to $PSProfile.Settings.PSVersionStringLength if present.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $global:PSProfile.Settings.PSVersionStringLength
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
