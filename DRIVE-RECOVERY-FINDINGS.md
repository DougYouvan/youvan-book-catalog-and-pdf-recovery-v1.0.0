# Drive Recovery Findings

The September 30, 2026 audit compared **50 distinct Amazon titles** with **6,135 PDFs** in [Youvan Papers Public](https://drive.google.com/drive/folders/15Kd8bUjm7zVaKdVIwbPhqjjV68aUZQvc). Matching-title PDFs were found for **45 titles**; **five titles were not found**. Six existing PDFs require edition or completeness review.

These are inventory findings. A matching title, substantial page count, or valid PDF does not establish identity with the latest Amazon edition. The comparison covers the supplied author-page capture, not every work the author has published.

Recovery is **paused at the user's request**. The findings below do not authorize a public Drive upload or replacement.

## Five Titles Not Found in the Public Folder

| Full title | Observed Amazon product URL |
|---|---|
| Intelligent Design and the Genetic Code: Mathematics, Bootstrapping, and the Architecture of Biological Meaning | [Amazon](https://www.amazon.com/dp/B0HFBZ3BSJ) |
| The History That Never Closes: Nuclear Ambiguity, False Flags, Narrative Capture, and the Permanent Crisis of Attribution | [Amazon](https://www.amazon.com/History-That-Never-Closes-Attribution-ebook/dp/B0HFXKJLM4) |
| Jezebel and the Religion of Power | [Amazon](https://www.amazon.com/Jezebel-Religion-Power-Douglas-Youvan-ebook/dp/B0HFVRW1ZG) |
| The Architecture Before the World: What the World Wide Web Teaches Us About Mathematics, AI, and Things That Do Not Exist Yet | [Amazon](https://www.amazon.com/Architecture-Before-World-Teaches-Mathematics-ebook/dp/B0HFTRMP5F) |
| Microbial Energy Transduction: Genetics, Structure, and Function of Membrane Proteins (CURRENT COMMUNICATIONS IN CELL AND MOLECULAR BIOLOGY) | [Amazon](https://www.amazon.com/Microbial-Energy-Transduction-Structure-COMMUNICATIONS/dp/0879691948) |

“Not found” means no matching PDF was identified in the audited public folder. It does not establish that the file is absent from the user's computer or other storage.

## Six Existing PDFs Requiring Review

| Title | Public PDF pages | Finding |
|---|---:|---|
| Questions of a Christian Biophysicist | 57 | Complete 820-question collection covering 2010-2013, with a 2023 preface; exact Kindle edition unverified. |
| Mathematics and LEGOs | 417 | Substantial complete book. PDF subtitle ends “and Mathematical Worlds”; Amazon adds “Self-Constructing.” |
| Solus Logos: The Living Word Beyond Sola Scriptura | 230 | Contents list Chapter 15, “The Exvangelical Conscience,” but no corresponding body heading or 15.x sections were found. Chapter 14 ends on printed page 171; Chapter 16 starts on printed page 172. This could be an omission or stale contents. |
| From Cubes to Worlds | 284 | Substantial book with 22 chapters; the final two pages retain an editorial draft note. |
| The American Gorbachev | 50 | Matching title and 21 numbered sections. It calls itself a paper and could be the published short book; exact Amazon edition unverified. |
| How to Cheat P vs NP | 195 | Substantial book. Public PDF subtitle uses “the Search for a Way Around Computational Hardness”; Amazon uses “Twenty Attempts to Outsmart Computation.” |

## Five Collected Local Outcomes

| Collected candidate | Pages | Result |
|---|---:|---|
| Mathematics and LEGOs | 1 | Cover only; does not supply the book interior. |
| Solus Logos | 24 | Different work; does not replace *The Living Word Beyond Sola Scriptura*. |
| The American Gorbachev | 50 | Reported local SHA256 exactly matches the downloaded public PDF. Same bytes; no new edition was recovered. |
| How to Cheat P vs NP | 195 | Reported local SHA256 exactly matches the downloaded public PDF. Same bytes; the subtitle question remains. |
| From Cubes to Worlds | 284 | Reported local SHA256 differs from the public PDF. This is a candidate for comparison, not proof of a content update or finished edition. |

The matching hashes were computed from the downloaded public files and compared with the hashes in the user's collection report.

| File | SHA256 |
|---|---|
| Gorbachev, public and reported local | `47C160DD726F7EF779525D2D01DB7319DF8EF8877648C35B96814BD90D206A57` |
| Cheat, public and reported local | `5530108E1D06A4574070698F961B9331E0F6E9B7AB9B93105BE66AE66E054E6C` |
| Cubes, public | `0932DDE8565A2366F113B928E83FA2090C952643FEB63E878D30200A86D11ECE` |
| Cubes, reported local | `715A0BE04B672DE4FD00C2219A4B7FD2455961EA4FD9298BFB09502597F76415` |

## Next Steps When Recovery Resumes

1. Obtain the correct filenames or aliases for the full interiors and the remaining unmatched local titles. Generic filenames and similarly named papers need content inspection; selecting the newest filename alone is insufficient.
2. Inspect the differing 284-page *Cubes* candidate, including its title, chapter structure, and final pages. Compare the public PDF's editorial note before deciding whether a replacement is appropriate.
3. Compare the latest *Solus Logos: The Living Word Beyond Sola Scriptura* manuscript with the public PDF, specifically Chapter 15 and the contents. Resolve whether the body is incomplete or the contents are stale.
4. Reconcile the remaining edition questions before preparing any public-folder update.

Prepared in collaboration with **GPT-6.1 Sol Ultra**.
