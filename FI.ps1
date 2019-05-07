# PSScriptInfo
# .VERSION 1.0
# .AUTHOR
#     Manuel B. Pons <manuelbpons@gmail.com>
# .COPYRIGHT
#     Manuel B. Pons 2019
# .TAGS
#     PowerShell,FusionInventory
# .RELEASENOTES
#     Version 1.0: 2019-09-27
#         Initial script created
# .DESCRIPTION
# The script will install and/or upgrade FusionInventory-Agent 
# the 'version' on the host. The current versions can be set as the target
# 'version':
#     - 2.4.2
#     - 2.4.3
#     - 2.5.0 (default if -Version not set)
#
# This script can be run on the following OS'
#     Windows Server 2008 (with SP2)
#     Windows Server 2008 R2 (with SP1)
#     Windows Server 2012
#     Windows Server 2012 R2
#     Windows Server 2016
# 
#     Windows 7 (with SP1)
#     Windows 8.1
#     Windows 10
# 
# All OS' can be upgraded to 2.5 
#
# .PARAMETER version
#     [string] - The target powershell version to upgrade to. This can be;
#         3.0,
#         4.0, or
#         5.1 (default)
#     Depending on the circumstances, the process to reach the target version
#     may require multiple reboots.
# .PARAMETER Verbose
#     [switch] - Whether to display Verbose logs on the console

# Variable Section
# Check SystemType to download the specific installer
# Put Server name where the Service needs to be conected

Param(
    [string]$Version = "2.5",
    [switch]$verbose = $false
)

$architecture = $env:PROCESSOR_ARCHITECTURE
if ($architecture -eq "AMD64") {$os = "x64"} else {$os = "x86"}
$Service = "fusioninventory-agent"
$Installer = $Service+"_windows-"+$os+"_"+$Version+".exe"
$Server = "http://glpibf.gbodegas.interno/plugins/fusioninventory/"
$Arguments = "/S /acceptlicense /add-firewall-exception /server='$Server' /installtasks=Full /no-start-menu /execmode=Service /installtype=from-scratch"
$Location = "\\192.200.8.7\Instaladores\Agents\Fusion-agent\releases\download\"+$Version+"\"
$username = "gbodegas\Administrator"
$password = ConvertTo-SecureString "Cruzv3rd3" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$Perl = "C:\Program Files\FusionInventory-Agent\perl\bin\"

Import-Module BitsTransfer
#Get-Command -Module BitsTransfer

$tmp_dir = $env:temp
if (-not (Test-Path -Path $tmp_dir)) {
    New-Item -Path $tmp_dir -ItemType Directory -Credential $cred > $null
}

$Build = "$tmp_dir\$Installer"

$ErrorActionPreference = 'Stop'
if ($verbose) {
    $VerbosePreference = "Continue"
}

Function Download-File($url, $path) {
    Write-Log -message "downloading url '$url' to '$path'"
	$client = New-Object -TypeName System.Net.WebClient
	$client.Headers.Add("UserAgent","Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.2 (KHTML, like Gecko) Chrome/22.0.1229.94 Safari/535.2")
	$client.Credentials = Get-Credential $cred
    $client.DownloadFile($url, $path)
}

Function Write-Log($message, $level="INFO") {
    # Poor man's implementation of Log4Net
    $date_stamp = Get-Date -Format s
    $log_entry = "$date_stamp - $level - $message"
    $log_file = "$tmp_dir\FusionInventory-install-upgrade.log"
    Write-Verbose -Message $log_entry
    Add-Content -Path $log_file -Value $log_entry
}

function Install {

	Write-Host("---- Downloading...")
	$file = "$tmp_dir\$Installer"
	$url = "$Location\$Installer"
    Download-File -url $url -path $file
	# robocopy $Location $tmp_dir $Installer /b /w:0 /r:0
	# Start-BitsTransfer -Source $Location\$Installer -Destination $Build -Credential $cred -TransferType Download 
	# Copy-Item -Path $Location$Installer -Destination $tmp_dir -Force -PassThru
	Start-Sleep -Seconds 2
	Write-Host("---- Installing...")
	#Push-Location $Perl
	Start-Process -Wait -PassThru -FilePath $Build -ArgumentList $Arguments
	Pop-Location
	Start-Sleep -Seconds 2
	Write-Host("---- Removing Installer File...")
	Remove-Item $Build -Force 

}

function Versioning {
	Push-Location $Perl

	Invoke-Expression 'cmd /C perl.exe fusioninventory-agent --version > version.txt'
	$Ver = (((Get-Content .\version.txt | Select-String -Pattern "Agent") -split (" "))[2]).replace("(","").replace(")","")
	if ($Ver -ge $Version) {return "True"} else {return "False"}

	Pop-Location
}

$logFileExists = Get-EventLog -list | Where-Object {$_.logdisplayname -eq "FusionInventory-Agent"}
if (! $logFileExists){
	New-EventLog -Source "FusionInventory-Agent" -LogName Application -MessageResourceFile $Installer -CategoryResourceFile $Installer -ErrorAction SilentlyContinue
} 

# Check is Service exist or not so the Services needs to be installed

Write-EventLog -LogName "Application" -Source "FusionInventory-Agent" -EventID 3001 -EntryType Information -Message "This script is going to check if the Service is installed, outdated and running" -Category 1 -RawData 10,20

Start-Sleep -Seconds 2

Write-Host("Fusioninventory Service Checking...")

if ( -Not (Get-Service -Name $Service -ErrorAction SilentlyContinue)){
	Write-EventLog -LogName "Application" -Source "FusionInventory-Agent" -EventID 3002 -EntryType Warning -Message "Service is not installed in this machine, is going install Fusion Inventory$ Ver silently." -Category 1 -RawData 10,20
	Start-Sleep -Seconds 2
	Write-Host("-- Service Do not exist, Please Wait...")
	Start-Sleep -Seconds 3
	Write-Host("-- Fixing...")
	Start-Sleep -Seconds 2
	Install
	Start-Sleep -Seconds 2
	Write-Host("---- Starting Service...")
	Start-Service -Name $Service
	Start-Sleep -Seconds 2
	Write-Host("-- Done")
} else {
	Write-EventLog -LogName "Application" -Source "FusionInventory-Agent" -EventID 3001 -EntryType Information -Message "The Service is already installed, Checking Version and if is running." -Category 1 -RawData 10,20
	Start-Sleep -Seconds 2
	$Versioning = Versioning
	if ($Versioning -eq "False") {
		Write-Host ("This machine has an old version of Fusion Inventory $Ver, installing new version $Version")
		Write-EventLog -LogName "Application" -Source "FusionInventory-Agent" -EventID 3001 -EntryType Information -Message "This machine has an old version of Fusion Inventory $Ver, installing new version $Version" -Category 1 -RawData 10,20
		Write-Host("-- Upgrading...")
		Install
	} else {
		Write-EventLog -LogName "Application" -Source "FusionInventory-Agent" -EventID 3001 -EntryType Information -Message "This machine is already updated" -Category 1 -RawData 10,20
		Write-Host("-- Is already Updated...")
	}
	# Check if the service is Removing and if not it starts the Service
	If ((Get-Service -Name FusionInventory-Agent).Status -ne 'Running'){
		Write-EventLog -LogName "Application" -Source "FusionInventory-Agent" -EventID 3002 -EntryType Warning -Message "Service is not running, Service is going to be restarted." -Category 1 -RawData 10,20
		Start-Sleep -Seconds 2
		Write-Host("-- Service is not Running, Fixing")
		Start-Sleep -Seconds 1
		Stop-Service -Name $Service
		Start-Service -Name $Service
	} else {
		Write-Host("-- Service is currently running")
		Write-EventLog -LogName "Application" -Source "FusionInventory-Agent" -EventID 3001 -EntryType Information -Message "Service is now running." -Category 1 -RawData 10,20
		Start-Sleep -Seconds 2
	}
}
Write-Host("All is OK now")

Write-EventLog -LogName "Application" -Source "FusionInventory-Agent" -EventID 3001 -EntryType Information -Message "FusionInventory-Agent was installed." -Category 1 -RawData 10,20

Start-Sleep -Seconds 2

Pop-Location