Function Invoke-SplitTextFile {
    Param (
        $InputFile,     # TODO:Obligatoire et le fichier doit exister
        $OutputFile1,	# TODO:Devrait être optionnel. Sinon, le fichier sera Fichier.1.ext
        $OutputFile2,	# TODO:Devrait être optionnel. Sinon, le fichier sera Fichier.2.ext
        $Split			# TODO:La position à couper le fichier. Sinon, il coupera en 2
    )
    begin {
        $in = New-Object System.IO.StreamReader ($InputFile)
        $out1 = New-Object System.IO.StreamWriter ($OutputFile1)
        $out2 = New-Object System.IO.StreamWriter ($OutputFile2)
        try {
            for ($s = 1; ($s -le $Split) -and (!$in.EndOfStream); $s++) {
                $Line = $in.ReadLine()
                $out1.WriteLine($Line)
            }
            while (!$in.EndOfStream) {
                $Line = $in.ReadLine()
                $out2.WriteLine($Line)
            }
        }
        finally {
            $out1.Close()
            $out2.Close()
            $in.Close()
        }
    }
}
