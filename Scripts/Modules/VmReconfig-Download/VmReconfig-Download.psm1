function Test-ObjectContainsProperties {
    <#
        Test if Object contains properties
        .SYPNOSIS
        ...
    #>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [psobject] $object
        , [Parameter(Mandatory=$false)] [String[]] $properties
        , [Parameter(Mandatory=$false)] [string] $any = $false
    )
    Begin {
        $count = 0;
    }
    Process{
        #Write-Host "name = $($object.name)"
        ForEach($property in $properties)
        {
            if (Get-Member -InputObject $object  -Name $property -MemberType Properties) 
            {
                #write-host "property = $property OK"
                $count++;
                if ($any -eq $true) { return $true }
            }
            else {
                if ( $any -ne $true){ return $false; }
            }
        }
        if ( $count -eq $properties.count) {return $true } else { return $false }
    }
    End{}
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
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $input
        , [Parameter(Mandatory=$false)] [String] $tab = ""
        , [Parameter(Mandatory=$false)] [string] $defaultpath = $env:DefaultDownloadPath
    )
    Begin {
        Write-Host "$tab  # Download" #◯
        $index = 0; $errorcount = 0;
        if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = $env:DefaultDownloadPath; }
    }
    Process{
        Try{
            $index++;
            $download = $PSItem
            $testobject_params = @{ object = $download; properties = @("name", "url"); any = $false }
            if ( -not ( Test-ObjectContainsProperties @testobject_params ) ) {
                $errorcount++;Write-Error "Error with Download [$index]: format is invalid [$($download | ConvertTo-Json -Compress)] ; expected formet = { `"name`": `"file name`", `"path`": `"download folder`", `"url`": `"file url`" }"; 
                return; 
            }
            [String]$name = $download.name.trim();
            Write-Host "$tab  |  => Download $index [$name]" #↳
            if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++;Write-Error "Error with Download [$index]: name is invalid [$name]"; return; }

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

            try{
                if ( (Test-Path $file -PathType Leaf) -and ($replace -ne $true) )
                {
                    Write-Host "$tab  |    ! Skipping existing file [$file]. Use `"replace`": true"; 
                } else {
                    if ( Test-Path $file -PathType Leaf) {
                        Write-Host "$tab  |    - Remove existing File"
                        Remove-Item $file -Force
                    }
                    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
                    $startdate = (get-date)
                    $progress = $ProgressPreference
                    $ProgressPreference = "SilentlyContinue"
                    Invoke-WebRequest -Uri $url -OutFile $file
                    $ProgressPreference = $progress
                    Write-Host "$tab  |    + File downloaded: $file [$(New-TimeSpan -Start $startdate -End (get-date))]"
                }
                
                if ( $extract) {
                    $destination = Join-Path -Path $fullpath -ChildPath $( [io.path]::GetFileNameWithoutExtension($file) )
                    if ( (Test-Path $destination -PathType Container)  -and ($replace -ne $true) )
                    {
                        Write-Host "$tab  |    ! Skipping existing archive folder [$file]. Use `"replace`": true"; 
                    } else {
                        if ( Test-Path $destination -PathType Container) {
                            Write-Host "$tab  |    - Remove archive folder: $destination"
                            Remove-Item -Path $destination -Force -Recurse
        
                        }
                    }
                    <#
                     $vol = Mount-DiskImage -ImagePath $iso -StorageType ISO -PassThru -NoDriveLetter | Get-Volume
                     $vol = Mount-DiskImage -ImagePath $iso -StorageType ISO -PassThru | Get-Volume
                    ls -l "$($vol.Path)" | %{ Copy-Item -LiteralPath $_.fullname -Destination $dest -Recurse -Force}
                    Get-DiskImage -DevicePath $vol.path.trimend('\') -ea silentlycontinue  | Dismount-DiskImage
                    mountvol $dest $vol.UniqueId
                    https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_12624-20320.exe
                    #>
                    Expand-Archive -Path $file -DestinationPath $destination -Force
                    Write-Host "$tab  |    + File extracted to: $destination"
                }
            }catch{
                Write-Error $_;    
            }

    } catch {
            $errorcount++;
            Throw $_;
        }
    }
    End{
        [string] $msg = if($errorcount -gt 0){"[errorcount found: $errorcount]"} else{""}
        Write-Host "$tab  * Download finished: $index $msg"; #⬤
    }
}
