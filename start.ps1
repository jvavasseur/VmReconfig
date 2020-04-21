$path = "C:\ProgramData\UiPath\Academy"
$scripts = "C:\ProgramData\UiPath\Academy\Scripts"
$repository = "https://github.com/jvavasseur/VmReconfig.git"

$path.Split("\") | % { $fullpath = if( [io.path]::IsPathRooted($_) ) { Join-Path $_ -ChildPath "" } else { (New-Item $fullpath -Name $_ -ItemType Directory -Force ).FullName } }
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name Nuget -Force
Install-Module posh-git -Scope CurrentUser -Force
Import-Module posh-git
#Add-PoshGitToProfile -AllHosts
if (Test-Path $scripts) { Remove-Item $scripts -Force -Recurse }
git clone $repository $scripts
