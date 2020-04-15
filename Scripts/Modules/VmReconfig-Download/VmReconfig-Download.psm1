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
        , [Parameter(Mandatory=$false)] [string] $defaultpath = $env:DefaultDownloadfPath
    )
    Begin {
        Write-Host "$tab  ◯ Download"
        $index = 0; $errorcount = 0;
        if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = $env:DefaultDownloadfPath; }
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
Write-Host "XXXX $($env:DefaultDownloadfPath)"
$env:DefaultDownloadfPath

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
