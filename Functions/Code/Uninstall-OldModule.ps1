function Uninstall-OldModule {
    # Module pour extraire la liste des modules à retirer
    param (
        [string[]]$ModulePath = @("$HOME\Documents\PowerShell\Modules","$HOME\OneDrive\Documents\PowerShell\Modules")
    )

    $i = 0
    foreach($mod in (Get-ChildItem $ModulePath)) {
        $ver = Get-ChildItem $mod.FullName -Directory
        if ($ver.count -gt 1) {
            $lastVer = (Get-Module -ListAvailable -Name $mod.Name).Version.ToString()
            '{0}:({1})' -f $mod.FullName,($ver.Count)
            foreach($v in $ver) {
                if ($v.Name -ne $lastVer) {
                    'DEL  ''{0}'' -r' -f $v.FullName
                }
                else { '#Keep {0}' -f $v.FullName}
                }
        } else {
            $i++
        }
    }
    "$i folders with only 1 version."
}