function Add-Shortcut {
    <#
        Add Shorcut
        .SYPNOSIS
        ...
    #>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $input
        , [Parameter(Mandatory=$false)] [String] $tab = ""
        , [Parameter(Mandatory=$false)] [string] $defaultpath = (Get-ShorcutsDirectory)
    )
    Begin {
        Write-Output "$tab$(" "*0) # Shorcuts" #◯
        $index = 0; $errorcount = 0;
        if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = (Get-ShorcutsDirectory); }
    }
    Process{
        Try{
            $index++;
            $Shorcut = $PSItem

            $testobject_params = @{ object = $Shorcut; properties = @("name", "target"); any = $false }
            if ( -not ( Test-ObjectContainsProperties @testobject_params ) ) {
                $errorcount++;Write-Error "Error with Shorcut [$index]: format is invalid [$($Shorcut | ConvertTo-Json -Compress)] ; expected formet = { `"name`": `"Shorcut name`", `"path`": `"path`", `"target`": `"target`" }"; 
                return; 
            }

            [String]$name = $Shorcut.name.trim();
            Write-Output "$tab$(" "*2) | => Shorcut $index [$name]" #↳
            if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++;Write-Error "Error with Shortcut [$index]: name is invalid [$name]"; return; }

            [String]$path = $Shorcut.path;
            if ([string]::IsNullOrWhiteSpace($path)) { 
                Write-Output "$tab$(" "*2) |    ~ Empty path replaced by Default path: [$defaultpath]"
                $path = $defaultpath.Trim(); 
            } else { $path = $path.Trim(); }

            $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
            if ( -Not ( Test-Path $fullpath -PathType Container) )
                { $errorcount++; Write-Error "Error with Shorcut [$name]: path is invalid or doesn't exist [$path]"; return;}

            $target = $Shorcut.target.trim()
            if ( [string]::IsNullOrWhiteSpace($target) )
                { $errorcount++;Write-Error "Error with Shorcut [$name]: target is invalid [$url]"; return; }

            $replace = if ( $shortcut.replace -eq $false) { $false } else { $true }

            $file = Join-Path -Path $fullpath -ChildPath $name   
            $file = if ( [io.path]::GetExtension($file) -ne ".lnk" ) { "$($file).lnk"} else { $file }

            Write-Output "$tab$(" "*2) |    ~ Resulting Shorcut file: [$file]"

            try{
                if ( (Test-Path $file -PathType Leaf) -and ($replace -ne $true) )
                {
                    Write-Output "$tab$(" "*2) |    ! Skipping existing Shorcut [$file]. Use `"replace`": true"; 
                } else {
                    if ( Test-Path $file -PathType Leaf) {
                        Write-Output "$tab$(" "*2) |    - Remove existing Shorcut"
                        Remove-Item $file -Force
                    }
                    try{
                        $shell = New-Object -ComObject ("WScript.Shell")
                        $object = $shell.CreateShortcut($file)
                        $object.TargetPath = $url;
                        $object.Arguments = "";
                        $object.WorkingDirectory = "";
                        $object.WindowStyle = 1;
                        $object.IconLocation = "$target, 0";

                        $object.Save()
                        Write-Output "$tab$(" "*2) |    + Shorcut created: $file "
                    }catch{
                        Write-Error $_.Exception;    
                    }
                    #Write-Output "$tab |    + Shorcut created: $file"
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
        Write-Output "$tab$(" "*0) * Shorcuts finished: $index $msg"; #⬤
    }
}
    
<#function Add-Favoritexxx {
    <#
        Create Favorites
        .SYPNOSIS
        ...
    # >
        [CmdletBinding()]
        Param (
            # Parameter help description
            [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Hashtable] $favorite
            , [Parameter(Mandatory=$false)] [String] $tab = ""
            , [Parameter(Mandatory=$false)] [string] $defaultpath = $env:DefaultFavoritePath
        )
        Begin {
            Write-Output "$tab  ◯ Favorites"
            $index = 0; $errorcount = 0;
            if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = $env:DefaultFavoritePath; }
            #$defaultpath = [System.Environment]::ExpandEnvironmentVariables($defaultpath);
        }
        Process{
            Try{
                $script:defaultdownloadfolder;
                $env:test
                Write-Output "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                $index++;
                [String]$name = $favorite.name.trim();
                Write-Output "$tab  |  ↳ Favorite $index [$name]"
                if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++;Write-Error "Error with Favorite [$index]: name is invalid [$name]"; return; }
                if ( -not ($name.EndsWith('.url'))){ $name += '.url'}
                [String]$path = $favorite.path.trim();
                if ([string]::IsNullOrWhiteSpace($path)) { 
                    Write-Output "$tab  |    ~ Empty path replaced by Default path: [$defaultpath]"
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
                        Write-Output "$tab  |    - Remove existing Favorite"
                        Remove-Item $file
                    }
                    try{
                        $shell = New-Object -ComObject ("WScript.Shell")
                        $object = $shell.CreateShortcut($file)
                        $object.TargetPath = $url;
                        $object.Save()
                        Write-Output "$tab  |    + Favorite created: $file "
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
            Write-Output "$tab  ⬤ Favorites created: $index $msg";
        }
    }
    #>