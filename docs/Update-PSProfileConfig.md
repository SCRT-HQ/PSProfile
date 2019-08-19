# Update-PSProfileConfig

## SYNOPSIS
Force refreshes the current PSProfile configuration by calling the $PSProfile.Refresh() method.

## SYNTAX

```
Update-PSProfileConfig [<CommonParameters>]
```

## DESCRIPTION
Force refreshes the current PSProfile configuration by calling the $PSProfile.Refresh() method.
This will update the GitPathMap with any new projects found and other tasks that don't run on every PSProfile load.

## EXAMPLES

### EXAMPLE 1
```
Update-PSProfileConfig
```

### EXAMPLE 2
```
Refresh-PSProfile
```

Uses the shorter alias command instead of the long command.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
