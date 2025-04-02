param (
    [string]$TestPath = "Tests\YourTests.Tests.ps1",
    [string]$ScriptUnderTest = "YourScript.ps1"
)

# Run Pester with coverage and get result
$pesterResult = Invoke-Pester -Script $TestPath -CodeCoverage $ScriptUnderTest -PassThru
$coverage = $pesterResult.CodeCoverage

# Load script contents
$scriptLines = Get-Content $ScriptUnderTest

# Get full line spans for all analyzed and executed blocks
$allLineSpans = $coverage.AnalyzedCommands | ForEach-Object { $_.Extent.StartLineNumber..$_.Extent.EndLineNumber }
$executedLineSpans = $coverage.ExecutedCommands | ForEach-Object { $_.Extent.StartLineNumber..$_.Extent.EndLineNumber }

# Flatten and deduplicate
$allLines = $allLineSpans | Select-Object -Unique
$executedLines = $executedLineSpans | Select-Object -Unique

# Get actual uncovered lines
$uncoveredLines = $allLines | Where-Object { $_ -notin $executedLines } | Sort-Object

# Display
if ($uncoveredLines.Count -eq 0) {
    Write-Host "Great! All lines are covered." -ForegroundColor Green
} else {
    Write-Host "`nUncovered Lines in '$ScriptUnderTest':" -ForegroundColor Cyan
    foreach ($line in $uncoveredLines) {
        if ($line -le $scriptLines.Count) {
            $code = $scriptLines[$line - 1].Trim()
            Write-Host "Line $line: $code" -ForegroundColor Yellow
        }
    }
}
