function Import-MyCsv {
    # Ma version de Import-Csv
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Path,
        [char]$Delimiter,
        [string]$Header,    # Utiliser ces propriétés
        [int16]$Skip,       # le nombre de lignes à ignorer (ou remplacer la ligne d'entête ?)
        [ValidateSet('DMY','MDY','YMD')]
        $DateFormat = 'MDY',
        [System.Text.Encoding]$Encoding
    )
    # Charger le fichier texte en mémoire
    $text = Get-Content -Encoding $Encoding -
    if ($Skip) {
        $text = $text[$Skip, $text.Count]
    }
    $csv = $text | ConvertFrom-Csv -Delimiter $Delimiter -Header $Header

    # Convertir les dates
    $csv
}