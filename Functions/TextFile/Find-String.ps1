Function Find-String {
    # High performance string finder
    Param (
        $InputFile,
        $Pattern
    )
    begin {
        $in = New-Object System.IO.StreamReader ($InputFile)
        try {
            while (!$in.EndOfStream) {
                $Line = $in.ReadLine()
                if ($Line -match $Pattern)
                { $return += $Line }
            }
        }
        finally {
            $in.Close() 
        }
        return ($return)
    }
}