param(
    [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $files
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $urls
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $configs
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [switch] $pullorigin = $false
)

$env:RootPath = "%ALLUSERSPROFILE%"
$env:DefaultFavoritePath = "%ALLUSERSPROFILE%\\Desktop"
$env:DefaultShortcutPath = "%ALLUSERSPROFILE%\\Desktop"
$env:DefaultDownloadPath = "%PROGRAMDATA%\\UiPath\\Academy\\Downloads"
$env:DefaultPoliciesPath = "%PROGRAMDATA%\\UiPath\\Academy\\Policies"
$env:LGPO = "%PROGRAMDATA%\\UiPath\\Academy\\Downloads\\lgpo\\LGPO.exe"

Clear-Host
Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"
$path = "C:\ProgramData\UiPath\Academy"
$scripts = "C:\ProgramData\UiPath\Academy\Scripts"
#$repository = "https://github.com/jvavasseur/VmReconfig.git"

Write-Host "Import Modules"
$env:PSModulePath = ($env:PSModulePath.Split(";") + "$PSScriptRoot\Modules" | Select-Object -Unique ) -join ';'
Import-Module posh-git -Force
Import-Module VmReconfig -Force #-Verbose;

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
if ( $pullorigin ) {
    Write-Host "Git Pull Origin"
    & 'C:\Program Files\Git\bin\git.exe' -C $scripts pull origin
}

$env:DefaultDownloadPath, $env:DefaultPoliciesPath | New-FolderPath

#$files = "xC:\ProgramData\UiPath\Academy\office-studio.json", "y"

$config = [io.path]::ChangeExtension($PSCommandPath, 'json')

$files = if ( $files.Count -gt 0){, $config + $files } else {$config} 

$tab = ""
$fileid = 0
$files | Foreach-Object {
    $fileid++
    $filename = $PSItem

    Write-Host $("-" * 100)
    Write-Host "$($tab)Configuration File $fileid"
    Write-Host "$tab  File: $filename"

    $json = $null
    if ( Test-Path -Path $filename -PathType Leaf ) {
        Write-Host "$tab  Read File"
        $json = Get-Content $filename | ConvertFrom-Json
    } else { write-error "file not found: $filename"; return } 

#    write-host $("x" * 100)
    if ( ( $null = $json ) ) {
        $params = $json.Downloads
        if ( -not ( $null -eq $params )) { $params | Get-FileFromUrl }
        $params = $json.Execute 
        if ( -not ( $null -eq $params )) { $params | Start-ConfigCommand }
    } else { write-host "XXXXXXXXXXXXXXXXXXXXXXXXXX" }
}

