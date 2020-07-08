# Fonction pour cr�er un dictionaire de mots (alias) et d�finitions
# Un alias poss�de une seule d�finition mais une d�finition peut poss�der plusieurs aliases.
function xsql {
    [CmdLetBinding()]
    param (
        [Parameter(Position=0)]
        $Alias,

        [Parameter(Position=1)]
        $Definition,

        [switch]$Reset
    )
    $jsonPath = "$home\xsql.json"
    if ($Reset) {
        $script:xsql = @()
        Remove-Item $jsonPath -ErrorAction Ignore
    }
    if (-not $script:xsql) {
        if (Test-Path $jsonPath) {
            Write-Warning 'Chargement du fichier JSON'
            $script:xsql = Get-Content $jsonPath | Convertfrom-Json
        } else {
            Write-Verbose 'Initialisation de la cache'
            $script:xsql = @()
        }
    }
    if ($Alias -and $Definition) { # Ajout ou modification d'un alias
        if ($obj = $script:xsql | Where-Object Alias -eq $Alias) {
            Write-Verbose 'Modification d''alias'
            $obj.Definition = $Definition
        } else {
            Write-Verbose 'Ajout d''alias'
            $script:xsql += [PSCustomObject]@{
                Alias = $Alias
                Definition = $Definition
            }
        }
    } elseif ($Alias) {         # Demande quelle d�finition pour un alias
        $script:xsql | Where-Object Alias -eq $Alias | Select-Object -ExpandProperty Definition
    } elseif ($Definition) {    # Voir tous les aliases pour une d�finition
        $script:xsql | Where-Object Definition -eq $Definition | Select-Object Alias, Definition
    } else {                    # La table compl�te
        $script:xsql
    }
    $script:xsql | ConvertTo-Json | Set-Content $jsonPath
}
