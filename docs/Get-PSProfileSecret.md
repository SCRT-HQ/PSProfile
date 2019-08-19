# Get-PSProfileSecret

## SYNOPSIS
Gets a Secret from the $PSProfile.Vault.

## SYNTAX

```
Get-PSProfileSecret [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Gets a Secret from the $PSProfile.Vault.

## EXAMPLES

### EXAMPLE 1
```
Get-PSProfileSecret -Name MyApiKey
```

Gets the Secret named 'MyApiKey' from the $PSProfile.Vault.

## PARAMETERS

### -Name
The name of the Secret you would like to retrieve from the Vault.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
