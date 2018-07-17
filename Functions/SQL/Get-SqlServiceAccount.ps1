Function Get-SqlServiceAccount {
    # Migré dans SqlInventory
    # Extract the SQL service accounts of this machine
    # (Find-Instance).ComputerName | select -Unique | %{Get-SqlServiceAccount -ComputerName $_ -EngineOnly } | Out-GridView
    [CmdletBinding()]
    Param(
        $ComputerName = 'localhost',
        [switch]$EngineOnly
    )
    if ($EngineOnly) {
        Get-WmiObject -Class Win32_Service -ComputerName $ComputerName |
            Where-Object {$_.Name -like 'MSSQL$*' -or $_.Name -eq 'MSSQLSERVER'} |
            Select-Object SystemName, DisplayName, StartName, State
    }
    else {
        Get-WmiObject -Class Win32_Service -ComputerName $ComputerName |
            Where-Object {$_.DisplayName -like 'SQL*'} |
            Select-Object SystemName, DisplayName, StartName, State
    }
}
