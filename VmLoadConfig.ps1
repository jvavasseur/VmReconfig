#requires -Version 1

Clear-Host
Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"

$env:PSModulePath = ($env:PSModulePath.Split(";") + "$PSScriptRoot\Modules" | Select-Object -Unique ) -join ';'
#$env:PSModulePath = $env:PSModulePath.Split(";") + "$PSScriptRoot\Modules" | Select-Object -Unique | Join-String -Property {$_} -Separator ";"

Import-Module VmReconfig -Force #-Verbose;

$json = '
{
    "downloads": [
        { "name": "lgpo.zip", path: "", url: "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip", "replace": false, "extract": true }
        , { "name": "wallpaper.jpg", pathx: "", "xxxx": "", "url": "https://i.ytimg.com/vi/DTX_wdydipM/maxresdefault.jpg" }
        , { "name": "OfficeProfessionalRetail.img", "url": "https://officecdn.microsoft.com/db/492350F6-3A01-4F97-B9C0-C7C6DDF67D60/media/en-US/ProfessionalRetail.img", "replace": false, "extract": "false" }
        , { "name": "notapad++.exe", "url": "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.5/npp.7.8.5.Installer.x64.exe", "replace": false }
        , { "name": "SSMS.exe", "url": "https://download.microsoft.com/download/f/e/b/feb0e6be-21ce-4f98-abee-d74065e32d0a/SSMS-Setup-ENU.exe", "replace": false }
    ]
    , "favorites": [
        { "name": "Your Shortcut2.url", "path": "%ALLUSERSPROFILE%\\Desktop", "url": "http://xxx.com" }
        , { "name": " toto ", "path": "  ", "url": "http://xxx.com" }
        , { "name": "Your Shortcut3.url", "path": "%ALLUSERSPROFILE%\\Desktop", "url": "http://xxx.com" }
    ]
    , "localepolicies": [
        { "name": "gpo1.txt", "type": "filE", "path": ""}
        , { "name": "TimeZone-Alaska.txt", "type": "link", "path": "", "url": "https://raw.githubusercontent.com/jvavasseur/UiPathAcademyRessources/master/Policies/TimeZone-Alaska.txt"}
        , { "name": "TimeZone-Myanmar.txt", "type": "link", "path": "", "url": "https://raw.githubusercontent.com/jvavasseur/UiPathAcademyRessources/master/Policies/TimeZone-Myanmar.txt"}
        , { "name": "TimeZone-Paris.txt", "type": "link", "path": "", "url": "https://raw.githubusercontent.com/jvavasseur/UiPathAcademyRessources/master/Policies/TimeZone-Paris.txt"}
        , { "name": "rules.txt", "type": "list", "path": "", "rules": [
            { "container": "User", "location": "Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System", "key": "Wallpaper", "value": "SZ:%PROGRAMDATA%\\UiPath\\Academy\\Downloads\\wallpaper.jpg" }
            , { "container": "User", "location": "Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System", "key": "WallpaperStyle", "value": "SZ:0" }
            , { "container": "User", "location": "Software\\Policies\\Microsoft\\Internet Explorer\\Control Panel", "key": "HomePage", "value": "DWORD:1" }
            , { "container": "User", "location": "Software\\Policies\\Microsoft\\Internet Explorer\\Main", "key": "Start Page", "value": "SZ:www.uipath.com"}
            , { "container": "Machine", "location": "SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation", "key": "Haiti Standard Time", "value": "SZ:Afghanistan Standard Time"}
        ] }
    ]
}'
#        #{ "name": "Your Shortcut.url", "path": "$env:ALLUSERSPROFILE\\Desktop", "url": "http://xxx.com" }

$env:RootPath = "%ALLUSERSPROFILE%"
$env:DefaultFavoritePath = "%ALLUSERSPROFILE%\\Desktop"
$env:DefaultShortcutPath = "%ALLUSERSPROFILE%\\Desktop"
$env:DefaultDownloadPath = "%PROGRAMDATA%\\UiPath\\Academy\\Downloads"
$env:DefaultPoliciesPath = "%PROGRAMDATA%\\UiPath\\Academy\\Policies"
$env:LGPO = "%PROGRAMDATA%\\UiPath\\Academy\\Downloads\\lgpo\\LGPO.exe"

$tab = "";
$test = ConvertFrom-Json -InputObject $json #-AsHashtable -NoEnumerate

Write-Ouput "--------------------------- →" 
#$test.favorites | Add-Favorite
"+" * 50
$test.downloads | Get-FileFromUrl
#$test.localepolicies | Import-LocalePolicies
exit

function Add-Folders {
    <#
        Create Favorites
        .SYPNOSIS
        ...
    #>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $folders
        , [Parameter(Mandatory=$false)] [String] $tab = ""
        , [Parameter(Mandatory=$false)] [string] $path = $env:RootPath
    )
    Begin {
        Write-Ouput "$tab ◯ Folder"
        $tab += "  "
        $id = 0
    }
    Process{
        $_.GetType().fullname
        $id++
        Write-Ouput "[$id] $($_.name)"
    }
    End{
    }
}

#$test.downloads | Add-Folders

Write-Ouput "////" 
exit 

Write-Ouput "$tab  | Shortcuts"
$index = 0;
$test.favorites | Foreach-Object {
    $index++;
    $name = $_.name.trim();
    $path = $_.path.trim();
    Write-Ouput "$tab | | Shortcut $index [$name]"
    $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
    $url = $_.url.trim()
    if ( Test-Path $fullpath -PathType Container)
    {
        $file = Join-Path -Path $fullpath -ChildPath $name
        if ( Test-Path $file -PathType Leaf)
        {
            Write-Ouput "$tab |    - Remove existing shortcut"
            Remove-Item $file
        }
        $Shell = New-Object -ComObject ("WScript.Shell")
        $Favorite = $Shell.CreateShortcut($file)
        $Favorite.TargetPath = $url;
        $Favorite.Save()
        Write-Ouput "$tab |    + Shortcut created [$name]: $fullpath "
    }else { Write-Error "Shortcut error [$name] in: path not found [$path]"}
}
Write-Ouput "QQQQ"
$test.favorites | Add-Shortcuts
$test.favorites[0].GetType() 
<#
Clear-Host
$json = '{ "keys":["value1", "x", "ppp"], "Key":"value2", "Key":"value3", "xxx":["xxx"] }' 
$test = ConvertFrom-Json $json -NoEnumerate
#$test | Where-Object { $_.key -eq "Key" }

$test | ForEach-Object {
    Write-Ouput $_
    Write-Ouput "----"
}

[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    [String] $DirectoryToCreate)

if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    
    try {
        New-Item -Path $DirectoryToCreate -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$DirectoryToCreate'. Error was: $_" -ErrorAction Stop
    }
    "Successfully created directory '$DirectoryToCreate'."

}
else {
    "Directory already existed"
}
#>