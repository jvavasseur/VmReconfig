param(
    [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string[]] $Files
    , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string[]] $Urls
    , [Parameter(Mandatory=$false, ValueFromPipeline = $false)] [string[]] $Json
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [switch] $pullorigin = $false
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [switch] $UpdateLocalePolicies = $true
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [switch] $UpdateDesktop = $true
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $WorkingDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $LogsDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $DownloadsDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $PoliciesDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $TempDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $ScriptsDirectory
    , [Parameter(Mandatory=$false, ValueFromPipeline = $true)] [string] $LGpo
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
    Write-Ouput "Git Pull Origin"
    & 'C:\Program Files\Git\bin\git.exe' -C $PSScriptRoot pull origin
}

#----------------------------------------------------------------------------------------------------
# Load Modules
#----------------------------------------------------------------------------------------------------
Write-Ouput "Import Modules"
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
# Start VM Config
#----------------------------------------------------------------------------------------------------
Start-VmConfig -Files $Files -Urls $Urls -Json $json

$params = @{
    UpdateLocalePolicies = $UpdateLocalePolicies 
    UpdateDesktop = $UpdateDesktop 
    tab = $tab
}
End-VmConfig @params


<#
$files.count
$urls.count
$json.count
if ( $null -eq $json ) {"xxxx"}
$files | Where-Object { -not ([string]::IsNullOrWhiteSpace($_)) } | %{ $_ }
$urls | Where-Object { -not ([string]::IsNullOrWhiteSpace($_)) } | %{ $_ }
$json | Where-Object { -not ([string]::IsNullOrWhiteSpace($_)) } | %{ $_ }
#>