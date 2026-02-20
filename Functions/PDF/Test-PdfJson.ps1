<#
.SYNOPSIS
    Valide que les calculs sont bon
#>
function Test-PdfJson {
    [CmdLetBinding()]
    param (
        $Path,
        [switch]$Preview,
        [switch]$Force
    )
    function ValidateData ($data) {

        #region Institution

        Write-Verbose "ValidateData..."
        if ($data.Institution.Split(' ').Count -gt 1) {
            Write-Log "> Institution more than 1 word : $($data.Institution)"
        }
        if ($data.Period -notmatch $data.EndDate.Substring(0,6)) {
            Write-Log "> Period $($data.Period) does not match EndDate YYYY-MM $($data.EndDate.Substring(0,6))"
        }
        if ($data.StartDate -gt $data.EndDate) {
            Write-Log "> StatDate $($data.StartDate) is greater than EndDate $($data.EndDate)"
        }

        #endregion

        #region Accounts & Operations

        $start = $data.StartDate
        $end = $data.EndDate
        foreach ($account in $data.Accounts) {
            # Date1 must be inside of start and end date
            if ($account.Operations | Where-Object Date1 -gt $end -or Date1 -lt $start) {
                Write-Log ('> Date1 ({0}) on LineNo {1} is out of bound' -f $account.Date1 ,$account.LineNo)
            }
            # TotalAmout = sum(Amount)
            if (($account.Operations | Measure-Object -Sum Amount).Sum -eq $data.Total) {
                Write-Log ('> Date1 ({0}) on LineNo {1} is out of bound' -f $account.Date1 ,$account.LineNo)
            }
            # TotalRemittance = sum(Remittance)
            #
        }

        #endregion

        return $data
    }
}