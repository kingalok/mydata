param (
    [string]$ScriptPath = "YourScript.ps1",
    [string]$TestPath = "Tests\YourTests.Tests.ps1"
)

# Run Pester with coverage
$pesterConfig = [PesterConfiguration]::Default
$pesterConfig.Run.Path = $TestPath
$pesterConfig.CodeCoverage.Enabled = $true
$pesterConfig.CodeCoverage.Path = $ScriptPath
$pesterConfig.Output.Verbosity = 'Detailed'

$result = Invoke-Pester -Configuration $pesterConfig

# Collect line-level info
$coverageData = $result.CodeCoverage
$analyzed = $coverageData.AnalyzedLines | Sort-Object -Unique
$executed = $coverageData.ExecutedLines | Sort-Object -Unique
$uncovered = $analyzed | Where-Object { $_ -notin $executed }

$total = $analyzed.Count
$covered = $executed.Count
$missed = $uncovered.Count
$coveragePercent = if ($total -eq 0) { 0 } else { [math]::Round(($covered / $total) * 100, 2) }

# Print summary
Write-Host "`nCode Coverage Summary:" -ForegroundColor Cyan
Write-Host "Total Lines Analyzed: $total"
Write-Host "Lines Covered      : $covered"
Write-Host "Lines Missed       : $missed"
Write-Host "Coverage %         : $coveragePercent%" -ForegroundColor Green

# Print missed lines
if ($missed -eq 0) {
    Write-Host "`nGreat! All lines are covered." -ForegroundColor Green
} else {
    $scriptLines = Get-Content $ScriptPath
    Write-Host "`nUncovered Lines in '$ScriptPath':" -ForegroundColor Yellow
    foreach ($line in $uncovered) {
        if ($line -le $scriptLines.Count) {
            $code = $scriptLines[$line - 1].Trim()
            Write-Host "Line $line: $code"
        }
    }
}
