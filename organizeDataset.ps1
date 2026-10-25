<#
.SYNOPSIS
    Organizes downloaded saree images into categorized folders (PowerShell companion).
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$baseDir = Join-Path $scriptDir "dataset"
$rawDir = Join-Path $baseDir "raw"
$procDir = Join-Path $baseDir "processed"

$categories = @("silk", "cotton", "designer", "printed", "handloom", "unclassified")
foreach ($cat in $categories) {
    $dir = Join-Path $baseDir $cat
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
}
if (-not (Test-Path $procDir)) { New-Item -ItemType Directory -Force -Path $procDir | Out-Null }

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "  ORGANIZING AND VALIDATING REAL SAREE DATASET                     " -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan

$rawFiles = Get-ChildItem -Path $rawDir -Filter "*.*" | Where-Object { $_.Length -gt 512 }
$organizedCount = 0

foreach ($file in $rawFiles) {
    $name = $file.Name.ToLower()
    $targetCat = "unclassified"
    
    if ($name -like "silk*") { $targetCat = "silk" }
    elseif ($name -like "cotton*") { $targetCat = "cotton" }
    elseif ($name -like "designer*") { $targetCat = "designer" }
    elseif ($name -like "printed*") { $targetCat = "printed" }
    elseif ($name -like "handloom*") { $targetCat = "handloom" }

    $destCatFile = Join-Path $baseDir "$targetCat\$($file.Name)"
    $destProcFile = Join-Path $procDir $file.Name

    if (-not (Test-Path $destCatFile)) {
        Copy-Item -Path $file.FullName -Destination $destCatFile -Force
    }
    if (-not (Test-Path $destProcFile)) {
        Copy-Item -Path $file.FullName -Destination $destProcFile -Force
    }
    $organizedCount++
}

Write-Host "Successfully validated and organized $organizedCount images into dataset folders!" -ForegroundColor Green
Write-Host ""
foreach ($cat in $categories) {
    $count = (Get-ChildItem -Path (Join-Path $baseDir $cat) -Filter "*.*").Count
    Write-Host ("  - dataset/{0,-13}: {1} images" -f $cat, $count) -ForegroundColor Yellow
}
Write-Host ("  - dataset/processed  : {0} images" -f (Get-ChildItem -Path $procDir -Filter "*.*").Count) -ForegroundColor Green
Write-Host "====================================================================" -ForegroundColor Cyan
