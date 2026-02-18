<#
.SYNOPSIS
    Outil d'extraction de data de relevés PDF via Google Gemini
.NOTES
    Il faut une clé API de Gemini. La façon la plus simple de l'obtenir est d'utiliser Google AI Studio https://aistudio.google.com/api-keys.
    Si aucun data n'est produit, il ne faut pas créer de fichier JSON
    Pour activer plus de verbose, il est possible de définir la variable $VerboseLevel = 2
#>
function Get-PdfJson {
    [CmdLetBinding()]
    param (
        [Parameter(Mandatory)]
        $Path,
        [ValidateSet('gemini-2-flash','gemini-3-flash-preview')]
        $Model = 'gemini-3-flash-preview'
    )
    if (!$GeminiApiKeyEncrypted) {
        throw "Il faut définir la variable GeminiApiKeyEncrypted. Je pourrais assiter pour créer le fichier xml et extraire dans le profile ?"
    }
    $VerboseActive = $PSBoundParameters['Verbose']

    #region fonctions privées

    function Get-ApiKey {
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($GeminiApiKeyEncrypted))
    }

    function AskGemini ($filePdf) {
        # Conversion du PDF en Base64 (Gemini accepte l'envoi direct en base64 pour les fichiers < 20MB)
        $fileBytes = [System.IO.File]::ReadAllBytes($filePdf)
        $fileBase64 = [Convert]::ToBase64String($fileBytes)

        $url = switch ($Model) {
            'gemini-3-flash-preview' { "https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=$(Get-ApiKey)"; break }
            'gemini-2-flash'         { "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$(Get-ApiKey)"; break }
        }

        $body = @{
            contents = @(
                @{
                    parts = @(
                        @{ text = Get-Content "$PSScriptRoot\Get-PdfJson.prompt.txt" -Raw
                        },
                        @{ inline_data = @{ mime_type = "application/pdf"; data = $fileBase64 } }
                    )
                }
            )
            generationConfig = @{ temperature = 0 }
        } | ConvertTo-Json -Depth 10

        #try {
            $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()
            $response = Invoke-RestMethod -Method Post -Uri $url -Headers @{"Content-Type" = "application/json" } -Body $body
            $stopWatch.Stop()

            if ($VerboseActive) {
                $response | Export-Clixml ($fileTemp = New-TemporaryFile)
                Write-Verbose "Response: `$a = Import-CliXml $fileTemp"
            }
            if ($data = $response.candidates[0].content.parts[0].text.Trim()) {
                return [PSCustomObject]@{
                    Data1      = $data
                    TokenCount = $response.usageMetadata.totalTokenCount
                    Model      = $response.modelVersion
                    Duration   = $stopWatch.Elapsed.ToString()
                }
            } else {
                throw "Gemini a retourné une réponse vide"
            }
        <#}
        catch {
            Write-Warning "Erreur dans le traitement de $filePdf"
            return "Erreur"
        }#>
    }

    function Write-Verbose2 ($Message) {
        if ($VerboseLevel -gt 1) { Write-Verbose $Message }
    }

    function ValidateData ($data) {
        # Vérifier les calculs

    }

    #endregion

    # --- Traitement ---
    $files = Get-ChildItem -Path $Path -Filter *.pdf -Recurse -File
    foreach ($file in $files) {
        Write-Verbose "Analyse de : $($file.Name)..."
        $resp = AskGemini $file.FullName

        Write-Verbose "`$resp.Data size = $($resp.Data1.Length)"
        Write-Verbose2 $resp.Data1

        # On converti du JSON en objet pour éventuellement le re-convertir en JSON ?
        $data = ($resp.Data1 -replace "``````json`r?`n" -replace "``````(`r?`n)*") | ConvertFrom-Json

        $obj = [PSCustomObject]@{
            Data = $data
            File = [PSCustomObject]@{
                Name          = $file.Name
                LastWriteTime = $file.LastWriteTime
                Length        = $file.Length
                SHA256        = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
            }
            Stat = [PSCustomObject]@{
                Module      = $MyInvocation.MyCommand.Module.Name
                Version     = $MyInvocation.MyCommand.Module.Version.ToString()
                ExtractTime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                Model       = $resp.Model
                TokenCount  = $resp.TokenCount
                Duration    = $resp.Duration
            }
        }
        $jsonPath = '{0}\{1}.json' -f $file.Directory, $file.BaseName
        $obj | ConvertTo-Json -Compress -Depth 10 | Out-File $jsonPath

        # Objet retourné
        return Get-ChildItem $jsonPath
    }
}
