# build_article_docx_R3.ps1 -- R3 = R2 (frozen) + optional journal layout in two columns (author instruction of 2026-11-26)
#   Without -TwoColumn the output is the same as that of build_article_docx_R2.ps1 (single column, A4, 11 pt, margins 2.5 cm).
#   With -TwoColumn (marked R3 below) the Word file gets a layout that saves pages:
#     * the front matter (title, author notes, authors, abstract, keywords, highlights) stays in one column, from Sect. 1 on the text runs in two columns
#       (continuous section break, A4, margins 2.0 cm, column gap 0.8 cm, text 10 pt, references 8.5 pt, data tables 8.5 pt);
#     * every figure with its caption is a floating one-cell table, 17 cm wide, positioned at the top of the margin (the top of the page that
#       carries the paragraph after the figure), no overlap of two figures, so that figures stand at the top of the pages across both columns;
#     * display equations whose estimated width exceeds about 5.6 cm (the cell of a column is 6.8 cm, the estimate may be low) are set in a one-column continuous section (full width), the narrow ones stay
#       in the column; data tables are scaled to the column width; the horizontal rules of the markdown are dropped.
#   Source syntax, Lua filter (build_R2/article_R2.lua) and numbering (Word SEQ / REF fields, F9 to renumber) are unchanged.
#   The check script build_R1/verify_docx_R1.ps1 works on both outputs.
# Usage (from anywhere):  powershell -File build_article_docx_R3.ps1 [-Md <file.md>] [-Docx <file.docx>] [-TwoColumn]
#   default Md = ARTICLE_FULL_THESIS_EN_R5.6.md; default Docx = <Md>.docx, or <Md>_2COL.docx with -TwoColumn.
# Needs pandoc >= 3 with Lua. In Word, Ctrl+A then F9 renumbers every field after a figure, table or equation is inserted or deleted.
# --- header of build_article_docx_R2.ps1 (R2 = R1 + citation REF fields), unchanged text of R1 follows ---
# Builds the Word version of an article markdown file of this folder.
#   pandoc + article_R2.lua  -> equations, figures and tables get Word SEQ/REF fields (automatic numbers),
#                               display equations are 3-column tables with the number at the far right
#   reference document      -> A4, Times New Roman 11 pt, black headings, three-line data tables
#   post-processing         -> vertical centring of equation rows, 10 pt data tables, no path in picture alt text
param([string]$Md = '', [string]$Docx = '', [switch]$TwoColumn)
$here = $PSScriptRoot
$papers = Split-Path -Parent $here
if ($Md -eq '') { $Md = Join-Path $papers 'ARTICLE_FULL_THESIS_EN_R5.6.md' }
$Md = (Resolve-Path -LiteralPath $Md).Path
if ($Docx -eq '') {
  if ($TwoColumn) { $Docx = [IO.Path]::Combine((Split-Path -Parent $Md), [IO.Path]::GetFileNameWithoutExtension($Md) + '_2COL.docx') }
  else { $Docx = [IO.Path]::ChangeExtension($Md, '.docx') }
}
$U8 = New-Object Text.UTF8Encoding($false)
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# ---- layout parameters (R3). The single-column values are those of R2 ----
$LP = @{
  szBody = 22; after = 120; line = 276; cmpB = 40; cmpA = 40
  h1sz = 28; h1b = 320; h1a = 120; h2sz = 24; h2b = 240; h2a = 100; h3sz = 22; h3b = 200; h3a = 80; h4sz = 22; h4b = 160; h4a = 60
  titleSz = 32; titleB = 120; titleA = 240; capSz = 20; capB = 60; capA = 200; tcapB = 200; tcapA = 80; figB = 160; figA = 40
  blkSz = 20; dataSz = 20; margin = 1418; hdr = 709; gap = 454
}
if ($TwoColumn) {
  $LP.szBody = 20; $LP.after = 80; $LP.line = 252; $LP.cmpB = 20; $LP.cmpA = 20
  $LP.h1sz = 26; $LP.h1b = 240; $LP.h1a = 100; $LP.h2sz = 22; $LP.h2b = 200; $LP.h2a = 80; $LP.h3sz = 20; $LP.h3b = 140; $LP.h3a = 60; $LP.h4sz = 20; $LP.h4b = 120; $LP.h4a = 40
  $LP.titleSz = 28; $LP.titleB = 80; $LP.titleA = 160; $LP.capSz = 18; $LP.capB = 40; $LP.capA = 60; $LP.tcapB = 120; $LP.tcapA = 60; $LP.figB = 0; $LP.figA = 40
  $LP.blkSz = 17; $LP.dataSz = 17; $LP.margin = 1134; $LP.hdr = 567; $LP.gap = 454
}
function T([string]$s) { foreach ($k in $LP.Keys) { $s = $s.Replace('@' + $k + '@', [string]$LP[$k]) }; return $s }

function ZipDir($dir, $out) {
  # zip with forward-slash entry names ([Content_Types].xml first), as Word expects
  if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Force }
  $root = (Get-Item -LiteralPath $dir).FullName
  $zip = [IO.Compression.ZipFile]::Open($out, 'Create')
  try {
    $files = @(Get-ChildItem -LiteralPath $root -Recurse -File)
    $ordered = @($files | Where-Object { $_.Name -eq '[Content_Types].xml' }) + @($files | Where-Object { $_.Name -ne '[Content_Types].xml' })
    foreach ($f in $ordered) {
      $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
      [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $f.FullName, $rel, [IO.Compression.CompressionLevel]::Optimal)
    }
  } finally { $zip.Dispose() }
}

$work = Join-Path ([IO.Path]::GetTempPath()) ('article_docx_' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
try {
  # ---- reference document ----
  # binary output must bypass the PowerShell pipeline
  & cmd.exe /c "pandoc --print-default-data-file reference.docx > `"$work\ref_default.docx`""
  if (-not (Test-Path -LiteralPath "$work\ref_default.docx") -or (Get-Item -LiteralPath "$work\ref_default.docx").Length -lt 1000) { throw 'could not export the pandoc reference document' }
  $rx = "$work\ref_x"
  [IO.Compression.ZipFile]::ExtractToDirectory("$work\ref_default.docx", $rx)
  $st = [IO.File]::ReadAllText("$rx\word\styles.xml", $U8)
  function SetStyle($id, $xml) {
    $pat = '(?s)<w:style [^>]*w:styleId="' + $id + '".*?</w:style>'
    if (-not [regex]::IsMatch($script:st, $pat)) { throw "style $id not found" }
    $xml = T $xml
    $script:st = [regex]::Replace($script:st, $pat, { param($m) $xml })
  }
  $dd = T '<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="@szBody@"/><w:szCs w:val="@szBody@"/><w:lang w:val="en-GB" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="@after@" w:line="@line@" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>'
  $st = [regex]::Replace($st, '(?s)<w:docDefaults>.*?</w:docDefaults>', { param($m) $dd })
  SetStyle 'BodyText' '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="@after@" w:line="@line@" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr></w:style>'
  SetStyle 'Compact' '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="@cmpB@" w:after="@cmpA@" w:line="240" w:lineRule="auto"/><w:jc w:val="left"/></w:pPr></w:style>'
  SetStyle 'Heading1' '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="@h1b@" w:after="@h1a@"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="@h1sz@"/><w:szCs w:val="@h1sz@"/></w:rPr></w:style>'
  SetStyle 'Heading2' '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="@h2b@" w:after="@h2a@"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="@h2sz@"/><w:szCs w:val="@h2sz@"/></w:rPr></w:style>'
  SetStyle 'Heading3' '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="@h3b@" w:after="@h3a@"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="@h3sz@"/><w:szCs w:val="@h3sz@"/></w:rPr></w:style>'
  SetStyle 'Heading4' '<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading4Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="@h4b@" w:after="@h4a@"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="@h4sz@"/><w:szCs w:val="@h4sz@"/></w:rPr></w:style>'
  SetStyle 'Title' '<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="TitleChar"/><w:uiPriority w:val="10"/><w:qFormat/><w:pPr><w:spacing w:before="@titleB@" w:after="@titleA@" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="@titleSz@"/><w:szCs w:val="@titleSz@"/></w:rPr></w:style>'
  SetStyle 'Caption' '<w:style w:type="paragraph" w:styleId="Caption"><w:name w:val="Caption"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:pPr><w:spacing w:before="@capB@" w:after="@capA@" w:line="240" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr><w:rPr><w:sz w:val="@capSz@"/><w:szCs w:val="@capSz@"/></w:rPr></w:style>'
  SetStyle 'TableCaption' '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TableCaption"><w:name w:val="Table Caption"/><w:basedOn w:val="Caption"/><w:pPr><w:keepNext/><w:spacing w:before="@tcapB@" w:after="@tcapA@"/></w:pPr></w:style>'
  SetStyle 'Figure' '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Figure"><w:name w:val="Figure"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="@figB@" w:after="@figA@"/><w:jc w:val="center"/></w:pPr></w:style>'
  SetStyle 'CaptionedFigure' '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionedFigure"><w:name w:val="Captioned Figure"/><w:basedOn w:val="Figure"/><w:pPr><w:keepNext/><w:jc w:val="center"/></w:pPr></w:style>'
  SetStyle 'BlockText' '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:pBdr><w:top w:val="single" w:sz="4" w:space="4" w:color="808080"/><w:left w:val="single" w:sz="4" w:space="4" w:color="808080"/><w:bottom w:val="single" w:sz="4" w:space="4" w:color="808080"/><w:right w:val="single" w:sz="4" w:space="4" w:color="808080"/></w:pBdr><w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/><w:spacing w:before="60" w:after="60"/><w:ind w:left="170" w:right="170"/></w:pPr><w:rPr><w:sz w:val="@blkSz@"/><w:szCs w:val="@blkSz@"/></w:rPr></w:style>'
  SetStyle 'Table' '<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:semiHidden/><w:unhideWhenUsed/><w:qFormat/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="single" w:sz="8" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblStylePr w:type="firstRow"><w:tcPr><w:tcBorders><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders><w:vAlign w:val="bottom"/></w:tcPr></w:tblStylePr></w:style>'
  if ($TwoColumn) {
    # R3: paragraph style of the reference list (8.5 pt), assigned to the numbered items under the heading References
    $refStyle = '<w:style w:type="paragraph" w:customStyle="1" w:styleId="RefItem"><w:name w:val="Ref Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="20" w:line="240" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr><w:rPr><w:sz w:val="17"/><w:szCs w:val="17"/></w:rPr></w:style>'
    $st = $st.Replace('</w:styles>', $refStyle + '</w:styles>')
  }
  [IO.File]::WriteAllText("$rx\word\styles.xml", $st, $U8)
  $rd = [IO.File]::ReadAllText("$rx\word\document.xml", $U8)
  $sect = T '<w:sectPr><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="@margin@" w:right="@margin@" w:bottom="@margin@" w:left="@margin@" w:header="@hdr@" w:footer="@hdr@" w:gutter="0"/></w:sectPr>'
  $rd = [regex]::Replace($rd, '(?s)<w:sectPr>.*?</w:sectPr>', { param($m) $sect })
  [IO.File]::WriteAllText("$rx\word\document.xml", $rd, $U8)
  ZipDir $rx "$work\ref_en.docx"

  # ---- pandoc ----
  Push-Location (Split-Path -Parent $Md)
  try {
    & pandoc (Split-Path -Leaf $Md) -f markdown-citations -t docx "--lua-filter=$papers\build_R2\article_R2.lua" "--reference-doc=$work\ref_en.docx" --resource-path=. -o "$work\raw.docx"
    if ($LASTEXITCODE -ne 0) { throw "pandoc failed ($LASTEXITCODE)" }
  } finally { Pop-Location }

  # ---- post-processing ----
  $x = "$work\raw_x"
  [IO.Compression.ZipFile]::ExtractToDirectory("$work\raw.docx", $x)
  $doc = [IO.File]::ReadAllText("$x\word\document.xml", $U8)
  $nil = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
  $dataRun = T '<w:r><w:rPr><w:sz w:val="@dataSz@"/><w:szCs w:val="@dataSz@"/></w:rPr><w:t'
  $script:nEq = 0; $script:nData = 0
  $doc = [regex]::Replace($doc, '(?s)<w:tbl>.*?</w:tbl>', {
    param($m)
    $t = $m.Value
    if ($t.Contains('SEQ Equation')) {
      $script:nEq++
      $t = $t.Replace('<w:tblLayout', $nil + '<w:tblLayout')
      $t = $t.Replace('<w:tcPr />', '<w:tcPr><w:vAlign w:val="center"/></w:tcPr>').Replace('<w:tcPr/>', '<w:tcPr><w:vAlign w:val="center"/></w:tcPr>')
    } else {
      $script:nData++
      $t = [regex]::Replace($t, '<w:r>(\s*)<w:t', $dataRun)
    }
    return $t
  })
  $doc = [regex]::Replace($doc, '<pic:cNvPr descr="[^"]*"', '<pic:cNvPr descr=""')

  if ($TwoColumn) {
    # ================= R3: two-column journal layout (DOM processing) =================
    $WNS = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    $xd = New-Object System.Xml.XmlDocument
    $xd.PreserveWhitespace = $true
    $xd.LoadXml($doc)
    $nsm = New-Object System.Xml.XmlNamespaceManager($xd.NameTable)
    $nsm.AddNamespace('w', $WNS)
    $nsm.AddNamespace('wp', 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing')
    $nsm.AddNamespace('a', 'http://schemas.openxmlformats.org/drawingml/2006/main')
    $nsm.AddNamespace('m', 'http://schemas.openxmlformats.org/officeDocument/2006/math')
    $nsm.AddNamespace('v', 'urn:schemas-microsoft-com:vml')
    $body = $xd.DocumentElement.SelectSingleNode('w:body', $nsm)

    $PW = 11906; $PH = 16838; $MG = $LP.margin; $GAP = $LP.gap
    $FULL = $PW - 2 * $MG                 # text width, 9638 twips (17.0 cm)
    $COL = [int](($FULL - $GAP) / 2)      # column width, 4592 twips (8.1 cm)
    $SPAN_CHARS = 28                      # equations wider than this (estimated, units of one letter, about 5.6 cm) span both columns

    function E([string]$name, $attrs, $kids) {
      $e = $xd.CreateElement('w', $name, $WNS)
      if ($attrs) { foreach ($k in $attrs.Keys) { $a = $xd.CreateAttribute('w', $k, $WNS); $a.Value = [string]$attrs[$k]; [void]$e.Attributes.Append($a) } }
      if ($kids) { foreach ($c in $kids) { [void]$e.AppendChild($c) } }
      return $e
    }
    function SectEl([bool]$cont, [int]$cols) {
      $kids = @()
      if ($cont) { $kids += (E 'type' @{ val = 'continuous' } $null) }
      $kids += (E 'pgSz' @{ w = $PW; h = $PH } $null)
      $kids += (E 'pgMar' @{ top = $MG; right = $MG; bottom = $MG; left = $MG; header = $LP.hdr; footer = $LP.hdr; gutter = 0 } $null)
      $ca = @{ space = $GAP }
      if ($cols -gt 1) { $ca['num'] = $cols }
      $kids += (E 'cols' $ca $null)
      return (E 'sectPr' $null $kids)
    }
    function TinyPara($sect) {
      # empty paragraph of about 2 pt; carries a section break when $sect is given
      $ppr = E 'pPr' $null @((E 'spacing' @{ before = 0; after = 0; line = 40; lineRule = 'exact' } $null), (E 'rPr' $null @((E 'sz' @{ val = 2 } $null), (E 'szCs' @{ val = 2 } $null))))
      if ($null -ne $sect) { [void]$ppr.AppendChild($sect) }
      return (E 'p' $null @($ppr))
    }
    function AddSectToPara($p, $sect) {
      $ppr = $p.SelectSingleNode('w:pPr', $nsm)
      if ($null -eq $ppr) { $ppr = E 'pPr' $null $null; if ($null -ne $p.FirstChild) { [void]$p.InsertBefore($ppr, $p.FirstChild) } else { [void]$p.AppendChild($ppr) } }
      $ex = $ppr.SelectSingleNode('w:sectPr', $nsm)
      if ($null -ne $ex) { [void]$ppr.RemoveChild($ex) }
      $before = $ppr.SelectSingleNode('w:pPrChange', $nsm)
      if ($null -ne $before) { [void]$ppr.InsertBefore($sect, $before) } else { [void]$ppr.AppendChild($sect) }
    }
    function PrevEl($n) {
      $p = $n.PreviousSibling
      while ($p -ne $null -and ($p.NodeType -ne 'Element' -or $p.LocalName -eq 'bookmarkStart' -or $p.LocalName -eq 'bookmarkEnd')) { $p = $p.PreviousSibling }
      return $p
    }
    function NextEl($n) {
      $p = $n.NextSibling
      while ($p -ne $null -and ($p.NodeType -ne 'Element' -or $p.LocalName -eq 'bookmarkStart' -or $p.LocalName -eq 'bookmarkEnd')) { $p = $p.NextSibling }
      return $p
    }
    function PStyle($p) {
      $s = $p.SelectSingleNode('w:pPr/w:pStyle', $nsm)
      if ($null -ne $s) { return $s.GetAttribute('val', $WNS) } else { return '' }
    }
    function SetTblWidths($tbl, [int[]]$grid) {
      $total = ($grid | Measure-Object -Sum).Sum
      $tpr = $tbl.SelectSingleNode('w:tblPr', $nsm)
      $w = $tpr.SelectSingleNode('w:tblW', $nsm)
      [void]$w.SetAttribute('type', $WNS, 'dxa'); [void]$w.SetAttribute('w', $WNS, [string]$total)
      if ($null -eq $tpr.SelectSingleNode('w:tblLayout', $nsm)) {
        $lay = E 'tblLayout' @{ type = 'fixed' } $null
        $look = $tpr.SelectSingleNode('w:tblLook', $nsm)
        if ($null -ne $look) { [void]$tpr.InsertBefore($lay, $look) } else { [void]$tpr.AppendChild($lay) }
      }
      $gc = @($tbl.SelectNodes('w:tblGrid/w:gridCol', $nsm))
      for ($i = 0; $i -lt $gc.Count; $i++) { [void]$gc[$i].SetAttribute('w', $WNS, [string]$grid[$i]) }
      foreach ($tr in @($tbl.SelectNodes('w:tr', $nsm))) {
        $i = 0
        foreach ($tc in @($tr.SelectNodes('w:tc', $nsm))) {
          $span = 1
          $gs = $tc.SelectSingleNode('w:tcPr/w:gridSpan', $nsm)
          if ($null -ne $gs) { $span = [int]$gs.GetAttribute('val', $WNS) }
          $cw = 0; for ($k = $i; $k -lt [Math]::Min($i + $span, $grid.Count); $k++) { $cw += $grid[$k] }
          $i += $span
          $tcpr = $tc.SelectSingleNode('w:tcPr', $nsm)
          if ($null -eq $tcpr) { $tcpr = E 'tcPr' $null $null; [void]$tc.InsertBefore($tcpr, $tc.FirstChild) }
          $old = $tcpr.SelectSingleNode('w:tcW', $nsm)
          if ($null -ne $old) { [void]$tcpr.RemoveChild($old) }
          $tcw = E 'tcW' @{ w = $cw; type = 'dxa' } $null
          if ($null -ne $tcpr.FirstChild) { [void]$tcpr.InsertBefore($tcw, $tcpr.FirstChild) } else { [void]$tcpr.AppendChild($tcw) }
        }
      }
    }

    # ---- 1. page setup of the last section, front-matter break before Sect. 1 ----
    $kids = @($body.ChildNodes | Where-Object { $_.NodeType -eq 'Element' })
    $introP = $null
    foreach ($n in $kids) { if ($n.LocalName -eq 'p' -and (PStyle $n) -eq 'Heading2' -and $n.InnerText.Trim() -eq '1. Introduction') { $introP = $n; break } }
    if ($null -eq $introP) { throw 'heading 1. Introduction not found' }
    $anchor = $introP
    $pv = $introP.PreviousSibling
    while ($pv -ne $null -and $pv.NodeType -ne 'Element') { $pv = $pv.PreviousSibling }
    if ($pv -ne $null -and $pv.LocalName -eq 'bookmarkStart') { $anchor = $pv }
    [void]$body.InsertBefore((TinyPara (SectEl $false 1)), $anchor)

    # ---- 1b. group spanning equations: when the text between two spanning equations is short (no heading, figure or data table, at most
    #          $GAPMAX characters), the text and the equations in between join the one-column section, so that no two-column fragment of
    #          a few lines is left between two equations (Word balances the columns before every continuous break) ----
    function IsEqTable($t) { return ($t.LocalName -eq 'tbl' -and $null -ne $t.SelectSingleNode('.//w:fldSimple[contains(@w:instr, "SEQ Equation")]', $nsm)) }
    # estimated width of a formula in units of one letter (about 0.2 cm at 10 pt): letters and digits 1, operators 1.6, brackets and commas 0.6,
    # sub- and superscripts 0.7, a fraction the wider of its two parts, an aligned system the widest row, a matrix the sum of its column widths
    $opChars = ([string][char]0x3D) + [char]0x2B + [char]0x2212 + [char]0x2D + [char]0x3C + [char]0x3E + [char]0x2264 + [char]0x2265 + [char]0xB1 + [char]0xD7 + [char]0xB7 + [char]0x2248 + [char]0x2192
    function MWKids($n) { $s = 0.0; foreach ($c in $n.ChildNodes) { if ($c.NodeType -eq 'Element') { $s += (MW $c) } }; return $s }
    function MWOf($n, [string]$name) { $c = $n.SelectSingleNode('m:' + $name, $nsm); if ($null -eq $c) { return 0.0 }; return (MWKids $c) }
    function MW($n) {
      switch ($n.LocalName) {
        'r' {
          $s = 0.0
          foreach ($t in @($n.SelectNodes('m:t', $nsm))) {
            foreach ($ch in $t.InnerText.ToCharArray()) {
              if ($opChars.IndexOf($ch) -ge 0) { $s += 1.6 }
              elseif ($ch -eq [char]0x26) { }
              elseif ($ch -eq ' ' -or $ch -eq ',' -or $ch -eq '(' -or $ch -eq ')' -or $ch -eq '[' -or $ch -eq ']') { $s += 0.6 }
              else { $s += 1.0 }
            }
          }
          return $s
        }
        'sSub' { return (MWOf $n 'e') + 0.7 * (MWOf $n 'sub') }
        'sSup' { return (MWOf $n 'e') + 0.7 * (MWOf $n 'sup') }
        'sSubSup' { return (MWOf $n 'e') + 0.7 * [Math]::Max((MWOf $n 'sub'), (MWOf $n 'sup')) }
        'f' { return [Math]::Max((MWOf $n 'num'), (MWOf $n 'den')) + 0.5 }
        'rad' { return 0.7 * (MWOf $n 'deg') + (MWOf $n 'e') + 1.2 }
        'nary' { return (MWOf $n 'e') + 0.7 * [Math]::Max((MWOf $n 'sub'), (MWOf $n 'sup')) + 1.5 }
        'd' { $s = 0.0; foreach ($e in @($n.SelectNodes('m:e', $nsm))) { $s += (MWKids $e) }; return $s + 1.5 }
        'eqArr' { $mx = 0.0; foreach ($e in @($n.SelectNodes('m:e', $nsm))) { $w = (MWKids $e); if ($w -gt $mx) { $mx = $w } }; return $mx }
        'm' {
          $colw = New-Object System.Collections.ArrayList
          foreach ($mr in @($n.SelectNodes('m:mr', $nsm))) {
            $j = 0
            foreach ($e in @($mr.SelectNodes('m:e', $nsm))) {
              $w = (MWKids $e)
              if ($j -ge $colw.Count) { [void]$colw.Add($w) } elseif ($w -gt $colw[$j]) { $colw[$j] = $w }
              $j++
            }
          }
          $s = 0.0; foreach ($w in $colw) { $s += $w + 1.0 }
          return $s
        }
        default { return (MWKids $n) }
      }
    }
    function EqChars($t) { $mw = 0.0; foreach ($om in @($t.SelectNodes('.//m:oMath', $nsm))) { $w = (MWKids $om); if ($w -gt $mw) { $mw = $w } }; return $mw }
    $GAPMAX = 700
    $fullSet = New-Object 'System.Collections.Generic.HashSet[object]'
    $joinSet = New-Object 'System.Collections.Generic.HashSet[object]'
    $spanIdx = @()
    $eqWidthLog = @()
    for ($i = 0; $i -lt $kids.Count; $i++) { if (IsEqTable $kids[$i]) { $wq = EqChars $kids[$i]; $eqWidthLog += [int][Math]::Round($wq); if ($wq -gt $SPAN_CHARS) { $spanIdx += $i } } }
    "estimated equation widths (letters): " + ($eqWidthLog -join " ")
    for ($q = 1; $q -lt $spanIdx.Count; $q++) {
      $ia = $spanIdx[$q - 1]; $ib = $spanIdx[$q]; $gap = 0; $blocked = $false
      for ($k = $ia + 1; $k -lt $ib; $k++) {
        $ek = $kids[$k]
        if ($ek.LocalName -eq 'p') {
          $sk = PStyle $ek
          if ($sk -like 'Heading*' -or $sk -eq 'CaptionedFigure' -or $sk -eq 'ImageCaption') { $blocked = $true } else { $gap += $ek.InnerText.Length }
        } elseif ($ek.LocalName -eq 'tbl' -and -not (IsEqTable $ek)) { $blocked = $true }
      }
      if (-not $blocked -and $gap -le $GAPMAX) {
        [void]$joinSet.Add($kids[$ib])
        for ($k = $ia + 1; $k -lt $ib; $k++) { [void]$fullSet.Add($kids[$k]) }
      }
    }

    # ---- 2. walk the body ----
    $cFig = 0; $cSpan = 0; $cEqCol = 0; $cEqFull = 0; $cTbl = 0; $cRef = 0; $cHr = 0
    $inRefs = $false; $inNomen = $false; $lastCloser = $null
    foreach ($n in $kids) {
      if ($n.NodeType -ne 'Element') { continue }
      if ($n.LocalName -eq 'p') {
        if ($null -ne $n.SelectSingleNode('.//v:rect', $nsm)) { [void]$body.RemoveChild($n); $cHr++; continue }
        $sv = PStyle $n
        if ($sv -eq 'Heading2') {
          $tx = $n.InnerText.Trim()
          $inRefs = ($tx -eq 'References'); $inNomen = ($tx -eq 'Nomenclature')
        } elseif ($sv -like 'Heading*') { $inRefs = $false; $inNomen = $false }
        if ($inRefs -and ($null -ne $n.SelectSingleNode('w:pPr/w:numPr', $nsm))) {
          $ps = $n.SelectSingleNode('w:pPr/w:pStyle', $nsm)
          if ($null -eq $ps) { $ps = E 'pStyle' @{ val = 'RefItem' } $null; $ppr = $n.SelectSingleNode('w:pPr', $nsm); [void]$ppr.InsertBefore($ps, $ppr.FirstChild) }
          else { [void]$ps.SetAttribute('val', $WNS, 'RefItem') }
          $cRef++
        }
        if ($sv -eq 'CaptionedFigure') {
          $cap = NextEl $n
          if ($cap -eq $null -or $cap.LocalName -ne 'p' -or (PStyle $cap) -ne 'ImageCaption') { throw 'figure paragraph without caption' }
          # the image size is already that of the 17 cm text width (pandoc scales width=100% to the page of the reference document)
          $tcell = E 'tc' $null @((E 'tcPr' $null @((E 'tcW' @{ w = $FULL; type = 'dxa' } $null))))
          $tbl = E 'tbl' $null @(
            (E 'tblPr' $null @(
              (E 'tblpPr' @{ leftFromText = 0; rightFromText = 0; topFromText = 0; bottomFromText = 170; vertAnchor = 'margin'; horzAnchor = 'margin'; tblpXSpec = 'center'; tblpYSpec = 'top' } $null),
              (E 'tblOverlap' @{ val = 'never' } $null),
              (E 'tblW' @{ w = $FULL; type = 'dxa' } $null),
              (E 'tblBorders' $null @((E 'top' @{ val = 'nil' } $null), (E 'left' @{ val = 'nil' } $null), (E 'bottom' @{ val = 'nil' } $null), (E 'right' @{ val = 'nil' } $null), (E 'insideH' @{ val = 'nil' } $null), (E 'insideV' @{ val = 'nil' } $null))),
              (E 'tblLayout' @{ type = 'fixed' } $null),
              (E 'tblCellMar' $null @((E 'left' @{ w = 0; type = 'dxa' } $null), (E 'right' @{ w = 0; type = 'dxa' } $null))),
              (E 'tblLook' @{ val = '0000'; firstRow = 0; lastRow = 0; firstColumn = 0; lastColumn = 0; noHBand = 0; noVBand = 0 } $null))),
            (E 'tblGrid' $null @((E 'gridCol' @{ w = $FULL } $null))),
            (E 'tr' $null @((E 'trPr' $null @((E 'cantSplit' $null $null))), $tcell)))
          [void]$body.InsertBefore($tbl, $n)
          [void]$tcell.AppendChild($n)
          [void]$tcell.AppendChild($cap)
          [void]$body.InsertAfter((TinyPara $null), $tbl)
          $cFig++
        }
      } elseif ($n.LocalName -eq 'tbl') {
        if (IsEqTable $n) {
          if ((EqChars $n) -gt $SPAN_CHARS) {
            SetTblWidths $n @(316, ($FULL - 316 - 950), 950)
            $prev = PrevEl $n
            if ($joinSet.Contains($n)) {
              # the text between the previous spanning equation and this one stays in the one-column section: drop the break between them
              [void]$body.RemoveChild($lastCloser)
            } elseif ($prev -ne $null -and $prev.LocalName -eq 'p' -and $null -eq $prev.SelectSingleNode('w:pPr/w:sectPr', $nsm)) {
              AddSectToPara $prev (SectEl $true 2)
            } else {
              [void]$body.InsertBefore((TinyPara (SectEl $true 2)), $n)
            }
            $closer = TinyPara (SectEl $true 1)
            [void]$body.InsertAfter($closer, $n)
            $lastCloser = $closer
            $cSpan++
          } elseif ($fullSet.Contains($n)) {
            SetTblWidths $n @(316, ($FULL - 316 - 950), 950)
            $cEqFull++
          } else {
            SetTblWidths $n @(100, ($COL - 100 - 620), 620)
            $cEqCol++
          }
        } else {
          $cols = @($n.SelectNodes('w:tblGrid/w:gridCol', $nsm))
          $old = @($cols | ForEach-Object { [int]$_.GetAttribute('w', $WNS) })
          if ($inNomen -and $old.Count -eq 2) { $new = @([int]($COL * 0.3), ($COL - [int]($COL * 0.3))) }
          else {
            $sum = ($old | Measure-Object -Sum).Sum
            $new = @(); $acc = 0
            for ($i = 0; $i -lt $old.Count; $i++) {
              if ($i -lt $old.Count - 1) { $v = [int]($COL * $old[$i] / $sum); $acc += $v; $new += $v } else { $new += ($COL - $acc) }
            }
          }
          SetTblWidths $n $new
          $cTbl++
        }
      }
    }
    # ---- 3. last section: two columns, continuous ----
    $oldSect = $body.SelectSingleNode('w:sectPr', $nsm)
    $newSect = SectEl $true 2
    if ($null -ne $oldSect) { [void]$body.ReplaceChild($newSect, $oldSect) } else { [void]$body.AppendChild($newSect) }

    $ws = New-Object System.Xml.XmlWriterSettings
    $ws.Encoding = $U8; $ws.Indent = $false
    $xw = [System.Xml.XmlWriter]::Create("$x\word\document.xml", $ws)
    $xd.Save($xw); $xw.Close()
    "two-column layout: figures $cFig floating at the page top ; spanning equations $cSpan (breaks removed by grouping $($joinSet.Count)) ; short equations inside a full-width group $cEqFull ; in-column equations $cEqCol ; data tables $cTbl ; reference items $cRef ; rules removed $cHr"
  } else {
    [IO.File]::WriteAllText("$x\word\document.xml", $doc, $U8)
  }
  ZipDir $x $Docx
  "equation tables: $script:nEq ; data tables: $script:nData"
  "docx: " + (Get-Item -LiteralPath $Docx).Length + " bytes -> " + $Docx
} finally {
  Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
