param (
    $manifestPath = "$PSScriptRoot\..\MyToolBox.psd1"
)

$manifest = Import-PowerShellDataFile $manifestPath
[Version]$current = $manifest.ModuleVersion
Write-Host "Curent version = $($current.ToString())"

$new = [Version]::new($current.Major, $current.Minor, $current.Build + 1)
Update-ModuleManifest -Path $manifestPath -ModuleVersion $new
Write-Host "New version = $($new.ToString())"