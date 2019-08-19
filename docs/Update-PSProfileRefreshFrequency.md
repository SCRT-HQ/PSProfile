# Update-PSProfileRefreshFrequency

## SYNOPSIS
Sets the Refresh Frequency for PSProfile.
The $PSProfile.Refresh() runs tasks that aren't run during every profile load, i.e.
SymbolicLink creation, Git project path discovery, module installation, etc.

## SYNTAX

```
Update-PSProfileRefreshFrequency [-Timespan] <TimeSpan> [-Save] [<CommonParameters>]
```

## DESCRIPTION
Sets the Refresh Frequency for PSProfile.
The $PSProfile.Refresh() runs tasks that aren't run during every profile load, i.e.
SymbolicLink creation, Git project path discovery, module installation, etc.

## EXAMPLES

### EXAMPLE 1
```
Update-PSProfileRefreshFrequency -Timespan '03:00:00' -Save
```

Updates the RefreshFrequency to 3 hours and saves the PSProfile configuration after updating.

## PARAMETERS

### -Timespan
The frequency that you would like to refresh your PSProfile configuration.
Refresh will occur during the profile load after the time since last refresh has surpassed the desired refresh frequency.

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
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
