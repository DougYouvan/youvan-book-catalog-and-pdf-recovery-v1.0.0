# Fresh standalone version. Run with Windows PowerShell -STA.
# Windows PowerShell: copy one page, export one Title/URL CSV.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
$null = Read-Host 'In Chrome, click the Amazon page, press Ctrl+A then Ctrl+C. Return here and press Enter'
$html = [System.Windows.Forms.Clipboard]::GetText([System.Windows.Forms.TextDataFormat]::Html)
if (-not $html) { throw 'No copied HTML. Copy the Amazon page body, then run again.' }
Write-Host 'Copied page received. Reading book links...'
$html = $html -replace '(?is)<(script|style)\b[^>]*>.*?</\1\s*>|<!--.*?-->', ''

function Attribute([string]$markup, [string]$name) {
    $m = [regex]::Match($markup, '(?is)(?:^|\s)' + $name + '\s*=\s*(?:"([^"]*)"|''([^'']*)'')')
    $encoded = $m.Groups[1].Value + $m.Groups[2].Value
    [System.Net.WebUtility]::HtmlDecode($encoded)
}
function Text([string]$markup) {
    $plain = $markup -replace '<[^>]*>', ' '
    $decoded = [System.Net.WebUtility]::HtmlDecode($plain)
    ($decoded -replace '\s+', ' ').Trim()
}

$books = @{}
$generic = '(?i)^(?:image|(?:book )?cover(?: image)?|paperback|mass market paperback|hardcover|kindle(?: edition| ebook| unlimited)?|ebook|audiobook|audio cd|see options|select options|see details|view details|details|buy now|add to cart|learn more|see all formats(?: and editions)?)$'
foreach ($a in [regex]::Matches($html, '(?is)<a\b(?<attrs>[^>]*)>(?<body>.*?)</a\s*>')) {
    $attrs = $a.Groups['attrs'].Value
    $body = $a.Groups['body'].Value
    $href = Attribute $attrs 'href'
    $uri = $null
    if (-not [uri]::TryCreate([uri]'https://www.amazon.com/', $href, [ref]$uri)) { continue }
    if ($uri.Host -notmatch '(?i)(^|\.)amazon\.com$') { continue }
    $m = [regex]::Match($uri.AbsolutePath, '(?i)/(?:dp|gp/product)/([a-z0-9]{10})(?:/|$)')
    if (-not $m.Success) { continue }
    $asin = $m.Groups[1].Value.ToUpperInvariant()
    $labels = @(
        (Attribute $attrs 'title')
        (Attribute $attrs 'aria-label')
        (Attribute $body 'alt')
        (Text $body)
    )
    $title = ''
    foreach ($label in $labels) {
        $label = ([string]$label -replace '\s+', ' ').Trim()
        if ($label -notmatch '\p{L}' -or $label -match $generic -or $label -match '(?i)\bout of 5 stars\b|\$\d') { continue }
        if (-not $title -or ($title -match '(?:\.{3}|\u2026)$' -and $label -notmatch '(?:\.{3}|\u2026)$')) { $title = $label }
    }
    if (-not $books.ContainsKey($asin) -or $books[$asin] -eq '[Title missing]' -or
        ($title -and $books[$asin] -match '(?:\.{3}|\u2026)$' -and $title -notmatch '(?:\.{3}|\u2026)$')) {
        if (-not $title) { $title = '[Title missing]' }
        $books[$asin] = $title
    }
}
if (-not $books.Count) { throw 'No product links found. Copy the book list from Chrome and try again.' }
$rows = @($books.GetEnumerator() | ForEach-Object {
    [pscustomobject]@{ Title = $_.Value; URL = 'https://www.amazon.com/dp/' + $_.Key }
} | Sort-Object Title)
$path = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Douglas-Youvan-Books.csv'
$rows | Export-Csv -LiteralPath $path -NoTypeInformation -Encoding UTF8
Write-Host ("Saved {0} product links: {1}" -f $rows.Count, $path)
if ($rows.Count -ne 51) { Write-Warning 'Expected 51 books. Upload the CSV so the extracted list can be checked.' }
if (@($rows | Where-Object { $_.Title -match '^\[Title missing\]$|(?:\.{3}|\u2026)$' }).Count) {
    Write-Warning 'Some titles are missing or truncated. Upload the CSV for review.'
}
