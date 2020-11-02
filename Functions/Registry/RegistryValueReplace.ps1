# https://stackoverflow.com/questions/26680410/powershell-find-and-replace-on-registry-values

# Replace all registry key values and/or registry key names under a given path.
# Example Usage:
#   RegistryValueReplace "ExistingValue" "NewValue" 'HKEY_CURRENT_USER\Software\100000_DummyData'
#   RegistryValueReplace "ExistingValue" "NewValue" 'HKEY_USERS\*\Software\100000_DummyData' -ReplaceKeyNames $true -CaseSensitive $true
#   RegistryValueReplace 'C:\\Program Files\\Microsoft SQL Server' 'E:\Program Files\Microsoft SQL Server' 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server*' -LoggingOn $true

function RegistryValueReplace {
    [CmdLetBinding()]
    param (
        [string]$OldValue = $(throw "OldValue (the current value) required."),
        [string]$NewValue = $(throw "NewValue (the replacement value) required."),
        [string]$RegkPath = $(throw "RegkPath (The full registry key path) required."),
        [bool] $CaseSensitive = $false,     # If true, search and replace is case sensitive
        [bool] $WholeWord = $false,         # If true, searches for whole word within the value.
        [bool] $ExactMatch = $false,        # If true, the entire value must match OldValue, and partial replacements are NOT performed
        [bool] $ReplaceKeyNames = $false,   # If true, replaces registry key names
        [bool] $ReplaceValues = $true,
        [bool] $LoggingOn = $false
    )
    $PowershellRegPrefix = 'Microsoft.PowerShell.Core\Registry::'
    $MatchFor = if ($WholeWord -eq $true) { ".*\b$OldValue\b.*" } else { ".*$OldValue.*" }
    if ($RegkPath -NotLike "$PowershellRegPrefix*") { $RegkPath = $PowershellRegPrefix + $RegkPath }

    @(Get-Item -ErrorAction SilentlyContinue -path  $RegkPath) +
    @(Get-ChildItem -Recurse $RegkPath -ErrorAction SilentlyContinue) |
    ForEach-Object {
        Get-ItemProperty -Path "$PowershellRegPrefix$_" |
        ForEach-Object {
            $CurrentShellFoldersPath = $_.PSPath
            #$SID = $CurrentShellFoldersPath.Split('\')[2]
            $_.PSObject.Properties |
            ForEach-Object {
                if ($_.Name -cne "PSChildName" -and (($ExactMatch -eq $true -and $_.Value -clike $OldValue) -or ($ExactMatch -eq $false -and
                            (($CaseSensitive -eq $false -and $_.Value -match $MatchFor) -or ($CaseSensitive -eq $true -and $_.Value -cmatch $MatchFor))))) {
                    $Original = $_.Value
                    $Create_NewValue = $_.Value
                    $SubKeyName = $_.Name
                    if ($CaseSensitive -eq $true) { $Create_NewValue = $Create_NewValue -creplace $OldValue, $NewValue }
                    else { $Create_NewValue = $Create_NewValue -replace $OldValue, $NewValue }
                    if ($_.Name -eq "PSPath" -and $_.Value -eq $CurrentShellFoldersPath) {
                        if ($ReplaceKeyNames -eq $true) {
                            Move-Item -Path $CurrentShellFoldersPath -Destination $Create_NewValue
                            Write-Verbose "Renamed registry key '$CurrentShellFoldersPath' to '$Create_NewValue'"
                        }
                        else {
                            Write-Verbose "....Skipping renaming key '$CurrentShellFoldersPath->$SubKeyName' due to input option!!!"
                        }
                    }
                    else {
                        if ($ReplaceValues -eq $true) {
                            Set-ItemProperty -Path $CurrentShellFoldersPath -Name $_.Name -Value $Create_NewValue
                            Write-Verbose "Renamed '$Original' to '$Create_NewValue' for registry key '$CurrentShellFoldersPath->$SubKeyName'"
                        }
                        else {
                            Write-Verbose "....Skipping renaming value '$CurrentShellFoldersPath->$SubKeyName' due to input option!!!"
                        }
                    }
                }
            }
        }
    }
}
