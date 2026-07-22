foreach ($file in (Get-ChildItem "$PSScriptRoot\Functions\*.ps1" -Recurse)) {
    Write-Verbose $file.Name
    . $file.FullName
}
$global:cfg = [PSCustomObject]@{
    BinFolder = "$PSScriptRoot\Bin"
}
$ModuleVersion = ([string](Select-String -Pattern 'ModuleVersion' -Path $PSScriptRoot\*.psd1).Line).Split('=')[1].Replace('''','').Trim()
Write-Host "MyToolbox ($ModuleVersion)" -ForegroundColor DarkGray
