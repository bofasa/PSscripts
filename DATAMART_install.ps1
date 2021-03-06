# PSScriptInfo
# .VERSION 1.3
# .GUID 23743bae-7604-459d-82c5-a23d36b0820e
# .AUTHOR
#     Manuel B. Pons <manuelb@grupobodegas.com.gt>
# .COPYRIGHT
#     Manuel B. Pons 2019
# .TAGS
#     PowerShell,DATAMART
# .RELEASENOTES
#     Version 1.3: 2019-04-24
#         Initial script created
# .DESCRIPTION
# Instala la aplicacion DATAMART en la maquina del usuario
# Copia la carpeta DATAMART a C:\users\%USERNAME%\Documents\reportes
# y tambien genera la llave en el registro de windows para su uso.

# Parameter help description
Param(
    [Parameter(Mandatory=$true)]
    [string]$UserName=$env:USERNAME,
    [Parameter(Mandatory=$true)]
    [string]$Server,
    [string]$ComputerName = "localhost"
)

function main {
    $InstallDir = "reportes"
    $User_Documents = "C:\users\$UserName\Documents\"
    $User_Desktop = "C:\users\$UserName\Desktop\"

    $url="\\$Server\Users\monitoreo\Documents\COMPARTIDO\DATAMART\"

    Create-Folder -Folder $InstallDir -Path $User_Documents
    Download -From $url -To "$User_Documents\$InstallDir"
    Windows-Register -Folder $InstallDir -UserName $UserName
    Make-SymLink -Destination $User_Desktop -Source "$User_Documents\$InstallDir"
}


function Create-Folder {
    param (
        [string]$Folder,
        [string]$Path
    )
    Write-Host "Creando Folder" -ForegroundColor DarkYellow
    if ( -Not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
        New-Item -Path $Path -ItemType Directory -Name $Folder -Force
    }
    Get-Item -Path "$Path\$Folder"
}

# Copia DATAMART en la Carpeta Documentos del usuario

function Download {
    param (
        [string]$From,
        [string]$To
    )
    Robocopy.exe $From $to * /b /s /w:0 /r:0
}

# Reg

function Windows-Register {
    param (
        [string]$Folder,
        [string]$UserName
    )
    $RegKeyDatamart ="HKCU:\Software\VB and VBA Program Settings\$Folder\Variables Globales"
    $Value = "C:\Users\$UserName\Documents\$Folder\"

    if (-Not (Test-Path -Path $RegKeyDatamart -ErrorAction SilentlyContinue)){ New-Item -Path $RegKeyDatamart -Force}

    $property = Get-ItemProperty -Path $RegKeyDatamart -Name "empresa_ubicacion" -ErrorAction SilentlyContinue

    if ( -Not $property){
        New-ItemProperty -Path $RegKeyDatamart -Name "empresa_ubicacion" -Value $Value -Force
    } else {
        Set-ItemProperty -Path $RegKeyDatamart -Name "empresa_ubicacion" -Value $Value -Force
    }

    $property = Get-ItemProperty -Path $RegKeyDatamart -Name "db_archivo" -ErrorAction SilentlyContinue
    if ( -Not $property){
        New-ItemProperty -Path $RegKeyDatamart -Name "db_archivo" -Value "rgn_BI-DM.dsn" -Force
    } else {
        Set-ItemProperty -Path $RegKeyDatamart -Name "db_archivo" -Value "rgn_BI-DM.dsn" -Force
    }

    Write-Host ""
    Get-ItemProperty -Path $RegKeyDatamart | Format-List -Property *
}

function Make-SymLink {
    param (
        [string]$Destination,
        [string]$Source
    )
    Remove-Item -Path "$Destination\DATAMART Menu" -Force -ErrorAction SilentlyContinue
    New-Item -ItemType SymbolicLink -Path $Destination -Name "DATAMART Menu" -Value "$Source\menu.xlsm" -Force
}

main