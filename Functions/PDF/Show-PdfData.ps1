<#
.SYNOPSIS
    Afficher de façon condensé le JSON.
.DESCRIPTION
    Il est possible de passer le fichier PDF ou le JSON
#>
function Show-PdfData {
    [CmdLetBinding()]
    param (
        $Path
    )

    #region Private functions

    function Out-String2 {
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

    <#$jsonFile = if ($file.Extension -ne '.json') {
        '{0}\{1}.json' -f $file.Directory, $file.BaseName
    }
    else {
        $file.FullName
    }#>

    $json = Get-Content $jsonFile | ConvertFrom-Json

    Out-String2 ($json.Data | Select-Object -ExcludeProperty Accounts `
    | Format-Table -AutoSize)

    foreach ($account in $json.Data.Accounts) {
        Out-String2 ($account | Select-Object -ExcludeProperty Operations `
        | Format-Table -AutoSize)

        # Ajouter la ligne 0 pour faciliter la lecture
        $account.Operations += [PSCustomObject]@{
            LineNo     = 0
            Date1      = $json.Data.StartDate
            Date2      = $null
            Descr      = 'Opening balance'
            Location   = $null
            Amount     = 0.00
            Balance    = $account.StartBalance
            Remittance = 0.00
            Note       = $null
        }
        Out-String2 -InputObject ($account.Operations | Sort-Object LineNo `
        | Format-Table -AutoSize)

        '-'*80
    }
}