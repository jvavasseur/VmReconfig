
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
        #Write-Output "name = $($object.name)"
        ForEach($property in $properties)
        {
            if (Get-Member -InputObject $object  -Name $property -MemberType Properties) 
            {
                #Write-Output "property = $property OK"
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
        , [Parameter(Mandatory=$false)] [string] $defaultpath = (Get-DownloadsDirectory)
    )
    Begin {
        Write-Output "$tab$(" "*0) # Downloads" #◯
        $index = 0; $errorcount = 0;
        if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = (Get-DownloadsDirectory); }
    }
    Process{
        Try{
            $index++;
            $download = $PSItem

            $testobject_params = @{ object = $download; properties = @("name", "url"); any = $false }
            if ( -not ( Test-ObjectContainsProperties @testobject_params ) ) {
                $errorcount++;Write-Error "Error with Download [$index]: JSON format is invalid [$($download | ConvertTo-Json -Compress)] ; expected formet = { `"name`": `"file name`", `"path`": `"download folder`", `"url`": `"file url`" }"; 
                return; 
            }

            [String]$name = $download.name.trim();
            Write-Output "$tab$(" "*2) | => Download [$index]: $name" #↳
            if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++;Write-Error "Error with Download [$index]: name is invalid [$name]"; return; }

            [String]$path = $download.path;
            if ([string]::IsNullOrWhiteSpace($path)) { 
                Write-Output "$tab$(" "*2) |   ~ Empty path replaced by Default path: [$defaultpath]"
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
            $execute = if ( $download.execute -eq $true) { $true } else { $false }

            $file = Join-Path -Path $fullpath -ChildPath $name

            try{
                if ( (Test-Path $file -PathType Leaf) -and ($replace -ne $true) )
                {
                    Write-Output "$tab$(" "*2) |    ! Skipping existing file [$file]. Use `"replace`": true"; 
                } else {
                    if ( Test-Path $file -PathType Leaf) {
                        Write-Output "$tab$(" "*2) |    - Remove existing File"
                        Remove-Item $file -Force
                    }
                    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
                    $startdate = (get-date)
                    $progress = $ProgressPreference
                    $ProgressPreference = "SilentlyContinue"
                    Invoke-WebRequest -Uri $url -OutFile $file
                    $ProgressPreference = $progress
                    Write-Output "$tab$(" "*2) |    + File downloaded: $file [$(New-TimeSpan -Start $startdate -End (get-date))]"
                }
                
                if ( $extract) {
                    $destination = Join-Path -Path $fullpath -ChildPath $( [io.path]::GetFileNameWithoutExtension($file) )
                    if ( (Test-Path $destination -PathType Container)  -and ($replace -ne $true) )
                    {
                        Write-Output "$tab$(" "*2) |    ! Skipping existing archive folder [$file]. Use `"replace`": true"; 
                    } else {
                        if ( Test-Path $destination -PathType Container) {
                            Write-Output "$tab$(" "*2) |    - Remove archive folder: $destination"
                            Remove-Item -Path $destination -Force -Recurse        
                        }
                    }
                    <#
                     $vol = Mount-DiskImage -ImagePath $iso -StorageType ISO -PassThru -NoDriveLetter | Get-Volume
                    ls -l "$($vol.Path)" | %{ Copy-Item -LiteralPath $_.fullname -Destination $dest -Recurse -Force}
                    Get-DiskImage -DevicePath $vol.path.trimend('\') -ea silentlycontinue  | Dismount-DiskImage
                    #>
                    Expand-Archive -Path $file -DestinationPath $destination -Force
                    Write-Output "$tab$(" "*2) |    + File extracted to: $destination"
                }

                if ( $execute ) {
                    $command = @{ command = $file; parameters = $download.parameters}
                    Start-ConfigCommand -Command $command -Wait $true -quiet: $true
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
        Write-Output "$tab$(" "*0) * Downloads finished: $index $msg"; #⬤
    }
}


function Start-ConfigCommand {
<#
    Execute command
    .SYPNOSIS
    ...
#>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $command
        , [Parameter(Mandatory=$false)] [string] $defaultpath = (Get-ScriptsDirectory)
        , [Parameter(Mandatory=$false)] [switch] $wait
        , [Parameter(Mandatory=$false)] [switch] $quiet = $false #= [switch]::Present
        , [Parameter(Mandatory=$false)] [String] $tab = ""
    )
    Begin {
        $index = 0; $errorcount = 0;
        if ( -not $quiet ) { Write-Output "$tab  # Execute" }
        if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = (Get-DownloadsDirectory); }
#        if ([string]::IsNullOrWhiteSpace($quiet)) { Write-Output "NULL" } else { Write-Output "ok $quiet" }
    }
    Process{
        try {
            $index++;
            $name = $command.name
            $file = $command.command
            #$file = $command.command
            if ([string]::IsNullOrWhiteSpace($file)) { $errorcount++; Write-Error "command name is missing"; return }
            if ( -not $quiet ) { Write-Output "$tab  |  => Execute $index [$name]" } #↳
            Write-Output "$tab  |    - Execute command [parameters = $params]"

#Write-Output "params = $params"
#Write-Output "command = $file"
            $fullname = if ( [string]::IsNullOrWhiteSpace( [io.path]::GetDirectoryName($file) ) ) { 
                Write-Output "$tab  |    - File not found, check default folder: $defaultpath"
                Join-Path -Path ([System.Environment]::ExpandEnvironmentVariables($defaultpath)) -ChildPath $file
            } else { [System.Environment]::ExpandEnvironmentVariables($file) }
#            Write-Output " fullname = $fullname"
            $workingdir = [io.path]::GetDirectoryName($fullname)
#            Write-Output " working dir = $workingdir"
            
#            if ( Test-Path -Path $fullname -PathType Leaf ) { Write-Output "OK" } else { write-error "error"}
#  $testobject_params = @{ object = $download; properties = @("name", "url"); any = $false }
            $process_params = @{ FilePath = $fullname; NoNewWindow = $true; Wait = $true ; PassThru = $true ; WorkingDirectory = $workingdir }
            if ([string]::IsNullOrWhiteSpace($command.parameters)) {} else { $process_params.Add("ArgumentList", $command.parameters) }
            $process_params
            $process = Start-Process @process_params
            Write-Output "$tab  |    - Command executed [exit code = $($process.ExitCode)]"
        } catch {
            $errorcount++;
            Throw $_;
        }
    }
    End{
        if ( -not $quiet ) {
            [string] $msg = if($errorcount -gt 0){"[errorcount found: $errorcount]"} else{""}
            Write-Output "$tab  * Execute finished: $index $msg"; #⬤
        }
    }
}
    