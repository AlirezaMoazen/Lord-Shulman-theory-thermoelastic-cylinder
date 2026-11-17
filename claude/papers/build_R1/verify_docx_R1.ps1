# verify_docx_R1.ps1 -Md <file.md> -Docx <file.docx>
# Checks that every text unit of the markdown (paragraph, list item, table cell; math and citations removed) landed in the docx,
# by comparing the first and last 20 letters (a-z only). pandoc exits 0 even when it drops content.
param([string]$Md, [string]$Docx)
$U8 = New-Object Text.UTF8Encoding($false)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$z = [IO.Compression.ZipFile]::OpenRead($Docx)
$e = $z.GetEntry('word/document.xml')
$sr = New-Object IO.StreamReader($e.Open(), $U8)
$xml = $sr.ReadToEnd(); $sr.Close(); $z.Dispose()
$wt = ([regex]::Matches($xml, '<w:t[^>]*>([^<]*)</w:t>') | ForEach-Object { $_.Groups[1].Value }) -join ''
$wt = [Net.WebUtility]::HtmlDecode($wt)
$docL = ([regex]::Replace($wt, '[^A-Za-z]', '')).ToLower()
$text = [IO.File]::ReadAllText($Md, $U8)
# drop comment, yaml
$text = [regex]::Replace($text, '(?s)<!--.*?-->', '')
$text = [regex]::Replace($text, '(?s)\A---\r?\n.*?\r?\n---\r?\n', '')
$blocks = [regex]::Split($text, "\r?\n\s*\r?\n")
$n = 0; $miss = 0
foreach ($b in $blocks) {
  $t = $b.Trim()
  if ($t -eq '' -or $t.StartsWith('$$') -or $t.StartsWith(':::') -or $t.StartsWith('![') -or $t -eq '---') { continue }
  foreach ($ln in ($t -split "\r?\n")) {
    $l = $ln.Trim()
    if ($l -eq '' -or $l.StartsWith('$$') -or $l.StartsWith(':::') -or $l.StartsWith('![') -or $l.StartsWith('|---') -or $l -eq '---') { continue }
    $l = $l -replace '^>\s?', '' -replace '^#+\s+', '' -replace '^\d+\.\s+', '' -replace '^[-*]\s+', ''
    if ($l.StartsWith('|')) { $cells = $l.Trim('|').Split('|') } else { $cells = @($l) }
    foreach ($c in $cells) {
      $s = [regex]::Replace($c, '\$[^$]*\$', ' ')
      $s = [regex]::Replace($s, '\{\{[^}]*\}\}', ' ')
      $s = [regex]::Replace($s, '\[[0-9,\s–\-]+\]', ' ')
      $L = ([regex]::Replace($s, '[^A-Za-z]', '')).ToLower()
      if ($L.Length -lt 12) { continue }
      $n++
      $a = $L.Substring(0, [Math]::Min(20, $L.Length)); $b2 = $L.Substring($L.Length - [Math]::Min(20, $L.Length))
      if (-not $docL.Contains($a) -or -not $docL.Contains($b2)) { $miss++; if ($miss -le 12) { 'MISS: ' + $c.Substring(0, [Math]::Min(90, $c.Length)) } }
    }
  }
}
"checked $n text units, missing $miss"
