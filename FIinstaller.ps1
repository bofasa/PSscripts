$Computers = Get-ADComputer -Filter * -Properties * | Where-Object {$_.IPv4Address -ne $null}

$cred = D:\Powershell_Scripts\Credentials.ps1
$Path = ".\FI.ps1"

$Total = $Computers.Count

$Total = $Computers.Count
$Num = 0
$DateStart = Get-Date
 
0..($Computers.Count + 1)| ForEach-Object {
    $IP = $Computers[$_].Name
    if ($IP -ne $Null){
        $Num += 1
        $Date = Get-Date -UFormat "%m-%d-%Y %H:%M:%S"
        if((Test-Connection -ComputerName $IP -BufferSize 16 -Count 1 -ErrorVariable 0 -Quiet)) {
            Write-Host "$Num of $Total - $Date -  Entering $IP  " -NoNewline
            #Invoke-Command -ComputerName $IP -ScriptBlock {Invoke-Expression -Command 'Remove-PSDrive -Name "J"' -ErrorAction SilentlyContinue} -Credential $cred -ErrorAction SilentlyContinue
            #Invoke-Command -ComputerName $IP -ScriptBlock {Invoke-Expression -Command 'net use j: /delete' -ErrorAction SilentlyContinue} -Credential $cred -ErrorAction SilentlyContinue
            Invoke-Command -ComputerName $IP -FilePath $Path -Credential $cred
            #Invoke-Command -ComputerName $IP -ScriptBlock {Invoke-Expression -Command 'net use j: /delete' -ErrorAction SilentlyContinue} -Credential $cred -ErrorAction SilentlyContinue
            #Invoke-Command -ComputerName $IP -ScriptBlock {Invoke-Expression -Command 'net use j: /delete' -ErrorAction SilentlyContinue} -Credential $cred -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 10 -Verbose
        }
    }
}

$DateStop = Get-Date
$TotalTime = $DateStop - $DateStart
Write-Host "Total Time $TotalTime"