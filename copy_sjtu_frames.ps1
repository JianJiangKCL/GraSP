$sjtuSteps = @(2,5,6,8,11,12,15,17)
$srcRoot = "D:\proj\grasp\frames"
$dstRoot = "D:\proj\grasp\sjtu_frames"

if (-not (Test-Path $dstRoot)) { New-Item -ItemType Directory -Path $dstRoot | Out-Null }

$totalCopied = 0

foreach ($split in @('train','test')) {
    $path = "D:\proj\grasp\annotations\annotations\grasp_long-term_$split.json"
    Write-Host "Loading $split annotations..." -ForegroundColor Cyan
    $data = Get-Content -Raw $path | ConvertFrom-Json
    
    $frameSet = @{}
    
    foreach ($ann in $data.annotations) {
        if ($sjtuSteps -contains $ann.steps) {
            $imgName = $ann.image_name
            $case = ($imgName -split '/')[0]
            $frame = ($imgName -split '/')[1]
            $step = $ann.steps
            $key = "$case|step_$step|$frame"
            if (-not $frameSet.ContainsKey($key)) {
                $frameSet[$key] = $true
            }
        }
    }
    
    Write-Host "$split : $($frameSet.Count) frames to copy" -ForegroundColor Green
    
    $count = 0
    foreach ($key in $frameSet.Keys) {
        $parts = $key -split '\|'
        $case = $parts[0]
        $stepDir = $parts[1]
        $frame = $parts[2]
        
        $dstDir = Join-Path $dstRoot "$case\$stepDir"
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
        
        $srcFile = Join-Path $srcRoot "$case\$frame"
        $dstFile = Join-Path $dstDir $frame
        
        if (Test-Path $srcFile) {
            Copy-Item -Path $srcFile -Destination $dstFile -Force
            $count++
        } else {
            Write-Host "  MISSING: $srcFile" -ForegroundColor Yellow
        }
        
        if ($count % 2000 -eq 0 -and $count -gt 0) {
            Write-Host "  Copied $count / $($frameSet.Count) ..." -ForegroundColor Gray
        }
    }
    
    Write-Host "$split done: copied $count frames" -ForegroundColor Green
    $totalCopied += $count
}

Write-Host ""
Write-Host "All done! Total copied: $totalCopied frames" -ForegroundColor Cyan
Write-Host "Output directory: $dstRoot" -ForegroundColor Cyan
