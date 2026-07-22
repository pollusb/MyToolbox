<#
.SYNOPSIS
    Sortir la liste des fichiers associés aux PDF (JSON et TXT)
#>
function Get-PdfFile {
    param (
        $Path
    )
    Get-ChildItem $Path -Filter *.pdf | Select-Object Name,
        @{n='JSON'; e={Test-Path ('{0}\{1}.json' -f $_.Directory, $_.BaseName)}},
        @{n='TXT';  e={Test-Path ('{0}\{1}.txt'  -f $_.Directory, $_.BaseName)}}
}