function Get-PdfText {
    <#
    .SYNOPSIS
        A simple wrapper for PDFTOTEXT that does a little more
    .DESCRIPTION
        It can run for multiple PDF using a list of files or pattern
        It can extract text and return to standard output -PassThru
    #>
    [CmdLetBinding()]
    param (
        $Path,
        $Layout = 'layout',
        $ProgramPath = 'pdftotext.exe', # Should be avail in PATH
        [switch]$PassThru,
        [switch]$Force
    )
    # check Program location
    $v = & $ProgramPath -v *>&1 | Out-String
    Write-Verbose ($v -replace '\r\n',' ')

    $act = @{ Activity = 'Extracting text from PDF files' }
    [int]$i = 0

    $files = Get-ChildItem -Path $Path -Filter *.pdf
    foreach ($file in $files) {
        $textPath = '{0}\{1}.txt' -f $file.Directory, $file.BaseName
        if ($files.Count -gt 1) {
            Write-Progress @act -Status $file.Name -PercentComplete ($i++ * 100 / $files.Count)
        }
        <# vérification avant de remplacer les fichiers
        if (!$Force -and (Test-Path $textPath)) {
            do {
                $answer = Read-Host -Prompt ("Some text files are already present.`nOverwrite $textPath`n" +
                '[Y] Yes  [N] No  [A] Yes to All (same as -Force)')

                $proceed = switch ($answer) {
                    'Y' { $proceed = $true }
                    'N' { $proceed = $false }
                    'A' { $proceed = $true; $Force = $true }
                    default { $finished = $false }
                }
            } until ($finished)
        }
        #>
        $arg = @("-$Layout", '-enc', 'UTF-8', '-eol', 'dos', $file.FullName)
        Write-Verbose "$ProgramPath $($arg -join ' ')"
        & $ProgramPath $arg
        Get-ChildItem $textPath
    }
}