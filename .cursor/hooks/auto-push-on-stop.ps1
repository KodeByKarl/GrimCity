# Cursor hook: on agent stop, push any unpushed commits on this repo.
$ErrorActionPreference = "Continue"
try { [void][Console]::In.ReadToEnd() } catch {}

$repo = "c:\Users\darna\OneDrive\Desktop\GrimCity"
if (-not (Test-Path (Join-Path $repo ".git"))) {
  Write-Output "{}"
  exit 0
}

Push-Location $repo
try {
  $branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
  if ($branch -and $branch -ne "HEAD") {
    $status = git status -sb 2>$null
    if ($status -match 'ahead') {
      git push -u origin $branch 2>&1 | Out-Null
    }
  }
} finally {
  Pop-Location
}

Write-Output "{}"
exit 0
