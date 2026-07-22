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
        [switch]$Preview,
        [switch]$Force
    )

    $files = Get-ChildItem -Path $Path -Filter *.pdf
    foreach ($file in $files) {
        $basePath = '{0}\{1}' -f $file.Directory, $file.BaseName

        if (Test-Path "$basePath.json") {
            $json = Get-Content "$basePath.json" | ConvertFrom-Json
            $a = $json.Data.Accounts[0].AccountName
            $p = $json.Data.Period
            $i = $json.Data.Institution

            # Il faut ignorer le cas ou le nom avant et après est le même
            $command = (Get-ChildItem $basePath* | ForEach-Object {
                $newName = '{0}_{1}_{2}{3}' -f $p, $a, $i, $_.Extension
                if ($newName -ne $_.Name) {
                    "Rename-Item '{0}' '{1}'" -f $_.Fullname, $newName
                }
            }) -join "`n"

            [PSCustomObject]@{
                Path        = $file.Directory
                BaseName    = $file.BaseName + '*'
            #    PDF         = $file.BaseName + '.pdf'
            #    JSON        = $file.BaseName + '.json'
                Period      = $p
                Account     = $a
                Institution = $i
                RenameCmd   = $command
            }
            if ($Force) { $command | %{ Invoke-Expression $_ } }
        } else {
            Write-Warning "$basePath.json was not found"
        }
    }
}