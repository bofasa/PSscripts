# Silent Install tightvnc 

# Path for the workdir
Param(
    [Parameter(Mandatory=$true)]
    [string]$Server = "https://www.tightvnc.com",
    [string]$Version = "2.8.11",
    [Parameter(Mandatory=$true)]
    [string]$Password
)
function main {
    $Destination = "c:\installer"
    $Source = Detect-File-Arch -Version $Version -Server $Server

    if (Get-Service -Name "vncserver")
    {
        Stop-Service -Name vncserver -Force -PassThru
        Set-Service -Name vncserver -StartupType Disabled -PassThru
        Start-Sleep 2
    }

    Test-WorkDir -Workdir $Destination
    Download-VNC -Destination $Destination -Source $Source.destination -File $Source.file
    Install-VNC -Destination $Destination -File $Source.file -Password $Password
}

function Detect-File-Arch{
    param (
        [string]$Version,
        [string]$Server
    )
    [hashtable]$return = @{}

    $Architecture = $env:PROCESSOR_ARCHITECTURE
    if ($Architecture -eq "AMD64"){$os = "64bit"} else {$os = "32bit"}
    if ($Server -match "https") {
        $source = "$Server/download/$Version/$file"
    } else {
        $return.destination = "\\$Server\Instaladores\vnc\releases\download\"
        $return.file = "tightvnc-$Version-gpl-setup-$os.msi"
        #$source = "\\$Server\Instaladores\vnc\releases\download\$Version\$file"
        return $return
    }
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
        [string]$Destination,
        [string]$File
    )
    Robocopy.exe $Source $Destination $File /b /s /w:0 /r:0
}

# Start the installation

function Install-VNC {
    param(
        [string]$Destination,
        [string]$File,
        [string]$Password
    )
    Write-Host "/i $Destination\$File /quiet /norestart ADDLOCAL=Server SERVER_REGISTER_AS_SERVICE=1 SERVER_ADD_FIREWALL_EXCEPTION=1 SERVER_ALLOW_SAS=1 SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=$Password"
    Start-Process -FilePath msiexec.exe -ArgumentList "/i $Destination\$File /quiet /norestart ADDLOCAL=Server SERVER_REGISTER_AS_SERVICE=1 SERVER_ADD_FIREWALL_EXCEPTION=1 SERVER_ALLOW_SAS=1 SET_USEVNCAUTHENTICATION=1 VALUE_OF_USEVNCAUTHENTICATION=1 SET_PASSWORD=1 VALUE_OF_PASSWORD=$Password" -PassThru
    # Wait XX Seconds for the installation to finish
    Start-Sleep -s 60
    # Remove the installer
    #Remove-Item -Force "$Destination\$File"
    Remove-Item -Force $Destination -Recurse

    Stop-Service -Name tvnserver
    Start-Service -Name tvnserver
}

main