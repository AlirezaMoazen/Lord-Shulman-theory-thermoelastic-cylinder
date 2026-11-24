# references_to_ris_R1.ps1 -- export the reference list of an article markdown file as an RIS file for EndNote
# Purpose : author instruction of 2026-11-23 (Prom8 item 20): "write all references with EndNote". EndNote's own citation
#           fields can only be created by EndNote from the author's library, so this script gives the next best thing: every
#           entry of the numbered list under the heading "References" becomes one RIS record (journal article when the
#           entry has the form  authors, "title," journal, vol., no., pp., year ; otherwise a generic record). The original
#           text of the entry is kept in the note field N1 and the number in the list in the accession number field AN, so
#           nothing is lost when a field is not recognised.
# Use     : in EndNote choose File > Import > File, select the .ris file, import option "Reference Manager (RIS)",
#           text translation UTF-8, into a NEW EMPTY library. Records then get the record numbers 1 to 92 in list order.
# Usage   : powershell -File references_to_ris_R1.ps1 [-Md <file.md>] [-Ris <file.ris>]
# Output  : a check line with the number of records and of records recognised as journal articles.
param([string]$Md = '', [string]$Ris = '')
$here = $PSScriptRoot
$papers = Split-Path -Parent $here
if ($Md -eq '') { $Md = Join-Path $papers 'ARTICLE_FULL_THESIS_EN_R5.md' }
$Md = (Resolve-Path -LiteralPath $Md).Path
if ($Ris -eq '') { $Ris = [IO.Path]::ChangeExtension($Md, $null).TrimEnd('.') + '_references.ris' }
$U8 = New-Object Text.UTF8Encoding($false)
$text = [IO.File]::ReadAllText($Md, $U8) -replace "`r`n", "`n"
$a = $text.IndexOf("`n## References"); if ($a -lt 0) { throw 'heading References not found' }
$b = $text.IndexOf("`n## ", $a + 5); if ($b -lt 0) { $b = $text.Length }
$sec = $text.Substring($a, $b - $a)
$entries = [regex]::Matches($sec, '(?m)^(\d+)\. (.+)$')

function Convert-Author($au) {
  # "S. Zhao" -> "Zhao, S." ; "M. Omidi Bidgoli" -> "Omidi Bidgoli, M." ; a single token stays as it is
  $tok = $au.Trim() -split '\s+'
  $ini = @(); $i = 0
  while ($i -lt $tok.Count - 1 -and $tok[$i] -match '^\p{Lu}\.(-\p{Lu}\.)?$') { $ini += $tok[$i]; $i++ }
  $last = ($tok[$i..($tok.Count - 1)]) -join ' '
  if ($ini.Count -eq 0) { return $last }
  return $last + ', ' + ($ini -join ' ')
}

$sb = New-Object Text.StringBuilder
$n = 0; $nj = 0
foreach ($m in $entries) {
  $num = [int]$m.Groups[1].Value; $raw = $m.Groups[2].Value.Trim()
  $n++
  $authors = @(); $title = ''; $rest = ''
  $q = [regex]::Match($raw, '^(?<au>.*?),?\s*"(?<ti>[^"]+)"\s*(?<rest>.*)$')
  if ($q.Success) {
    $auTxt = $q.Groups['au'].Value
    $title = $q.Groups['ti'].Value.Trim().TrimEnd(',')
    $rest = $q.Groups['rest'].Value.Trim().TrimStart(',').Trim()
    $auTxt = $auTxt -replace ',?\s+and\s+', ', ' -replace ',\s*,', ','
    $authors = @($auTxt -split ',\s*' | Where-Object { $_.Trim() -ne '' } | ForEach-Object { Convert-Author $_ })
  } else {
    $title = $raw
  }
  $year = ''; $ym = [regex]::Match($rest, '(19|20)\d\d\.?\s*$'); if ($ym.Success) { $year = $ym.Value.Trim().TrimEnd('.') }
  $vol = ''; $vm = [regex]::Match($rest, 'vol\.\s*([\w\-]+)'); if ($vm.Success) { $vol = $vm.Groups[1].Value }
  $iss = ''; $im = [regex]::Match($rest, 'no\.\s*([\w\-]+)'); if ($im.Success) { $iss = $im.Groups[1].Value }
  $sp = ''; $ep = ''
  $pm = [regex]::Match($rest, 'pp\.\s*([\w]+)\s*\p{Pd}\s*([\w]+)')
  if ($pm.Success) { $sp = $pm.Groups[1].Value; $ep = $pm.Groups[2].Value }
  else { $pm1 = [regex]::Match($rest, '\bp\.\s*([\w]+)'); if ($pm1.Success) { $sp = $pm1.Groups[1].Value } }
  $jour = ''
  $jm = [regex]::Match($rest, '^(?<j>[^,]+?)(,\s*(vol\.|no\.|pp\.|p\.|e\d|(19|20)\d\d)|\s*$)')
  if ($jm.Success -and $rest -notmatch '^(pp\.|p\.|vol\.|no\.)') { $jour = $jm.Groups['j'].Value.Trim() }
  $isJ = ($jour -ne '' -and $q.Success)
  if ($isJ) { $nj++ }
  [void]$sb.AppendLine('TY  - ' + $(if ($isJ) { 'JOUR' } else { 'GEN' }))
  foreach ($au in $authors) { [void]$sb.AppendLine('AU  - ' + $au) }
  [void]$sb.AppendLine('TI  - ' + $title)
  if ($jour -ne '') { [void]$sb.AppendLine('JO  - ' + $jour) }
  if ($year -ne '') { [void]$sb.AppendLine('PY  - ' + $year) }
  if ($vol -ne '') { [void]$sb.AppendLine('VL  - ' + $vol) }
  if ($iss -ne '') { [void]$sb.AppendLine('IS  - ' + $iss) }
  if ($sp -ne '') { [void]$sb.AppendLine('SP  - ' + $sp) }
  if ($ep -ne '') { [void]$sb.AppendLine('EP  - ' + $ep) }
  [void]$sb.AppendLine('AN  - ' + $num)
  [void]$sb.AppendLine('N1  - Entry ' + $num + ' of the reference list: ' + $raw)
  [void]$sb.AppendLine('ER  - ')
  [void]$sb.AppendLine('')
}
[IO.File]::WriteAllText($Ris, $sb.ToString(), $U8)
"RIS records: $n (journal articles recognised: $nj, generic: $($n - $nj)) -> $Ris"
