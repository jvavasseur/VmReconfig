function New-FolderPath {
    <#
        Create folder hierarchy
        .SYPNOSIS
        ...
    #>
    [CmdletBinding()]
    Param (
        # Parameter help description
        [Parameter(Mandatory=$true, ValueFromPipeline = $true)] [Array] $path
        , [Parameter(Mandatory=$false)] [String] $tab = ""
    )
    Begin { Write-Host "Create folder path" }
    Process {
        $path = [System.Environment]::ExpandEnvironmentVariables($path)
        if ( Test-Path -Path $path -PathType Container ) { Write-Host "$tab ~ Folder exists: $path" }
        else {
            $path.Split("\") | ForEach-Object { 
                $fullpath = if( [io.path]::IsPathRooted($_) ) { Join-Path $_ -ChildPath "" } else { (New-Item $fullpath -Name $_ -ItemType Directory -Force ).FullName } 
            }
            Write-Host "$tab ~ Folder created: $path"
        }
    }
    End{}
}