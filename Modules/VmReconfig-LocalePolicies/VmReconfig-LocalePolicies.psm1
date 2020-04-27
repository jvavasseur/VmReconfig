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
        Write-Host " test local policies"
        $env:DefaultDownloadPath, $env:DefaultPoliciesPath | New-FolderPath

    }
    end{} 
}
function Import-LocalePolicies {
    <#
        Load Locale GPO
        .SYPNOSIS
        ...
    #>
        [CmdletBinding()]
        Param (
            # Parameter help description
            [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Hashtable] $policies
            , [Parameter(Mandatory=$false)] [String] $tab = ""
            , [Parameter(Mandatory=$false)] [string] $defaultpath = $env:DefaultPoliciesPath
        )
        Begin {
            Write-Host "$tab  ◯ Locale Policies"
            $index = 0; $errorcount = 0;
            if ([string]::IsNullOrWhiteSpace($defaultpath)) { $defaultpath = $env:DefaultPoliciesPath; }
            $types = @('file', 'link', 'list')
            $containers = @('user', 'machine')
        }
        Process{
            Try{
                $index++;
                if ([string]::IsNullOrWhiteSpace($policies)) { $errorcount++; Write-Error "Error with Locale Policies [$index]: format is invalid [$policies]"; return; }
                if ( -not ($policies.ContainsKey("name") -And $policies.ContainsKey("type"))) {
                    $errorcount++; Write-Error "Error with Locale Policies parameters [$index]: format is invalid [$($policies | ConvertTo-Json -Compress)] ; expected format = { `"name`": `"file name`", `"type`": `"file/url/link`", `"path`": `"file location`" ...}"; 
                    return; 
                }

                [String]$name = $policies.name.trim();
                Write-Host "$tab  |  ↳ Policies $index [$name]"
    
                if ([string]::IsNullOrWhiteSpace($name)) { $errorcount++; Write-Error "Error with Locale Policies [$index]: name is invalid [$name]"; return; }

                $type = $policies.type.trim().ToLower();
                if ( $types -notcontains $type ) { $errorcount++; Write-Error "Error with Locale Policies [$index]: type is invalid [$type]. Use `"file`", `"link`" or `"rules`""; return; }

                [String]$path = $policies.path;
                if ([string]::IsNullOrWhiteSpace($path)) { 
                    Write-Host "$tab  |    ~ Empty path replaced by Default path: [$defaultpath]"
                    $path = $defaultpath.Trim(); 
                } else { $path = $path.Trim(); }

                $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
                if ( -Not ( Test-Path $fullpath -PathType Container))
                    { $errorcount++; Write-Error "Error with Locale Policies [$name]: path is invalid or doesn't exist [$path]"; return;}

                switch ($type){
                    "file"  {
                        $file = Join-Path -Path $fullpath -ChildPath $name
                        Write-Host "$tab  |    + File found: $file"
                    }
                    "link"  {
                        if ( -not ($policies.ContainsKey("url") )) 
                            { $errorcount++; Write-Error "Error with Locale Policies [$name]: url is invalid or missing"; return; }

                        $url = $policies.url.trim();
                        if ( $null -eq ($url -as [System.URI]).AbsoluteURI )
                            { $errorcount++; Write-Error "Error with Locale Policies [$name]: url is invalid or missing [$url]"; return; }
            
                        $file = Join-Path -Path $fullpath -ChildPath $name
                        if ( Test-Path $file -PathType Leaf)
                        {
                            Write-Host "$tab  |    - Remove existing File"
                            Remove-Item $file -Force
                        }
                        try{
                            Invoke-WebRequest -Uri $url -OutFile $file
                            Write-Host "$tab  |    + File downloaded: $file"
                        }catch{
                            Write-Error $_;    
                        }
                    }
                    "list"  {
                        if ( -not ($policies.ContainsKey("rules") )) 
                            { $errorcount++; Write-Error "Error with Locale Policies [$name]: rules are invalid or missing"; return; }
                        $rules = $policies.rules;
                        if ([string]::IsNullOrWhiteSpace($rules)) { $errorcount++; Write-Error "Error with Locale Policies [$index]: name is invalid [$name]"; return; }
        
                        $file = Join-Path -Path $fullpath -ChildPath $name
                        if ( Test-Path $file -PathType Leaf)
                        {
                            Write-Host "$tab  |    - Remove existing File"
                            Remove-Item $file -Force
                        }
                        try{
                            $row = 0;
                            "; ----------------------------------------------------------------------" | Out-File -FilePath $file -Encoding ascii
                            Add-Content -Path $file -Encoding ascii -Value $(Get-Date -Format "; dddd MM/dd/yyyy HH:mm:ss")
                            Add-Content -Path $file -Encoding ascii -Value "; POLICY"
    
                            ForEach($rule in $rules) {
                                $row++;
                                if ( -not ($rule.ContainsKey("container") -And $rule.ContainsKey("location") -And $rule.ContainsKey("key") -And $rule.ContainsKey("value")))
                                    { $errorcount++; Write-Error "Error with rule [$row]: rule is invalid or parameter(s) are missing (container, location, key and value) [$($rule | ConvertTo-Json -Compress)]"; continue; }

                                $container = $rule.container.Trim();
                                if ([string]::IsNullOrWhiteSpace($rules)) { $errorcount++; Write-Error "Error with Locale Policies [$row]: container is invalid [$container]"; return; }
                                if ( $containers -notcontains $container ) { $errorcount++; Write-Error "Error with Locale Policies [$row]: container is invalid [$container]"; return; }
                                $location = $rule.location.Trim();
                                if ([string]::IsNullOrWhiteSpace($location)) { $errorcount++; Write-Error "Error with Locale Policies [$row]: container is invalid [$location]"; return; }
                                $key = $rule.key.Trim();
                                if ([string]::IsNullOrWhiteSpace($key)) { $errorcount++; Write-Error "Error with Locale Policies [$row]: container is invalid [$key]"; return; }
                                $value = $rule.value.Trim();
                                if ([string]::IsNullOrWhiteSpace($value)) { $errorcount++; Write-Error "Error with Locale Policies [$row]: container is invalid [$value]"; return; }

                                Add-Content -Path $file -Encoding ascii -Value ""
                                Add-Content -Path $file -Encoding ascii -Value $container
                                Add-Content -Path $file -Encoding ascii -Value $location
                                Add-Content -Path $file -Encoding ascii -Value $key
                                Add-Content -Path $file -Encoding ascii -Value $value
                                "$key = $value"

                            }

                            Write-Host "$tab  |    + Rules found: $row"
                            Write-Host "$tab  |    + File created: $file"
                        }catch{
                            Write-Error $_;    
                        }
                    }
                }
                if ( Test-Path $file -PathType Leaf)
                {

#                    $file
                } else { $errorcount++; Write-Error "Error with Locale Policies [$name]: file not found [$file]"; return; }

                    <#                $url = $download.url.trim()
                if ( $null -eq ($url -as [System.URI]).AbsoluteURI )
                    { $errorcount++; Write-Error "Error with Download [$name]: url is invalid [$url]"; return; }
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
#>
            }catch{
                $errorcount++;
                Throw $_;
            }
        }
        End{
            [string] $msg = if($errorcount -gt 0){"[errorcount found: $errorcount]"} else{""}
            Write-Host "$tab  ⬤ Locale Policies finished: $index $msg";
        }
    }
    