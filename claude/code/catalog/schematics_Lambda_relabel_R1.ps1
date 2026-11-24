# schematics_Lambda_relabel_R1.ps1 -- relabel the pattern name A as Lambda in the two pattern schematics of the article
# Purpose : author instruction of 2026-11-23 (Prom8, item 3) -- the figures that show the pattern A are reproduced with the
#           symbol Lambda. The two schematics are raster images embedded in the thesis (no generating script exists for these
#           exact versions), so ONLY the label of the fifth sector is replaced: the dark pixels of the letter A are painted
#           white and the letter Lambda (U+039B) is drawn in Times New Roman bold, scaled so that its height equals that of
#           the old letter and centred on the old letter. Every other pixel stays identical to the source.
# Inputs  : figures_ch123/GPL_patterns_schematic_thesis_R1.png, figures_ch123/porosity_patterns_schematic_thesis_R1.png
# Outputs : figures_ch123/GPL_patterns_schematic_thesis_R2.png, figures_ch123/porosity_patterns_schematic_thesis_R2.png
# Run from claude/ :  powershell -File code/catalog/schematics_Lambda_relabel_R1.ps1
# New file (R1); the source images stay untouched.
Add-Type -AssemblyName System.Drawing
$here = Split-Path -Parent $PSScriptRoot          # claude/code -> claude
$claude = Split-Path -Parent $here
$dir = Join-Path $claude 'figures_ch123'
$pairs = @(
  @('GPL_patterns_schematic_thesis_R1.png',      'GPL_patterns_schematic_thesis_R2.png'),
  @('porosity_patterns_schematic_thesis_R1.png', 'porosity_patterns_schematic_thesis_R2.png'))
$lam = [string][char]0x039B

function Get-DarkBox($bmp, $x0, $y0, $x1, $y1) {
  $minx = 1e9; $maxx = -1; $miny = 1e9; $maxy = -1
  for ($y = $y0; $y -lt $y1; $y++) { for ($x = $x0; $x -lt $x1; $x++) {
      $c = $bmp.GetPixel($x, $y)
      if (($c.R + $c.G + $c.B) -lt 600) {
        if ($x -lt $minx) { $minx = $x }; if ($x -gt $maxx) { $maxx = $x }
        if ($y -lt $miny) { $miny = $y }; if ($y -gt $maxy) { $maxy = $y } } } }
  return @($minx, $miny, $maxx, $maxy)
}

foreach ($p in $pairs) {
  $src = Join-Path $dir $p[0]; $dst = Join-Path $dir $p[1]
  $img = New-Object Drawing.Bitmap $src
  # title band of the lower-right sector (the fifth pattern)
  $x0 = [int]($img.Width * 0.60); $x1 = [int]($img.Width * 0.75)
  $y0 = [int]($img.Height * 0.50); $y1 = [int]($img.Height * 0.56)
  $bb = Get-DarkBox $img $x0 $y0 $x1 $y1
  $w = $bb[2] - $bb[0] + 1; $h = $bb[3] - $bb[1] + 1
  if ($bb[2] -lt 0 -or $w -gt 40 -or $h -gt 40) { throw "label of $($p[0]) not found (bbox $($bb -join ','))" }
  # ink colour = darkest pixel of the old label (the labels are dark grey, not pure black)
  $ink = [Drawing.Color]::Black; $best = 1e9
  for ($y = $bb[1]; $y -le $bb[3]; $y++) { for ($x = $bb[0]; $x -le $bb[2]; $x++) {
      $c = $img.GetPixel($x, $y); $s = $c.R + $c.G + $c.B
      if ($s -lt $best) { $best = $s; $ink = $c } } }
  $brush = New-Object Drawing.SolidBrush $ink
  # find the font size (px) whose Lambda has the same height as the old label
  $size = 20.0; $lbox = $null
  for ($it = 0; $it -lt 12; $it++) {
    $t = New-Object Drawing.Bitmap 120, 120
    $g = [Drawing.Graphics]::FromImage($t); $g.Clear([Drawing.Color]::White)
    $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $f = New-Object Drawing.Font 'Times New Roman', $size, ([Drawing.FontStyle]::Bold), ([Drawing.GraphicsUnit]::Pixel)
    $g.DrawString($lam, $f, [Drawing.Brushes]::Black, 20, 20)
    $lbox = Get-DarkBox $t 0 0 120 120
    $lh = $lbox[3] - $lbox[1] + 1
    $f.Dispose(); $g.Dispose(); $t.Dispose()
    if ($lh -eq $h) { break }
    $size = $size * $h / $lh
  }
  $lw = $lbox[2] - $lbox[0] + 1
  # paint the old label white (2 px margin), draw Lambda centred on the old label, bottom edges aligned
  $g = [Drawing.Graphics]::FromImage($img)
  $g.FillRectangle([Drawing.Brushes]::White, $bb[0] - 2, $bb[1] - 2, $w + 4, $h + 4)
  $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $f = New-Object Drawing.Font 'Times New Roman', $size, ([Drawing.FontStyle]::Bold), ([Drawing.GraphicsUnit]::Pixel)
  $dx = $bb[0] + ($w - $lw) / 2.0 - ($lbox[0] - 20)
  $dy = $bb[1] - ($lbox[1] - 20)
  $g.DrawString($lam, $f, $brush, [single]$dx, [single]$dy)
  $g.Dispose(); $f.Dispose(); $brush.Dispose()
  $img.SetResolution(219.9894, 219.9894)
  $img.Save($dst, [Drawing.Imaging.ImageFormat]::Png)
  $img.Dispose()
  "{0} -> {1}  (old label {2}x{3} px at x {4}..{5}, y {6}..{7}; Lambda font {8:N1} px)" -f $p[0], $p[1], $w, $h, $bb[0], $bb[2], $bb[1], $bb[3], $size
}
