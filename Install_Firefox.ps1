# Silent Install Firefox 
# Download URL: https://www.mozilla.org/en-US/firefox/all/

# Path for the workdir

function main {
    $workdir = "c:\installer\"
    $destination = "$workdir\firefox_install.exe"
    $source = Detect-File-Arch
    Test-WorkDir -Workdir $workdir
    Download-Firefox -OS $os -Destination $destination -Source $source
    Install-Firefox -Workdir $workdir -Path $destination

}

function Detect-File-Arch{
    $Architecture = $env:PROCESSOR_ARCHITECTURE 
    if ($Architecture -eq "AMD64"){
        return ("https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=es-MX")
    } else {
        return ("https://download.mozilla.org/?product=firefox-latest-ssl&os=win&lang=es-MX")
    }  
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
        [string]$OS,
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