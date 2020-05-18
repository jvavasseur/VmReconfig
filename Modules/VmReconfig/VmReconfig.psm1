function Get-ShortString {
    <#
        Test if Object contains properties
        .SYPNOSIS
        ...
    #>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [string] $string
        , [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [int] $length = 50       
    )
    Begin {}
    Process{
        $shorttext = $string.Replace("`r", " ").Replace("`n", " ").Replace("    ", " ").Replace("  ", " ").SubString(0,[math]::min($length, $string.length) )
        $shorttext
    }
    End{}
}
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
#Write-Ouput "name = $($object.name)"
##Write-Ouput $(Get-Member -InputObject $object -MemberType Properties)
        ForEach($property in $properties)
        {
#Write-Ouput "property = $property"
            if (Get-Member -InputObject $object  -Name $property -MemberType Properties) 
            {
#Write-Ouput "property = $property OK"
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

function New-FolderPath {
    <#
        Create folder hierarchy
        .SYPNOSIS
        ...
    #>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $Path
        , [Parameter(Mandatory=$false)] [String] $tab = ""
        , [Parameter(Mandatory=$false)] [Switch] $quiet
    )
    Begin {
        if ($quiet) { Write-Ouput "$tab Create folder path" }
    }
    Process {
        $Path = [System.Environment]::ExpandEnvironmentVariables($Path)
        if ( Test-Path -Path $Path -PathType Container ) { Write-Ouput "$tab = Folder exists: $Path" }
        else {
            $path.Split("\") | ForEach-Object { 
                $fullpath = if( [io.path]::IsPathRooted($_) ) { Join-Path $_ -ChildPath "" } else { (New-Item $fullpath -Name $_ -ItemType Directory -Force ).FullName } 
            }
            Write-Ouput "$tab + Folder created: $path"
        }
    }
    End{}
}

function Get-CommonParameters {
    <#
        Create folder hierarchy
        .SYPNOSIS
        ...
    #>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [Switch] $IncludeOptionnalParameters
    )
    Process {
        [System.Management.Automation.PSCmdlet]::CommonParameters
        if ( $IncludeOptionnalParameters ) { [System.Management.Automation.PSCmdlet]::OptionalCommonParameters }
    }   
}

function Initialize-Directories
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $WorkingDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $LogsDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $DownloadsDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $PoliciesDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $TempDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $ScriptsDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $DesktopDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $FavoritesDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $shortcutsDirectory
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $LGpo
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $tab = ""
        )
    Begin{}
    Process{
<#        "root $PSScriptRoot"
        "invoc $($PSCmdlet.MyInvocation.MyCommand.Path)"
        "S $($MyInvocation.ScriptName)"
        "C $($MyInvocation.PSCommandPath)" #>
        $ScriptDirectoty = Split-Path -Path $MyInvocation.PSCommandPath -Parent
        $ParentDirectory = Split-Path -Path $ScriptDirectoty -Parent
        $ParentDirectory = (Get-Item $MyInvocation.ScriptName).Directory.Parent.Fullname

        try{
            #region Working Directory
            $path = $WorkingDirectory
            If (([string]::IsNullOrWhiteSpace($path))) { 
                $path = (Get-Item $MyInvocation.ScriptName).Directory.Parent.Fullname
            }
            Write-Output "$($tab)Set Working Directory: [$path]"
            $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
            If ( -not(Test-Path -Path $fullpath -isValid ) ) { Throw "Working Directory is invalid: $path" }
            #if ( [string]::IsNullOrWhiteSpace( [IO.Path]::GetPathRoot($fullpath) )) {
            if ( -not [IO.Path]::IsPathRooted($fullpath) ) {
                    Write-Ouput "$tab ! Not Rooted path set to Parent Directory: $ParentDirectory"
                $fullpath = [IO.Path]::GetFullPath( [IO.Path]::Combine($ParentDirectory, $fullpath) )
                Write-Ouput "$tab ~ Resulting Full Path: $fullpath"
            }
            New-FolderPath -Path $fullpath -tab $tab
            $path = Set-WorkingDirectory -Path $fullpath 
            Write-Ouput "$tab + Working Directory set: $path"
            #endregion Working Directory

            #region Custom Directories
            Init-CustomVariableDirectory -Name "LogS" -Value $LogsDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Downloads" -Value $DownloadsDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Policies" -Value $PoliciesDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Temp" -Value $TempDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Scripts" -Value $ScriptsDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Desktop" -Value $DesktopDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Favorites" -Value $FavoritesDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Shortcuts" -Value $ShortcutsDirectory -tab $tab

            If ([string]::IsNullOrWhiteSpace($lgpo) ) { 
                $path = [io.path]::Combine( (Get-DownloadsDirectory), "LGPO", "lgpo.exe")

            }
            $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
            if ( -Not ( Test-Path $fullpath -PathType Leaf))
            { Throw "lgpo.exe not found: $fullpath" }
            Unblock-File -path $fullpath
            Set-LGpo -Path $fullpath

            #endregion Custom Directories
        }
        catch{
            throw;
        }
    }
    End{}
}

function Test-Directories
{
    [CmdletBinding()]
    param ()
    Begin{}
    Process{
        "get wd"
        Get-WorkingDirectory
        "get var"
        get-variable "workingDirectory" -scope Script
    }
}

function Start-VmConfig
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string[]] $Files
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string[]] $Urls
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string[]] $Json
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $tab = ""
    )
    Begin{
        Write-Ouput "$($tab)Start processing Files"
        $count = 0
    }
    Process{
        Write-Ouput $("-" * 100)
        $Files | Where-Object { -not ([string]::IsNullOrWhiteSpace($_)) } | Set-VmConfigFromFile
        Write-Ouput $("-" * 100)
        $Urls | Where-Object { -not ([string]::IsNullOrWhiteSpace($_)) } | Set-VmConfigFromUrl
        Write-Ouput $("-" * 100)
        $Json | Where-Object { -not ([string]::IsNullOrWhiteSpace($_)) } | Set-VmConfigFromJson

    }
    End{}
}

function End-VmConfig
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [switch] $UpdateLocalePolicies = $true
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [switch] $UpdateDesktop = $true
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $tab = ""
        )
    Begin{
        Write-Ouput "$($tab)Start Post processing "
        $count = 0
    }
    Process{
        if ($UpdateLocalePolicies)
        {
            Write-Ouput "$($tab) ~ Reload Locale Policies"
            #Invoke-GPUpdate -Force
            Start-Process "gpupdate" -ArgumentList "/force" -Wait
        } else { Write-Ouput "$($tab) ! Locale Policies not reloaded (use [UpdateLocalePolicies]) " }
        
        if ($UpdateDesktop)
        {
            Write-Ouput "$($tab) ~ Reload Desktop"
            Start-Process "RUNDLL32.EXE" -ArgumentList "USER32.DLL,UpdatePerUserSystemParameters 1, True" -Wait
        } else { Write-Ouput "$($tab) ! Desktop not reloaded (use [UpdateDesktop])" }
    }
    End {
        Write-Ouput "$($tab)End Post processing "
    }
}
            
function Set-VmConfigFromFile
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $File
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $tab = ""
    )
    Begin{
        Write-Ouput "$($tab)Start processing Files"
        $count = 0
    }
    Process{
        try {
            $count++
            Write-Ouput "$($tab)$(" "*2)File [$count]: $File"
            Update-VmConfigFromFile -File $File 

<#            $fullpath = [System.Environment]::ExpandEnvironmentVariables($file)
            if ( Test-Path -Path $fullpath -PathType Leaf ) {
                Write-Ouput "$tab$(" "*4)~ Read File"
                $json = Get-Content $fullpath | ConvertFrom-Json
            } else { throw "Config file not found: $fullpath" } 

            if ( ( $null = $json ) ) {
                $params = $json.Downloads
                if ( -not ( $null -eq $params )) { 
                    Write-Ouput "$tab$(" "*4)Downloads"
                    #$params | Get-FileFromUrl 
                } 
                else { Write-Ouput "$tab$(" "*4)! Downloads: nothing to process"}

                $params = $json.Favorites 
                if ( -not ( $null -eq $params )) { 
                    Write-Ouput "$tab$(" "*4)Favorites"
                    #$params | Start-ConfigCommand 
                }
                else { Write-Ouput "$tab$(" "*4)! Favorites: nothing to process"}

                $params = $json.Execute 
                if ( -not ( $null -eq $params )) { 
                    Write-Ouput "$tab$(" "*4)Execute"
                    #$params | Start-ConfigCommand 
                }
                else { Write-Ouput "$tab$(" "*4)Execute: nothing to process"}
            }#>
        }
        catch {
            throw
        }
    }
    End{
        Write-Ouput "$($tab)End processing Files"
    }
}

function Update-VmConfigFromFile
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $File
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $tab = ""
    )
    Begin{
    }
    Process{
        try {
            $fullpath = [System.Environment]::ExpandEnvironmentVariables($file)
            if ( Test-Path -Path $fullpath -PathType Leaf ) {
                Write-Ouput "$tab$(" "*4) ~ Read File..."
                $json = Get-Content -Path $fullpath -Raw #| ConvertFrom-Json
            } else { throw "Config file not found: $fullpath" } 
        
            if ( -not ( [string]::IsNullOrWhiteSpace($json) ) ) {
                Update-VmConfigFromJson -Json $json
            } else { Write-Ouput "$tab$(" "*4)! Empty File..."}
        }
        catch {
            throw
        }
    }
    End{
        #Write-Ouput "$($tab)End processing Files"
    }
}

function Update-VmConfigFromJson
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $Json
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $tab = ""
    )
    Begin{
    }
    Process{
        try {
            $shorttext = $json.Replace("`r", " ").Replace("`n", " ").Replace("    ", " ").Replace("  ", " ").SubString(0,[math]::min(50,$json.length) )
            Write-Ouput "$tab$(" "*4) ~ Validate JSON data: $shorttext..."    
            $data = $json | ConvertFrom-Json

            if ( ( $null = $data ) ) {
                Write-Ouput "$tab$(" "*4)Start Processing Data"

                $params = $data.Downloads
                if ( -not ( $null -eq $params )) { 
                    $params | Get-FileFromUrl -tab "$tab$(" "*6)" -defaultpath (Get-DownloadsDirectory)
                } 
                else { Write-Ouput "$tab$(" "*4)! Downloads: nothing to process"}

                $params = $data.Favorites 
                if ( -not ( $null -eq $params )) { 
                    $params | Add-Favorite -tab "$tab$(" "*6)" -defaultpath (Get-FavoritesDirectory)
                }
                else { Write-Ouput "$tab$(" "*4)! Favorites: nothing to process"}

                $params = $data.Shortcuts 
                if ( -not ( $null -eq $params )) { 
                    $params | Add-Shortcut -tab "$tab$(" "*6)" -defaultpath (Get-ShortcutsDirectory)
                }
                else { Write-Ouput "$tab$(" "*4)! Shorcuts: nothing to process"}

                $params = $data.Policies 
                if ( -not ( $null -eq $params )) { 
                    $params | Update-Policies -tab "$tab$(" "*6)" -defaultpath (Get-ScriptsDirectory)
                }
                else { Write-Ouput "$tab$(" "*4)Policies: nothing to process"}

                $params = $data.Execute 
                if ( -not ( $null -eq $params )) { 
                    $params | Start-ConfigCommand -tab "$tab$(" "*6)" -defaultpath (Get-ScriptsDirectory)
                }
                else { Write-Ouput "$tab$(" "*4)Execute: nothing to process"}
            } else { Write-Ouput "$tab$(" "*4)Nothing to process" }
        }
        catch {
            throw
        }
    }
    End{
        #Write-Ouput "$($tab)End processing Files"
    }
}

function Set-VmConfigFromUrl
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $Url
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $tab = ""
    )
    Begin{
        Write-Ouput "$($tab)Start processing URL"
        $count = 0
    }
    Process{
        try {
            $count++
            Write-Ouput "$tab$(" "*2)URL [$count] $Url"
            $filename = "$([guid]::NewGuid()).json"
            $fullpath = [io.path]::Combine( (Get-TempDirectory), $filename)
            Write-Ouput "$tab$(" "*4)Download to temp file: $fullpath"

            [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
            $startdate = (get-date)
            $progress = $ProgressPreference
            $ProgressPreference = "SilentlyContinue"
            Invoke-WebRequest -Uri $url -OutFile $fullpath
            $ProgressPreference = $progress
            Write-Ouput "$tab$(" "*4) ~ File downloaded [$(New-TimeSpan -Start $startdate -End (get-date))]"

            Update-VmConfigFromFile -File $fullpath 
}
        catch { throw }
    }
    End{
        Write-Ouput "$($tab)End processing URL"
    }
}

function Set-VmConfigFromJson
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $Json
        , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string] $tab = ""
    )
    Begin{
        Write-Ouput "$($tab)Start processing JSON"
        $count = 0
    }
    Process{
        $count++
#        $shorttext = $json.SubString(0,[math]::min(30,$json.length) )
#        "$tab$(" "*4)JSON [$count] $shorttext..."
        Update-VmConfigFromJson -Json $json
    }
    End{
        if ($count -eq 0) { Write-Ouput "$tab$(" "*2)Nothing to process" }
        Write-Ouput "$($tab)End processing JSON"
    }
}

