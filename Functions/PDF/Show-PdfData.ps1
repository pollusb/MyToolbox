<#
.SYNOPSIS
    Afficher de façon condensé le JSON.
.DESCRIPTION
    Il est possible de passer le fichier PDF ou le JSON
#>
function Show-PdfData {
    param (
        $Path
    )
    $file = Get-ChildItem -Path $Path | Select-Object -First 1
    $jsonFile = if ($file.Extension -ne '.json') {
        '{0}\{1}.json' -f $file.Directory, $file.BaseName
    } else {
        $file.FullName
    }
    $data = Get-Content $jsonFile | ConvertFrom-Json

    $data.Data | Select-Object -ExcludeProperty Accounts | Out-String
    $data.Data.Accounts[0] | Select-Object -ExcludeProperty Operations | Out-String
    $data.Data.Accounts[0].Operations | Format-Table -AutoSize | Out-String
}