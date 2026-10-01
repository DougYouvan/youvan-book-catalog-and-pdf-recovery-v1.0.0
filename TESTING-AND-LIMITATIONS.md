# Testing and Limitations

This deposit preserves the testing evidence and limitations of the local PDF collection scripts. It does not certify that a collected file is the final Amazon edition of a book.

## Version Status

| Version | Status | Meaning |
| --- | --- | --- |
| v1 | Known flawed; archived for the record | The user's Windows run exposed incorrect cover and title selection. Do not use it for a new collection. |
| v2 | Corrected experimental version | It addresses the observed failures and passes fixture tests, but has not been run by the user on Windows. |

## Recorded Test Evidence

The automated checks ran with PowerShell 7.4.6 on Linux. Windows PDF inspection was mocked at the WinRT boundary for integrated collection tests. These results verify the tested selection and copying logic; they do not constitute an end-to-end Windows PowerShell 5.1 or Windows PDF-reader test.

| Test set | Recorded result |
| --- | --- |
| Independent v1 helper checks | 20 of 20 passed |
| Independent v2 helper and integrated checks | 23 of 23 passed |
| Root integrated fixture checks | Passed for v1 and v2; separate from the independent counts above |

The checks covered filename normalization, matching and exclusions, exact `.pdf` extension filtering, modified-time selection, identical-file deduplication, different-content timestamp ties, exclusion of previous collection folders, copy verification, destination collision protection, and preservation of source bytes and modification timestamps.

The v2 regression checks specifically covered:

- Excluding `Mathematics_and_LEGOs_Paperback_Cover_v2.pdf`.
- Rejecting an unlabeled one-page candidate without copying it.
- Excluding the different work named `Solus Logos - A Univalent Theology of Divine Identity and Universal Mediation.pdf`.
- Rejecting another 24-page Solus candidate under the conservative 100-page screen.
- Selecting an older eligible 230-page Solus interior after rejecting newer unsuitable candidates.
- Allowing an interior explicitly named “with cover” or “including cover”.
- Copying distinct, equally recent eligible files only to `Needs-Review`, while deduplicating identical bytes.
- Detecting that a collected Solus file was byte-for-byte identical to the audited public PDF using its actual SHA256.
- Reporting filename clues without automatically copying those clues.

## Evidence from the User's Windows Run

The user ran v1 on Windows. Its Windows PDF reader returned page counts including 1, 24, 284, 50, and 195. This is evidence that the reader executed in that environment, rather than only in a mocked test.

That run also exposed two real selection errors:

1. A one-page LEGO cover was collected instead of an interior.
2. A 24-page, differently subtitled Solus Logos work was collected for the target *Solus Logos: The Living Word Beyond Sola Scriptura*.

The successful reader calls did not validate v1's selection policy. V1 allowed a plain `cover` token, matched the broad Solus title without distinguishing the alternate work, and selected by modified time before applying sufficient interior eligibility checks. Suspicious files could still be copied to `Needs-Review`.

V2 has not been user-run on Windows at the time of this deposit. Its actual WinRT initialization, asynchronous calls, and PDF inspection therefore remain unverified in a v2 Windows run.

## V2 Selection Policy

V2 excludes named covers, wrappers, and the known alternate Solus work. It rejects files with one or two pages, unsuitable first-page geometry, or failed inspection. It checks matching candidates before selecting the newest eligible interior, and records rejected candidates so that an older selection is visible.

For Solus Logos, it applies a conservative minimum of 100 pages because the audited public book has 230 pages. This is a heuristic screen, not a content or edition test. A legitimate shorter edition could be rejected and would require manual identification.

The six titles with known public-edition or content questions remain in `Needs-Review` even after basic interior checks pass. Distinct eligible files sharing the newest modification timestamp also remain there; the script does not guess a winner. Identical newest files are deduplicated by SHA256.

The scripts copy into new local folders. They do not move, rename, or edit source files. The copying helper checks source and destination SHA256 values and refuses an existing destination. Source bytes and modification timestamps were unchanged in the recorded tests.

## Remaining Limitations

- “Newest” means Windows **Date modified**, not the newest manuscript revision. Downloading, restoring, or exporting a file can change its timestamp. A filename suffix such as `(2)` is not treated as a revision number.
- Matching uses filenames and explicit aliases. The script does not extract PDF text or compare title pages, chapter content, or tables of contents with the Amazon edition.
- Page count and first-page geometry cannot establish that a PDF contains the complete, correct book. A differently named file can be missed, and a similarly named paper can still require review.
- The Solus page threshold and other structural screens can reject a legitimate file. Rejected candidates are listed for manual inspection.
- A matching public SHA256 establishes identical bytes. Different bytes may reflect content, formatting, or metadata; they do not by themselves establish a corrected edition.
- Windows reader failures, unreadable files, and scan errors can leave a title uncollected. A `Not-Found` result is not proof that the book exists nowhere on the computer.
- The report's filename clues are filtered suggestions for uncollected titles, not a complete inventory of Downloads. They are not automatically selected.
- No script uploads to Google Drive or replaces a public PDF. Opening and reviewing the collected files is still required before any separate upload.

## Rerunning the Portable Tests

From the repository root, run:

```powershell
pwsh -NoProfile -File ./tests/Collect-Youvan-PDFs-v2.Tests.ps1
pwsh -NoProfile -File ./tests/Independent-v2.Tests.ps1
```

The portable fixture tests mock the Windows PDF-reader boundary. Passing them does not replace a real Windows PowerShell 5.1 run with actual PDFs. The reported 23 independent v2 checks refer to the original recorded test run. The portable copy also passed 23 checks; it substitutes a synthetic Solus file for the downloaded public PDF and checks the embedded public hash against the recorded baseline. It uses temporary fixture directories and repository-relative paths.

## Credit

Prepared in collaboration with Douglas C. Youvan and GPT-6.1 Sol Ultra.
