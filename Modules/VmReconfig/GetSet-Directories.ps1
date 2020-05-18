#----------------------------------------------------------------------------------------------------
# Custom Directory
#----------------------------------------------------------------------------------------------------
function Set-CustomVariable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Name
        , [Parameter(Mandatory=$true)] [Object]$Value
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $Name
            Value = $Value; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

function Init-CustomVariableDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Name
        , [Parameter(Mandatory=$false)] [Object]$Value
        , [Parameter(Mandatory=$false)] [string] $tab = ""
        #, [Parameter(Mandatory=$false)] [Switch] $quiet
    )
    process {
        $Name = (Get-Culture).TextInfo.ToTitleCase($Name).Trim()
        $path = $value
        Write-Output "$($tab)Set [$name] Directory: [$value]"
        If (([string]::IsNullOrWhiteSpace($value))) { 
            Write-Output "$tab ! Missing [$name] Directory set to Working Directory: $((Get-WorkingDirectory))"
            $fullpath = [IO.Path]::GetFullPath( [IO.Path]::Combine( (Get-WorkingDirectory), $name) )
            Write-Output "$tab ~ Resulting Full Path: $fullpath"
        } else {
            $fullpath = [System.Environment]::ExpandEnvironmentVariables($path)
            If ( -not(Test-Path -Path $fullpath -isValid ) ) { Throw "$name Directory is invalid: $path" }
            if ( -not [IO.Path]::IsPathRooted($fullpath) ) {
                    Write-Output "$tab ! Not Rooted path set relative to Working Directory: $(Get-WorkingDirectory)"
                $fullpath = [IO.Path]::GetFullPath( [IO.Path]::Combine( (Get-WorkingDirectory), $fullpath) )
                Write-Output "$tab ~ Resulting Full Path: $fullpath"
            }
        }
        New-FolderPath -Path $fullpath -tab $tab
        $path = Set-CustomVariable -Name "$($name)Directory" -Value $fullpath 
        Write-Output "$tab + [$Name] Directory set: $path"
    }
}


#----------------------------------------------------------------------------------------------------
# Working directory
#----------------------------------------------------------------------------------------------------
function Get-WorkingDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-WorkingDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Logs directory
#----------------------------------------------------------------------------------------------------
function Get-LogsDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-LogsDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Download directory
#----------------------------------------------------------------------------------------------------
function Get-DownloadsDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-DownloadsDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Policies directory
#----------------------------------------------------------------------------------------------------
function Get-PoliciesDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-PoliciesDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Temp directory
#----------------------------------------------------------------------------------------------------
function Get-TempDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-TempDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Scripts directory
#----------------------------------------------------------------------------------------------------
function Get-ScriptsDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-ScriptsDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Desktop directory
#----------------------------------------------------------------------------------------------------
function Get-DesktopDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-DesktopDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Favorites directory
#----------------------------------------------------------------------------------------------------
function Get-FavoritesDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-FavoritesDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Shortcuts directory
#----------------------------------------------------------------------------------------------------0
function Get-ShortcutsDirectory {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-ShortcutsDirectory {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}

#----------------------------------------------------------------------------------------------------
# Lgpo path
#----------------------------------------------------------------------------------------------------0
function Get-Lgpo {
    [CmdletBinding()]
    Param ( [Parameter(Mandatory=$false)] [String]$Scope = "Script" )
    Process{
        try {
            Get-Variable -Name $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1] -Scope $Scope -ValueOnly -ErrorAction Stop
        } catch [System.Management.Automation.ItemNotFoundException] {
            Throw "Variable has not been properly set: $($PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1])"
        } catch{ Throw }
    }
}
function Set-Lgpo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$Path
        , [Parameter(Mandatory=$false)] [String]$Scope = "Script"
        , [Parameter(Mandatory=$false)] [String]$Option = ""
    )
    process {
        $params = @{
            Name = $PSCmdLet.MyInvocation.MyCommand.Name.Split('-', 2)[1]
            Value = $path; Scope = $Scope; Passthru = $true#; Option = 'constant'; 
        }            
        (Set-Variable @params).value
    }
}
