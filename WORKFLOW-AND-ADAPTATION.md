# Workflow and Adaptation

Prepared by GPT-6.1 Sol Ultra with Douglas C. Youvan.

## Amazon Capture and Edition Selection

Source author page: https://www.amazon.com/stores/Douglas-Youvan/author/B00JH810OQ/allbooks

The useful source was the complete HTML capture supplied by Douglas. It contained 51 `data-testid="product-grid-item"` cards, 50 distinct title strings, and 67 product-edition links. The product-grid extract is retained in `sources/`; the extracted records are in `catalog/amazon-listings-51.json`.

An HTML file opened in Chrome looks like the original rendered page. That does not mean it is an image. An AI or parser can read its text and markup without asking the user to open developer tools. A screenshot alone does not preserve all product URLs.

The small `Capture-Amazon-Page.ps1` helper reads HTML from the Windows clipboard after copying the page. A clipboard capture can be incomplete even when the visible page has more cards. Check the actual captured card count before trusting it. This session's earlier capture had only 32 title matches; it was superseded by the full saved page.

The archived `Amazon-Books.ps1` extractor collects product URLs by ASIN. It can count multiple editions of one book, so its hard-coded warning about 51 is not a reliable distinct-book check. It is retained as an implementation example, not the authoritative final catalog.

For a future capture, preserve the supplied snapshot, extract complete titles from card `title` or `aria-label` attributes, associate the primary binding and alternative-format links with the same card, and remove only tracking query parameters from product URLs. Deduplicate titles separately from editions. Review duplicate titles and availability notices before choosing a preferred edition.

For this capture, paperback preference gave 36 paperback links and 14 Kindle links. The old out-of-print duplicate of *The Universe Beyond Its Equations* was excluded from the preferred set, while both listings remain in the evidence. Listings and availability can change; do not treat this snapshot as current stock information.

## Homepage Update

The source was the actual full PHP file, not a screenshot reconstruction. The finished page has 50 full clickable titles and direct Amazon product links. The original 22 entries' relative order and links were preserved. The heading became “Books by Douglas Youvan”. Douglas installed the file and reported success.

The PHP also lists local papers using `dirname(__DIR__) . '/PDF/Youvan Papers Public'`. Another host must adapt that server path. Changing a book catalog should not accidentally change the paper-listing behavior.

## Public PDF Audit

Public folder: https://drive.google.com/drive/folders/15Kd8bUjm7zVaKdVIwbPhqjjV68aUZQvc

Inventory covered all 6,135 PDFs, with no child folders found. The 45 book matches were checked through title pages, page counts and content structure. One older work was found under the unrelated filename `Original 2011 P=NP Amazon .pdf`; its scanned title page resolved the match. This illustrates why filename-only absence is not conclusive.

Maintain a distinction between missing titles, matching but uncertain editions, and a specific completeness problem. The audit does that. For Solus Logos, the public contents list Chapter 15 but the body jumps from Chapter 14 to Chapter 16; an omitted chapter and stale contents are both possibilities until the manuscript is checked.

## Local Interior Recovery

Search the underlying Downloads folder, not Explorer's virtual search-results view. Filter exact `.pdf` extensions. A filename containing “pdf” but ending in `.php` is not automatically a usable book PDF.

Normalize spaces, underscores, punctuation, CamelCase and Unicode before comparing explicit title aliases. Wrapper words, covers and templates must be screened before the newest candidate is selected. The observed LEGO cover had only one page. The observed Solus file had 24 pages and a different subtitle; sharing the first two title words was insufficient.

Select by Date modified only among eligible likely interiors, and record rejected newer candidates. Treat equally recent different bytes as unresolved; deduplicate identical bytes. Copy to a new output folder, exclude previous output folders from later searches, and verify copied SHA256 values. Keep source files intact.

Date modified can reflect downloading or restoring a file rather than author revision order. Page count and dimensions are structural screens, not content identity. Compare title pages and chapters before a public upload. Hash identity proves identical bytes; a hash difference does not prove a content correction.

## Reuse with Another Author

Replace the captured source, the 50-title catalog, Drive metadata and public hash baselines. In the collector, replace the records in `Get-BookTargets`, including full titles, explicit aliases, output stems, review notes and filename clues. Remove the Youvan-specific Solus exclusion and page threshold unless they apply to the new work.

Start with one known interior and one known cover on a copied test set. Confirm the report distinguishes them, confirm tied versions remain unresolved, and confirm original bytes and timestamps survive. The included fixture tests provide regression examples; real Windows PDF-reader and content checks remain necessary.

The file-picker launcher avoids assuming a downloaded script has an exact filename. Earlier failures in this session were often path/filename problems before a script had even started.
