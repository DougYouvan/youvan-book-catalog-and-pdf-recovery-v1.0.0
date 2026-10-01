# AI Handoff

Assistant: **GPT-6.1 Sol Ultra**. Project owner: Douglas C. Youvan. Snapshot date: September 30, 2026, America/Chicago. Deposit version: v1.0.0.

Douglas requested a stop to active recovery and a GitHub deposit of useful results. Preserve that pause. This handoff is for a later authorized continuation or adaptation by another reader; it is not an instruction to upload or replace public files now.

## Read First

1. `README.md`
2. `docs/DRIVE-RECOVERY-FINDINGS.md`
3. `docs/TESTING-AND-LIMITATIONS.md`
4. `evidence/Google-Drive-Book-Audit-2026-09-30.txt`
5. `evidence/local-collection-v1.json`

Use `catalog/paperback-preferred-50.json` for the working 50-title catalog. Use `catalog/amazon-listings-51.json` when edition links and the duplicate listing matter. Full titles and URLs are preserved; do not replace them with guessed titles or ASINs.

## User Requirements

- Douglas will run PowerShell on Windows but will not use Chrome developer tools.
- All 51 listings were visible on one author-page view. There was no “see more” control to use.
- Prefer the paperback when the captured page supplies both paperback and ebook links.
- Print the full title on one line and its URL on the next when producing a plain list.
- The homepage book box uses clickable titles linking directly to Amazon product pages.
- Full PDFs are free in his public Drive folder. Distinguish an inventory match from the correct, latest, complete book interior.
- Local problems include varied filenames, duplicated downloads, mistaken wrappers, and uncertain revisions.
- Do not infer version order from `(1)`, `(2)`, or similar browser-download suffixes.
- Earlier attempts failed because of a missing assumed `.ps1` filename and a PowerShell `HtmlDecode` argument-parsing error. Provide complete runnable files and a file-picker launcher.
- Keep Amazon details and Windows paths; Douglas explicitly requested no redaction of them.
- Credit the assistant as **GPT-6.1 Sol Ultra**.

## Established Outcomes

The author-page capture, not a live completeness claim, contained 51 listings and 50 distinct titles. The old and new *Universe Beyond Its Equations* ASINs both remain in the listing evidence; the working choice is B0HKFD94CD.

The full homepage source was supplied, updated, installed by Douglas, and reported working. Preserve the finished `website/index.php`; the source before the change is kept for comparison.

The Drive inventory covered 6,135 PDFs. Forty-five captured titles had a matching public PDF. Five were not found. Six of the public versions needed review. The exact titles, URLs and findings are in the audit; do not equate the user's historical publication tally with this captured 50-title set.

The original local collector completed on Windows and the PDF reader returned actual page counts. Its report nevertheless showed two bad selections: a one-page LEGO cover and a different 24-page Solus work. A successful run or a `Needs-Review` copy is not evidence of the right book.

Two local copies match the public SHA256 exactly: *The American Gorbachev* and *How to Cheat P vs NP*. They are unchanged public files, not newly recovered editions. The local *From Cubes to Worlds* copy differs in bytes; both local and public copies have 284 pages. The public copy ended with an editorial draft note. Inspect the local copy before calling it a correction.

## Corrected Collector

`scripts/Collect-Youvan-PDFs-v2.ps1` checks all matching candidates before choosing the newest eligible interior. It excludes cover filenames, one- or two-page files, the known alternate Solus subtitle, unsuitable geometry and failed PDF inspections. It logs the rejected candidates so that choosing an older eligible file is visible.

The Solus 100-page minimum is a conservative heuristic based on the audited 230-page book. It does not prove identity, and a legitimate shorter edition would require manual identification. V2 has not been run by Douglas on Windows. Its selection/copy logic passed tests on PowerShell 7.4.6 on Linux with the Windows reader mocked. Do not describe it as end-to-end Windows validated.

## If Recovery Is Resumed

First inspect the local `From_Cubes_to_Worlds_Paperback_Interior_KDP_CLEAN.pdf`, or the collected `From-Cubes-to-Worlds.pdf`, against the public version. Check the final editorial note and whether its content actually changed.

Then obtain the new collector report or local filename clues for unresolved titles. Add evidence-backed aliases rather than broad thematic guesses. Generic PDF filenames will require title-page inspection or manual selection. A Downloads search-results window is not a filesystem directory.

For the intended Solus book, find the full *The Living Word Beyond Sola Scriptura* interior and check Chapter 15, “The Exvangelical Conscience”. The 24-page *Univalent Theology* PDF must not substitute for it.

For any proposed public replacement, inspect title page, subtitle, chapter structure, ending, and edition. A new timestamp, different hash or equal page count alone is insufficient. No Drive files were uploaded or replaced during this recovery work.

## Adapting the Example

Replace the Amazon source and catalog, update `Get-BookTargets` aliases/review notes/public hashes, and choose appropriate structural screens for the other author's actual books. Reuse the file picker, copy protection, timestamp-tie handling and report pattern. Run tests and verify the Windows reader with real PDFs. Keep uncertainty explicit.
