<#
.SYNOPSIS
    A file rename using PDF extracted text file
.DESCRIPTION
    Il reste du travail a faire car je dois trouver pour chaque type de relevé ou trouver les info
    La solution semble être d'utiliser l'IA pour extraire les info
.NOTES
    Utilise la fonction Format-Date dans le même module
#>
function Rename-PdfFile {
    [CmdLetBinding()]
    param (
        $Path,
        $Pattern = @{
            Account = 'Numéro de Compte\s+\d{4} xxxx xxxx (\d{4})'
            Period  = 'au (\d{1,2} \S+ \d{4})'
        },
        $NewNameFormat = '{Period}_{Account}_Tangerine',
        [switch]$Preview,
        [switch]$Force
    )
    function NewNameFormat {
        param ($period, $account)
        ($NewNameFormat -replace 'Period','0' -replace 'Account','1') -f $period, $account
    }

    $files = Get-ChildItem -Path $Path -Filter *.pdf
    foreach ($file in $files) {
        $textPath = '{0}\{1}.txt' -f $file.Directory, $file.BaseName
        $text = Get-Content $textPath

        $M = $text | Select-String -Pattern $Pattern.Period
        $period = Format-Date -StringDate $M.Matches.Groups[1].Value -Format 'yyyy-MM'

        $M = $text | Select-String -Pattern $Pattern.Account
        $account = $M.Matches.Groups[1].Value

        [PSCustomObject]@{
            Path        = $file.Directory
            PDF         = $file.Name
            TXT         = $textPath | Split-Path -Leaf
            Account     = $account
            Period      = $period
            NewBaseName = '{0}_{1}_Tangerine' -f $period, $account
        }
    }
}