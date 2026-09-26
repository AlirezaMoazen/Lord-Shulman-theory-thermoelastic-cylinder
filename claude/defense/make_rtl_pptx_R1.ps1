# Post-process a pandoc-generated .pptx for right-to-left Persian text.
# Pandoc's pptx writer emits no paragraph direction, so Persian lands
# left-aligned with Latin-first fallback fonts. This walks every slide's XML
# and sets rtl="1" + algn="r" on each paragraph, and a Persian-capable
# complex-script font on each run.
param(
    [Parameter(Mandatory=$true)][string]$SrcPptx,
    [Parameter(Mandatory=$true)][string]$OutPptx,
    [string]$Font = "Tahoma"
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$work = Join-Path ([System.IO.Path]::GetDirectoryName($OutPptx)) "_rtlwork"
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
[System.IO.Compression.ZipFile]::ExtractToDirectory($SrcPptx, $work)

$ns = "http://schemas.openxmlformats.org/drawingml/2006/main"
$targets = @()
$targets += Get-ChildItem (Join-Path $work "ppt\slides") -Filter *.xml -ErrorAction SilentlyContinue
$targets += Get-ChildItem (Join-Path $work "ppt\slideLayouts") -Filter *.xml -ErrorAction SilentlyContinue
$targets += Get-ChildItem (Join-Path $work "ppt\slideMasters") -Filter *.xml -ErrorAction SilentlyContinue

$nPar = 0; $nRun = 0
foreach ($f in $targets) {
    [xml]$doc = Get-Content -Raw -Encoding UTF8 $f.FullName
    $nsm = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
    $nsm.AddNamespace("a", $ns)

    # --- paragraphs: force RTL + right alignment ---
    foreach ($p in $doc.SelectNodes("//a:p", $nsm)) {
        $pPr = $p.SelectSingleNode("a:pPr", $nsm)
        if ($null -eq $pPr) {
            $pPr = $doc.CreateElement("a", "pPr", $ns)
            [void]$p.InsertBefore($pPr, $p.FirstChild)
        }
        $pPr.SetAttribute("rtl", "1")
        $pPr.SetAttribute("algn", "r")
        $nPar++
    }

    # --- runs: tag language and give the complex-script font ---
    foreach ($rPr in $doc.SelectNodes("//a:rPr | //a:endParaRPr | //a:defRPr", $nsm)) {
        $rPr.SetAttribute("lang", "fa-IR")
        $rPr.SetAttribute("dirty", "0")
        foreach ($tag in @("latin","cs")) {
            $el = $rPr.SelectSingleNode("a:$tag", $nsm)
            if ($null -eq $el) {
                $el = $doc.CreateElement("a", $tag, $ns)
                [void]$rPr.AppendChild($el)
            }
            $el.SetAttribute("typeface", $Font)
        }
        $nRun++
    }

    $doc.Save($f.FullName)
}

# Repack manually. ZipFile::CreateFromDirectory writes Windows BACKSLASH
# separators in entry names, which is not valid OPC/OOXML -- PowerPoint can
# refuse such a file. Write each entry with an explicit forward-slash name,
# and put [Content_Types].xml first as the OPC spec expects.
if (Test-Path $OutPptx) { Remove-Item $OutPptx -Force }
# Enumerate relative to $work so entry names need no substring arithmetic
# (the caller's path may use an 8.3 short name, which makes prefix lengths lie).
Push-Location $work
$relNames = @(Get-ChildItem -Recurse -File -Name)
Pop-Location
$pairs = foreach ($rn in $relNames) {
    [pscustomobject]@{
        Full = (Join-Path $work $rn)
        Name = ($rn -replace '\\','/')
    }
}
$ordered = @()
$ordered += $pairs | Where-Object { $_.Name -eq '[Content_Types].xml' }
$ordered += $pairs | Where-Object { $_.Name -ne '[Content_Types].xml' }

$zs = [System.IO.File]::Open($OutPptx, [System.IO.FileMode]::Create)
$zip = New-Object System.IO.Compression.ZipArchive($zs, [System.IO.Compression.ZipArchiveMode]::Create)
foreach ($p in $ordered) {
    $entry = $zip.CreateEntry($p.Name, [System.IO.Compression.CompressionLevel]::Optimal)
    $es = $entry.Open()
    $bytes = [System.IO.File]::ReadAllBytes($p.Full)
    $es.Write($bytes, 0, $bytes.Length)
    $es.Dispose()
}
$zip.Dispose(); $zs.Dispose()
Remove-Item $work -Recurse -Force

Write-Output "paragraphs set RTL: $nPar"
Write-Output "runs restyled     : $nRun"
Write-Output "written           : $OutPptx"
