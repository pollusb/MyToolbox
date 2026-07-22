function Get-VideoHeight {
    # uses exiftool
    # https://search.brave.com/search?q=exiftool+powershell+module&summary=1&conversation=095a8154389f590c0fb9ed2df2ab03328001
    param (
        $Path,
        $VideoPattern = '(mkv|mp4|m4v|mpg|m2ts|divx|wmv|iso|avi)$'
    )
    foreach ($file in (Get-ChildItem $Path)) {
        if ($file.Name -match $VideoPattern) {
            $file | Select-Object Name, Directory,
            @{n='SizeGB';e={$_.Length/1GB}},
            @{n='Height';e={(exiftool.exe $_.FullName|Select-String 'Height +: (\d+)').Matches.Groups[1].Value}}
        }
    }
}