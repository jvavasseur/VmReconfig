$path = "C:\ProgramData\UiPath\Academy"
$scripts = "C:\ProgramData\UiPath\Academy\VmReconfig"
$repository = "https://github.com/jvavasseur/VmReconfig.git"

Write-Output "Add modules"
$path.Split("\") | % { $fullpath = if( [io.path]::IsPathRooted($_) ) { Join-Path $_ -ChildPath "" } else { (New-Item $fullpath -Name $_ -ItemType Directory -Force ).FullName } }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name Nuget -Force
Install-Module posh-git -Scope CurrentUser -Force
Import-Module posh-git
#Add-PoshGitToProfile -AllHosts

Write-Output "Add Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Write-Output "Add git"
choco install git -y --params "GitOnlyOnPath"

Write-Output "Pull repository"
if (Test-Path $scripts) { Remove-Item $scripts -Force -Recurse }
#& 'C:\Program Files\Git\bin\git.exe' -C $scripts pull origin

& 'C:\Program Files\Git\bin\git.exe' clone $repository $scripts

cd $scripts
Write-Output ".\Init-VM.ps1 -pullorigin"