function Export-AllDatabase {
param (
    $SqlInstance
    ,$RootPath = '.'
    #, $Cred     = Get-Credential   # décommenter si authentification SQL
)


# Options de scripting (équivalent des options SSMS "Generate Scripts")
$opts = New-DbaScriptingOption
$opts.ScriptSchema            = $true
$opts.IncludeDatabaseContext  = $true
$opts.IncludeHeaders          = $false
$opts.ScriptBatchTerminator   = $true
$opts.AnsiFile                = $true
$opts.Indexes                 = $true
$opts.DriAll                  = $true   # clés primaires/étrangères, contraintes
$opts.Triggers                = $true
$opts.Permissions             = $true
$opts.IncludeIfNotExists      = $true

# Toutes les bases utilisateur
$dbs = Get-DbaDatabase -SqlInstance $SqlInstance -ExcludeSystem  # -SqlCredential $Cred

foreach ($db in $dbs) {
    $dbPath = Join-Path $RootPath $db.Name
    New-Item -ItemType Directory -Path $dbPath -Force | Out-Null

    $common = @{
        SqlInstance = $SqlInstance
        Database    = $db.Name
        # SqlCredential = $Cred
    }

    # Tables
    Get-DbaDbTable @common |
        Export-DbaScript -FilePath (Join-Path $dbPath "01_Tables.sql") `
                         -ScriptingOptionsObject $opts -NoPrefix

    # Vues
    Get-DbaDbView @common -ExcludeSystemView |
        Export-DbaScript -FilePath (Join-Path $dbPath "02_Views.sql") `
                         -ScriptingOptionsObject $opts -NoPrefix

    # Procédures stockées
    Get-DbaDbStoredProcedure @common -ExcludeSystemSp |
        Export-DbaScript -FilePath (Join-Path $dbPath "03_StoredProcedures.sql") `
                         -ScriptingOptionsObject $opts -NoPrefix

    # Fonctions utilisateur (scalaires + table-valued)
    Get-DbaDbUdf @common -ExcludeSystemUdf |
        Export-DbaScript -FilePath (Join-Path $dbPath "04_Functions.sql") `
                         -ScriptingOptionsObject $opts -NoPrefix

    # Triggers de base de données
    Get-DbaDbTrigger @common |
        Export-DbaScript -FilePath (Join-Path $dbPath "05_DbTriggers.sql") `
                         -ScriptingOptionsObject $opts -NoPrefix

    # Schémas, rôles, utilisateurs (optionnel)
    Get-DbaDbSchema  @common | Export-DbaScript -FilePath (Join-Path $dbPath "06_Schemas.sql")  -ScriptingOptionsObject $opts -NoPrefix
    Get-DbaDbRole    @common | Export-DbaScript -FilePath (Join-Path $dbPath "07_Roles.sql")    -ScriptingOptionsObject $opts -NoPrefix
    Get-DbaDbUser    @common | Export-DbaScript -FilePath (Join-Path $dbPath "08_Users.sql")    -ScriptingOptionsObject $opts -NoPrefix
}
}