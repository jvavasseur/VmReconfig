function Add-Favorite {
    <#
        Add Favorite
        .SYPNOSIS
        ...
    #>
        [CmdletBinding()]
        Param (
            # Parameter help description
            [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $input
            , [Parameter(Mandatory=$false)] [String] $tab = ""
            , [Parameter(Mandatory=$false)] [string] $defaultpath = (Get-FavoritesDirectory)
        )
        Begin {
            Write-Output "$tab$(" "*0) # Favorites" #◯
            $index = 0; $errorcount = 0;
            if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = (Get-FavoritesDirectory); }
        }
        Process{
            Try{
                $index++;
                $favorite = $PSItem
    
                $testobject_params = @{ object = $favorite; properties = @("name", "url"); any = $false }
                if ( -not ( Test-ObjectContainsProperties @testobject_params ) ) {
                    $errorcount++;Write-Error "Error with Favorite [$index]: format is invalid [$($favorite | ConvertTo-Json -Compress)] ; expected formet = { `"name`": `"favorite name`", `"path`": `"path`", `"url`": `"url`" }"; 
                    return; 
                }

                [String]$name = $favorite.name.trim();
                Write-Output "$tab$(" "*2) | => Favorite $index [$name]" #↳
                if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++;Write-Error "Error with Favorite [$index]: name is invalid [$name]"; return; }
    
                [String]$path = $favorite.path;
                if ([string]::IsNullOrWhiteSpace($path)) { 
                    Write-Output "$tab$(" "*2) |    ~ Empty path replaced by Default path: [$defaultpath]"
                    $path = $defaultpath.Trim(); 
                } else { $path = $path.Trim(); }
    
                $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
                if ( -Not ( Test-Path $fullpath -PathType Container) )
                    { $errorcount++; Write-Error "Error with Favorite [$name]: path is invalid or doesn't exist [$path]"; return;}
    
                $url = $favorite.url.trim()
                if ( $null -eq ($url -as [System.URI]).AbsoluteURI )
                    { $errorcount++;Write-Error "Error with Favorite [$name]: url is invalid [$url]"; return; }
    
                $replace = if ( $favorite.replace -eq $false) { $false } else { $true }
    
                $file = Join-Path -Path $fullpath -ChildPath $name   
                $file = if ( [io.path]::GetExtension($file) -ne ".url" ) { "$($file).url"} else { $file }

                Write-Output "$tab$(" "*2) |    ~ Resulting Favorite file: [$file]"

                try{
                    if ( (Test-Path $file -PathType Leaf) -and ($replace -ne $true) )
                    {
                        Write-Output "$tab$(" "*2) |    ! Skipping existing Favorite [$file]. Use `"replace`": true"; 
                    } else {
                        if ( Test-Path $file -PathType Leaf) {
                            Write-Output "$tab$(" "*2) |    - Remove existing Favorite"
                            Remove-Item $file -Force
                        }
                        try{
                            $shell = New-Object -ComObject ("WScript.Shell")
                            $object = $shell.CreateShortcut($file)
                            $object.TargetPath = $url;
                            $object.Save()
                            Write-Output "$tab$(" "*2) |    + Favorite created: $file "
                        }catch{
                            Write-Error $_.Exception;    
                        }
                        #Write-Output "$tab |    + Favorite created: $file"
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
            Write-Output "$tab$(" "*0) * Favorites finished: $index $msg"; #⬤
        }
    }
    
    