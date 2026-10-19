Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = "Stop"
$POUND = [char]0xA3  # pound sign

$base = "C:\Users\Kanch\Downloads\image\codealpha_tasks\task3_data_visualization"
$outDir = Join-Path $base "charts"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$csv = Import-Csv (Join-Path $base "books_dataset.csv")
$prices = @($csv | ForEach-Object { [double]$_.price_gbp })
$ratings = @($csv | ForEach-Object { [int]$_.rating })
$titles = @($csv | ForEach-Object { $_.title })
$n = $prices.Count

$C_BLUE   = [System.Drawing.Color]::FromArgb(70,130,180)
$C_GREEN  = [System.Drawing.Color]::FromArgb(46,139,87)
$C_PURPLE = [System.Drawing.Color]::FromArgb(147,112,219)
$C_ORANGE = [System.Drawing.Color]::FromArgb(255,140,0)
$C_RED    = [System.Drawing.Color]::FromArgb(220,20,60)
$C_GRAY   = [System.Drawing.Color]::FromArgb(130,130,130)
$C_GRID   = [System.Drawing.Color]::FromArgb(232,232,232)
$C_TEXT   = [System.Drawing.Color]::FromArgb(40,40,40)

$fontTitle = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fontLabel = New-Object System.Drawing.Font("Segoe UI", 10)
$fontTick  = New-Object System.Drawing.Font("Segoe UI", 8)
$brushText = New-Object System.Drawing.SolidBrush($C_TEXT)
$brushGray = New-Object System.Drawing.SolidBrush($C_GRAY)
$penGrid   = New-Object System.Drawing.Pen($C_GRID, 1)
$penAxis   = New-Object System.Drawing.Pen($C_GRAY, 1)

function New-Canvas([int]$w, [int]$h) {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    $g.Clear([System.Drawing.Color]::White)
    return @{ Bmp = $bmp; G = $g }
}
function Save-Canvas($c, [string]$path) {
    $c.Bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $c.G.Dispose(); $c.Bmp.Dispose()
    Write-Host "saved $(Split-Path $path -Leaf)"
}
function FillRect($g, $color, $x, $y, $w, $h) {
    $b = New-Object System.Drawing.SolidBrush($color)
    $g.FillRectangle($b, [float]$x, [float]$y, [float]$w, [float]$h)
    $b.Dispose()
}
function DrawAxes($g, $left, $top, $right, $bottom) {
    $g.DrawLine($penAxis, [float]$left, [float]$top, [float]$left, [float]$bottom)
    $g.DrawLine($penAxis, [float]$left, [float]$bottom, [float]$right, [float]$bottom)
}
function FormatNum([double]$v) { return ("{0:N0}" -f $v) }

# ============================================================
# 1. Price distribution (histogram)
# ============================================================
$c = New-Canvas 1000 650; $g = $c.G
$left = 90; $top = 80; $right = 950; $bottom = 560
$pw = $right - $left; $ph = $bottom - $top
$g.DrawString("Distribution of Book Prices", $fontTitle, $brushText, 90, 22)

$min = ($prices | Measure-Object -Minimum).Minimum
$max = ($prices | Measure-Object -Maximum).Maximum
$bins = 20
$binW = ($max - $min) / $bins
$counts = New-Object 'int[]' $bins
foreach ($p in $prices) {
    $idx = [int][Math]::Floor(($p - $min) / $binW)
    if ($idx -ge $bins) { $idx = $bins - 1 }
    if ($idx -lt 0) { $idx = 0 }
    $counts[$idx]++
}
$maxCount = ($counts | Measure-Object -Maximum).Maximum
for ($i = 0; $i -le 4; $i++) {
    $y = $bottom - ($ph * $i / 4)
    $g.DrawLine($penGrid, [float]$left, [float]$y, [float]$right, [float]$y)
    $g.DrawString((FormatNum ([double]($maxCount * $i / 4))), $fontTick, $brushGray, 45, $y - 8)
}
for ($i = 0; $i -lt $bins; $i++) {
    $x = $left + ($pw * $i / $bins)
    $bw = $pw / $bins
    $bh = if ($maxCount -gt 0) { $ph * $counts[$i] / $maxCount } else { 0 }
    $y = $bottom - $bh
    FillRect $g $C_BLUE $x $y ($bw - 2) $bh
}
DrawAxes $g $left $top $right $bottom
for ($i = 0; $i -le 5; $i++) {
    $xval = $min + ($max - $min) * $i / 5
    $x = $left + $pw * $i / 5
    $g.DrawString((FormatNum $xval), $fontTick, $brushGray, [float]($x - 10), [float]($bottom + 8))
}
$g.DrawString("Price (GBP)", $fontLabel, $brushText, [float]($left + $pw / 2 - 30), [float]($bottom + 32))
$g.DrawString("Number of Books", $fontLabel, $brushText, 20, 45)
Save-Canvas $c (Join-Path $outDir "01_price_distribution.png")

# ============================================================
# 2. Rating distribution (bar)
# ============================================================
$c = New-Canvas 850 600; $g = $c.G
$left = 90; $top = 80; $right = 800; $bottom = 520
$pw = $right - $left; $ph = $bottom - $top
$g.DrawString("Number of Books by Star Rating", $fontTitle, $brushText, 90, 22)
$counts = @(0,0,0,0,0)
foreach ($r in $ratings) { if ($r -ge 1 -and $r -le 5) { $counts[$r-1]++ } }
$maxCount = ($counts | Measure-Object -Maximum).Maximum
for ($i = 0; $i -le 4; $i++) {
    $y = $bottom - ($ph * $i / 4)
    $g.DrawLine($penGrid, [float]$left, [float]$y, [float]$right, [float]$y)
    $g.DrawString((FormatNum ([double]($maxCount * $i / 4))), $fontTick, $brushGray, 45, $y - 8)
}
$slot = $pw / 5
for ($i = 0; $i -lt 5; $i++) {
    $bw = $slot * 0.6
    $x = $left + $slot * $i + ($slot - $bw) / 2
    $bh = if ($maxCount -gt 0) { $ph * $counts[$i] / $maxCount } else { 0 }
    $y = $bottom - $bh
    FillRect $g $C_GREEN $x $y $bw $bh
    $g.DrawString($counts[$i].ToString(), $fontLabel, $brushText, [float]($x + $bw/2 - 10), [float]($y - 20))
    $g.DrawString(($i + 1).ToString(), $fontLabel, $brushText, [float]($x + $bw/2 - 5), [float]($bottom + 8))
}
DrawAxes $g $left $top $right $bottom
$g.DrawString("Rating (stars)", $fontLabel, $brushText, [float]($left + $pw/2 - 40), [float]($bottom + 32))
$g.DrawString("Count", $fontLabel, $brushText, 20, 45)
Save-Canvas $c (Join-Path $outDir "02_rating_distribution.png")

# ============================================================
# 3. Average price by rating
# ============================================================
$c = New-Canvas 850 600; $g = $c.G
$left = 90; $top = 80; $right = 800; $bottom = 520
$pw = $right - $left; $ph = $bottom - $top
$g.DrawString("Average Price by Rating", $fontTitle, $brushText, 90, 22)
$sums = @(0.0,0.0,0.0,0.0,0.0); $cnts = @(0,0,0,0,0)
for ($i = 0; $i -lt $n; $i++) { $r = $ratings[$i]; $sums[$r-1] += $prices[$i]; $cnts[$r-1]++ }
$avgs = @(); for ($r = 1; $r -le 5; $r++) { if ($cnts[$r-1] -gt 0) { $avgs += $sums[$r-1]/$cnts[$r-1] } else { $avgs += 0 } }
$maxVal = ($avgs | Measure-Object -Maximum).Maximum
for ($i = 0; $i -le 4; $i++) {
    $y = $bottom - ($ph * $i / 4)
    $g.DrawLine($penGrid, [float]$left, [float]$y, [float]$right, [float]$y)
    $g.DrawString(("${POUND}" + (FormatNum ([double]($maxVal * $i / 4)))), $fontTick, $brushGray, 40, $y - 8)
}
$slot = $pw / 5
for ($i = 0; $i -lt 5; $i++) {
    $bw = $slot * 0.6
    $x = $left + $slot * $i + ($slot - $bw) / 2
    $bh = if ($maxVal -gt 0) { $ph * $avgs[$i] / $maxVal } else { 0 }
    $y = $bottom - $bh
    FillRect $g $C_PURPLE $x $y $bw $bh
    $g.DrawString(("${POUND}" + ("{0:N1}" -f $avgs[$i])), $fontTick, $brushText, [float]($x + $bw/2 - 18), [float]($y - 18))
    $g.DrawString(($i + 1).ToString(), $fontLabel, $brushText, [float]($x + $bw/2 - 5), [float]($bottom + 8))
}
DrawAxes $g $left $top $right $bottom
$g.DrawString("Rating (stars)", $fontLabel, $brushText, [float]($left + $pw/2 - 40), [float]($bottom + 32))
$g.DrawString("Average Price (GBP)", $fontLabel, $brushText, 20, 45)
Save-Canvas $c (Join-Path $outDir "03_avg_price_by_rating.png")

# ============================================================
# 4. Price spread by rating (boxplot)
# ============================================================
function Quantile($sorted, [double]$q) {
    $m = $sorted.Count
    if ($m -eq 0) { return 0 }
    $pos = ($m - 1) * $q
    $lo = [int][Math]::Floor($pos); $hi = [int][Math]::Ceiling($pos)
    if ($lo -eq $hi) { return $sorted[$lo] }
    return $sorted[$lo] + ($sorted[$hi] - $sorted[$lo]) * ($pos - $lo)
}
$c = New-Canvas 950 620; $g = $c.G
$left = 90; $top = 80; $right = 900; $bottom = 530
$pw = $right - $left; $ph = $bottom - $top
$g.DrawString("Price Spread by Rating", $fontTitle, $brushText, 90, 22)
$groups = @{}
for ($r = 1; $r -le 5; $r++) { $groups[$r] = New-Object System.Collections.Generic.List[double] }
for ($i = 0; $i -lt $n; $i++) { $groups[$ratings[$i]].Add($prices[$i]) }
$gmin = $min; $gmax = $max
for ($i = 0; $i -le 4; $i++) {
    $y = $bottom - ($ph * $i / 4)
    $g.DrawLine($penGrid, [float]$left, [float]$y, [float]$right, [float]$y)
    $g.DrawString(("${POUND}" + (FormatNum ([double]($gmin + ($gmax-$gmin)*$i/4)))), $fontTick, $brushGray, 40, $y - 8)
}
$slot = $pw / 5
for ($r = 1; $r -le 5; $r++) {
    $arr = $groups[$r].ToArray(); [Array]::Sort($arr)
    if ($arr.Count -eq 0) { continue }
    $q1 = Quantile $arr 0.25; $med = Quantile $arr 0.5; $q3 = Quantile $arr 0.75
    $iqr = $q3 - $q1
    $loW = $q1 - 1.5*$iqr; $hiW = $q3 + 1.5*$iqr
    $lo = ($arr | Where-Object { $_ -ge $loW } | Measure-Object -Minimum).Minimum
    $hi = ($arr | Where-Object { $_ -le $hiW } | Measure-Object -Maximum).Maximum
    function Y($v) { return $bottom - (($v - $gmin) / ($gmax - $gmin)) * $ph }
    $cx = $left + $slot * ($r - 1) + $slot / 2
    $bw = 70
    $pen = New-Object System.Drawing.Pen($C_BLUE, 1.5)
    $g.DrawLine($pen, [float]$cx, [float](Y $hi), [float]$cx, [float](Y $q3))
    $g.DrawLine($pen, [float]$cx, [float](Y $lo), [float]$cx, [float](Y $q1))
    $g.DrawLine($pen, [float]($cx-20), [float](Y $hi), [float]($cx+20), [float](Y $hi))
    $g.DrawLine($pen, [float]($cx-20), [float](Y $lo), [float]($cx+20), [float](Y $lo))
    FillRect $g ([System.Drawing.Color]::FromArgb(200,220,240)) ($cx-$bw/2) (Y $q3) $bw ((Y $q1)-(Y $q3))
    $g.DrawRectangle($pen, [float]($cx-$bw/2), [float](Y $q3), [float]$bw, [float]((Y $q1)-(Y $q3)))
    $medPen = New-Object System.Drawing.Pen($C_RED, 2)
    $g.DrawLine($medPen, [float]($cx-$bw/2), [float](Y $med), [float]($cx+$bw/2), [float](Y $med))
    foreach ($v in $arr) {
        if ($v -lt $loW -or $v -gt $hiW) {
            $b = New-Object System.Drawing.SolidBrush($C_RED)
            $g.FillEllipse($b, [float]($cx-3), [float]((Y $v)-3), 6, 6); $b.Dispose()
        }
    }
    $g.DrawString($r.ToString(), $fontLabel, $brushText, [float]($cx-5), [float]($bottom+8))
}
DrawAxes $g $left $top $right $bottom
$g.DrawString("Rating (stars)", $fontLabel, $brushText, [float]($left+$pw/2-40), [float]($bottom+32))
$g.DrawString("Price (GBP)", $fontLabel, $brushText, 20, 45)
Save-Canvas $c (Join-Path $outDir "04_price_by_rating_boxplot.png")

# ============================================================
# 5. Price vs rating scatter
# ============================================================
$c = New-Canvas 1000 650; $g = $c.G
$left = 90; $top = 80; $right = 950; $bottom = 560
$pw = $right - $left; $ph = $bottom - $top
$g.DrawString("Price vs Rating", $fontTitle, $brushText, 90, 22)
$xmin = 0.5; $xmax = 5.5
for ($i = 0; $i -le 4; $i++) {
    $y = $bottom - ($ph * $i / 4)
    $g.DrawLine($penGrid, [float]$left, [float]$y, [float]$right, [float]$y)
    $g.DrawString(("${POUND}" + (FormatNum ([double]($min + ($max-$min)*$i/4)))), $fontTick, $brushGray, 40, $y - 8)
}
for ($i = 0; $i -le 5; $i++) {
    $xv = $i + 1
    if ($xv -le 5) {
        $x = $left + (($xv - $xmin) / ($xmax - $xmin)) * $pw
        $g.DrawLine($penGrid, [float]$x, [float]$top, [float]$x, [float]$bottom)
        $g.DrawString($xv.ToString(), $fontTick, $brushGray, [float]($x - 4), [float]($bottom + 8))
    }
}
$rnd = New-Object System.Random(42)
$b = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(150,255,140,0))
for ($i = 0; $i -lt $n; $i++) {
    $jitter = ($rnd.NextDouble() - 0.5) * 0.5
    $xv = $ratings[$i] + $jitter
    $x = $left + (($xv - $xmin) / ($xmax - $xmin)) * $pw
    $y = $bottom - (($prices[$i] - $min) / ($max - $min)) * $ph
    $g.FillEllipse($b, [float]($x-4), [float]($y-4), 8, 8)
}
$b.Dispose()
DrawAxes $g $left $top $right $bottom
$g.DrawString("Rating (jittered)", $fontLabel, $brushText, [float]($left+$pw/2-45), [float]($bottom+32))
$g.DrawString("Price (GBP)", $fontLabel, $brushText, 20, 45)
Save-Canvas $c (Join-Path $outDir "05_price_vs_rating_scatter.png")

# ============================================================
# 6. Top 10 most expensive books
# ============================================================
$idx = 0..($n-1) | Sort-Object { $prices[$_] } -Descending | Select-Object -First 10
$idx = $idx[($idx.Count-1)..0]
$c = New-Canvas 1000 600; $g = $c.G
$left = 320; $top = 80; $right = 950; $bottom = 540
$pw = $right - $left; $ph = $bottom - $top
$g.DrawString("Top 10 Most Expensive Books", $fontTitle, $brushText, 90, 22)
$maxVal = ($idx | ForEach-Object { $prices[$_] } | Measure-Object -Maximum).Maximum
for ($i = 0; $i -le 4; $i++) {
    $x = $left + $pw * $i / 4
    $g.DrawLine($penGrid, [float]$x, [float]$top, [float]$x, [float]$bottom)
    $g.DrawString(("${POUND}" + (FormatNum ([double]($maxVal * $i / 4)))), $fontTick, $brushGray, [float]($x-15), [float]($bottom+8))
}
$slot = $ph / 10
for ($j = 0; $j -lt $idx.Count; $j++) {
    $i = $idx[$j]
    $bw = $pw * $prices[$i] / $maxVal
    $y = $top + $slot * $j + 6
    FillRect $g $C_RED $left $y ($bw) ($slot - 12)
    $label = $titles[$i]
    if ($label.Length -gt 32) { $label = $label.Substring(0, 32) + "..." }
    $g.DrawString($label, $fontTick, $brushText, 90, [float]($y + 4))
    $g.DrawString(("${POUND}" + ("{0:N2}" -f $prices[$i])), $fontTick, $brushText, [float]($left + $bw + 5), [float]($y + 4))
}
DrawAxes $g $left $top $right $bottom
$g.DrawString("Price (GBP)", $fontLabel, $brushText, [float]($left+$pw/2-40), [float]($bottom+32))
Save-Canvas $c (Join-Path $outDir "06_top10_expensive.png")

# ============================================================
# 7. Price band share (pie)
# ============================================================
$bands = @(0,0,0,0)
$bandLabels = @("Budget (<${POUND}20)", "Mid (${POUND}20-35)", "Premium (${POUND}35-50)", "Luxury (${POUND}50+)")
foreach ($p in $prices) {
    if ($p -lt 20) { $bands[0]++ }
    elseif ($p -lt 35) { $bands[1]++ }
    elseif ($p -lt 50) { $bands[2]++ }
    else { $bands[3]++ }
}
$c = New-Canvas 900 650; $g = $c.G
$g.DrawString("Share of Books by Price Band", $fontTitle, $brushText, 90, 22)
$total = ($bands | Measure-Object -Sum).Sum
$colors = @([System.Drawing.Color]::FromArgb(255,183,197), [System.Drawing.Color]::FromArgb(174,213,129), [System.Drawing.Color]::FromArgb(255,236,177), [System.Drawing.Color]::FromArgb(179,205,227))
$start = 0.0
$cx = 330; $cy = 350; $rad = 200
for ($i = 0; $i -lt 4; $i++) {
    $sweep = 360.0 * $bands[$i] / $total
    $b = New-Object System.Drawing.SolidBrush($colors[$i])
    $g.FillPie($b, [float]($cx-$rad), [float]($cy-$rad), [float](2*$rad), [float](2*$rad), [float]$start, [float]$sweep)
    $mid = ($start + $sweep/2) * [Math]::PI / 180
    $lx = $cx + [Math]::Cos($mid) * $rad * 0.6
    $ly = $cy + [Math]::Sin($mid) * $rad * 0.6
    $pct = 100.0 * $bands[$i] / $total
    $g.DrawString(("{0:N1}%" -f $pct), $fontLabel, $brushText, [float]($lx-15), [float]($ly-8))
    $start += $sweep
}
$penPie = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 2)
$g.DrawEllipse($penPie, [float]($cx-$rad), [float]($cy-$rad), [float](2*$rad), [float](2*$rad))
for ($i = 0; $i -lt 4; $i++) {
    FillRect $g $colors[$i] 620 (180 + $i*55) 24 24
    $g.DrawString($bandLabels[$i], $fontLabel, $brushText, 655, [float](184 + $i*55))
    $g.DrawString(("{0} books" -f $bands[$i]), $fontTick, $brushGray, 655, [float](202 + $i*55))
}
Save-Canvas $c (Join-Path $outDir "07_price_band_pie.png")

# ============================================================
# 8. Correlation heatmap
# ============================================================
function Mean($a) { return ($a | Measure-Object -Average).Average }
function Std($a) { $m = Mean $a; $s = 0.0; foreach ($x in $a) { $s += ($x-$m)*($x-$m) }; return [Math]::Sqrt($s/$a.Count) }
function Corr($a, $b) {
    $ma = Mean $a; $mb = Mean $b; $num = 0.0; $da = 0.0; $db = 0.0
    for ($i = 0; $i -lt $a.Count; $i++) {
        $num += ($a[$i]-$ma)*($b[$i]-$mb)
        $da += ($a[$i]-$ma)*($a[$i]-$ma)
        $db += ($b[$i]-$mb)*($b[$i]-$mb)
    }
    if ($da -eq 0 -or $db -eq 0) { return 0.0 }
    return $num/[Math]::Sqrt($da*$db)
}
$series = @{
    "price_gbp" = $prices
    "rating" = $ratings
    "in_stock" = @($csv | ForEach-Object { [double]$_.in_stock })
}
$names = @("price_gbp", "rating", "in_stock")
$corr = @{}
foreach ($a in $names) { foreach ($b in $names) { $corr["$a|$b"] = Corr $series[$a] $series[$b] } }

function Lerp([double]$a, [double]$b, [double]$t) { return [int]($a + ($b-$a)*$t) }
function HeatColor([double]$v) {
    if ($v -ge 0) {
        return [System.Drawing.Color]::FromArgb((Lerp 255 178 $v), (Lerp 255 24 $v), (Lerp 255 43 $v))
    } else {
        $t = -$v
        return [System.Drawing.Color]::FromArgb((Lerp 255 33 $t), (Lerp 255 102 $t), (Lerp 255 172 $t))
    }
}
$c = New-Canvas 750 650; $g = $c.G
$g.DrawString("Correlation Heatmap", $fontTitle, $brushText, 90, 22)
$cell = 130; $x0 = 170; $y0 = 110
for ($i = 0; $i -lt 3; $i++) {
    for ($j = 0; $j -lt 3; $j++) {
        $v = $corr["$($names[$j])|$($names[$i])"]
        FillRect $g (HeatColor $v) ($x0 + $j*$cell) ($y0 + $i*$cell) $cell $cell
        $txt = "{0:N2}" -f $v
        $g.DrawString($txt, $fontLabel, $brushText, [float]($x0 + $j*$cell + 45), [float]($y0 + $i*$cell + 55))
    }
    $g.DrawString($names[$i], $fontTick, $brushText, 20, [float]($y0 + $i*$cell + 60))
}
for ($j = 0; $j -lt 3; $j++) {
    $g.DrawString($names[$j], $fontTick, $brushText, [float]($x0 + $j*$cell + 20), [float]($y0 - 25))
}
$g.DrawString("Color scale: blue = negative, white = 0, red = positive", $fontTick, $brushGray, 170, 540)
Save-Canvas $c (Join-Path $outDir "08_correlation_heatmap.png")

Write-Host "`nAll charts generated in $outDir"
Get-ChildItem $outDir -Filter *.png | Select-Object Name, Length | Format-Table -AutoSize
