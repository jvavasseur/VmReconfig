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
        if ($quiet) { Write-Host "$tab Create folder path" }
    }
    Process {
        $Path = [System.Environment]::ExpandEnvironmentVariables($Path)
        if ( Test-Path -Path $Path -PathType Container ) { Write-Host "$tab = Folder exists: $Path" }
        else {
            $path.Split("\") | ForEach-Object { 
                $fullpath = if( [io.path]::IsPathRooted($_) ) { Join-Path $_ -ChildPath "" } else { (New-Item $fullpath -Name $_ -ItemType Directory -Force ).FullName } 
            }
            Write-Host "$tab + Folder created: $path"
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
        , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $tab = ""
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
            Write-host "$($tab)Set Working Directory: [$path]"
            $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
            If ( -not(Test-Path -Path $fullpath -isValid ) ) { Throw "Working Directory is invalid: $path" }
            #if ( [string]::IsNullOrWhiteSpace( [IO.Path]::GetPathRoot($fullpath) )) {
            if ( -not [IO.Path]::IsPathRooted($fullpath) ) {
                    Write-host "$tab ! Not Rooted path set to Parent Directory: $ParentDirectory"
                $fullpath = [IO.Path]::GetFullPath( [IO.Path]::Combine($ParentDirectory, $fullpath) )
                Write-host "$tab ~ Resulting Full Path: $fullpath"
            }
            New-FolderPath -Path $fullpath -tab $tab
            $path = Set-WorkingDirectory -Path $fullpath 
            Write-Host "$tab + Working Directory set: $path"
            #endregion Working Directory

            #region Custom Directories
            Init-CustomVariableDirectory -Name "LogS" -Value $LogsDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Download" -Value $DownloadDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Policies" -Value $PoliciesDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Temp" -Value $TempDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Scripts" -Value $ScriptsDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Desktop" -Value $DesktopDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Favorites" -Value $FavoritesDirectory -tab $tab
            Init-CustomVariableDirectory -Name "Shortcuts" -Value $ShortcutsDirectory -tab $tab

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

function Set-VmConfigFromFile
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $File
    )
    Begin{
        Write-Host "Start processing Files"
        $count = 0
    }
    Process{
        $count++
        "[$count] $File"
    }
    End{
        Write-Host "End processing Files"
    }
}

function Set-VmConfigFromUrl
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $Url
    )
    Begin{
        Write-Host "Start processing Files"
        $count = 0
    }
    Process{
        $count++
        "[$count] $Url"
    }
    End{
        Write-Host "End processing Files"
    }
}

function Set-VmConfigFromJson
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $Json
    )
    Begin{
        Write-Host "Start processing Files"
        $count = 0
    }
    Process{
        $count++
        "[$count] $Json"
    }
    End{
        Write-Host "End processing Files"
    }
}

