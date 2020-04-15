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
            , [Parameter(Mandatory=$false)] [string] $defaultpath = $env:DefaultFavoritePath
        )
        Begin {
            Write-Host "$tab  ◯ Favorites"
            $index = 0; $errorcount = 0;
            if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = $env:DefaultFavoritePath; }
            #$defaultpath = [System.Environment]::ExpandEnvironmentVariables($defaultpath);
        }
        Process{
            Try{
                $script:defaultdownloadfolder;
                $env:test
                Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
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
    