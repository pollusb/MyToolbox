<#
.SYNOPSIS
    Outil d'extraction de data de relevés PDF
.NOTES
    Il faut une clé API de Gemini. La façon la plus simple de l'obtenir est d'utiliser Google AI Studio https://aistudio.google.com/api-keys.
#>
function Get-PdfFile {
    param (
        $Path
    )
    Get-ChildItem $Path -Filter *.pdf | Select-Object Name,
        @{n='JSON';e={Test-Path ('{0}\{1}.json' -f $_.Directory, $_.BaseName)}},
        @{n='TXT';e={Test-Path ('{0}\{1}.txt' -f $_.Directory, $_.BaseName)}}
}