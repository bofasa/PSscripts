# Silent Install Firefox 
# Download URL: https://www.mozilla.org/en-US/firefox/all/

# Path for the workdir

Param(
    [Parameter(Mandatory=$true)]
    [string]$Server = "https://download.mozilla.org",
    [string]$Version = "67.0.3"
)
function main {
    $Destination = "c:\installer\"
    $Source = Detect-File-Arch -Server $Server -Version $Version
    
    Test-WorkDir -Workdir $Destination
    Download-Firefox -Destination $Destination -Source $Source.destination -File $Source.file
    Install-Firefox -Destination $Destination -File $Source.file
}

function Detect-File-Arch{
    param (
        [string]$Server,
        [string]$Version
    )
    [hashtable]$return = @{}
    $Architecture = $env:PROCESSOR_ARCHITECTURE
    if ($Architecture -eq "AMD64"){$os = "win64"} else {$os = "win"}
    if ($Server -match "https") {
        return ("$Server/?product=firefox-latest-ssl&os=$os&lang=es-MX")
    } else {
        Write-Host "\\$Server\Instaladores\firefox\releases\download\$Version\Firefox_Setup_$os.exe"
        $return.destination = "\\$Server\Instaladores\firefox\releases\download\$Version\"
        $return.file = "Firefox_Setup_$os.exe"
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
function Download-Firefox {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$File
    )
        Robocopy.exe $Source $Destination $File /b /s /w:0 /r:0 /MT:12
        #Start-BitsTransfer -Source $Source -Destination "$Destination/$File"
}

# Start the installation

function Install-Firefox {
    param(
        [string]$Destination,
        [string]$File
    )
    Start-Process -FilePath "$Destination\$File" -ArgumentList "-ms -ma" -PassThru -Wait -NoNewWindow

    # Wait XX Seconds for the installation to finish
    Start-Sleep -s 60
    # Remove the installer
    #Remove-Item -Force "$Destination\$File"
    Remove-Item -Force $Destination -Recurse
}

main