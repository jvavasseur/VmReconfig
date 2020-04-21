Clear-Host
Get-Date -Format "dddd MM/dd/yyyy HH:mm:ss"

$env:PSModulePath = $env:PSModulePath.Split(";") + "$PSScriptRoot\Modules" | Select-Object -Unique | Join-String -Property {$_} -Separator ";"

$manifest = @{
    Path = "$PSScriptRoot\VmReconfig.psd1"
    NestedModules = @('VmReconfig-Download', 'VmReconfig-Shortcut')
    Guid = (New-Guid)
    ModuleVersion = '1.0.0.0'
    Description = 'VM Reconfiguration module'
    PowerShellVersion = $PSVersionTable.PSVersion.ToString() 
    Author = "Julien Vavasseur"
}
#-FunctionsToExport @('Write-Foo', 'Write-Bar','Write-FooBar', 'Write-FooBarBaz')
New-ModuleManifest  @manifest

