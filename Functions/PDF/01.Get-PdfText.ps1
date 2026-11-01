function Get-PdfPageText {
    <#
    .SYNOPSIS
        Extract pages text from a PDF file
    .DESCRIPTION
        Use the iTextSharp PdfTextExtractor to return UTF8 text from PDF
    .PARAMETER NoEmptyLine
        Will remove empty line from the output text
    .PARAMETER Trim
        Will trim start and end of lines from output text
    .PARAMETER Raw
        Will return a long string instead of a collection of lines
    .EXAMPLE
        Get-PdfPageText -Path YourFile.pdf | Out-File YourFile.txt
    .EXAMPLE
        Get-ChildItem *.pdf | Get-PdfPageText
    .LINK
        Inspired from: https://github.com/datenteiler/PDFHacks/blob/master/Export-TextFromPDF.ps1
    .NOTES
        Tags: PDF
        Author: Pollus Brodeur (pollusb)
        Copyright: (c) 2026 Pollus Brodeur, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $Path,
        [int16]$NbPage = 32767, # Max number of pages to export

        # Text Alteration switches
        [switch]$NoEmptyLine,   # Remove line with blank caracters like space or tab
        [switch]$Trim,          # Trim space at start and end of line
        [switch]$Raw,           # Return one string of text instead of a collection of lines
        [string]$PageDelimiter  # Add a page delimiter like a line
    )
    begin {
        $bin = $cfg.BinFolder
        $null = [System.Reflection.Assembly]::LoadFrom("$bin\BouncyCastle.Cryptography.dll")
        $null = [System.Reflection.Assembly]::LoadFrom("$bin\itextsharp.dll")
    }
    process {
        foreach ($file in (Get-ChildItem $Path)) {
            $allPages = @()
            [string[]]$rawPage = $null

            # Read from PDF file
            $reader = New-Object iTextSharp.text.pdf.PdfReader -ArgumentList $file
            $nbPg = [math]::Min($reader.NumberOfPages, $NbPage)
            for ([int16]$i = 1; $i -le $nbPg; $i++) {
                Write-Verbose "Processing page $i from ""$($file.Name)"" using iText"
                $rawPage += [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($reader, $i) -replace '\n',"`r`n"
                if ($PageDelimiter) {
                    $rawPage = $rawPage + "`r`n$PageDelimiter`r`n" # Text alterations
                    Write-Verbose "added page delimiter"
                }
            }

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
            $allPages
        }
    }
}
