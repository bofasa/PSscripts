#$username = "gbodegas\Administrator"
#$password = ConvertTo-SecureString “Cruzv3rd3” -AsPlainText -Force
#$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$IPbase="192.168."

$Source="C:\Instaladores\"

181..252 | ForEach-Object {
    $IP = $IPbase+"$_"+".2"
    $IP
    if(Test-Connection -Cn $IP -BufferSize 16 -Count 1 -ea 0 -quiet) {
        #Start-BitsTransfer \\192.200.9.54\Instaladores\SAP_HANA_CLIENT_W32.7z \\$IP\"Utilitarios 2018"\ -Credential $cred 
        #Start-BitsTransfer \\192.200.9.54\Instaladores\SAP_HANA_CLIENT_W32.7z \\$IP\Utilitarios -Credential $cred
        $Path = Test-Path -Path \\$IP\"Utilitarios 2018"
        $Path2 = Test-Path -Path \\$IP\"Utilitarios"
        if ($Path) {
            Write-Host "Utilitarios 2018"
            Copy-Item -Path $Source\SAP_HANA_CLIENT_W32 \\$IP\"Utilitarios 2018"\SAP_HANA_CLIENT_W32 -Recurse -Force
        }
        if ($Path2) {
            Write-Host "Utilitarios"
            Copy-Item -Path $Source\SAP_HANA_CLIENT_W32 \\$IP\Utilitarios\SAP_HANA_CLIENT_W32 -Recurse -Force
        }
    } else {
        Write-Host "Cannot be reached"
    }
}
 