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
    [string]$Server = "192.200.9.223",
    [string]$ComputerName = "localhost",
)

function main {
    $InstallDir = "reportes"
    $User_Documents = "C:\users\$UserName\Documents\"
    $User_Desktop = "C:\users\$UserName\Desktop\"

    $url="\\$Server\Users\monitoreo\Documents\COMPARTIDO\DATAMART\"    
}


function Create-Folder {
    param (
        [string]$Folder,
        [string]$Path
    )
    if ( -Not (Test-Path -Path $Path -ErrorAction SilentlyContinue)) {
        New-Item -Path $Path -ItemType Directory -Name $Folder -Force
    }
    Get-Item -Path "$Path\$Folder"
    return "$Path\$Folder"
}



# # Copia DATAMART en la Carpeta Documentos del usuario

function Download {
    param (
        [string]$From,
        [string]$To
    )
    Robocopy.exe $From $to * /b /s
}


# Reg

function Windows-Register {
    param (
        [string]$Dir = $Folder
    )
    $RegKeyDatamart ="HKCU:\Software\VB and VBA Program Settings\$Dir\Variables Globales"

    if (-Not (Test-Path -Path $RegKeyDatamart -ErrorAction SilentlyContinue)){ New-Item -Path $RegKeyDatamart -Force}

    $property = Get-ItemProperty -Path $RegKeyDatamart -Name "empresa_ubicacion" -ErrorAction SilentlyContinue

    if ( -Not $property){
        New-ItemProperty -Path $RegKeyDatamart -Name "empresa_ubicacion" -Value "C:\Users\$UserName\Documents\$Folder\" -Force
    } else {
        Set-ItemProperty -Path $RegKeyDatamart -Name "empresa_ubicacion" -Value "C:\Users\$UserName\Documents\$Folder\" -Force
    }

    $property = Get-ItemProperty -Path $RegKeyDatamart -Name "db_archivo" -ErrorAction SilentlyContinue
    if ( -Not $property){
        New-ItemProperty -Path $RegKeyDatamart -Name "db_archivo" -Value "rgn_BI-DM.dsn" -Force
    } else {
        Set-ItemProperty -Path $RegKeyDatamart -Name "db_archivo" -Value "rgn_BI-DM.dsn" -Force
    }

    Get-ItemProperty -Path $RegKeyDatamart | Format-List -Property *
}

function Make-SymLink {
    param (
        [string]$Destination
    )
    Remove-Item -Path "$Destination\DATAMART Menu" -Force -ErrorAction SilentlyContinue

    if (-Not (Get-Item -Path "$Destination\DATAMART Menu" -ErrorAction SilentlyContinue)){
        New-Item -ItemType SymbolicLink -Path $Destination -Name "DATAMART Menu" -Value "$path\menu.xlsm" -Force
    } else {
        Write-Host "Acceso Directo ya existe"
    }
}

