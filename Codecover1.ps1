param (
    [string]$TestPath = "Tests\YourTests.Tests.ps1",
    [string]$ScriptUnderTest = "YourScript.ps1"
)

# Run Pester and capture coverage
$pesterResult = Invoke-Pester -Script $TestPath -CodeCoverage $ScriptUnderTest -PassThru
$coverage = $pesterResult.CodeCoverage

# Get all script lines
$scriptLines = Get-Content $ScriptUnderTest

# Build list of all analyzed and executed line numbers
$allLines = $coverage.AnalyzedCommands | ForEach-Object { $_.Extent.StartLineNumber }
$executedLines = $coverage.ExecutedCommands | ForEach-Object { $_.Extent.StartLineNumber }

# Compute uncovered lines
$uncoveredLines = $allLines | Where-Object { $_ -notin $executedLines } | Sort-Object -Unique

# Output uncovered lines
if ($uncoveredLines.Count -eq 0) {
    Write-Host "Great! All lines are covered." -ForegroundColor Green
} else {
    Write-Host "`nUncovered Lines in '$ScriptUnderTest':" -ForegroundColor Cyan
    foreach ($line in $uncoveredLines) {
        $code = $scriptLines[$line - 1].Trim()
        Write-Host "Line $line: $code" -ForegroundColor Yellow
    }
}
