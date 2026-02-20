# Supprimer tous les fichiers récents Windows avec confirmation
function Remove-MRU {
    try {
        # Récupère le chemin du dossier "Recent" de l'utilisateur
        $recentPath = Join-Path $env:APPDATA "Microsoft\Windows\Recent"

        if (Test-Path $recentPath) {
            # Liste les fichiers trouvés
            $files = Get-ChildItem -Path $recentPath -Force -ErrorAction Stop

            if ($files.Count -gt 0) {
                Write-Host "Suppression de $($files.Count) fichiers récents..." -ForegroundColor Yellow

                # Supprime les fichiers
                Remove-Item -Path $recentPath\* -Force -ErrorAction Stop

                Write-Host "✅ Liste des fichiers récents vidée avec succès." -ForegroundColor Green
            }
            else {
                Write-Host "Aucun fichier récent trouvé." -ForegroundColor Cyan
            }
        }
        else {
            Write-Host "Le dossier des fichiers récents n'existe pas." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Erreur lors de la suppression : $($_.Exception.Message)" -ForegroundColor Red
    }
}