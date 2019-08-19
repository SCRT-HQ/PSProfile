# Start-BuildScript

## SYNOPSIS
For those using the typical build.ps1 build scripts for PowerShell projects, this will allow invoking the build script quickly from wherever folder you are currently in using a child process.

## SYNTAX

```
Start-BuildScript [-NoExit] [-NoRestore] [-Project <String>] [-Task <String[]>] [-Engine <String>]
 [<CommonParameters>]
```

## DESCRIPTION
For those using the typical build.ps1 build scripts for PowerShell projects, this will allow invoking the build script quickly from wherever folder you are currently in using a child process.
Any projects in the ProjectPaths list that were discovered during PSProfile load and have a build.ps1 file will be able to be tab-completed for convenience.
Temporarily sets the path to the build folder, invokes the build.ps1 file, then returns to the original path that it was invoked from.

## EXAMPLES

### EXAMPLE 1
```
Start-BuildScript MyModule -NoExit
```

Changes directories to the repo root of MyModule, invokes build.ps1, imports the compiled module in a clean child process and stops before exiting to allow testing of the newly compiled module.

### EXAMPLE 2
```
bld MyModule -ne
```

Same experience as Example 1 but uses the shorter alias 'bld' to call.
Also uses the parameter alias \`-ne\` instead of \`-NoExit\`

## PARAMETERS

### -NoExit
If $true, does not exit the child process once build.ps1 has completed and imports the built module in BuildOutput (if present to allow testing of the built project in a clean environment.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ne

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoRestore
If $true, sets $env:NoNugetRestore to $false to prevent NuGet package restoration (if applicable).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: nr

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Engine
{{ Fill Engine Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: e

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Project
{{ Fill Project Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: p

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Task
{{ Fill Task Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: t

Required: False
Position: Named
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
