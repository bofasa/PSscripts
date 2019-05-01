# Silent Install Firefox 
# Download URL: https://www.mozilla.org/en-US/firefox/all/

# Path for the workdir

Param(
    [Parameter(Mandatory=$true)]
    [string]$Server = "https://download.mozilla.org"
)
function main {
    $workdir = "c:\installer\"
    $destination = "$workdir\firefox_install.exe"
    $source = Detect-File-Arch -Server $Server
    Test-WorkDir -Workdir $workdir
    Download-Firefox -Destination $destination -Source $source
    Install-Firefox -Workdir $workdir -Path $destination
}

function Detect-File-Arch{
    param (
        [string]$Server
    )
    $Architecture = $env:PROCESSOR_ARCHITECTURE
    if ($Architecture -eq "AMD64"){$os = "win64"} else {$os = "win"}
    return ("$Server/?product=firefox-latest-ssl&os=$os&lang=es-MX")
}

function Test-WorkDir {
    param(
        [string]$Workdir
    )
    # Check if work directory exists if not create it
    
    If (Test-Path -Path $workdir -PathType Container)
    {
        Write-Host "$workdir already exists" -ForegroundColor Red
    } else {
        New-Item -Path $workdir  -ItemType directory
    }    
}

# Download the installer
function Download-Firefox {
    param(
        [string]$Destination,
        [string]$Source
    )
    # Check if Invoke-Webrequest exists otherwise execute WebClient   
    if (Get-Command 'Invoke-Webrequest')
    {
        Invoke-WebRequest $source -OutFile $destination
    } else {
        $WebClient = New-Object System.Net.WebClient
        $webclient.DownloadFile($source, $destination)
    }    
}

# Start the installation

function Install-Firefox {
    param(
        [string]$Workdir,
        [string]$Path
    )
    Start-Process -FilePath $Path -ArgumentList "/S"
    # Wait XX Seconds for the installation to finish
    Start-Sleep -s 60
    # Remove the installer
    Remove-Item -Force $workdir\firefox*    
}

main