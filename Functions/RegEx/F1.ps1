function F1 {
    param (
        [ValidateSet('RegEx')]
        $Topic = 'RegEx'
    )
    $csv = @"
Descr                                                               `tCode
Pour détecter CRLN (Windows) ou LN (Linux)                          `t``r?``n
Pour retirer les espaces en début de lignes d''un texte multilignes `t(?m)^\s+
"@
    $csv | ConvertFrom-Csv -Delimiter "`t"
}