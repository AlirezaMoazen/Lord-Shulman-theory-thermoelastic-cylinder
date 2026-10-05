# Remove image alt-text (the "Description"/"Alt Text" field) from a .docx.
#
# Word stores alt-text as descr="..." / title="..." attributes on the drawing
# elements <wp:docPr> and <pic:cNvPr>. It is invisible in normal reading view
# but travels with the file. In this thesis it carried three things worth
# removing: absolute local paths from another machine (C:\Users\<name>\...),
# internal project folder names, and auto-generated figure descriptions whose
# stated mesh contradicted the chapter text.
#
# The source file is never modified -- output goes to a new .docx.
#
#   .\strip_image_alttext_R1.ps1 -Src "thesis.docx" -Out "thesis_clean.docx"

param(
    [Parameter(Mandatory=$true)][string]$Src,
    [Parameter(Mandatory=$true)][string]$Out
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$work = Join-Path ([System.IO.Path]::GetDirectoryName($Out)) ("_altwork_" + [guid]::NewGuid().ToString("N").Substring(0,6))
[System.IO.Compression.ZipFile]::ExtractToDirectory((Resolve-Path $Src), $work)

$total = 0
Get-ChildItem $work -Recurse -File -Filter *.xml | ForEach-Object {
    $raw = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    $before = $raw

    # strip alt-text attributes only on the drawing property elements
    $raw = [regex]::Replace($raw, '(<(?:wp|pic|a|wps|wpg):(?:docPr|cNvPr)\b[^>]*?)\s+descr="[^"]*"', '$1')
    $raw = [regex]::Replace($raw, '(<(?:wp|pic|a|wps|wpg):(?:docPr|cNvPr)\b[^>]*?)\s+title="[^"]*"',  '$1')

    if ($raw -ne $before) {
        $hits = ([regex]::Matches($before, 'descr="')).Count + ([regex]::Matches($before, '<(?:wp|pic):(?:docPr|cNvPr)[^>]*title="')).Count
        $total += $hits
        [System.IO.File]::WriteAllText($_.FullName, $raw, (New-Object System.Text.UTF8Encoding($false)))
        Write-Output ("  cleaned: " + $_.Name + "  (" + $hits + " attributes)")
    }
}

# Repack. ZipFile::CreateFromDirectory writes Windows backslash separators into
# entry names, which is invalid OPC and can make Word reject the file, so each
# entry is written explicitly with a forward-slash name and [Content_Types].xml
# is placed first as the OPC spec expects.
if (Test-Path $Out) { Remove-Item $Out -Force }
Push-Location $work
$rel = @(Get-ChildItem -Recurse -File -Name)
Pop-Location
$pairs = foreach ($r in $rel) {
    [pscustomobject]@{ Full = (Join-Path $work $r); Name = ($r -replace '\\','/') }
}
$ordered = @()
$ordered += $pairs | Where-Object { $_.Name -eq '[Content_Types].xml' }
$ordered += $pairs | Where-Object { $_.Name -ne '[Content_Types].xml' }

$fs  = [System.IO.File]::Open($Out, [System.IO.FileMode]::Create)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
foreach ($p in $ordered) {
    $e  = $zip.CreateEntry($p.Name, [System.IO.Compression.CompressionLevel]::Optimal)
    $es = $e.Open()
    $b  = [System.IO.File]::ReadAllBytes($p.Full)
    $es.Write($b, 0, $b.Length)
    $es.Dispose()
}
$zip.Dispose(); $fs.Dispose()
Remove-Item $work -Recurse -Force

Write-Output ("alt-text attributes removed : " + $total)
Write-Output ("written                     : " + $Out)
