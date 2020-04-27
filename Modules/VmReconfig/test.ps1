function Test-Test {
    begin{}
    process{
        Write-Host " test "
        $env:DefaultDownloadPath, $env:DefaultPoliciesPath | New-FolderPath
        test-LocalePolicies
    }
    end{} 
}