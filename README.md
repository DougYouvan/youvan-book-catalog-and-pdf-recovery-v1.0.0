# Youvan Book Catalog and PDF Recovery — v1.0.0

Useful results from Douglas C. Youvan's September 30, 2026 working session: collecting Amazon book titles and product links, updating the book box at [youvan.ai](https://youvan.ai/), checking the public PDF archive, and recovering book interiors from Windows Downloads.

**Assistant: GPT-6.1 Sol Ultra.** Prepared in collaboration with Douglas C. Youvan.

This is a dated working example and an AI handoff. The homepage update was completed and Douglas reported that it worked. PDF recovery was paused at his request. The corrected collector is included for future work; it has not been run by Douglas on Windows.

## Start Here

| Purpose | File |
| --- | --- |
| Give this project to another AI | [AI-HANDOFF.md](AI-HANDOFF.md) |
| Full title on one line, preferred Amazon URL on the next | [catalog/paperback-preferred-50.txt](catalog/paperback-preferred-50.txt) |
| Machine-readable preferred catalog | [catalog/paperback-preferred-50.json](catalog/paperback-preferred-50.json) |
| All 51 captured listings and their editions | [catalog/all-listings-and-editions.txt](catalog/all-listings-and-editions.txt) |
| Completed homepage PHP | [website/index.php](website/index.php) |
| Full public-PDF audit | [evidence/Google-Drive-Book-Audit-2026-09-30.txt](evidence/Google-Drive-Book-Audit-2026-09-30.txt) |
| What the local collection actually recovered | [docs/DRIVE-RECOVERY-FINDINGS.md](docs/DRIVE-RECOVERY-FINDINGS.md) |
| Corrected experimental collector | [scripts/Collect-Youvan-PDFs-v2.ps1](scripts/Collect-Youvan-PDFs-v2.ps1) |
| Test results and limits | [docs/TESTING-AND-LIMITATIONS.md](docs/TESTING-AND-LIMITATIONS.md) |
| Adapt the workflow for another author | [docs/WORKFLOW-AND-ADAPTATION.md](docs/WORKFLOW-AND-ADAPTATION.md) |

## Snapshot Results

- The supplied Amazon HTML contained **51 listings, 50 distinct title strings, and 67 linked product editions**.
- The preferred catalog selects **36 paperback links and 14 Kindle links** from that capture.
- *The Universe Beyond Its Equations* appeared twice. The preferred catalog and homepage use **B0HKFD94CD**, while preserving the old **B0HKC85YHS** listing in the raw listing data. The old listing was marked out of print.
- The public Drive folder contained **6,135 PDFs**. Matching PDFs were found for **45 of the 50 distinct captured titles**. Five titles were not found; six existing versions needed edition or content review.
- The first collector searched **790 local PDFs** and copied matches for five titles. Two of those selections were unsuitable, two matched existing public PDFs exactly, and one had different bytes worth inspecting.

These counts describe the supplied snapshots. Amazon can rotate listings and availability, and this capture is not a complete historical bibliography or a promise of current stock.

## Local Collection Findings

| Title | Finding |
| --- | --- |
| Mathematics and LEGOs | The selected file was a one-page paperback cover. It is not the interior. |
| Solus Logos | The selected 24-page file has the subtitle *A Univalent Theology of Divine Identity and Universal Mediation*. It is a different work from the target book. |
| From Cubes to Worlds | The selected 284-page KDP CLEAN file has a different SHA256 from the audited public PDF. Content still needs comparison. |
| The American Gorbachev | The selected 50-page PDF is byte-for-byte identical to the audited public PDF. |
| How to Cheat P vs NP | The selected 195-page PDF is byte-for-byte identical to the audited public PDF. |

The five missing public titles were not recovered by the first local filename search. *Questions of a Christian Biophysicist*, already present publicly, was also not found under its expected local filename. `Not-Found` describes this search, not the entire computer.

## Running the Corrected Collector Later

The intended environment is Windows 10 or 11, **Windows PowerShell 5.1**, and the built-in Windows PDF reader. No Python, Adobe installation, or Chrome developer tools are required for collection.

Extract or download the repository, open Windows PowerShell, paste this block, and choose **Collect-Youvan-PDFs-v2.ps1**:

```powershell
Add-Type -AssemblyName System.Windows.Forms
$picker = New-Object System.Windows.Forms.OpenFileDialog
$picker.Filter = 'PowerShell scripts (*.ps1)|*.ps1'
$picker.Title = 'Select Collect-Youvan-PDFs-v2.ps1'
if ($picker.ShowDialog() -eq 'OK') {
    powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -File $picker.FileName
}
```

It searches the actual Downloads folder, creates a fresh `Books-for-Google-Drive-...` folder, and copies eligible matches with clear names. It excludes covers, one- or two-page files, and the known alternate Solus work before choosing the newest eligible interior. The report includes rejected candidates, comparisons with recorded public hashes, and other filename clues for unresolved titles.

Original files are preserved. Known edition questions and differing-content timestamp ties stay in `Needs-Review`. “Newest” means **Date modified**, not a verified manuscript revision. Read the report and inspect PDFs before any separate Drive upload. The collector does not upload anything.

For a different source folder, pass `-SourceFolder 'D:\YourFolder'` when invoking the collector. An Explorer search-results view is a virtual view; supply the underlying folder path.

**Do not run the archived v1 collector for a new recovery.** Its Windows run exposed the cover and wrong-work selections above. V2 fixes those observed cases and passed fixture tests, but still needs a real Windows run and content review.

## Website Files

`website/index.php` is the completed full PHP homepage. `website/index-before.php` preserves Douglas's original supplied source. The update expanded the book box from 22 entries to 50, kept the existing entries' relative order and links, and displayed full clickable titles under “Books by Douglas Youvan”. Douglas installed it and reported success.

The PHP page uses its original server layout, including `../PDF/Youvan Papers Public`. Adapt that path when using the page on another server. This repository is not a standalone copy of the 6,135-file PDF archive.

## Evidence and Reproducibility

`evidence/drive-pdf-inventory-2026-09-30.json` preserves public file metadata. `evidence/audited-book-pdf-baselines.json` records the 45 inspected book PDFs, public URLs, page counts where recorded, and SHA256 values. `evidence/local-collection-v1.json` preserves facts transcribed from the report Douglas pasted, including his Windows paths.

`sources/amazon-author-product-grid-2026-09-30.html` contains the product-grid DOM extracted from the complete supplied saved page. It keeps all 51 cards and their linked editions; it is a data source, not a complete offline Amazon website. The screenshots preserve the original homepage box and Downloads search view.

Tests run from the repository root with PowerShell 7:

```powershell
pwsh -NoProfile -File ./tests/Collect-Youvan-PDFs-v2.Tests.ps1
pwsh -NoProfile -File ./tests/Independent-v2.Tests.ps1
```

These tests mock the Windows PDF-reader boundary. The portable independent test uses a synthetic Solus fixture; the originally recorded independent run used the real audited PDF. Details are in the testing document.

Douglas explicitly requested preservation of his Amazon identifiers and PC file paths. They remain in this deposit. Full book PDFs are referenced through their public URLs rather than bundled here.
