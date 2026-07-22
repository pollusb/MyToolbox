function Approve-PdfJson {
    # Après l'inspection manuelle
    param (
        $JsonPath,
        $Notes = "Validé manuellement $(Get-Date -f 'yyyy-MM-dd hh:mm')"
    )
    $json = Get-Content -Path $JsonPath | ConvertFrom-Json
    if ($json.Data.Notes) {
        $json.Data.Notes = $Notes
    } else {
        $json.Data | Add-Member -Type NoteProperty -Name 'Notes' -Value $Notes
    }

    $json | ConvertTo-Json -Depth 10 -Compress | Set-Content $jsonPath -Encoding UTF8
}