Function Remove-TSQLComments {
    # Search and Replace comments in TSQL files for analysis
    # Tested on PSv2
    # Output Param to save the result in a different file | out-file File2.sql
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        $Path,
        [switch] $ReplaceWith,
        [switch] $ReplaceFileContent
    )
    Process {
        $Encoding = Get-FileEncoding -FilePath $Path
        $Code = Get-Content -Path $Path -Encoding $Encoding | Out-String
        if ($ReplaceWithBlank) {
            $Code = $Code -replace '(?smi)\/\*.*?\*\/', ''
            $Code = $Code -replace '--.*', ''
        }
        else {
            $Code = $Code -replace '(?smi)\/\*.*?\*\/', '/*comments removed*/'
            $Code = $Code -replace '--.*', '--comments removed'
        }
        if ($ReplaceFileContent) {
            Set-Content -Path $Path -Value $Code -Encoding $Encoding
        } else {
            return $Code
        }
    }
}