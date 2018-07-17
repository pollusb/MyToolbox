Function SearchReplaceTextFileDotNet {
    #TODO:Make sure we can pass filename like .\Myfile.txt. It returns an error right now.
    Param (
        $InputFile,
        $OutputFile,
        $Pattern,
        $With,
        $Skip = 0 # number of lines to skip
    )
    begin {
        $in = New-Object System.IO.StreamReader ($InputFile)
        $out = New-Object System.IO.StreamWriter ($OutputFile)
        try {
            # skip the first N lines
            for ($s = 1; $s -le $skip; $s++) { $Line = $in.ReadLine() }
            while (!$in.EndOfStream) {
                $Line = $in.ReadLine()
                if ($Pattern) { $Line = $Line -replace $Pattern, $With }
                $out.WriteLine($Line)
            }
        }
        finally {
            $out.Close()
            $in.Close()
        }
    }
}