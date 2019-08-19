# Get-MyCreds

## SYNOPSIS
Gets a credential object from the PSProfile Vault.
Defaults to getting your current user's PSCredentials if stored in the Vault.

## SYNTAX

```
Get-MyCreds [[-Item] <String>] [-IncludeDomain] [<CommonParameters>]
```

## DESCRIPTION
Gets a credential object from the PSProfile Vault.
Defaults to getting your current user's PSCredentials if stored in the Vault.

## EXAMPLES

### EXAMPLE 1
```
Get-MyCreds
```

Gets the current user's PSCredentials from the Vault.

### EXAMPLE 2
```
Invoke-Command -ComputerName Server01 -Credential (Creds)
```

Passes your current user credentials via the \`Creds\` alias to the Credential parameter of Invoke-Command to make a call against Server01 using your PSCredential

### EXAMPLE 3
```
Invoke-Command -ComputerName Server01 -Credential (Get-MyCreds SvcAcct07)
```

Passes the credentials for account SvcAcct07 to the Credential parameter of Invoke-Command to make a call against Server01 using a different PSCredential than your own.

## PARAMETERS

### -Item
The name of the Secret you would like to retrieve from the Vault.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $(if ($env:USERNAME) {
                $env:USERNAME
            }
            elseif ($env:USER) {
                $env:USER
            })
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeDomain
If $true, prepends the domain found in $env:USERDOMAIN to the Username on the PSCredential object before returning it.
If not currently in a domain, prepends the MachineName instead.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: d, Domain

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

### PSCredential
## NOTES

## RELATED LINKS
