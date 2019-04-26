# $Computer = Get-ADComputer -Filter * -Properties * | Where-Object {$Null -ne $_.IPv4Address}
$Computer = Get-ADComputer -Filter * -Properties *

$cred = D:\Powershell_Scripts\Credentials.ps1

$Total = $Computer.Count
$Num = 0
$DateStart = Get-Date
0..$Computer.Count | ForEach-Object {
    # Variables de busqueda
    $Software = "Spiceworks Agent"
    $Service = "SpiceworksAgent"
    # Get IP from AD Computer List
    $IP = $Computer[$_].Name
    if ($Null -ne $IP){
        $Num += 1
        $Date = Get-Date -UFormat "%m-%d-%Y %H:%M:%S"
        # Test Connection to Computer
        if((Test-Connection -ComputerName $IP -BufferSize 16 -Count 1 -ErrorVariable 0 -Quiet)) {
            Write-Host "$Num of $Total - $Date - Entering $IP  " -NoNewline
            # Test if service exists
            $Service = Invoke-Command -ComputerName $IP -Credential $cred -ScriptBlock {
                param($RService)
                Get-Service -Name $RService
            } -ArgumentList $Service -ErrorAction SilentlyContinue
            # If service exits, uninstall software
            if ($Service) {
                "Uninstalling $Software, will take time"
                Invoke-Command -ComputerName $IP -Credential $cred -ScriptBlock {
                    param($RSoftware)
                    (Get-WmiObject Win32_Product | Where-Object { $_.name -eq $RSoftware }).Uninstall()
                } -ArgumentList $Software
            } else { "Just Passing by"}
        } else { "No connection to $IP"}
    } else {"$IP has no IP"}
}
$DateStop = Get-Date
$TotalTime = $DateStop - $DateStart
Write-Host "Total Time $TotalTime"