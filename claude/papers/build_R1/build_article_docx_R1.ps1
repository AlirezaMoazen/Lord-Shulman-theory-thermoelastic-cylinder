# build_article_docx_R1.ps1
# Builds the Word version of an article markdown file of this folder (default ARTICLE_FULL_THESIS_EN_R3.md).
#   pandoc + article_R1.lua  -> equations, figures and tables get Word SEQ/REF fields (automatic numbers),
#                               display equations are 3-column tables with the number at the far right
#   reference document      -> A4, Times New Roman 11 pt, black headings, three-line data tables
#   post-processing         -> vertical centring of equation rows, 10 pt data tables, no path in picture alt text
# Usage (from anywhere):  powershell -File build_article_docx_R1.ps1 [-Md <file.md>] [-Docx <file.docx>]
# Needs pandoc >= 3 with Lua. In Word, Ctrl+A then F9 renumbers every field after a figure, table or equation is inserted or deleted.
param([string]$Md = '', [string]$Docx = '')
$here = $PSScriptRoot
$papers = Split-Path -Parent $here
if ($Md -eq '') { $Md = Join-Path $papers 'ARTICLE_FULL_THESIS_EN_R3.md' }
$Md = (Resolve-Path -LiteralPath $Md).Path
if ($Docx -eq '') { $Docx = [IO.Path]::ChangeExtension($Md, '.docx') }
$U8 = New-Object Text.UTF8Encoding($false)
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

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
    $script:st = [regex]::Replace($script:st, $pat, { param($m) $xml })
  }
  $dd = '<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman"/><w:sz w:val="22"/><w:szCs w:val="22"/><w:lang w:val="en-GB" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="120" w:line="276" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>'
  $st = [regex]::Replace($st, '(?s)<w:docDefaults>.*?</w:docDefaults>', { param($m) $dd })
  SetStyle 'BodyText' '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="276" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr></w:style>'
  SetStyle 'Compact' '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="40" w:after="40" w:line="240" w:lineRule="auto"/><w:jc w:val="left"/></w:pPr></w:style>'
  SetStyle 'Heading1' '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="320" w:after="120"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>'
  SetStyle 'Heading2' '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="100"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'
  SetStyle 'Heading3' '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="80"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>'
  SetStyle 'Heading4' '<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading4Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="160" w:after="60"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>'
  SetStyle 'Title' '<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="TitleChar"/><w:uiPriority w:val="10"/><w:qFormat/><w:pPr><w:spacing w:before="120" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr></w:style>'
  SetStyle 'Caption' '<w:style w:type="paragraph" w:styleId="Caption"><w:name w:val="Caption"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:pPr><w:spacing w:before="60" w:after="200" w:line="240" w:lineRule="auto"/><w:jc w:val="both"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>'
  SetStyle 'TableCaption' '<w:style w:type="paragraph" w:customStyle="1" w:styleId="TableCaption"><w:name w:val="Table Caption"/><w:basedOn w:val="Caption"/><w:pPr><w:keepNext/><w:spacing w:before="200" w:after="80"/></w:pPr></w:style>'
  SetStyle 'Figure' '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Figure"><w:name w:val="Figure"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="160" w:after="40"/><w:jc w:val="center"/></w:pPr></w:style>'
  SetStyle 'CaptionedFigure' '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionedFigure"><w:name w:val="Captioned Figure"/><w:basedOn w:val="Figure"/><w:pPr><w:keepNext/><w:jc w:val="center"/></w:pPr></w:style>'
  SetStyle 'BlockText' '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:pBdr><w:top w:val="single" w:sz="4" w:space="4" w:color="808080"/><w:left w:val="single" w:sz="4" w:space="4" w:color="808080"/><w:bottom w:val="single" w:sz="4" w:space="4" w:color="808080"/><w:right w:val="single" w:sz="4" w:space="4" w:color="808080"/></w:pBdr><w:shd w:val="clear" w:color="auto" w:fill="F2F2F2"/><w:spacing w:before="60" w:after="60"/><w:ind w:left="170" w:right="170"/></w:pPr><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr></w:style>'
  SetStyle 'Table' '<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:semiHidden/><w:unhideWhenUsed/><w:qFormat/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="single" w:sz="8" w:space="0" w:color="000000"/><w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="108" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="108" w:type="dxa"/></w:tblCellMar></w:tblPr><w:tblStylePr w:type="firstRow"><w:tcPr><w:tcBorders><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/></w:tcBorders><w:vAlign w:val="bottom"/></w:tcPr></w:tblStylePr></w:style>'
  [IO.File]::WriteAllText("$rx\word\styles.xml", $st, $U8)
  $rd = [IO.File]::ReadAllText("$rx\word\document.xml", $U8)
  $sect = '<w:sectPr><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="1418" w:right="1418" w:bottom="1418" w:left="1418" w:header="709" w:footer="709" w:gutter="0"/></w:sectPr>'
  $rd = [regex]::Replace($rd, '(?s)<w:sectPr>.*?</w:sectPr>', { param($m) $sect })
  [IO.File]::WriteAllText("$rx\word\document.xml", $rd, $U8)
  ZipDir $rx "$work\ref_en.docx"

  # ---- pandoc ----
  Push-Location (Split-Path -Parent $Md)
  try {
    & pandoc (Split-Path -Leaf $Md) -f markdown-citations -t docx "--lua-filter=$here\article_R1.lua" "--reference-doc=$work\ref_en.docx" --resource-path=. -o "$work\raw.docx"
    if ($LASTEXITCODE -ne 0) { throw "pandoc failed ($LASTEXITCODE)" }
  } finally { Pop-Location }

  # ---- post-processing ----
  $x = "$work\raw_x"
  [IO.Compression.ZipFile]::ExtractToDirectory("$work\raw.docx", $x)
  $doc = [IO.File]::ReadAllText("$x\word\document.xml", $U8)
  $nil = '<w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders>'
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
      $t = [regex]::Replace($t, '<w:r>(\s*)<w:t', '<w:r><w:rPr><w:sz w:val="20"/><w:szCs w:val="20"/></w:rPr><w:t')
    }
    return $t
  })
  $doc = [regex]::Replace($doc, '<pic:cNvPr descr="[^"]*"', '<pic:cNvPr descr=""')
  [IO.File]::WriteAllText("$x\word\document.xml", $doc, $U8)
  ZipDir $x $Docx
  "equation tables: $script:nEq ; data tables: $script:nData"
  "docx: " + (Get-Item -LiteralPath $Docx).Length + " bytes -> " + $Docx
} finally {
  Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue
}
