Function Get-NbLines {
    #Retourne le nombre de lignes
    Param (
        $Path
    )
    begin {
        $in = New-Object System.IO.StreamReader ($Path)
        $Nb = 0
        try {
            while (!$in.EndOfStream) {
                $Nb++
                $in.ReadLine()
            }
        }
        finally {
            $in.Close()
        }
        return($Nb)
    }
}