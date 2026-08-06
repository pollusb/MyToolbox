function Export-AllDatabase {
    # https://github.com/pollusb/MyToolbox/blob/master/Functions/SQL/Export-AllDatabase.ps1
    param (
        $SqlInstance,
        $Database,
        [ValidateSet('All','Tables','Views','StoredProcedures','Functions','DbTriggers','Schemas','Roles','Users')]
        $ObjectType = 'All',
        $RootPath = '.',
        [switch]$IncludeSystem,
        [switch]$Force
    )

    #region

    function Get-ScriptFilename {
        # When Database is CaseSensitive, we need to check if a file with the same name already exists, and if so, increment the filename with a number.
        param (
            [string]$Path,
            [string]$Schema,
            [string]$Name,
            [switch]$CaseSensitive
        )
        if ($caseSensitive) {
            $dir = Get-ChildItem ('{0}\{1}.{2}*.sql' -f $Path, $Schema, $Name)
            $fullPath = if ($dir.Count -gt 0) {
                '{0}\{1}.{2}-{3}.sql' -f $Path, $Schema, $Name, ($dir.Count + 1)
            }
            else {
                '{0}\{1}.{2}.sql' -f $Path, $Schema, $Name
            }
        } else {
            $fullPath = '{0}\{1}.{2}.sql' -f $Path, $Schema, $Name
        }
        return $fullPath
    }

    #endregion

    $opts = New-DbaScriptingOption
    $opts.ScriptSchema = $true
    $opts.AnsiFile     = $true

    $dbs = Get-DbaDatabase -SqlInstance $SqlInstance -ExcludeSystem:(-not $IncludeSystem) -Database $Database

    foreach ($db in $dbs) {
        # Progression ?

        # Verify if Case Sensitivity
        if ($caseSensitive = $db.Collation -match '_CS') {
            Write-Warning "DB $($db.Name) is case sensitive $($db.Collation)."
        }
        
        # Preparing path
        $dbPath = Join-Path $RootPath $db.Name
        New-Item -ItemType Directory -Path $dbPath -Force | Out-Null

        $common = @{
            SqlInstance = $SqlInstance
            Database    = $db.Name
        }

        if ($ObjectType -match 'All|Tables') {
        }

        if ($ObjectType -match 'All|Views') {
        }

        if ($ObjectType -match 'All|StoredProcedures') {
            foreach ($obj in (Get-DbaDbStoredProcedure @common -ExcludeSystemSp)) {
                # Determine filename considering existing files with the same name when Collation is CaseSensitive
                $filename = Get-ScriptFilename -Path $dbPath -Schema $obj.Schema -Name $obj.Name -CaseSensitive:$caseSensitive

                Export-DbaScript -FilePath $filename `
                    -ScriptingOptionsObject $opts -NoPrefix `
                    -InputObject $obj
            }
        }

<#
        # Fonctions utilisateur (scalaires + table-valued)
        Get-DbaDbUdf @common -ExcludeSystemUdf |
            Export-DbaScript -FilePath (Join-Path $dbPath "04_Functions.sql") `
                            -ScriptingOptionsObject $opts -NoPrefix

        # Triggers de base de données
        Get-DbaDbTrigger @common |
            Export-DbaScript -FilePath (Join-Path $dbPath "05_DbTriggers.sql") `
                            -ScriptingOptionsObject $opts -NoPrefix

        # Schémas, rôles, utilisateurs (optionnel)
#        Get-DbaDbSchema  @common | Export-DbaScript -FilePath (Join-Path $dbPath "06_Schemas.sql")  -ScriptingOptionsObject $opts -NoPrefix
#        Get-DbaDbRole    @common | Export-DbaScript -FilePath (Join-Path $dbPath "07_Roles.sql")    -ScriptingOptionsObject $opts -NoPrefix
#        Get-DbaDbUser    @common | Export-DbaScript -FilePath (Join-Path $dbPath "08_Users.sql")    -ScriptingOptionsObject $opts -NoPrefix
#>
    }
}