# Collect the 11 missing / unresolved books from Downloads.
# Windows PowerShell 5.1, Windows 10 or 11. No additional software needed.
# Copies only. It does not upload, move, delete, or change your source files.
[CmdletBinding()]
param(
    [string]$SourceFolder = '',
    [switch]$NoOpen,
    [switch]$NoPause
)

$ErrorActionPreference = 'Stop'

function Get-BookTargets {
    @(
        [pscustomobject]@{ Stem='Intelligent-Design-and-the-Genetic-Code'; Title='Intelligent Design and the Genetic Code: Mathematics, Bootstrapping, and the Architecture of Biological Meaning'; Aliases=@('intelligent design and the genetic code'); Review=''; Audit='Missing from the public Drive folder.' }
        [pscustomobject]@{ Stem='The-History-That-Never-Closes'; Title='The History That Never Closes: Nuclear Ambiguity, False Flags, Narrative Capture, and the Permanent Crisis of Attribution'; Aliases=@('the history that never closes','history that never closes'); Review=''; Audit='Missing from the public Drive folder.' }
        [pscustomobject]@{ Stem='Jezebel-and-the-Religion-of-Power'; Title='Jezebel and the Religion of Power'; Aliases=@('jezebel and the religion of power'); Review=''; Audit='Missing from the public Drive folder.' }
        [pscustomobject]@{ Stem='The-Architecture-Before-the-World'; Title='The Architecture Before the World: What the World Wide Web Teaches Us About Mathematics, AI, and Things That Do Not Exist Yet'; Aliases=@('the architecture before the world','architecture before the world'); Review=''; Audit='Missing from the public Drive folder.' }
        [pscustomobject]@{ Stem='Microbial-Energy-Transduction'; Title='Microbial Energy Transduction: Genetics, Structure, and Function of Membrane Proteins (CURRENT COMMUNICATIONS IN CELL AND MOLECULAR BIOLOGY)'; Aliases=@('microbial energy transduction','0879691948','9780879691947'); Review=''; Audit='Missing from the public Drive folder.' }
        [pscustomobject]@{ Stem='Questions-of-a-Christian-Biophysicist'; Title='Questions of a Christian Biophysicist'; Aliases=@('questions of a christian biophysicist'); Review='Check that this is the full intended book edition. The public PDF is a 57-page question collection.'; Audit='Existing public version needs edition review.' }
        [pscustomobject]@{ Stem='Mathematics-and-LEGOs'; Title='Mathematics and LEGOs: From Bricks and Morphisms to Relation, Meaning, and Self-Constructing Mathematical Worlds'; Aliases=@('mathematics and legos'); Review='Check the title page and edition. The public PDF has an older or different subtitle.'; Audit='Existing public version needs edition review.' }
        [pscustomobject]@{ Stem='Solus-Logos'; Title='Solus Logos: The Living Word Beyond Sola Scriptura'; Aliases=@('solus logos'); Review='Check Chapter 15, The Exvangelical Conscience. It is listed in the public PDF contents but was not found in its body.'; Audit='Existing public version may have an omitted chapter or an outdated contents list.' }
        [pscustomobject]@{ Stem='From-Cubes-to-Worlds'; Title='From Cubes to Worlds: Anonymous Generation and the Emergence of Mathematics, Physics, and Gravitation'; Aliases=@('from cubes to worlds'); Review='Check the final pages. The public PDF ends with an editorial draft note.'; Audit='Existing public version needs final-manuscript review.' }
        [pscustomobject]@{ Stem='The-American-Gorbachev'; Title='The American Gorbachev: Trump, Strategic Retrenchment, and the Unmaking of Hegemonic Infrastructure'; Aliases=@('the american gorbachev','american gorbachev'); Review='Check that this is the full intended book edition. The public PDF is 50 pages and describes itself as a paper.'; Audit='Existing public version needs edition review.' }
        [pscustomobject]@{ Stem='How-to-Cheat-P-vs-NP'; Title='How to Cheat P vs NP: Relativity, Quantum Loops, Infinite Computers, and Twenty Attempts to Outsmart Computation'; Aliases=@('how to cheat p vs np','how to cheat p versus np'); Review='Check the title page and edition. The public PDF has a different subtitle.'; Audit='Existing public version needs edition review.' }
    )
}

function ConvertTo-MatchName([string]$Name) {
    # Spaces, punctuation, underscores, accents and CamelCase are interchangeable.
    $s = $Name -creplace '([a-z])([A-Z])', '$1 $2'
    $s = $s.Normalize([Text.NormalizationForm]::FormD)
    $s = $s -replace '\p{Mn}', ''
    $s = $s.ToLowerInvariant() -replace '&', ' and '
    $s = $s -replace '[^a-z0-9]+', ' '
    return ($s -replace '\s+', ' ').Trim()
}

function Test-BookName([string]$Name, $Target) {
    $normalized = ' ' + (ConvertTo-MatchName $Name) + ' '
    foreach ($alias in $Target.Aliases) {
        if ($normalized.Contains(' ' + (ConvertTo-MatchName $alias) + ' ')) { return $true }
    }
    return $false
}

function Test-WrapperName([string]$Name) {
    $s = ConvertTo-MatchName $Name
    # "With cover" can describe an interior, so plain "cover" is not rejected.
    return ($s -match '\b(wrapper|wraparound|wrap|jacket|spine|template)\b|\b(front cover|back cover|cover only|full cover|cover spread)\b')
}

function Get-DownloadsFolder {
    try {
        $key = Get-ItemProperty -LiteralPath 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
        $value = $key.'{374DE290-123F-4565-9164-39C4925E467B}'
        if ($value) { return [Environment]::ExpandEnvironmentVariables($value) }
    } catch { }
    return (Join-Path $env:USERPROFILE 'Downloads')
}

function Get-SourcePdfs([string]$Folder) {
    $scanErrors = @()
    $files = @(Get-ChildItem -LiteralPath $Folder -File -Recurse -ErrorAction SilentlyContinue -ErrorVariable +scanErrors |
        Where-Object {
            $_.Extension -ieq '.pdf' -and
            $_.FullName -notmatch '[\\/]Books-for-Google-Drive-[^\\/]+[\\/]'
        })
    return [pscustomobject]@{ Files=$files; Errors=@($scanErrors | ForEach-Object { $_.ToString() }) }
}

function Test-PdfHeader([string]$Path) {
    $stream = [IO.File]::OpenRead($Path)
    try {
        $buffer = New-Object byte[] 1024
        $count = $stream.Read($buffer, 0, $buffer.Length)
        return ([Text.Encoding]::ASCII.GetString($buffer, 0, $count).Contains('%PDF-'))
    } finally { $stream.Dispose() }
}

function Initialize-PdfReader {
    $script:PdfReaderAvailable = $false
    $script:PdfReaderProblem = ''
    try {
        Add-Type -AssemblyName System.Runtime.WindowsRuntime
        $null = [Windows.Storage.StorageFile, Windows.Storage, ContentType=WindowsRuntime]
        $null = [Windows.Data.Pdf.PdfDocument, Windows.Data.Pdf, ContentType=WindowsRuntime]
        $script:WinRtAsTask = [System.WindowsRuntimeSystemExtensions].GetMethods() |
            Where-Object {
                $_.Name -eq 'AsTask' -and $_.IsGenericMethodDefinition -and
                $_.GetGenericArguments().Length -eq 1 -and $_.GetParameters().Length -eq 1 -and
                $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1'
            } | Select-Object -First 1
        if ($null -eq $script:WinRtAsTask) { throw 'Windows PDF reader could not be initialized.' }
        $script:PdfReaderAvailable = $true
    } catch { $script:PdfReaderProblem = $_.Exception.Message }
}

function Wait-WinRt($Operation, [Type]$ResultType) {
    $method = $script:WinRtAsTask.MakeGenericMethod([Type[]]@($ResultType))
    $task = $method.Invoke($null, [object[]]@($Operation))
    if (-not $task.Wait(15000)) { throw 'Windows PDF inspection timed out.' }
    return $task.Result
}

function Get-PdfInspection([string]$Path) {
    $page = $null
    try {
        if (-not (Test-PdfHeader $Path)) {
            return [pscustomobject]@{ Pages=0; Suitable=$false; Reason='File does not have a PDF header. It will not be copied.'; ValidHeader=$false }
        }
        if (-not $script:PdfReaderAvailable) {
            return [pscustomobject]@{ Pages=0; Suitable=$false; Reason=('Windows could not inspect page count: ' + $script:PdfReaderProblem); ValidHeader=$true }
        }
        $storage = Wait-WinRt ([Windows.Storage.StorageFile]::GetFileFromPathAsync($Path)) ([Windows.Storage.StorageFile])
        $document = Wait-WinRt ([Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync($storage)) ([Windows.Data.Pdf.PdfDocument])
        $count = [int]$document.PageCount
        if ($count -le 2) {
            return [pscustomobject]@{ Pages=$count; Suitable=$false; Reason='Only one or two pages: possible cover, wrapper or excerpt. Check manually.'; ValidHeader=$true }
        }
        $page = $document.GetPage(0)
        if ($page.Size.Height -le 0 -or ($page.Size.Width / $page.Size.Height) -gt 1.25) {
            return [pscustomobject]@{ Pages=$count; Suitable=$false; Reason='Very wide first page: possible cover spread. Check manually.'; ValidHeader=$true }
        }
        return [pscustomobject]@{ Pages=$count; Suitable=$true; Reason='PDF opens, has more than two pages, and has no wide first-page cover warning.'; ValidHeader=$true }
    } catch {
        return [pscustomobject]@{ Pages=0; Suitable=$false; Reason=('Could not inspect this PDF: ' + $_.Exception.Message); ValidHeader=$true }
    } finally {
        if ($null -ne $page) { $page.Dispose() }
    }
}

function Get-NewestCandidates($Files) {
    $ordered = @($Files | Sort-Object @{ Expression={ $_.LastWriteTimeUtc }; Descending=$true }, @{ Expression={ $_.FullName }; Descending=$false })
    if ($ordered.Count -eq 0) { return @() }
    $newestTime = $ordered[0].LastWriteTimeUtc
    return @($ordered | Where-Object { $_.LastWriteTimeUtc -eq $newestTime })
}

function Copy-CheckedPdf($File, [string]$Destination, [string]$ExpectedHash) {
    # Detect a source changed since selection; confirm the copied bytes as well.
    if ((Get-FileHash -LiteralPath $File.FullName -Algorithm SHA256).Hash -ne $ExpectedHash) {
        throw 'Source changed during collection. Run the script again after the download or edit finishes.'
    }
    if (Test-Path -LiteralPath $Destination) { throw ('Destination already exists: ' + $Destination) }
    Copy-Item -LiteralPath $File.FullName -Destination $Destination -ErrorAction Stop
    if ((Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash -ne $ExpectedHash) {
        Remove-Item -LiteralPath $Destination -ErrorAction SilentlyContinue
        throw 'The copied file failed its SHA256 check. No selected copy was retained.'
    }
}

function Write-SelectionReport($Records, [string]$Folder, [string]$Source, [int]$PdfCount, $ScanErrors) {
    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add('DOUGLAS YOUVAN - LOCAL PDF COLLECTION')
    $lines.Add('Created: ' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
    $lines.Add('Source: ' + $Source)
    $lines.Add('PDF files searched: ' + $PdfCount)
    $lines.Add('')
    $lines.Add('Selected = newest filename match passed the basic PDF / wrapper checks.')
    $lines.Add('Needs-Review = a copy was collected, but edition, completeness or selection is unresolved.')
    $lines.Add('Not-Found / Not-Copied = no PDF was collected for that title.')
    $lines.Add('')
    $lines.Add('Newest means Windows Date modified. It does not prove the newest manuscript revision.')
    $lines.Add('Filename numbers such as (2) are not treated as revision numbers.')
    $lines.Add('A matching filename and page count do not prove the full correct book is present.')
    $lines.Add('Open each collected PDF before uploading. Nothing has been uploaded to Google Drive.')
    $lines.Add('Original files were not moved, renamed, deleted or edited.')
    $lines.Add('')
    foreach ($record in $Records) {
        $lines.Add($record.Title)
        $lines.Add('Status: ' + $record.Status)
        $lines.Add('Audit: ' + $record.Audit)
        foreach ($note in $record.Notes) { $lines.Add('Note: ' + $note) }
        foreach ($choice in $record.Choices) {
            $lines.Add('Source file: ' + $choice.Source)
            $lines.Add('Date modified: ' + $choice.Modified)
            $lines.Add('Pages: ' + $(if ($choice.Pages -gt 0) { [string]$choice.Pages } else { 'Not verified' }))
            if ($choice.Destination) { $lines.Add('Collected copy: ' + $choice.Destination) }
            if ($choice.Hash) { $lines.Add('SHA256: ' + $choice.Hash) }
            $lines.Add('Check: ' + $choice.Check)
        }
        if ($record.Ignored.Count -gt 0) {
            $lines.Add('Excluded because the filename indicates a wrapper, cover or template:')
            foreach ($name in $record.Ignored) { $lines.Add('  ' + $name) }
        }
        $lines.Add('')
    }
    if ($ScanErrors.Count -gt 0) {
        $lines.Add('Some locations could not be read; Not-Found results are incomplete:')
        foreach ($message in $ScanErrors) { $lines.Add('  ' + $message) }
    }
    $path = Join-Path $Folder 'Selection-Report.txt'
    $lines.ToArray() | Set-Content -LiteralPath $path -Encoding UTF8
    return $path
}

function Invoke-BookCollection([string]$Folder, [switch]$SuppressOpen) {
    if (-not $Folder) { $Folder = Get-DownloadsFolder }
    if (-not (Test-Path -LiteralPath $Folder -PathType Container)) { throw ('Cannot find the source folder: ' + $Folder) }
    $Folder = (Get-Item -LiteralPath $Folder).FullName
    Write-Host ('Searching PDFs in: ' + $Folder)
    $scan = Get-SourcePdfs $Folder
    Write-Host ('Found ' + $scan.Files.Count + ' PDF files. Checking the 11 target titles...')
    Initialize-PdfReader
    $outputName = 'Books-for-Google-Drive-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0,6)
    $output = Join-Path $Folder $outputName
    $selectedFolder = Join-Path $output 'Selected'
    $reviewFolder = Join-Path $output 'Needs-Review'
    $null = New-Item -ItemType Directory -Path $output, $selectedFolder, $reviewFolder
    $records = New-Object 'System.Collections.Generic.List[object]'

    foreach ($target in (Get-BookTargets)) {
        Write-Host ('  ' + $target.Stem)
        $matches = @($scan.Files | Where-Object { Test-BookName $_.BaseName $target })
        $wrappers = @($matches | Where-Object { Test-WrapperName $_.BaseName })
        $candidates = @($matches | Where-Object { -not (Test-WrapperName $_.BaseName) })
        $record = [pscustomobject]@{
            Title=$target.Title; Audit=$target.Audit; Status='Not-Found'
            Notes=(New-Object 'System.Collections.Generic.List[string]')
            Choices=(New-Object 'System.Collections.Generic.List[object]')
            Ignored=@($wrappers | ForEach-Object { $_.FullName })
        }
        $records.Add($record)
        if ($candidates.Count -eq 0) {
            $record.Notes.Add('No matching interior filename was found. Files with unrelated or generic names cannot be identified automatically.')
            continue
        }
        $newest = @(Get-NewestCandidates $candidates)
        $record.Notes.Add('Matched ' + $candidates.Count + ' possible interior file(s); selected by Date modified, not by filename numbering.')
        $hashed = New-Object 'System.Collections.Generic.List[object]'
        foreach ($file in $newest) {
            try {
                $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash
                $hashed.Add([pscustomobject]@{ File=$file; Hash=$hash })
            } catch {
                $record.Notes.Add('Could not read newest candidate: ' + $file.FullName + ' -- ' + $_.Exception.Message)
            }
        }
        if ($hashed.Count -ne $newest.Count) {
            $record.Status = 'Not-Copied'
            $record.Notes.Add('A newest candidate was unreadable. No older file was substituted.')
            continue
        }
        $groups = @($hashed | Group-Object -Property Hash)
        $tie = ($groups.Count -gt 1)
        if ($newest.Count -gt $groups.Count) { $record.Notes.Add('Identical newest files were deduplicated by SHA256.') }
        if ($tie) { $record.Notes.Add('Different files share the newest Date modified. All distinct tied files go to Needs-Review; no winner was guessed.') }
        if ($target.Review) { $record.Notes.Add($target.Review) }
        $number = 0
        $copied = 0
        foreach ($group in $groups) {
            $number++
            $item = $group.Group[0]
            $file = $item.File
            $inspection = Get-PdfInspection $file.FullName
            $needsReview = ($tie -or [bool]$target.Review -or -not $inspection.Suitable)
            $choice = [pscustomobject]@{
                Source=$file.FullName; Modified=$file.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss.fffffff zzz')
                Pages=$inspection.Pages; Hash=$item.Hash; Check=$inspection.Reason; Destination=''
            }
            $record.Choices.Add($choice)
            if (-not $inspection.ValidHeader) { continue }
            $name = $target.Stem + $(if ($tie) { '-candidate-' + $number } else { '' }) + '.pdf'
            $destination = Join-Path $(if ($needsReview) { $reviewFolder } else { $selectedFolder }) $name
            try {
                Copy-CheckedPdf $file $destination $item.Hash
                $choice.Destination = $destination
                $copied++
                if ($needsReview) { $record.Status = 'Needs-Review' } elseif ($record.Status -ne 'Needs-Review') { $record.Status = 'Selected' }
            } catch { $record.Notes.Add('Copy failed: ' + $_.Exception.Message) }
        }
        if ($copied -eq 0) { $record.Status = 'Not-Copied' }
        if ($copied -lt $groups.Count -and $copied -gt 0) {
            $record.Status = 'Needs-Review'
            $record.Notes.Add('At least one newest candidate could not be collected. Review the checks above.')
        }
    }
    $report = Write-SelectionReport $records $output $Folder $scan.Files.Count $scan.Errors
    $selectedCount = @($records | Where-Object { $_.Status -eq 'Selected' }).Count
    $reviewCount = @($records | Where-Object { $_.Status -eq 'Needs-Review' }).Count
    $uncollectedCount = @($records | Where-Object { $_.Status -eq 'Not-Found' -or $_.Status -eq 'Not-Copied' }).Count
    Write-Host ''
    Write-Host ('Selected: ' + $selectedCount + ' titles; Needs review: ' + $reviewCount + '; Not collected: ' + $uncollectedCount)
    Write-Host ('New folder: ' + $output)
    Write-Host 'Read Selection-Report.txt and open the collected PDFs before uploading.'
    if (-not $SuppressOpen) {
        try { Start-Process -FilePath 'explorer.exe' -ArgumentList ('"' + $output + '"') } catch { }
        try { Start-Process -FilePath 'notepad.exe' -ArgumentList ('"' + $report + '"') } catch { }
    }
    return [pscustomobject]@{ Output=$output; Report=$report; Records=$records.ToArray() }
}

# Dot-sourcing loads the functions for verification without running a collection.
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $null = Invoke-BookCollection -Folder $SourceFolder -SuppressOpen:$NoOpen
    } catch {
        Write-Host ''
        Write-Host ('Collection stopped: ' + $_.Exception.Message) -ForegroundColor Red
        Write-Host 'Your source files were not changed. Copy this message if you need help.'
    }
    if (-not $NoPause) { $null = Read-Host 'Press Enter to close' }
}
