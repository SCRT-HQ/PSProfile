# Open-Code

## SYNOPSIS
A drop-in replacement for the Visual Studio Code CLI \`code\`.
Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

## SYNTAX

### Path (Default)
```
Open-Code [-Path] <String> [-AddToWorkspace] [-Arguments <Object>] [<CommonParameters>]
```

### InputObject
```
Open-Code [[-Path] <String>] [-InputObject <Object>] [-Language <String>] [-Wait] [-Arguments <Object>]
 [<CommonParameters>]
```

### Cookbook
```
Open-Code [-AddToWorkspace] [-Arguments <Object>] [<CommonParameters>]
```

## DESCRIPTION
A drop-in replacement for the Visual Studio Code CLI \`code\`.
Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

## EXAMPLES

### EXAMPLE 1
```
Get-Process | ConvertTo-Csv | Open-Code -Language csv
```

Gets the current running processes, converts to CSV format and opens it in Code via background job as a CSV.
Easy Out-GridView!

### EXAMPLE 2
```
def Update-PSProfileSetting | code -l ps1
```

Using shorter aliases, gets the current function definition of the Update-PSProfileSetting function and opens it in Code as a PowerShell file to take advantage of immediate syntax highlighting.

## PARAMETERS

### -Path
The path of the file or folder to open with Code.
Allows tab-completion of GitPath aliases if ProjectPaths are filled out with PSProfile that expand to the full path when invoked.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: InputObject
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AddToWorkspace
If $true, adds the folder to the current Code workspace.

```yaml
Type: SwitchParameter
Parameter Sets: Path, Cookbook
Aliases: add, a

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Pipeline input to display as a temporary file in Code.
Temp files are automatically cleaned up after the file is closed in Code.
No need to add the \`-\` after \`code\` to specify that pipeline input is expected.

```yaml
Type: Object
Parameter Sets: InputObject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Language
The language or extension of the temporary file created from the pipeline input.
This allows specifying a file type like 'powershell' or 'csv' or an extension like 'ps1', enabling opening of the temp file with the editor file language already set correctly.

```yaml
Type: String
Parameter Sets: InputObject
Aliases: l, lang, Extension

Required: False
Position: Named
Default value: Txt
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait
If $true, waits for the file to be closed in Code before returning to the prompt.
If $false, opens the file using a background job to allow immediately returning to the prompt.
Defaults to $false.

```yaml
Type: SwitchParameter
Parameter Sets: InputObject
Aliases: w

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Arguments
Any additional arguments to be passed directly to the Code CLI command, e.g.
\`Open-Code --list-extensions\` or \`code --list-extensions\` will still work the same as expected.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

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
