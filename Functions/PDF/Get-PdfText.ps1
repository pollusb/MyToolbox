function Get-PdfPageText {
    <#
    .SYNOPSIS
        Extract pages text from a PDF file
    .DESCRIPTION
        Use the iTextSharp PdfTextExtractor to get UTF8 text from PDF
        Use the -Cache option to read and write to cache (in .data folder in the file's parent folder)
    .PARAMETER NoEmptyLine
        Will remove empty line from the output text
    .PARAMETER Trim
        Will trim start and end of lines from output text
    .PARAMETER Raw
        Will return a long string instead of a collection of lines
    .PARAMETER Force
        Will overwrite files in Cache or OutputFolder
    .PARAMETER Passthru
        Will return text to default output
    .PARAMETER Cache
        Read and write to cache. If it does not exists, extract it and cache it.
    .EXAMPLE
        Get-PdfPageText -Path YourFile.pdf | Out-File YourFile.txt
    .EXAMPLE
        Get-ChildItem *.pdf | Get-PdfPageText -Cache
    .LINK
        Inspired from: https://github.com/datenteiler/PDFHacks/blob/master/Export-TextFromPDF.ps1
    .NOTES
        This function should do only extract text from a PDF File
        Other functions calling this one should alter text or save it in cache
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Path,
        #[int16]$NbPage = 32767, # Max number of pages to export

        # Text Alteration [TODO: move to another function]
        [switch]$NoEmptyLine,   # Remove line with blank caracters like space or tab
        [switch]$Trim,          # Trim space at start and end of line
        [switch]$Raw,           # Return one string of text instead of a collection of lines
        [string]$PageDelimiter, # Add a page delimiter like a line
        [switch]$AppendResume
    )
    begin {
        $bin = $cfg.BinFolder
        $null = [System.Reflection.Assembly]::LoadFrom("$bin\BouncyCastle.Cryptography.dll")
        $null = [System.Reflection.Assembly]::LoadFrom("$bin\itextsharp.dll")
    }
    process {
        foreach ($file in (Get-ChildItem $Path)) {
            $allPages = @()
            #$cacheFld = "$($file.Directory)\.data"
            #$cacheTxt = '{0}\{1}.txt' -f $cacheFld, $file.BaseName
            #$hash = (Get-FileHash -Algorithm SHA256 -Path $file).Hash
            [string[]]$rawPage = $null

            # Read from cache
            #if ($Cache -and !$Force) {
            #    if (Test-Path $cacheTxt) {
            #        $rawPage = Get-Content $cacheTxt -Raw
            #        Write-Verbose "Text retreived from cache [$($file.Name)]"
            #        $found = $true
            #    }
            #}

            # Read from PDF file
            #if ($Force -or !$found) {
                $reader = New-Object iTextSharp.text.pdf.PdfReader -ArgumentList $file
                $nbPg = [math]::Min($reader.NumberOfPages, $NbPage)
                for ([int16]$i = 1; $i -le $nbPg; $i++) {
                    Write-Verbose "Processing page $i from ""$($file.Name)"" using iText"
                    $rawPage += [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($reader, $i) -replace '\n',"`r`n"
                    if ($PageDelimiter) {
                        $rawPage = $rawPage + "`r`n$PageDelimiter`r`n"
                        Write-Verbose "added page delimiter"
                    }
                }
            #}

            # Text alterations
            if ($NoEmptyLine) { $rawPage = $rawPage -replace '(?m)^\s+$[\r\n]*' }
            $allPages = if ($Trim -and !$Raw) {
                $rawPage.Split("`r`n").Trim()
                Write-Verbose 'trim and not raw'
            } elseif ($Trim -and $Raw) {
                $rawPage.Split("`r`n").Trim() -join "`r`n"
                Write-Verbose 'trim and raw'
            } elseif ($Raw) {
                $rawPage
                Write-Verbose 'raw text'
            } else {
                $rawPage.Split("`r`n")
                Write-Verbose 'collection of lines (not raw)'
            }

            #$resume = [PSCustomObject]@{
            #    PdfPath  = $file.Directory
            #    PdfFile  = $file.Name
            #    #PdfHash  = $hash
            #    #Length   = $file.Length
            #    #TxtPath  = $cacheTxt
            #    Now      = Get-Date -f 'yyyy-MM-dd HH:mm'
            #    #NbPages  = $nbPg
            #}

            # Write cache
            #if ($Cache) {
            #    $null = mkdir ($cacheFld = "$($file.Directory)\.data") -ErrorAction SilentlyContinue
            #    $allPages | Out-File $cacheTxt
            #
            #    if ($AppendResume) {
            #        $resume | Format-List | Out-File $cacheTxt -Append
            #    }
            #    Write-Verbose "Write to cache $cacheTxt"
            #}
            #elseif ($OutputFolder) {
            #    $allPages | Out-File ($txtPath = '{0}\{1}.txt' -f $OutputFolder, $file.BaseName)
            #    $resume.TextPath = $txtPath
            #}

            # Console output
            #if ($Passthru) {
                $allPages
            #}
            #else {
            #    $resume
            #}
        }
    }
}
