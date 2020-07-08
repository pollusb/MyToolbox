Function Hostname {
    # Replacement to hostname.exe pour retourner le FQDN
    Invoke-Expression "(Get-WmiObject win32_computersystem).DNSHostName.ToUpper()+'.'+(Get-WmiObject win32_computersystem).Domain.ToLower()" # Version WMI
}