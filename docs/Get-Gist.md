# Get-Gist

## SYNOPSIS
Gets a GitHub Gist's contents using the public API

## SYNTAX

```
Get-Gist [-Id] <String> [-File <String[]>] [-Sha <String>] [-Metadata <Object>] [-Invoke] [<CommonParameters>]
```

## DESCRIPTION
Gets a GitHub Gist's contents using the public API

## EXAMPLES

### EXAMPLE 1
```
Get-Gist -Id f784228937183a1cf8105351872d2f8a -Invoke
```

Gets the Update-Release and Test-GetGist functions from the following Gist URL and loads them into the current session for subsequent use: https://gist.github.com/scrthq/f784228937183a1cf8105351872d2f8a

## PARAMETERS

### -Id
The ID of the Gist to get

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -File
The specific file from the Gist to get.
If excluded, gets all of the files as an array of objects.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Files

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Sha
The SHA of the specific Gist to get, if desired.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Metadata
Any additional metadata you want to include on the resulting object, e.g.
for identifying what the Gist is, add notes, etc.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Invoke
If $true, invokes the Gist contents.
If the Gist contains any PowerShell functions, it will adjust the scope to Global before invoking so the function remains available in the session after Get-Gist finishes.
Useful for loading functions directly from a Gist.

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
