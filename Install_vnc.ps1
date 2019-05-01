# Silent Install tightvnc 

# Path for the workdir
Param(
    [Parameter(Mandatory=$true)]
    [string]$Server = "https://www.tightvnc.com/",
    [string]$Version = "2.8.11"
)
function main {
    $workdir = "c:\installer\"
    $file = Detect-File-Arch -Version $Version
    $destination = "$workdir\$file"
    #$source = "\\$Server\Agents\vnc\releases\download\2.8.11\$file"
    $source = "$Server/download/$Version/$file"
    Test-WorkDir -Workdir $workdir
    Download-VNC -Destination $destination -Source $source 
    Install-VNC -Workdir $workdir -Path $destination -File $file
}

function Detect-File-Arch{
    param (
        [string]$Version
    )
    $Architecture = $env:PROCESSOR_ARCHITECTURE
    if ($Architecture -eq "AMD64"){$os = "64bit"} else {$os = "32bit"}
    return ("tightvnc-$Version-gpl-setup-$os.msi")
}

function Test-WorkDir {
    param(
        [string]$Workdir
    )
    # Check if work directory exists if not create it
    If (Test-Path -Path $Workdir -PathType Container)
    {
        Write-Host "$Workdir already exists" -ForegroundColor Red
    } else {
        New-Item -Path $Workdir  -ItemType directory
    }    
}

# Download the installer
function Download-VNC {
    param(
        [string]$Source,
        [string]$Destination
    )
    # Check if Invoke-Webrequest exists otherwise execute WebClient
    if (Get-Command 'Invoke-Webrequest')
    {
        Invoke-WebRequest $Source -OutFile $Destination
    } else {
        $WebClient = New-Object System.Net.WebClient
        $webclient.DownloadFile($Source, $Destination)
    }    
}

# Start the installation

function Install-VNC {
    param(
        [string]$Workdir,
        [string]$Path,
        [string]$File
    )
    Start-Process -FilePath msiexec.exe -ArgumentList "/I $Path /quiet /norestart ADDLOCAL='Server'"
    # Wait XX Seconds for the installation to finish
    Start-Sleep -s 60
    # Remove the installer
    Remove-Item -Force "$Workdir\$File"
}

main