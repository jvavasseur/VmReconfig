$json = '{
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
        { "config": "User", "path": "Software\Microsoft\Windows\CurrentVersion\Policies\System", "name": "Wallpaper", "value": "SZ:c:\\test.bmp" }
        { "config": "User", "path": "Software\Microsoft\Windows\CurrentVersion\Policies\System", "name": "WallpaperStyle", "value": "SZ:0 }
    ]
}'
#        #{ "name": "Your Shortcut.url", "path": "$env:ALLUSERSPROFILE\\Desktop", "url": "http://xxx.com" }

$script:defaultfavoritefolder = "%ALLUSERSPROFILE%\\Desktop"
$script:defaultshortcutfolder = "%ALLUSERSPROFILE%\\Desktop"
$script:defaultdownloadfolder = "%PROGRAMDATA%\\UiPath\\Academy\\Downloads"

$test = ConvertFrom-Json -InputObject $json -AsHashtable -NoEnumerate
#-AsHashTable #-NoEnumerate
#$test

$tab = "";

function Add-Favorite {
<#
    Create Favorites
    .SYPNOSIS
    ...
#>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Hashtable] $favorite
        , [Parameter(Mandatory=$false)] [String] $tab = ""
        , [Parameter(Mandatory=$false)] [string] $defaultpath = "%ALLUSERSPROFILE%\\Desktop"
    )
    Begin {
        Write-Host "$tab  ◯ Favorites"
        $index = 0; $errorcount = 0;
        if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = "%ALLUSERSPROFILE%\\Desktop"; }
        #$defaultpath = [System.Environment]::ExpandEnvironmentVariables($defaultpath);
    }
    Process{
        Try{
            $index++;
            [String]$name = $favorite.name.trim();
            Write-Host "$tab  |  ↳ Favorite $index [$name]"
            if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++;Write-Error "Error with Favorite [$index]: name is invalid [$name]"; return; }
            if ( -not ($name.EndsWith('.url'))){ $name += '.url'}
            [String]$path = $favorite.path.trim();
            if ([string]::IsNullOrWhiteSpace($path)) { 
                Write-Host "$tab  |    ~ Empty path replaced by Default path: [$defaultpath]"
                $path = $defaultpath; 
            }
            $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
            $url = $favorite.url.trim()
            if ( $null -eq ($url -as [System.URI]).AbsoluteURI )
                { $errorcount++;Write-Error "Error with Favorite [$name]: url is invalid [$url]"; return; }
            if ( Test-Path $fullpath -PathType Container)
            {
                $file = Join-Path -Path $fullpath -ChildPath $name
                if ( Test-Path $file -PathType Leaf)
                {
                    Write-Host "$tab  |    - Remove existing Favorite"
                    Remove-Item $file
                }
                try{
                    $shell = New-Object -ComObject ("WScript.Shell")
                    $object = $shell.CreateShortcut($file)
                    $object.TargetPath = $url;
                    $object.Save()
                    Write-Host "$tab  |    + Favorite created: $file "
                }catch{
                    Write-Error $_.Exception;    
                }
            }else { $errorcount++; Write-Error "Error with Favorite [$name]: path is invalid or doesn't exist [$path]"; return;}
        }catch{
            $errorcount++;
            Throw $_.Exception;
        }
    }
    End{
        [string] $msg = if($errorcount -gt 0){"[errorcount found: $errorcount]"} else{""}
        Write-Host "$tab  ⬤ Favorites created: $index $msg";
    }
}

function Get-FileFromUrl {
    <#
        Download File
        .SYPNOSIS
        ...
    #>
        [CmdletBinding()]
        Param (
            # Parameter help description
            [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Hashtable] $download
            , [Parameter(Mandatory=$false)] [String] $tab = ""
            , [Parameter(Mandatory=$false)] [string] $defaultpath = $script:defaultdownloadfolder
        )
        Begin {
            Write-Host "$tab  ◯ Download"
            $index = 0; $errorcount = 0;
            if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = $script:defaultdownloadfolder; }
        }
        Process{
            Try{
                $index++;
                if ( -not ($download.ContainsKey("name") -And $download.ContainsKey("url"))) {
                    $errorcount++;Write-Error "Error with Download [$index]: format is invalid [$($download | ConvertTo-Json -Compress)] ; expected formet = { `"name`": `"file name`", `"path`": `"download folder`", `"url`": `"file url`" }"; 
                    return; 
                }
                [String]$name = $download.name.trim();
                Write-Host "$tab  |  ↳ Download $index [$name]"
                if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++;Write-Error "Error with Download [$index]: name is invalid [$name]"; return; }
                #if ( -not ($name.EndsWith('.url'))){ $name += '.url'}
                [String]$path = $download.path;
                if ([string]::IsNullOrWhiteSpace($path)) { 
                    Write-Host "$tab  |    ~ Empty path replaced by Default path: [$defaultpath]"
                    $path = $defaultpath.Trim(); 
                } else { $path = $path.Trim(); }
                $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
                if ( -Not ( Test-Path $fullpath -PathType Container))
                    { $errorcount++; Write-Error "Error with Download [$name]: path is invalid or doesn't exist [$path]"; return;}
                $url = $download.url.trim()
                if ( $null -eq ($url -as [System.URI]).AbsoluteURI )
                    { $errorcount++;Write-Error "Error with Download [$name]: url is invalid [$url]"; return; }
                $replace = if ( $download.replace -eq $false) { $false } else { $true }
                $extract = if ( $download.extract -eq $true) { $true } else { $false }

                $file = Join-Path -Path $fullpath -ChildPath $name
                if ( Test-Path $file -PathType Leaf)
                {
                    if ( $replace -eq $true) {
                        Write-Host "$tab  |    - Remove existing File"
                        Remove-Item $file -Force
                    } else { Write-Host "$tab  |    ! Replace set to [false] or not set, existing file won't be replace [$file]. Use `"replace`": true"; return; }
                }
                try{
                    Invoke-WebRequest -Uri $url -OutFile $file
                    Write-Host "$tab  |    + File downloaded: $file"
                    if ( $extract) {
                        $destination = Join-Path -Path $fullpath -ChildPath $(Split-Path $file -LeafBase)
                        if ( Test-Path $destination -PathType Container)
                        {
                            Write-Host "$tab  |    - Remove archive folder: $destination"
                            Remove-Item -Path $destination -Force -Recurse
                        }
                        Expand-Archive -Path $file -DestinationPath $destination -Force
                        Write-Host "$tab  |    + File extracted to: $destination"
                    }
                }catch{
                    Write-Error $_;    
                }
            }catch{
                $errorcount++;
                Throw $_;
            }
        }
        End{
            [string] $msg = if($errorcount -gt 0){"[errorcount found: $errorcount]"} else{""}
            Write-Host "$tab  ⬤ Download finished: $index $msg";
        }
    }

Write-Host "---------------------------" 
$test.favorites | Add-Favorite
"+" * 50
$test.downloads | Get-FileFromUrl

Write-Host "////" 
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