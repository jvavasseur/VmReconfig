param(
    [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $Files
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $Urls
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $Json
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [switch] $pullorigin = $false
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $WorkingDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $LogsDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $DownloadsDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $PoliciesDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $TempDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $ScriptsDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $DesktopDirectory = "%ALLUSERSPROFILE%\Desktop"
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $FavoritesDirectory = "%ALLUSERSPROFILE%\Desktop"
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $shortcutsDirectory = "%ALLUSERSPROFILE%\Desktop"
)

#----------------------------------------------------------------------------------------------------
# Start
#----------------------------------------------------------------------------------------------------
Clear-Host
Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"
#----------------------------------------------------------------------------------------------------
# Settings
#----------------------------------------------------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#----------------------------------------------------------------------------------------------------
# Repository
#----------------------------------------------------------------------------------------------------
if ( $pullorigin ) {
    Write-Host "Git Pull Origin"
    & 'C:\Program Files\Git\bin\git.exe' -C $scripts pull origin
}

#----------------------------------------------------------------------------------------------------
# Load Modules
#----------------------------------------------------------------------------------------------------
Write-Host "Import Modules"
$env:PSModulePath = ($env:PSModulePath.Split(";") + "$PSScriptRoot\Modules" | Select-Object -Unique ) -join ';'
Import-Module posh-git -Force
Import-Module VmReconfig -Force -Verbose;
#Install-Module PowerShellLogging

#----------------------------------------------------------------------------------------------------
# Init
#----------------------------------------------------------------------------------------------------
$directories = @{}
($MyInvocation.MyCommand.Parameters).Keys | ForEach-Object {
    if ( ( (get-commonparameters -IncludeOptionnalParameters) -notcontains $_ ) -and ( (Get-Command Initialize-Directories).Parameters.Keys -contains $_ ) )
    {
        if ( $MyInvocation.BoundParameters.keys -contains $_ ) { $directories.add($_, $PSBoundParameters.Item($_)) }
            #"PARAM '$($_)' = '$($PSBoundParameters.Item($_))'"
        else {
            if ( $null -ne (Get-Variable -Name $_ -ErrorAction SilentlyContinue -ValueOnly) )
            { $directories.add($_, (Get-Variable -Name $_ -ErrorAction SilentlyContinue -ValueOnly) ) }
            #"default '$($_)' = '$(Get-Variable -Name $_ -ErrorAction SilentlyContinue -ValueOnly)'" 
            #else { "missing  '$($_)' =" }
        }
    }
}
Initialize-Directories @directories

#----------------------------------------------------------------------------------------------------
# Init
#----------------------------------------------------------------------------------------------------
$files | Set-VmConfigFromFile
$urls | Set-VmConfigFromUrl
$json | Set-VmConfigFromJson
