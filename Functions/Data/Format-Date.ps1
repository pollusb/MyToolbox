# Pour transformer une date française en ISO
function Format-Date {
    param (
        $StringDate,
        $Format = 'yyyy-MM-dd',
        $Culture = [System.Globalization.CultureInfo]::GetCultureInfo('fr-FR')
    )
    $date = [DateTime]::ParseExact($StringDate, 'd MMM yyyy', $Culture)
    $date.ToString($Format)
}