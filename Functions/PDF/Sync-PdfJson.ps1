function Sync-PdfJson {
    # MERGE data to Relevus Database
    param (
        $JsonPath
    )
    $json = Get-Content -Path $JsonPath
    $json = $json -replace "'","''"
    $sqlCommand = "DECLARE @j NVARCHAR(MAX) ='$json';
    EXEC dbo.usp_ImportBankStatement @Json = @j;"
    $sqlCommand
    $cnx = Connect-DbaInstance -SqlInstance 'localhost\sqlexpress' -Database Relevus -TrustServerCertificate
    Invoke-DbaQuery -SqlInstance $cnx -Query $sqlCommand
}