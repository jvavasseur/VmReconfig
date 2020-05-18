function Test-Test {
    begin{}
    process{
        Write-Ouput " test "
        $env:DefaultDownloadPath, $env:DefaultPoliciesPath | New-FolderPath
        test-LocalePolicies
    }
    end{} 
}