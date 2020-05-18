function Test-Test {
    begin{}
    process{
        Write-Output " test "
        $env:DefaultDownloadPath, $env:DefaultPoliciesPath | New-FolderPath
        test-LocalePolicies
    }
    end{} 
}