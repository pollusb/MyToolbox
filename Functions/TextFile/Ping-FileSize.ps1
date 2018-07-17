Function Ping-FileSize($File, [switch]$Beep, [int]$Seconds = 2) {
    for ($i = 1; $i -le 1000; $i++) {
        $size = Get-ChildItem -LiteralPath $File | Select-Object -ExpandProperty Length
        if ($size -ne $last) { $last = $size }
        else { if ($Beep) { [console]::beep(750, 750) }; break }
        Write-Host $size
        Start-Sleep -Seconds $Seconds
    }
}
