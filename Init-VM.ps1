param(
    [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $files
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $urls
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $configs
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [bool] $pullorigin = $false
)

$env:RootPath = "%ALLUSERSPROFILE%"
$env:DefaultFavoritePath = "%ALLUSERSPROFILE%\\Desktop"
$env:DefaultShortcutPath = "%ALLUSERSPROFILE%\\Desktop"
$env:DefaultDownloadPath = "%PROGRAMDATA%\\UiPath\\Academy\\Downloads"
$env:DefaultPoliciesPath = "%PROGRAMDATA%\\UiPath\\Academy\\Policies"
$env:LGPO = "%PROGRAMDATA%\\UiPath\\Academy\\Downloads\\lgpo\\LGPO.exe"

function New-FolderPath {
<#
    Download File
    .SYPNOSIS
    ...
#>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $path
        , [Parameter(Mandatory=$false)] [String] $tab = ""
    )
    Begin { Write-Host "Create folder path" }
    Process {
        $path = [System.Environment]::ExpandEnvironmentVariables($path)
        if ( Test-Path -Path $path -PathType Container ) { Write-Host "$tab ~ Folder exists: $path" }
        else {
            $path.Split("\") | ForEach-Object { 
                $fullpath = if( [io.path]::IsPathRooted($_) ) { Join-Path $_ -ChildPath "" } else { (New-Item $fullpath -Name $_ -ItemType Directory -Force ).FullName } 
            }
            Write-Host "$tab ~ Folder created: $path"
        }
    }
    End{}
}


Clear-Host
Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"
$path = "C:\ProgramData\UiPath\Academy"
$scripts = "C:\ProgramData\UiPath\Academy\Scripts"
#$repository = "https://github.com/jvavasseur/VmReconfig.git"

Write-Host "Import Modules"
$env:PSModulePath = ($env:PSModulePath.Split(";") + "$PSScriptRoot\Modules" | Select-Object -Unique ) -join ';'
Import-Module posh-git -Force
Import-Module VmReconfig -Force #-Verbose;

Write-Host "Git Pull Origin"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#git -C $scripts pull origin

$config = [io.path]::ChangeExtension($PSCommandPath, 'json')

if ( Test-Path -Path $config -PathType Leaf ) {
    $json = Get-Content $config | ConvertFrom-Json
}

$env:DefaultDownloadPath, $env:DefaultPoliciesPath | New-FolderPath

$json.Downloads | Get-FileFromUrl
