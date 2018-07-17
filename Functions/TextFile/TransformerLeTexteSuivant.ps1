Function TransformerLeTexteSuivant {
    <#
    Transforme le texte suivant:

    CCQSQL045048	USE [CitrixXA7PREPMonitoring];ALTER TABLE [MonitorData].[ResourceUtilization] WITH CHECK CHECK CONSTRAINT [ResourceUtilization_DesktopGroup];
    CCQSQL045048	USE [CitrixXA7PREPMonitoring];ALTER TABLE [MonitorData].[SessionMetrics] WITH CHECK CHECK CONSTRAINT [SessionMetrics_Session];
    CCQSIR044163	USE [2.7.17278.1TestManuel1d8e877b-6e86-4f69-938b-4cc5dd874814];ALTER TABLE [dbo].[TestTemp_Transaction] WITH CHECK CHECK CONSTRAINT [FK__TestTemp___NoCli__03275C9C];
    CCQSIR044163	USE [2.7.17278.1TestManuel1d8e877b-6e86-4f69-938b-4cc5dd874814];ALTER TABLE [dbo].[TestTemp_Prestation] WITH CHECK CHECK CONSTRAINT [FK__TestTemp___NoCli__52842541];

    en

    :CONNECT CCQSQL045048
    USE [CitrixXA7PREPMonitoring];ALTER TABLE [MonitorData].[ResourceUtilization] WITH CHECK CHECK CONSTRAINT [ResourceUtilization_DesktopGroup];
    USE [CitrixXA7PREPMonitoring];ALTER TABLE [MonitorData].[SessionMetrics] WITH CHECK CHECK CONSTRAINT [SessionMetrics_Session];
    GO
    :CONNECT CCQSIR044163
    USE [2.7.17278.1TestManuel1d8e877b-6e86-4f69-938b-4cc5dd874814];ALTER TABLE [dbo].[TestTemp_Transaction] WITH CHECK CHECK CONSTRAINT [FK__TestTemp___NoCli__03275C9C];
    USE [2.7.17278.1TestManuel1d8e877b-6e86-4f69-938b-4cc5dd874814];ALTER TABLE [dbo].[TestTemp_Prestation] WITH CHECK CHECK CONSTRAINT [FK__TestTemp___NoCli__52842541];
    #>
    Param (
        $InputFile,
        $OutputFile
    )
    begin {
        $in = New-Object System.IO.StreamReader (Resolve-Path -Path $InputFile )
        $out = New-Object System.IO.StreamWriter (Resolve-Path -Path $OutputFile)
        try {
            while (!$in.EndOfStream) {
                $Line = $in.ReadLine()
                if ($Line -match '^[\w\d]+\s') {
                    if ($matches[0] -eq $LastMatch) {
                        $Line -replace '^[\w\d]+\s', ''
                        $out.WriteLine($Line)
                    }
                    else {
                        $LastMatch = $matches[0]
                        $out.WriteLine('GO')
                        $Line -replace '^[\w\d]+\s', ":CONNECT $LastMatch`r`n"
                    }
                }
            }
        }
        finally {
            $out.Close()
            $in.Close()
        }
    }
}