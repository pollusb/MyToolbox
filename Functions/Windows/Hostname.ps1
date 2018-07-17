Function Hostname {
    # Replacement to hostname.exe pour retourner le FQDN
    return Invoke-Expression "(Get-WmiObject win32_computersystem).DNSHostName.ToUpper()+'.'+(Get-WmiObject win32_computersystem).Domain" # Version WMI
}