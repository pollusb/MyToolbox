<#
.SYNOPSIS
    Afficher de façon condensé le JSON.
.DESCRIPTION
    Il est possible de passer le fichier PDF ou le JSON
#>
function Show-PdfData {
    [CmdLetBinding()]
    param (
        $Path,
        [switch]$InvokePdf
    )

    #region Private functions

    function Out-String2 {
        # Vue compactée
        param (
            [Parameter(ValueFromPipeline)]
            $InputObject
        )
        process {
            (Out-String -InputObject $InputObject) -replace "(`r?`n)+$"
        }
    }

    #endregion

    $file = Get-ChildItem -Path $Path | Select-Object -First 1
    $jsonFile = $file.FullName -replace 'pdf$','json'
    $json = Get-Content $jsonFile | ConvertFrom-Json

    Out-String2 ($json.Data | Select-Object -ExcludeProperty Accounts `
    | Format-Table -AutoSize)

    $exclProp = @('Operations')
    if (!$json.Data.IsCreditCard) { $exclProp += 'TotalRemittance' }

    foreach ($account in $json.Data.Accounts) {
        # Seulement s'il y a des opérations
        if ($account.Operations.Count -gt 0){
            Out-String2 ($account | Select-Object -ExcludeProperty $exclProp `
            | Format-Table -AutoSize)            # Ajouter la ligne 0 pour faciliter la lecture

            # Le format Carte de crédit est différent de Compte bancaire
            if ($json.Data.IsCreditCard) {
                $account.Operations += [PSCustomObject]@{
                    Line       = 0
                    Date1      = $json.Data.StartDate
                    Date2      = $null
                    Descr      = 'Opening balance'
                    Location   = $null
                    Amount     = 0.00
                    Balance    = $account.StartBalance
                    Remittance = 0.00
                    Note       = $null
                }
            } else {
                $account.Operations += [PSCustomObject]@{
                    Line       = 0
                    Date1      = $json.Data.StartDate
                    Descr      = 'Opening balance'
                    Location   = $null
                    Amount     = 0.00
                    Balance    = $account.StartBalance
                    Note       = $null
                }
            }
            Out-String2 -InputObject ($account.Operations | Sort-Object Line `
            | Format-Table -AutoSize)

            '-'*80
        }
    }
    $pdfPath = (Resolve-Path ($Path -replace 'json$','pdf')).Path
    if ($InvokePdf) {
        Invoke-Item $pdfPath
    } else {
        "Invoke-Item -Path '$pdfPath'"
    }
}