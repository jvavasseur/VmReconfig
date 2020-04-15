Clear
Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"

$env:PSModulePath = $env:PSModulePath.Split(";") + "$PSScriptRoot\Modules" | Select-Object -Unique | Join-String -Property {$_} -Separator ";"
Import-Module VmReconfig -Force;

$json = '
{
    "downloads": [
        { "name": "lgpo.zip", path: "", url: "https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip", "replace": true, "extract": true }
        , { "name": "wallpaper.jpg", paxth: "", "url": "https://i.ytimg.com/vi/DTX_wdydipM/maxresdefault.jpg" }
    ]
    , "favorites": [
        { "name": "Your Shortcut2.url", "path": "%ALLUSERSPROFILE%\\Desktop", "url": "http://xxx.com" }
        , { "name": " toto ", "path": "  ", "url": "http://xxx.com" }
        , { "name": "Your Shortcut3.url", "path": "%ALLUSERSPROFILE%\\Desktop", "url": "http://xxx.com" }
    ]
    , "lgpo": [
        { "type": "User", "path": "Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System", "name": "Wallpaper", "value": "SZ:c:\\test.bmp" }
        , { "type": "User", "path": "Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System", "name": "WallpaperStyle", "value": "SZ:0" }
    ]
}'
#        #{ "name": "Your Shortcut.url", "path": "$env:ALLUSERSPROFILE\\Desktop", "url": "http://xxx.com" }

$env:DefaultFavoritePath = "%ALLUSERSPROFILE%\\Desktop"
$env:DefaultShortcutPath = "%ALLUSERSPROFILE%\\Desktop"
$env:DefaultDownloadfPath = "%PROGRAMDATA%\\UiPath\\Academy\\Downloads"
$env:test = "*****--" 

$tab = "";
$test = ConvertFrom-Json -InputObject $json -AsHashtable -NoEnumerate

Write-Host "---------------------------" 
$test.favorites | Add-Favorite
"+" * 50
$test.downloads | Get-FileFromUrl
Write-Host "////" 
$test.downloads 
$test 
exit 

Write-Host "$tab  | Shortcuts"
$index = 0;
$test.favorites | Foreach-Object {
    $index++;
    $name = $_.name.trim();
    $path = $_.path.trim();
    Write-Host "$tab | | Shortcut $index [$name]"
    $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
    $url = $_.url.trim()
    if ( Test-Path $fullpath -PathType Container)
    {
        $file = Join-Path -Path $fullpath -ChildPath $name
        if ( Test-Path $file -PathType Leaf)
        {
            Write-Host "$tab |    - Remove existing shortcut"
            Remove-Item $file
        }
        $Shell = New-Object -ComObject ("WScript.Shell")
        $Favorite = $Shell.CreateShortcut($file)
        $Favorite.TargetPath = $url;
        $Favorite.Save()
        Write-Host "$tab |    + Shortcut created [$name]: $fullpath "
    }else { Write-Error "Shortcut error [$name] in: path not found [$path]"}
}
write-host "QQQQ"
$test.favorites | Add-Shortcuts
$test.favorites[0].GetType() 
<#
Clear-Host
$json = '{ "keys":["value1", "x", "ppp"], "Key":"value2", "Key":"value3", "xxx":["xxx"] }' 
$test = ConvertFrom-Json $json -NoEnumerate
#$test | Where-Object { $_.key -eq "Key" }

$test | ForEach-Object {
    write-host $_
    write-host "----"
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