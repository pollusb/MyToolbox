param (
    $manifestPath = "$PSScriptRoot\..\MyToolBox.psd1"
)

$manifest = Import-PowerShellDataFile $manifestPath
[Version]$current = $manifest.ModuleVersion
$new = [Version]::new($current.Major, $current.Minor, $current.Build + 1)
Update-ModuleManifest -Path $manifestPath -ModuleVersion $new
