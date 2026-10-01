# Historical Implementations

`known-flawed-v1/Collect-Youvan-PDFs.ps1` is the first collector Douglas ran. It copied suspicious files to `Needs-Review` but still selected a one-page cover and a differently subtitled Solus work. Preserve it to understand and reproduce the failure; use the corrected experimental v2 for later work.

`clipboard-extractor/Amazon-Books.ps1` is an earlier product-link extractor. It indexes ASINs rather than distinct works and has a hard-coded 51-count warning. Its output is not the final 50-title preferred catalog. It demonstrates Windows clipboard HTML and safe separate-variable `HtmlDecode` handling after an earlier argument-parsing failure.

The complete supplied Amazon capture and the final catalog supersede partial clipboard results. These files are historical evidence, not recommended entry points.
