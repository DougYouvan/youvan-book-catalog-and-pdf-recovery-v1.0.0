$ErrorActionPreference='Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'scripts/Collect-Youvan-PDFs-v2.ps1')
function Assert($Condition,[string]$Message) { if (-not $Condition) { throw $Message } }
$root=Join-Path ([IO.Path]::GetTempPath()) ('youvan-interior-test-'+[Guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory -Path $root
$date=[datetime]::SpecifyKind([datetime]'2026-09-30T12:00:00',[DateTimeKind]::Utc)
function Fixture([string]$Name,[string]$Body,[int]$Age=0) {
    $p=Join-Path $root $Name
    [IO.File]::WriteAllText($p,$Body)
    [IO.File]::SetLastWriteTimeUtc($p,$date.AddDays(-$Age))
    return $p
}
try {
    $latest=Fixture 'Intelligent_Design_and_the_Genetic_Code (1).pdf' '%PDF-1.7 pages=240 latest' 0
    $null=Fixture 'Intelligent_Design_and_the_Genetic_Code (99).pdf' '%PDF-1.7 pages=220 older' 5
    $history=Fixture 'The_History_That_Never_Closes_Interior.pdf' '%PDF-1.7 pages=160 interior' 3
    $null=Fixture 'The_History_That_Never_Closes (2).pdf' '%PDF-1.7 pages=1 unlabelled-cover' 0
    $null=Fixture 'The_History_That_Never_Closes_WRAPPER.pdf' '%PDF-1.7 pages=1 wrapper' 0
    $null=Fixture 'Jezebel_v3_final.pdf' '%PDF-1.7 pages=160 shortened-name'
    $null=Fixture 'Jezebel_and_the_Religion_of_Power.pdf.php' '%PDF-1.7 pages=160 wrong-extension'
    $null=Fixture 'The_Architecture_Before_the_World (1).pdf' '%PDF-1.7 pages=180 edition-a'
    $null=Fixture 'The_Architecture_Before_the_World (2).pdf' '%PDF-1.7 pages=180 edition-b'
    $null=Fixture 'Microbial_Energy_Transduction.pdf' '<html>download failed</html>'
    $microbial=Fixture 'Microbial_Energy_Transduction (3).pdf' '%PDF-1.7 pages=260 older-valid' 4
    $null=Fixture 'Questions_of_a_Christian_Biophysicist.pdf' '%PDF-1.7 pages=57 questions'
    $legos=Fixture 'MathematicsAndLEGOs (1).pdf' '%PDF-1.7 pages=417 identical' 1
    $null=Fixture 'MathematicsAndLEGOs (2).pdf' '%PDF-1.7 pages=417 identical' 1
    $cover=Fixture 'Mathematics_and_LEGOs_Paperback_Cover_v2.pdf' '%PDF-1.7 pages=1 cover' 0
    $alternate=Fixture 'Solus Logos - A Univalent Theology of Divine Identity and Universal Mediation.pdf' '%PDF-1.7 pages=24 alternate' 0
    $null=Fixture 'Solus Logos draft.pdf' '%PDF-1.7 pages=24 unlabelled-short' 0
    $solus=Fixture 'Solus_Logos_Paperback_Interior_with_cover.pdf' '%PDF-1.7 pages=230 intended-book' 4
    $cubes=Fixture 'From_Cubes_to_Worlds_Paperback_Interior_KDP_CLEAN.pdf' '%PDF-1.7 pages=284 new-bytes'
    $gorb=Fixture 'The_American_Gorbachev.pdf' '%PDF-1.7 pages=50 public-copy'
    $null=Fixture 'How_to_Cheat_P_vs_NP.pdf' '%PDF-1.7 pages=195 book'
    $before=@(Get-ChildItem -LiteralPath $root -File | ForEach-Object { [pscustomobject]@{Path=$_.FullName; Hash=(Get-FileHash -LiteralPath $_.FullName).Hash; Modified=$_.LastWriteTimeUtc.Ticks} })
    # Only the Windows API boundary is mocked. Selection, hash, copy and report run for real.
    function Initialize-PdfReader { }
    function Get-PdfInspection([string]$Path) {
        if (-not (Test-PdfHeader $Path)) { return [pscustomobject]@{Pages=0; Suitable=$false; ValidHeader=$false; Reason='No PDF header'} }
        $body=[IO.File]::ReadAllText($Path)
        $pages=[int]([regex]::Match($body,'pages=(\d+)').Groups[1].Value)
        return [pscustomobject]@{Pages=$pages; Suitable=($pages -gt 2); ValidHeader=$true; Reason=$(if($pages -gt 2){'Mock: interior checks passed'}else{'One or two pages'})}
    }
    # Substitute a fixture's public hash only in the test target registry.
    $script:fixtureTargets=@(Get-BookTargets)
    $script:fixtureTargets[9].PublicHash=(Get-FileHash -LiteralPath $gorb).Hash
    function Get-BookTargets { $script:fixtureTargets }
    $run=Invoke-BookCollection -Folder $root -SuppressOpen
    Assert ($run.Records.Count -eq 11) 'Expected exactly 11 target records'
    $r=$run.Records
    Assert (@($r[0].Choices|Where-Object {$_.Destination})[0].Source -eq $latest) 'Date modified must win over (99) numbering'
    Assert (@($r[1].Choices|Where-Object {$_.Destination})[0].Source -eq $history) 'One-page newer file must not block older full interior'
    Assert ($r[1].Choices[0].Destination -eq '' -and $r[1].Choices[0].Pages -eq 1) 'One-page PDF must be logged but not copied'
    Assert ($r[2].Status -eq 'Not-Found' -and $r[2].Clues.Count -eq 1) 'Shortened filename must be surfaced without guessing it is the intended book'
    Assert ($r[3].Status -eq 'Needs-Review' -and @($r[3].Choices|Where-Object {$_.Destination}).Count -eq 2) 'Different eligible equal-time files must both go to review'
    Assert (@($r[4].Choices|Where-Object {$_.Destination})[0].Source -eq $microbial) 'Failed download must not block older eligible interior'
    Assert ($r[5].Status -eq 'Needs-Review') 'Known edition ambiguity must remain flagged'
    Assert (@($r[6].Choices|Where-Object {$_.Destination}).Count -eq 1) 'Identical eligible ties must be deduplicated'
    Assert ($r[6].Ignored -contains $cover) 'Actual reported cover filename must be excluded'
    Assert (@($r[7].Choices|Where-Object {$_.Destination})[0].Source -eq $solus) 'Intended Solus interior must win over newer wrong work and short PDF'
    Assert ($r[7].Ignored -contains $alternate) 'Actual alternate Solus filename must be excluded'
    Assert (@($r[7].Choices|Where-Object {$_.Pages -eq 24 -and $_.Destination}).Count -eq 0) 'Short Solus file must never be copied'
    Assert ($r[9].Notes -match 'byte-for-byte identical') 'Public-identical hash annotation missing'
    Assert ($r[8].Notes -match 'differs from the public') 'Public-different hash annotation missing'
    Assert (-not (Test-WrapperName 'Solus Logos Interior with cover.pdf')) 'Explicit with-cover interior must remain eligible'
    Assert (Test-WrapperName 'Solus Logos Paperback Cover.pdf') 'Cover token must be rejected'
    foreach($b in $before) {
        Assert ((Get-FileHash -LiteralPath $b.Path).Hash -eq $b.Hash) 'Original bytes changed'
        Assert ((Get-Item -LiteralPath $b.Path).LastWriteTimeUtc.Ticks -eq $b.Modified) 'Original modified time changed'
    }
    $after=Get-SourcePdfs $root
    Assert ($after.Files.Count -eq @($before | Where-Object { [IO.Path]::GetExtension($_.Path) -eq '.pdf' }).Count) 'Previous output folder not excluded'
    $report=Get-Content -LiteralPath $run.Report -Raw
    Assert ($report -match 'Jezebel_v3_final.pdf') 'Filename clues must survive into report'
    Assert ($report -match 'Rejected: 24 pages') 'Solus short-file rejection reason missing from report'
    'PASS: observed cover/subtitle failures fixed; newest eligible interior, ties, deduplication, filename clues, public hash comparisons and unchanged originals verified.'
} finally { Remove-Item -LiteralPath $root -Recurse -Force }
