& {
    Add-Type -AssemblyName System.Windows.Forms
    $null = Read-Host 'Copy the Amazon page with Ctrl+A, Ctrl+C, then return here and press Enter'
    $html = [System.Windows.Forms.Clipboard]::GetText([System.Windows.Forms.TextDataFormat]::Html)
    if (-not $html) { throw 'No page received. Copy the Amazon page body again.' }
    $path = Join-Path $env:USERPROFILE 'Downloads\Amazon-Books.html'
    [System.IO.File]::WriteAllText($path, $html, [System.Text.Encoding]::UTF8)
    Write-Host "Copied page received. Saved: $path"
}
