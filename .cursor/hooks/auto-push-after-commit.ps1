# Cursor hook: after any successful `git commit`, push to origin.
# Reads hook JSON from stdin; always exits 0 (fail-open).

$ErrorActionPreference = "Continue"
try {
  $raw = [Console]::In.ReadToEnd()
} catch {
  $raw = ""
}

# Only act when the shell command looks like a git commit
if ($raw -notmatch 'git\s+commit') {
  if ($raw) { Write-Output "{}" }
  exit 0
}

$repo = "c:\Users\darna\OneDrive\Desktop\GrimCity"
if (-not (Test-Path (Join-Path $repo ".git"))) {
  Write-Output "{}"
  exit 0
}

Push-Location $repo
try {
  $branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
  if (-not $branch -or $branch -eq "HEAD") {
    Write-Output "{}"
    exit 0
  }

  $ahead = 0
  $counts = git rev-list --left-right --count "origin/$branch...HEAD" 2>$null
  if ($counts) {
    $parts = ($counts -split '\s+')
    if ($parts.Count -ge 2) { [int]$ahead = $parts[1] }
  } else {
    # No upstream yet — still try push -u
    $ahead = 1
  }

  if ($ahead -gt 0) {
    git push -u origin $branch 2>&1 | Out-Null
  }
} finally {
  Pop-Location
}

Write-Output "{}"
exit 0
