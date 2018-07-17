Function Find-EmptyFolder {
    Param (
        $FolderPath = (Get-ChildItem .)
    )
    return (Get-ChildItem $FolderPath -Recurse -ErrorAction SilentlyContinue |
        Where-Object {$_.PSIsContainer -eq $True}) |
        Where-Object {$_.GetFiles().Count -eq 0} |
        Select-Object FullName
}

#Find-EmptyFolder -FolderPath $HOME

Function Get-EmptyFolder {
    # List all empty folders ()
    # https://stackoverflow.com/questions/1575493/how-to-delete-empty-subfolders-with-powershell
    # TODO: Have an Exclusion list and possibly a way to say this list and reuse it afterward
    Param(
        $Path,

        [string[]]$Exclusion # Can be a list of paths or a file listing all excluded paths
    )
    Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue |
        Where-Object {$_.PSIsContainer -and @(Get-ChildItem -LiteralPath $_.Fullname -Recurse -ErrorAction SilentlyContinue |
        Where-Object {!$_.PSIsContainer}).Length -eq 0} |
        Select-Object -ExpandProperty fullname

    # Filter out exclusions before returning the list
}