# Add-PSProfileSecret

## SYNOPSIS
Adds a PSCredential object or named SecureString to the PSProfile Vault then saves the current PSProfile.

## SYNTAX

### PSCredential (Default)
```
Add-PSProfileSecret [-Credential] <PSCredential> [-Force] [-Save] [<CommonParameters>]
```

### SecureString
```
Add-PSProfileSecret -Name <String> -SecureString <SecureString> [-Force] [-Save] [<CommonParameters>]
```

## DESCRIPTION
Adds a PSCredential object or named SecureString to the PSProfile Vault then saves the current PSProfile.

## EXAMPLES

### EXAMPLE 1
```
Add-PSProfileSecret (Get-Credential) -Save
```

Opens a Get-Credential window or prompt to enable entering credentials securely, then stores it in the Vault and saves your PSProfile configuration after updating.

### EXAMPLE 2
```
Add-PSProfileSecret -Name HomeApiKey -Value (ConvertTo-SecureString 1234567890xxx -AsPlainText -Force) -Save
```

Stores the secret value '1234567890xxx' as the name 'HomeApiKey' in $PSProfile.Vault and saves your PSProfile configuration after updating.

## PARAMETERS

### -Credential
The PSCredential to add to the Vault.
PSCredentials are recallable by the UserName from the stored PSCredential object via either \`Get-MyCreds\` or \`Get-PSProfileSecret -UserName $UserName\`.

```yaml
Type: PSCredential
Parameter Sets: PSCredential
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
For SecureString secrets, the friendly name to store them as for easy recall later via \`Get-PSProfileSecret\`.

```yaml
Type: String
Parameter Sets: SecureString
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureString
The SecureString to store as the provided Name for recall later.

```yaml
Type: SecureString
Parameter Sets: SecureString
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
If $true and the PSCredential's UserName or SecureString's Name already exists, it overwrites it.
Defaults to $false to prevent accidentally overwriting existing secrets in the $PSProfile.Vault.

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
