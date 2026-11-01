function Rename-PdfScript ($path, $profil) {
    
    #region private

    function mois ($mmm) {
        switch ($mmm) {
            'Jan' { '01'; break }
            'Feb' { '02'; break }
            'Mar' { '03'; break }
            'Apr' { '04'; break }
            'May' { '05'; break }
            'Jun' { '06'; break }
            'Jul' { '07'; break }
            'Aug' { '08'; break }
            'Sep' { '09'; break }
            'Oct' { '10'; break }
            'Nov' { '11'; break }
            'Dec' { '12'; break }
            defaut { throw 'oups!' }
        }
    }

    #endregion

    # pour MBNA
    switch ($profil) {
        'MBNA-pdf' {
            foreach ($f in (Get-ChildItem $path)) {
                $text = $f | Get-PdfPageText -NoEmptyLine -Trim
                $m = $text | Select-String 'Période du relevé : \d\d\/\d\d\/\d\d \w \d\d\/(\d\d)\/(\d\d)'
                $mm = $m.Matches.Groups[1].Value
                $yyyy = [int16]$m.Matches.Groups[2].Value + 2000
                $cmpt = '0169'
                'Rename-Object "{3}" {0}{1}-{2}-MBNA.pdf' -f $yyyy, $mm, $cmpt, $f.FullName
            }
        }
        'MBNA-csv' {
            foreach ($f in (Get-ChildItem $path)) {
                # pas besoin de lire le contenu
                $m = $f.BaseName | Select-String '(\w+)(\d{4})_(\w+)'
                'REN "{0}" {1}{2}-{3}-MBNA' -f $f.FullName, $m.Matches.Groups[2].Value, (mois $m.Matches.Groups[1].Value), $m.Matches.Groups[3].Value
            }
        }
    }
}