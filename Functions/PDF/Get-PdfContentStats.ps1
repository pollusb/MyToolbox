function Get-PdfContentStats {
    <#
    .SYNOPSIS
        Extract stats from text of a PDF file
    .DESCRIPTION
        Use the iTextSharp PdfTextExtractor to return UTF8 text from PDF
    .PARAMETER NoEmptyLine
        Will remove empty line from the output text
    .PARAMETER Trim
        Will trim start and end of lines from output text
    .PARAMETER Raw
        Will return a long string instead of a collection of lines
    .EXAMPLE
        Get-PdfContentStats -Path YourFile.pdf | Get-PdfContentStats
    .EXAMPLE
        Get-ChildItem *.pdf | Get-PdfContentStats
    .LINK
        Inspired from: https://github.com/datenteiler/PDFHacks/blob/master/Export-TextFromPDF.ps1
    .OUTPUTS
        PSCustomObject
        - Top 5 of institutions count
        - First institution
        - First 5 non-empty lines of extracted text seperated with CRLF
    .NOTES
        Tags: PDF
        Author: Pollus Brodeur (pollusb)
        Copyright: (c) 2026 Pollus Brodeur, licensed under MIT
        License: MIT https://opensource.org/licenses/MIT
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject # Raw text from PDF file OR PDF file path
    )
    begin {

        if ($InputObject.Count -gt 1) {
            Write-Verbose "InputObject is a collection of $($InputObject.Count) lines"
            if ($InputObject -is [string] -and (Test-Path $InputObject)) {
                Write-Verbose "InputObject is a file path"
                $text = Get-PdfPageText -Path $InputObject
            }
        }
        else {
            Write-Verbose "InputObject is a single line"
        }
    }
    process {
        foreach ($inst in $cfg.Institutions) {
            $cfg.Institutions | foreach-object {
                if ($match = $text -match $_) {
                    [pscustomobject]@{
                        Institution = $_.Split('|')[0]
                        Match       = $match
                    }
                }
            }
        }
        <#
        [PSCustomObject]@{
            Top5Count   = ($InputObject | Measure-Object).Count
            First       = ($InputObject | Select-Object -First 1)
            First5Lines = ($InputObject | Where-Object { $_ -match '\S' } | Select-Object -First 5) -join "`r`n"
        }
    }
#>
    }
}