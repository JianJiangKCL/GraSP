$sjtuSteps = @(2,5,6,8,11,12,15,17)
$output = @()

foreach ($split in @('train','test')) {
    $path = "D:\proj\grasp\annotations\annotations\grasp_long-term_$split.json"
    $data = Get-Content -Raw $path | ConvertFrom-Json
    
    # Group by case
    $grouped = @{}
    foreach ($ann in $data.annotations) {
        if ($sjtuSteps -contains $ann.steps) {
            $case = ($ann.image_name -split '/')[0]
            $step = $ann.steps
            $frameNum = [int]($ann.image_name -replace '.*/' -replace '\.jpg')
            $key = "$case|$step"
            if (-not $grouped.ContainsKey($key)) { $grouped[$key] = @() }
            $grouped[$key] += $frameNum
        }
    }
    
    $output += "## $($split.ToUpper()) split"
    $output += ""
    
    $cases = $grouped.Keys | ForEach-Object { ($_ -split '\|')[0] } | Sort-Object -Unique
    
    foreach ($case in $cases) {
        $caseTotal = 0
        $caseLines = @()
        
        foreach ($s in ($sjtuSteps | Sort-Object)) {
            $key = "$case|$s"
            if ($grouped.ContainsKey($key)) {
                $nums = $grouped[$key] | Sort-Object
                $count = $nums.Count
                $caseTotal += $count
                
                # Find continuous segments (gap > 30 means new segment)
                $segments = @()
                $segStart = $nums[0]
                $segEnd = $nums[0]
                for ($i = 1; $i -lt $nums.Count; $i++) {
                    if ($nums[$i] - $nums[$i-1] -gt 30) {
                        $segments += "$($segStart.ToString('D5'))~$($segEnd.ToString('D5'))($($segEnd - $segStart + 1))"
                        $segStart = $nums[$i]
                    }
                    $segEnd = $nums[$i]
                }
                $segments += "$($segStart.ToString('D5'))~$($segEnd.ToString('D5'))($($segEnd - $segStart + 1))"
                
                $segStr = $segments -join ', '
                $caseLines += "| step_$s | $count | $segStr |"
            }
        }
        
        $output += "### $case ($caseTotal frames)"
        $output += ""
        $output += "| Step | Count | Segments (start~end(span)) |"
        $output += "|------|-------|---------------------------|"
        $output += $caseLines
        $output += ""
    }
    $output += "---"
    $output += ""
}

$output -join "`n" | Out-File -FilePath "D:\proj\grasp\sjtu_segments.md" -Encoding utf8
Write-Host "Done. Output: sjtu_segments.md"
