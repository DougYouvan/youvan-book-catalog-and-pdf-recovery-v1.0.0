$ErrorActionPreference='Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'scripts/Collect-Youvan-PDFs-v2.ps1')
$root=Join-Path ([IO.Path]::GetTempPath()) ('youvan-independent-tests-'+[Guid]::NewGuid().ToString('N'))
$null=New-Item -ItemType Directory -Path $root -Force
$results=New-Object 'System.Collections.Generic.List[object]'
$script:PageMap=@{}
function Check($Name,$Pass,$Detail=''){$results.Add([pscustomobject]@{Test=$Name;Pass=[bool]$Pass;Detail=$Detail});if(-not$Pass){Write-Host ('FAIL '+$Name+' '+$Detail)}}
function Fixture($Name,$Pages,$Date,$Body='fixture'){
 $p=Join-Path $root $Name
 [IO.File]::WriteAllText($p,('%PDF-1.4 '+$Body))
 [IO.File]::SetLastWriteTimeUtc($p,[DateTime]$Date)
 $script:PageMap[$p]=$Pages
 Get-Item -LiteralPath $p
}
$targets=@(Get-BookTargets)
$solus=@($targets|Where-Object{$_.Stem-eq'Solus-Logos'})[0]
$lego=@($targets|Where-Object{$_.Stem-eq'Mathematics-and-LEGOs'})[0]
$jez=@($targets|Where-Object{$_.Stem-eq'Jezebel-and-the-Religion-of-Power'})[0]
Check 'Observed LEGO cover filename excluded' (Test-WrapperName 'Mathematics_and_LEGOs_Paperback_Cover_v2')
Check 'With cover interior allowed' (-not(Test-WrapperName 'Mathematics_and_LEGOs_With_Cover'))
Check 'Including cover interior allowed' (-not(Test-WrapperName 'Mathematics-and-LEGOs-Including-Cover'))
Check 'Hardcover is not standalone cover token' (-not(Test-WrapperName 'Mathematics-and-LEGOs-Hardcover-Interior'))
Check 'Known alternate Solus work rejected' ([bool](Get-WrongWorkReason 'Solus Logos - A Univalent Theology of Divine Identity and Universal Mediation' $solus))
Check 'Correct Solus subtitle allowed' (-not[bool](Get-WrongWorkReason 'Solus Logos - The Living Word Beyond Sola Scriptura' $solus))
Check 'Solus conservative floor 100 pages' ($solus.MinimumPages-eq100)
Check 'Compatibility Unicode letters normalize' (Test-BookName 'Ｊｅｚｅｂｅｌ_and_the_Religion_of_Power' $jez)
$legoGood=Fixture 'Mathematics_and_LEGOs_Paperback_Interior.pdf' 200 '2026-01-01T12:00:00Z' 'LEGO interior'
$legoCover=Fixture 'Mathematics_and_LEGOs_Paperback_Cover_v2.pdf' 1 '2026-04-01T12:00:00Z' 'LEGO cover'
$legoShort=Fixture 'Mathematics_and_LEGOs_latest.pdf' 1 '2026-03-01T12:00:00Z' 'LEGO unlabeled cover'
$solusShort=Fixture 'Solus_Logos_latest.pdf' 24 '2026-04-01T12:00:00Z' 'short Solus'
$solusWrong=Fixture 'Solus Logos - A Univalent Theology of Divine Identity and Universal Mediation.pdf' 24 '2026-05-01T12:00:00Z' 'wrong Solus'
$solusGoodPath=Join-Path $root 'Solus Logos - The Living Word Beyond Sola Scriptura.pdf'
$solusGood=Fixture 'Solus Logos - The Living Word Beyond Sola Scriptura.pdf' 230 '2026-02-01T12:00:00Z' 'Solus interior synthetic fixture'
$goodHash=(Get-FileHash -LiteralPath $solusGoodPath).Hash
$baseline=Get-Content -LiteralPath (Join-Path (Split-Path -Parent $PSScriptRoot) 'evidence/audited-book-pdf-baselines.json') -Raw|ConvertFrom-Json
$recordedHash=@($baseline|Where-Object{$_.source_listing-eq14})[0].sha256
Check 'Recorded audited Solus hash retained' ($recordedHash-eq$solus.PublicHash)
# The original recorded test used the real downloaded public PDF. This portable
# copy uses a synthetic file and substitutes only its fixture public hash.
$solus.PublicHash=$goodHash
$script:FixtureTargets=$targets
function Get-BookTargets { $script:FixtureTargets }
$idGood=Fixture 'Intelligent_Design_and_the_Genetic_Code_With_Cover.pdf' 180 '2026-02-01T12:00:00Z' 'ID interior'
$idNewCover=Fixture 'Intelligent_Design_and_the_Genetic_Code_Cover.pdf' 1 '2026-06-01T12:00:00Z' 'ID cover'
$jA=Fixture 'Jezebel_and_the_Religion_of_Power_a.pdf' 100 '2026-07-01T12:00:00Z' 'Jezebel A'
$jDupe=Fixture 'Jezebel_and_the_Religion_of_Power_copy.pdf' 100 '2026-07-01T12:00:00Z' 'Jezebel A'
$jB=Fixture 'Jezebel_and_the_Religion_of_Power_b.pdf' 100 '2026-07-01T12:00:00Z' 'Jezebel B'
$clue=Fixture 'A_Christian_Biophysicist_Question_Collection.pdf' 57 '2026-05-01T12:00:00Z' 'unmatched clue'
$allSources=@(Get-SourcePdfs $root).Files
$before=@{}
foreach($f in $allSources){$before[$f.FullName]=@((Get-FileHash -LiteralPath $f.FullName).Hash,$f.LastWriteTimeUtc)}
function Initialize-PdfReader{$script:PdfReaderAvailable=$true;$script:PdfReaderProblem=''}
function Get-PdfInspection([string]$Path){
 $p=[int]$script:PageMap[$Path]
 [pscustomobject]@{Pages=$p;Suitable=($p-gt2);Reason=$(if($p-le2){'one-page fixture'}else{'portrait fixture'});ValidHeader=$true}
}
$out=Invoke-BookCollection -Folder $root -SuppressOpen
$lr=@($out.Records|Where-Object{$_.Title-eq$lego.Title})[0]
$sr=@($out.Records|Where-Object{$_.Title-eq$solus.Title})[0]
$ir=@($out.Records|Where-Object{$_.Title-like'Intelligent Design and the Genetic Code:*'})[0]
$jr=@($out.Records|Where-Object{$_.Title-eq$jez.Title})[0]
$qr=@($out.Records|Where-Object{$_.Title-eq'Questions of a Christian Biophysicist'})[0]
Check 'LEGO chooses older eligible interior' (@($lr.Choices|Where-Object{$_.Destination}).Count-eq1-and(@($lr.Choices|Where-Object{$_.Destination})[0].Source-eq$legoGood.FullName))
Check 'LEGO observed named cover not copied' (-not(@($lr.Choices|Where-Object{$_.Source-eq$legoCover.FullName-and$_.Destination}).Count))
Check 'LEGO unlabeled 1-page candidate rejected without copy' (@($lr.Choices|Where-Object{$_.Source-eq$legoShort.FullName-and-not$_.Destination-and$_.Check-like'Rejected:*'}).Count-eq1)
Check 'Solus chooses correct 230-page interior' (@($sr.Choices|Where-Object{$_.Destination}).Count-eq1-and(@($sr.Choices|Where-Object{$_.Destination})[0].Source-eq$solusGoodPath))
Check '24-page generic Solus rejected with recorded reason' (@($sr.Choices|Where-Object{$_.Source-eq$solusShort.FullName-and-not$_.Destination-and$_.Check-like'*100-page*'}).Count-eq1)
Check 'Known alternate Solus recorded as ignored' ($sr.Ignored-contains$solusWrong.FullName)
Check 'Public identical-byte Solus annotation present' (@($sr.Notes|Where-Object{$_-like'*byte-for-byte identical*'}).Count-eq1)
Check 'Full interior with-cover copied despite newer cover' ($ir.Status-eq'Selected'-and(@($ir.Choices|Where-Object{$_.Destination})[0].Source-eq$idGood.FullName))
Check 'Different eligible timestamp ties copied only to review' ($jr.Status-eq'Needs-Review'-and(@($jr.Choices|Where-Object{$_.Destination}).Count-eq2)-and-not(@($jr.Choices|Where-Object{$_.Destination-and$_.Destination-notmatch'[\\/]Needs-Review[\\/]'}).Count))
Check 'Same hash eligible ties deduped' (@($jr.Notes|Where-Object{$_-like'*deduplicated by SHA256*'}).Count-eq1)
Check 'Unmatched Questions remains not found' ($qr.Status-eq'Not-Found')
Check 'Unmatched Questions filename clues recorded' ($qr.Clues.Count-eq1-and$qr.Clues[0].FullName-eq$clue.FullName)
$unchanged=$true
foreach($f in $allSources){if(((Get-FileHash -LiteralPath $f.FullName).Hash-ne$before[$f.FullName][0])-or((Get-Item -LiteralPath $f.FullName).LastWriteTimeUtc-ne$before[$f.FullName][1])){$unchanged=$false}}
Check 'All source hashes and modified timestamps preserved' $unchanged
$report=Get-Content -LiteralPath $out.Report -Raw
Check 'Report logs known alternate and page-floor rejection' ($report.Contains($solusWrong.FullName)-and$report.Contains('24 pages is below the conservative 100-page screen'))
$results.ToArray()|ConvertTo-Json -Depth 4|Set-Content -LiteralPath (Join-Path $root 'test-results.json') -Encoding UTF8
Write-Host ('Passed '+(@($results|Where-Object{$_.Pass}).Count)+' / '+$results.Count)

$failed=@($results|Where-Object{-not $_.Pass}).Count
Remove-Item -LiteralPath $root -Recurse -Force
if($failed){throw ([string]$failed+' independent tests failed')}
