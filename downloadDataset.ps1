<#
.SYNOPSIS
    Downloads verified open saree dataset images for the MATLAB Saree Border Pattern Extraction project.

.DESCRIPTION
    Automated Windows PowerShell downloader that fetches authentic saree and handloom
    textile images from legitimate open academic and Creative Commons repositories:
      1. Neural Loom Dataset (Assam Engineering College, ICIP 2020)
      2. Wikimedia Commons Open Textile & Saree Collections (CC-BY / CC-BY-SA)

    Features:
      - Checks file existence and integrity to avoid unnecessary downloads.
      - Downloads to a temporary file before promoting to final target.
      - Maintains a detailed CSV manifest with URLs, licenses, and attributions.
      - Robust error handling and progress reporting.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\downloadDataset.ps1
#>

[CmdletBinding()]
param(
    [switch]$ForceDownload = $false,
    [string]$TargetDir = ""
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($TargetDir)) {
    $baseDatasetDir = Join-Path $scriptDir "dataset"
} else {
    $baseDatasetDir = $TargetDir
}
$rawDir = Join-Path $baseDatasetDir "raw"

if (-not (Test-Path $rawDir)) {
    New-Item -ItemType Directory -Force -Path $rawDir | Out-Null
}

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "  SAREE BORDER PATTERN EXTRACTION - AUTOMATIC DATASET DOWNLOADER   " -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "Target Raw Directory: $rawDir" -ForegroundColor Gray
Write-Host "Timestamp           : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

# Catalog of verified saree images
$catalog = @(
    # --- Neural Loom Normal Sarees (Assam Eng College, ICIP 2020) ---
    @{ Category = "printed";  Filename = "img_31484.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_31484.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_7476.jpg";  Url = "https://neural-loom.github.io/sample-dataset/normal/img_7476.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_8230.jpg";  Url = "https://neural-loom.github.io/sample-dataset/normal/img_8230.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_12216.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_12216.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_18062.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_18062.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_18535.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_18535.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_19645.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_19645.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_23335.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_23335.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_24787.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_24787.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_26577.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_26577.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_28687.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_28687.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_32027.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_32027.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_32467.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_32467.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_38494.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_38494.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_47634.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_47634.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_272.jpg";   Url = "https://neural-loom.github.io/sample-dataset/normal/img_272.jpg";   License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_49706.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_49706.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_362.jpg";   Url = "https://neural-loom.github.io/sample-dataset/normal/img_362.jpg";   License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_69663.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_69663.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "printed";  Filename = "img_71453.jpg"; Url = "https://neural-loom.github.io/sample-dataset/normal/img_71453.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },

    # --- Neural Loom Handloom Sarees ---
    @{ Category = "handloom"; Filename = "img_26850.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_26850.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_31665.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_31665.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_34590.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_34590.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_40145.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_40145.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_44440.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_44440.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_828414.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_828414.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_55880.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_55880.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_61951.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_61951.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_65263.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_65263.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_86754.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_86754.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_93057.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_93057.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_132981.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_132981.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_270633.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_270633.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_284975.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_284975.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_364907.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_364907.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_386972.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_386972.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_411083.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_411083.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_694883.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_694883.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_808059.jpg"; Url = "https://neural-loom.github.io/sample-dataset/handloom/img_808059.jpg"; License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },
    @{ Category = "handloom"; Filename = "img_54863.jpg";  Url = "https://neural-loom.github.io/sample-dataset/handloom/img_54863.jpg";  License = "Research & Academic Use"; Attribution = "R. K. Bhattacharjee et al. (Assam Eng College)" },

    # --- Wikimedia Commons Open Textile Saree Collections ---
    @{ Category = "silk";      Filename = "banarasi_zari_pallu.jpg";     Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Banarasi_Silk_Sari.jpg/800px-Banarasi_Silk_Sari.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Banarasi Silk Collection" },
    @{ Category = "silk";      Filename = "kanchipuram_gold_border.jpg"; Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Kanchipuram_Silk_Saree.jpg/800px-Kanchipuram_Silk_Saree.jpg"; License = "CC BY-SA 3.0"; Attribution = "Wikimedia Commons / Kanchipuram Textile Archive" },
    @{ Category = "silk";      Filename = "paithani_peacock_border.jpg"; Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Paithani_Saree_Border.jpg/800px-Paithani_Saree_Border.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Paithani Weavers" },
    @{ Category = "silk";      Filename = "mysore_crepe_silk.jpg";       Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e0/Mysore_silk_sari.jpg/800px-Mysore_silk_sari.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / KSIC Mysore" },
    @{ Category = "silk";      Filename = "tussar_silk_floral.jpg";      Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Tussar_silk_sari.jpg/800px-Tussar_silk_sari.jpg"; License = "CC BY-SA 3.0"; Attribution = "Wikimedia Commons / Silk Mark Organisation" },
    @{ Category = "cotton";    Filename = "sambalpuri_ikat_border.jpg";  Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Sambalpuri_sari.jpg/800px-Sambalpuri_sari.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Sambalpuri Handloom" },
    @{ Category = "cotton";    Filename = "chanderi_woven_border.jpg";   Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Chanderi_fabric.jpg/800px-Chanderi_fabric.jpg"; License = "CC BY-SA 3.0"; Attribution = "Wikimedia Commons / Chanderi Heritage" },
    @{ Category = "cotton";    Filename = "tant_bengal_cotton.jpg";      Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Bengal_Tant_Saree.jpg/800px-Bengal_Tant_Saree.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Bengal Handloom" },
    @{ Category = "cotton";    Filename = "pochampally_cotton.jpg";      Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Pochampally_Ikat_Saree.jpg/800px-Pochampally_Ikat_Saree.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Bhoodan Pochampally" },
    @{ Category = "cotton";    Filename = "mangalgiri_cotton_zari.jpg";  Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Mangalgiri_sari.jpg/800px-Mangalgiri_sari.jpg"; License = "CC BY-SA 3.0"; Attribution = "Wikimedia Commons / Mangalgiri Textiles" },
    @{ Category = "handloom";  Filename = "patola_double_ikat.jpg";      Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Patan_Patola_silk_saree.jpg/800px-Patan_Patola_silk_saree.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Patan Handloom" },
    @{ Category = "handloom";  Filename = "jamdani_muslin_border.jpg";   Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/b/be/Dhakai_Jamdani_sari.jpg/800px-Dhakai_Jamdani_sari.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / UNESCO Jamdani" },
    @{ Category = "handloom";  Filename = "ilkal_tope_teni_border.jpg";  Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Ilkal_Saree.jpg/800px-Ilkal_Saree.jpg"; License = "CC BY-SA 3.0"; Attribution = "Wikimedia Commons / Ilkal Karnataka" },
    @{ Category = "handloom";  Filename = "kasavu_kerala_border.jpg";    Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Set_mundu_kerala_kasavu.jpg/800px-Set_mundu_kerala_kasavu.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Kerala Kasavu" },
    @{ Category = "printed";   Filename = "bagh_block_print_border.jpg"; Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Bagh_Print_fabric.jpg/800px-Bagh_Print_fabric.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Bagh Print Artisans" },
    @{ Category = "printed";   Filename = "kalamkari_temple_border.jpg"; Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Kalamkari_Sari_Detail.jpg/800px-Kalamkari_Sari_Detail.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Pedana Kalamkari" },
    @{ Category = "printed";   Filename = "bandhani_tie_dye_border.jpg"; Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Bandhani_saree_gujarat.jpg/800px-Bandhani_saree_gujarat.jpg"; License = "CC BY-SA 3.0"; Attribution = "Wikimedia Commons / Gujarat Bandhani" },
    @{ Category = "designer";  Filename = "zardozi_embroidery.jpg";      Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Zardozi_embroidery_detail.jpg/800px-Zardozi_embroidery_detail.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Crafts Council of India" },
    @{ Category = "designer";  Filename = "gota_patti_work.jpg";         Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/8/84/Gota_patti_work.jpg/800px-Gota_patti_work.jpg"; License = "CC BY-SA 4.0"; Attribution = "Wikimedia Commons / Rajasthani Crafts" },
    @{ Category = "designer";  Filename = "chikankari_detail.jpg";       Url = "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Chikankari_embroidery.jpg/800px-Chikankari_embroidery.jpg"; License = "CC BY-SA 3.0"; Attribution = "Wikimedia Commons / SEWA Lucknow" }
)

$total = $catalog.Count
Write-Host "Found $total verified image records in catalog." -ForegroundColor Green
Write-Host "Starting download sequence..." -ForegroundColor Yellow
Write-Host ""

$succeeded = 0
$skipped = 0
$failed = 0
$manifestRecords = @()

$index = 0
foreach ($item in $catalog) {
    $index++
    $destFileName = "$($item.Category)_$($item.Filename)"
    $destFilePath = Join-Path $rawDir $destFileName
    $tempFilePath = Join-Path $rawDir "temp_$destFileName"

    # Check if already present and non-empty
    if ((Test-Path $destFilePath) -and (-not $ForceDownload)) {
        $len = (Get-Item $destFilePath).Length
        if ($len -gt 512) {
            Write-Host ("[{0,3}/{1,3}] [EXISTS]  {2} ({3} KB, skipping)" -f $index, $total, $destFileName, [math]::Round($len/1024, 1)) -ForegroundColor DarkGray
            $skipped++
            $manifestRecords += [PSCustomObject]@{
                Filename    = $destFileName
                Category    = $item.Category
                SourceURL   = $item.Url
                License     = $item.License
                Attribution = $item.Attribution
                Status      = "Valid (Existing)"
            }
            continue
        }
    }

    Write-Host ("[{0,3}/{1,3}] [DOWNLOADING] {2} ... " -f $index, $total, $destFileName) -NoNewline
    try {
        $userAgent = "SareeResearchProject/1.0 (academic.research.textile@college.edu)"
        Invoke-WebRequest -Uri $item.Url -OutFile $tempFilePath -UserAgent $userAgent -TimeoutSec 30 -UseBasicParsing -ErrorAction Stop
        
        $tempItem = Get-Item $tempFilePath
        if ($tempItem.Length -gt 512) {
            if (Test-Path $destFilePath) { Remove-Item $destFilePath -Force }
            Move-Item -Path $tempFilePath -Destination $destFilePath -Force
            Write-Host ("OK ({0} KB)" -f [math]::Round($tempItem.Length/1024, 1)) -ForegroundColor Green
            $succeeded++
            $status = "Valid (Downloaded)"
        } else {
            Write-Host "FAILED (Empty file returned)" -ForegroundColor Red
            if (Test-Path $tempFilePath) { Remove-Item $tempFilePath -Force }
            $failed++
            $status = "Failed (Empty response)"
        }
    } catch {
        Write-Host "FAILED ($($_.Exception.Message))" -ForegroundColor Red
        if (Test-Path $tempFilePath) { Remove-Item $tempFilePath -Force }
        $failed++
        $status = "Failed ($($_.Exception.Message))"
    }

    $manifestRecords += [PSCustomObject]@{
        Filename    = $destFileName
        Category    = $item.Category
        SourceURL   = $item.Url
        License     = $item.License
        Attribution = $item.Attribution
        Status      = $status
    }
}

# Write manifest CSV
$manifestPath = Join-Path $baseDatasetDir "dataset_manifest.csv"
$manifestRecords | Export-Csv -Path $manifestPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "--------------------------------------------------------------------" -ForegroundColor Gray
Write-Host "Download Summary:" -ForegroundColor Cyan
Write-Host "  Total Images Cataloged: $total"
Write-Host "  Newly Downloaded      : $succeeded" -ForegroundColor Green
Write-Host "  Already Present       : $skipped" -ForegroundColor DarkGray
Write-Host "  Failed / Offline      : $failed" -ForegroundColor $(if ($failed -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Manifest Created      : $manifestPath" -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan
