foreach ($file in (Get-ChildItem "$PSScriptRoot\Functions\*.ps1" -Exclude *.test.ps1 -Recurse)) {
    Write-Verbose $file.Name
    . $file.FullName
}
$global:cfg = [PSCustomObject]@{
    #TODO: Il faut trouver un moyen de récupérer la version du module depuis le fichier .psd1
    ModuleVersion = 1.2.3 #([string](Select-String -Pattern 'ModuleVersion' -Path $PSScriptRoot\*.psd1).Line).Split('=')[1].Replace('''','').Trim()
    BinFolder     = "$PSScriptRoot\Bin"
    ModuleRoot    = $PSScriptRoot
    Institutions  = Get-Content "$($cfg.ModuleRoot)\Data\Institutions.csv"
}

# $ModuleVersion = ([string](Select-String -Pattern 'ModuleVersion' -Path $PSScriptRoot\*.psd1).Line).Split('=')[1].Replace('''','').Trim()
Write-Host "MyToolbox ($cfg.ModuleVersion)" -ForegroundColor DarkGray
