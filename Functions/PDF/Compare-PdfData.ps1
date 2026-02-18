function Compare-PdfData {
    param (
        $Path
    )
    $files = Get-ChildItem -Path $Path -Filter *.pdf -Recurse -File

    foreach ($file in $files) {
        $jsonPath = '{0}\{1}.json' -f $file.Directory, $file.BaseName
        Invoke-Item $file
        Invoke-Item $jsonPath
    }
}