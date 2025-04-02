param (
    [string]$ScriptPath = "YourScript.ps1",
    [string]$TestPath = "Tests\YourTests.Tests.ps1"
)

# Run Pester with code coverage
$pesterConfig = [PesterConfiguration]::Default
$pesterConfig.Run.Path = $TestPath
$pesterConfig.CodeCoverage.Enabled = $true
$pesterConfig.CodeCoverage.Path = $ScriptPath
$pesterConfig.Output.Verbosity = 'Detailed'

$result = Invoke-Pester -Configuration $pesterConfig

# Collect coverage info
$coverageData = $result.CodeCoverage
$analyzed = $coverageData.AnalyzedLines
$executed = $coverageData.ExecutedLines

# Determine uncovered lines
$uncovered = $analyzed | Where-Object { $_ -notin $executed } | Sort-Object

# Read script lines
$scriptLines = Get-Content $ScriptPath

# Show uncovered lines
if ($uncovered.Count -eq 0) {
    Write-Host "Great! 100% coverage." -ForegroundColor Green
} else {
    Write-Host "`nUncovered Lines in '$ScriptPath':" -ForegroundColor Cyan
    foreach ($line in $uncovered) {
        if ($line -le $scriptLines.Count) {
            $code = $scriptLines[$line - 1].Trim()
            Write-Host "Line $line: $code" -ForegroundColor Yellow
        }
    }
}
