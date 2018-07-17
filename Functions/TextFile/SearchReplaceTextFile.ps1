Function SearchReplaceTextFile {
    Param(
        $Pattern,
        $ReplaceText,
        $TextFile
    )
    (Get-Content $TextFile) -replace $Pattern, $ReplaceText | Set-Content $TextFile
}