[String]$LocalePoliciesFolder = "XXX init"
function Get-LocalePoliciesPath{
    [CmdletBinding()]
    Param ()
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope 1 -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Cannot find a variable with the name $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        }
    }
}
function Set-LocalePoliciesPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path
            Option = 'constant'; Scope = 1; Passthru = $true
        }            
        (Set-Variable @params).value
    }
}
function Test-LocalePolicies {
    begin{}
    process{
        Write-Ouput " test local policies"
        $env:DefaultDownloadPath, $env:DefaultPoliciesPath | New-FolderPath

    }
    end{} 
}
function Update-Policies {
    <#
        Load Locale GPO
        .SYPNOSIS
        ...
    #>
        [CmdletBinding()]
        Param (
            # Parameter help description
            [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $input
            , [Parameter(Mandatory=$false)] [String] $tab = ""
            , [Parameter(Mandatory=$false)] [string] $defaultpath = (Get-PoliciesDirectory)

#            [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Hashtable] $policies
#            , [Parameter(Mandatory=$false)] [String] $tab = ""
#            , [Parameter(Mandatory=$false)] [string] $defaultpath = $env:DefaultPoliciesPath
        )
        Begin {
            Write-Ouput "$tab$(" "*0) # Policies" #◯
            $index = 0; $errorcount = 0;
            if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = (Get-PoliciesDirectory); }

#            Write-Ouput "$tab  ◯ Locale Policies"
#            $index = 0; $errorcount = 0;
#            if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = $env:DefaultPoliciesPath; }
            $types = @('file', 'link', 'list')
            $containers = @('user', 'machine')
        }
        Process{
            Try{
                $index++;
                $policy = $PSItem
#Write-Ouput $policie

                $testobject_params = @{ object = $policy; properties = @("name", "configuration"); any = $false }
                if ( -not ( Test-ObjectContainsProperties @testobject_params ) ) {
                    $errorcount++;Write-Error "Error with Policy [$index]: JSON format is invalid $($policy | ConvertTo-Json -Compress)] ; expected format = { `"name`": `"name`", `"configuration`": `"User or computer`" ... }"; 
                    return; 
                }

#Write-Ouput $("x" * 100)

                [String]$name = $policy.name.trim();
                Write-Ouput "$tab$(" "*2) | => Policy [$index]: $name"
                if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++;Write-Error "Error with Policy [$index]: name is invalid [$name]"; return; }

#Write-Ouput $("z" * 100)
                $testobject_params = @{ object = $policy; properties = @("path", "url", "rules"); any = $true }
                if ( -not ( Test-ObjectContainsProperties @testobject_params ) ) {
                    $errorcount++;Write-Error "Error with Policy [$index]: JSON format is invalid $($policy | ConvertTo-Json -Compress)] ; missing 1 or more: [`"path`": `"file path`"], [`"url`": `"file url`"], [`rules`": `"list of rules`"] "; 
                    return; 
                }

#                if ([string]::IsNullOrWhiteSpace($policies)) { $errorcount++; Write-Error "Error with Locale Policies [$index]: format is invalid [$policies]"; return; }

#                if ( -not ($policies.ContainsKey("name") -And $policies.ContainsKey("type"))) {
#                    $errorcount++; Write-Error "Error with Locale Policies parameters [$index]: dfgdfgfg is invalid [$($policies | ConvertTo-Json -Compress)] ; expected format = { `"name`": `"file name`", `"type`": `"file/url/link`", `"path`": `"file location`" ...}"; 
#                    return; 
#                }

                [String]$configuration = $policy.configuration;
                #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                #XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                
                [String]$file = $policy.path;

                if ([string]::IsNullOrWhiteSpace($file)) {
                    Write-Ouput "$tab$(" "*8) | [path] parameter not found"
                } else {
                    Write-Ouput "$tab$(" "*2) |    Process [path] = $file"
                    $fullpath = [System.Environment]::ExpandEnvironmentVariables($file)
                    if ( Test-Path -Path $fullpath -PathType Leaf ) 
                    {
                        $tempfile = "$([guid]::NewGuid()).txt"
                        $temppath = [io.path]::Combine( (Get-TempDirectory), $tempfile)
                        Write-Ouput "$tab$(" "*2) |     ~ Copy to temp file: $temppath"
                        "; $("-"*100)" | Set-content -Path $temppath
                        "; CUSTOM POLICY:x $name" | Add-Content -Path $temppath -Encoding ascii
                        "; Creation time: $((get-date).ToString())" | Add-Content -Path $temppath -Encoding ascii
                        "; Configuration: $configuration" | Add-Content -Path $temppath -Encoding ascii
                        "; path: $file" | Add-Content -Path $temppath -Encoding ascii
                        "; $("-"*100)" | Add-content -Path $temppath -Encoding ascii
                        $content = Get-Content -Path $fullpath 
                        $content | Add-Content -Path $temppath -Encoding ascii

                        Import-Policies -File $temppath -Configuration $configuration -tab $tab
                    } else { throw "Policy file not found: $file" }        
                }

                [String]$url = $policy.url;
                if ([string]::IsNullOrWhiteSpace($url)) {
                    Write-Ouput "$tab$(" "*2) |    [url] parameter not found"
                } else {
                    Write-Ouput "$tab$(" "*2) |    Process [url] = $url"
                    $tempfile = "$([guid]::NewGuid()).txt"
                    $temppath = [io.path]::Combine( (Get-TempDirectory), $tempfile)

                    Write-Ouput "$tab$(" "*2) |     + Download to temp file: $temppath"
        
                    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
                    $startdate = (get-date)
                    $progress = $ProgressPreference
                    $ProgressPreference = "SilentlyContinue"
                    Invoke-WebRequest -Uri $url -OutFile $temppath
                    $ProgressPreference = $progress
                    Write-Ouput "$tab$(" "*2) |     ~ File downloaded [$(New-TimeSpan -Start $startdate -End (get-date))]"        

                    $content = Get-Content -Path $temppath 
                    "; $("-"*100)" | Set-content -Path $temppath -Encoding ascii
                    "; CUSTOM POLICY:x $name" | Add-Content -Path $temppath -Encoding ascii
                    "; Creation time: $((get-date).ToString())" | Add-Content -Path $temppath -Encoding ascii
                    "; Configuration: $configuration" | Add-Content -Path $temppath -Encoding ascii
                    "; url: $url" | Add-Content -Path $temppath -Encoding ascii
                    "; $("-"*100)" | Add-content -Path $temppath -Encoding ascii

                    $content | Add-Content -Path $temppath -Encoding ascii
                    Import-Policies -File $temppath -Configuration $configuration -tab $tab
                }
                
                $rules = $policy.rules;
                if ( $rules.count -eq 0) {
                    Write-Ouput "$tab$(" "*2) |    [rules] parameter not found"
                } else {
                    $shorttext = Get-ShortString -string ([system.String]::Join(" ", $rules)) -Length 100
                    Write-Ouput "$tab$(" "*2) |    Process [rules] = $shorttext ..."

                    $tempfile = "$([guid]::NewGuid()).txt"
                    $temppath = [io.path]::Combine( (Get-TempDirectory), $tempfile)
                    Write-Ouput "$tab$(" "*2) |     + Create temp file: $temppath"

                    "; $("-"*100)" | Set-content -Path $temppath -Encoding ascii
                    "; CUSTOM POLICY:x $name" | Add-Content -Path $temppath -Encoding ascii
                    "; Creation time: $((get-date).ToString())" | Add-Content -Path $temppath -Encoding ascii
                    "; Configuration: $configuration" | Add-Content -Path $temppath -Encoding ascii
                    "; rule: $shorttext" | Add-Content -Path $temppath -Encoding ascii
                    "; $("-"*100)" | Add-content -Path $temppath -Encoding ascii

                    $rules | ForEach-Object {
                        $key = $_.key
                        $values = $_.values
                        $values | ForEach-Object {
                            $value = $_.value
                            $action = $_.action

                            (Get-Culture).TextInfo.ToTitleCase($configuration) | Add-content -Path $temppath -Encoding ascii
                            $key | Add-content -Path $temppath -Encoding ascii
                            $value | Add-content -Path $temppath -Encoding ascii
                            $action | Add-content -Path $temppath -Encoding ascii
                            "" | Add-content -Path $temppath -Encoding ascii
                        }
                    } 
                    Import-Policies -File $temppath -Configuration $configuration -tab $tab
                }

            }catch{
                $errorcount++;
                Throw $_;
            }
        }
        End{
            [string] $msg = if($errorcount -gt 0){"[errorcount found: $errorcount]"} else{""}
            Write-Ouput "$tab$(" "*0) * Locale Policies finished: $index $msg"; #⬤
        }
    }
    
function Import-Policies {
    <#
        Load Locale GPO
        .SYPNOSIS
        ...
    #>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [String] $File
        , [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [String] $Configuration
        , [Parameter(Mandatory=$false)] [String] $tab = ""
    )
    Begin{}
    Process
    {
        $policypath = [io.path]::ChangeExtension($File, "pol")
        Write-Ouput "$tab$(" "*2) |     + Create Policy file: $policypath"
        #Write-Ouput "$(Get-LGpo) /r $File /w $policypath"
        Start-Process "$(Get-LGpo)" -ArgumentList "/r $File /w $policypath" -Wait -WindowStyle hidden
 
        Write-Ouput "$tab$(" "*2) |     + Import Policy file..."      
        Switch ($Configuration)
        {
            "User" { $args = "/u $policypath"; break; }
            "Computer" { $args = "/m $policypath"; break; }
            default { Throw "Error importing Policy file. Invalid Configuration ($configuration): User [User] or [Computer]"}
        }
#        Write-Ouput "$(Get-LGpo) $args"
        Start-Process "$(Get-LGpo)" -ArgumentList $args -Wait -WindowStyle hidden
        Write-Ouput "$tab$(" "*2) |     + Policy file imported: $policypath"
    }
    End{}
}