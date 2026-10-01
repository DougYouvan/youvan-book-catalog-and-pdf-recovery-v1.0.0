<?php
declare(strict_types=1);

$pdfDirectory = dirname(__DIR__) . '/PDF/Youvan Papers Public';

$papers = [];
$directoryError = null;

if (!is_dir($pdfDirectory) || !is_readable($pdfDirectory)) {
    $directoryError = 'The local PDF archive directory is not currently readable.';
} else {
    $iterator = new DirectoryIterator($pdfDirectory);

    foreach ($iterator as $fileInfo) {
        if ($fileInfo->isDot() || !$fileInfo->isFile()) {
            continue;
        }

        $filename = $fileInfo->getFilename();

        if (strtolower($fileInfo->getExtension()) !== 'pdf') {
            continue;
        }

        $title = preg_replace('/\.pdf$/i', '', $filename);
        $title = str_replace('_', ' ', $title);

        $papers[] = [
            'filename' => $filename,
            'title'    => $title,
            'mtime'    => $fileInfo->getMTime()
        ];
    }

usort($papers, static function (array $a, array $b): int {
    if ($a['mtime'] === $b['mtime']) {
        return strnatcasecmp($a['title'], $b['title']);
    }

    return $b['mtime'] <=> $a['mtime'];
});
}

$paperCount = count($papers);
$displayCount = $paperCount > 0 ? number_format($paperCount) : 'approximately 6,000';

$driveUrl = 'https://drive.google.com/drive/folders/15Kd8bUjm7zVaKdVIwbPhqjjV68aUZQvc?usp=sharing';
$githubUrl = 'https://github.com/DougYouvan';

$books2026 = [
    ['title' => 'The Birth of Mathematics: From Distinction to Higher Homotopy', 'url' => 'https://www.amazon.com/dp/B0HHZSZJ18'],
    ['title' => 'The Mathematical Landscape of Topoi: From Sets and Sheaves to HoTT and Univalence', 'url' => 'https://www.amazon.com/dp/B0HFD8Q1G5'],
    ['title' => 'How to Cheat P vs NP: Relativity, Quantum Loops, Infinite Computers, and Twenty Attempts to Outsmart Computation', 'url' => 'https://www.amazon.com/dp/B0HGJ9MW2X'],
    ['title' => 'The Virgin Oracle: From a Finite Alphabet to Abstract Algebra: How a Nascent Intelligence Could Rediscover Structure, Equivalence, Gluing, and Univalence', 'url' => 'https://www.amazon.com/dp/B0HFDJMSRB'],
    ['title' => 'Mathematics and LEGOs: From Bricks and Morphisms to Relation, Meaning, and Self-Constructing Mathematical Worlds', 'url' => 'https://www.amazon.com/dp/B0HFFC2ZDN'],
    ['title' => 'Mathematics from Quantum Randomness: How a QRNG Generated an Object That Led to a Theorem We Did Not Ask For', 'url' => 'https://www.amazon.com/dp/B0HHM7BK3R'],
    ['title' => 'From Cubes to Worlds: Anonymous Generation and the Emergence of Mathematics, Physics, and Gravitation', 'url' => 'https://www.amazon.com/dp/B0HFDPFMH2'],
    ['title' => 'Beyond the Black Box: Homotopy Type Theory and the Architecture of Future AI', 'url' => 'https://www.amazon.com/dp/B0HFQ6Q2GB'],
    ['title' => 'The GitHub Paradigm: Human to Bot, Bot to Bot, and the End of Attribution', 'url' => 'https://www.amazon.com/dp/B0HH96HSX4'],
    ['title' => 'The Polymathic Centaur: Human Lexicon, Machine Intelligence, and the Future of Thought', 'url' => 'https://www.amazon.com/dp/B0HFWV4WZ9'],
    ['title' => 'A Letter to Hartmut Neven: When Quantum Computers Challenge Causality', 'url' => 'https://www.amazon.com/dp/B0HH4Y9MQD'],
    ['title' => 'A Letter to Katerina Tikhonova: When Quantum Computers Instantiate Reality', 'url' => 'https://www.amazon.com/dp/B0HFHT6NLM'],
    ['title' => 'Stanisław Lem’s Solaris: Quantum Computer, Alien Logos, and the Instantiation of Reality', 'url' => 'https://www.amazon.com/dp/B0HFCZ6VF9'],
    ['title' => 'Mathematics of the Genetic Code', 'url' => 'https://www.amazon.com/dp/B0HFBP19D6'],
    ['title' => 'The Genetic Code as Executable Mathematics: From a 64-Entry Lookup Table to Exact Algebra, Graphs, and Exhaustive Search in Python', 'url' => 'https://www.amazon.com/dp/B0HDZ9L4NJ'],
    ['title' => 'From Cells to Equivalence: Cellular Automata from von Neumann to Category Theory and Homotopy Type Theory', 'url' => 'https://www.amazon.com/dp/B0HFSWFRN5'],
    ['title' => 'Intelligent Design and the Genetic Code: Mathematics, Bootstrapping, and the Architecture of Biological Meaning', 'url' => 'https://www.amazon.com/dp/B0HFBZ3BSJ'],
    ['title' => 'Protecting Science, Protecting the System: Two Open Letters and the Hidden Architecture of the COVID Origins War', 'url' => 'https://www.amazon.com/dp/B0HG89H74H'],
    ['title' => 'The Vanishing Record: COVID Origins, Hidden Emails, ResearchGate, and the Battle Over the Scientific Archive', 'url' => 'https://www.amazon.com/dp/B0HG6R6VHL'],
    ['title' => 'Too Ugly to Look Up from the Bible: Trump, Israel, War, and the Making of the Exvangelical Conscience', 'url' => 'https://www.amazon.com/dp/B0HFSXNN2Z'],
    ['title' => 'Sophia, the Didache, Jung, and Tolstoy: Beyond the Corporate Church', 'url' => 'https://www.amazon.com/dp/B0HFDBBJM8'],
    ['title' => 'Solus Logos: The Living Word Beyond Sola Scriptura', 'url' => 'https://www.amazon.com/dp/B0HFDJGDFT'],
];
?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <title>Douglas C. Youvan — Papers and Books</title>

  <meta
    name="description"
    content="Public archive of approximately 6,000 PDFs of papers and books by Douglas C. Youvan."
  >
  <meta name="robots" content="index,follow,max-image-preview:large">
  <meta name="author" content="Douglas C. Youvan">

  <style>
    :root {
      --blue: #1262bd;
      --blue-dark: #0d4e99;
      --text: #111;
      --muted: #555;
      --border: #d9d9d9;
      --panel: #fff;
      --background: #fafaf8;
      --search-background: #f6f8fb;
    }

    * { box-sizing: border-box; }

    html { scroll-behavior: smooth; }

    body {
      margin: 0;
      background: var(--background);
      color: var(--text);
      font-family: Arial, Helvetica, sans-serif;
      line-height: 1.45;
    }

    a { color: var(--blue); }

    .page {
      width: min(1180px, calc(100% - 36px));
      margin: 0 auto;
      padding: 18px 0 40px;
    }

    .top-actions,
    .actions {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 0;
      flex-wrap: wrap;
    }

    .top-actions { margin-bottom: 72px; }

    .button {
      display: inline-block;
      background: var(--blue);
      color: #fff;
      text-decoration: none;
      font-weight: 700;
      padding: 15px 28px;
      border-radius: 7px;
      border: 0;
      transition: background 0.15s ease;
    }

    .button:hover,
    .button:focus {
      background: var(--blue-dark);
    }

    .top-actions .button:first-child { border-radius: 7px 0 0 7px; }
    .top-actions .button:last-child { border-radius: 0 7px 7px 0; }

    header {
      text-align: center;
      margin-bottom: 28px;
    }

    h1 {
      margin: 0;
      font-size: clamp(3rem, 7vw, 5rem);
      line-height: 1.03;
      letter-spacing: -0.04em;
    }

    .subtitle {
      margin: 18px 0 0;
      color: var(--muted);
      font-size: clamp(1.1rem, 2vw, 1.45rem);
    }

    .actions { margin: 28px 0 24px; }

    .notice,
    .catalog-shell,
    .archive-shell {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 8px;
    }

    .notice {
      padding: 18px 22px;
      margin: 0 0 14px;
    }

    .notice p { margin: 0; }

    .sort-note {
      text-align: center;
      color: var(--muted);
      margin: 14px 0 22px;
    }

    .catalog-shell {
      padding: 22px;
      margin: 0 0 28px;
    }

    .catalog-header {
      display: flex;
      align-items: end;
      justify-content: space-between;
      gap: 18px;
      flex-wrap: wrap;
      margin-bottom: 14px;
    }

    .catalog-header h2 {
      margin: 0;
      font-size: 1.55rem;
    }

    .catalog-header p {
      margin: 4px 0 0;
      color: var(--muted);
    }

    .search-row {
      display: flex;
      gap: 10px;
      align-items: center;
      flex-wrap: wrap;
      margin-bottom: 14px;
    }

    #paperSearch {
      width: min(760px, 100%);
      flex: 1 1 520px;
      padding: 13px 15px;
      border: 1px solid #bfc7d1;
      border-radius: 7px;
      font: inherit;
      background: var(--search-background);
    }

    #paperSearch:focus {
      outline: 3px solid rgba(18, 98, 189, 0.16);
      border-color: var(--blue);
    }

    #resultCount {
      color: var(--muted);
      white-space: nowrap;
    }

    .paper-list {
      list-style: none;
      padding: 0;
      margin: 0;
      border-top: 1px solid #ececec;
      max-height: 620px;
      overflow-y: auto;
    }

    .paper-list li {
      border-bottom: 1px solid #ececec;
    }

    .paper-list a {
      display: block;
      padding: 10px 8px;
      color: #111;
      text-decoration: none;
      overflow-wrap: anywhere;
    }

    .paper-list a:hover,
    .paper-list a:focus {
      background: #f3f7fc;
      color: var(--blue-dark);
      text-decoration: underline;
    }

    .catalog-note {
      margin: 14px 0 0;
      color: var(--muted);
      font-size: 0.95rem;
    }



    .books-shell {
      background: var(--panel);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 22px;
      margin: 38px 0 0;
    }

    .books-shell h2 {
      margin: 0;
      font-size: 1.55rem;
    }

    .books-intro {
      margin: 4px 0 18px;
      color: var(--muted);
    }

    .books-list {
      margin: 0;
      padding-left: 1.6rem;
    }

    .books-list li {
      margin: 0 0 10px;
      padding-left: 4px;
    }

    .books-list li:last-child {
      margin-bottom: 0;
    }

    .books-list a {
      color: #111;
      text-decoration: none;
      overflow-wrap: anywhere;
    }

    .books-list a:hover,
    .books-list a:focus {
      color: var(--blue-dark);
      text-decoration: underline;
    }

    .archive-heading {
      text-align: center;
      margin: 36px 0 12px;
      font-size: 1.45rem;
    }

    .archive-shell {
      height: 760px;
      overflow: hidden;
    }

    .archive-frame {
      display: block;
      width: 100%;
      height: 100%;
      border: 0;
    }

    .fallback {
      text-align: center;
      color: var(--muted);
      margin: 14px 0 0;
    }

    .error {
      color: #8b0000;
      background: #fff4f4;
      border: 1px solid #e4b8b8;
      padding: 14px;
      border-radius: 7px;
    }

    footer {
      text-align: center;
      color: var(--muted);
      margin-top: 38px;
      padding-top: 18px;
      border-top: 1px solid #e5e5e5;
    }


    .logo-lead {
      width: 100%;
      margin: 0 auto 28px;
      background: #000;
      border-radius: 8px;
      overflow: hidden;
    }

    .logo-lead video {
      display: block;
      width: 100%;
      height: auto;
      aspect-ratio: 16 / 9;
      object-fit: cover;
      background: #000;
    }

    @media (max-width: 700px) {
      .page {
        width: min(100% - 22px, 1180px);
      }

      .top-actions {
        margin-bottom: 45px;
      }

      .top-actions .button {
        width: 100%;
        text-align: center;
        border-radius: 7px !important;
        margin-bottom: 8px;
      }

      .archive-shell {
        height: 620px;
      }
    }
  </style>
</head>

<body>
<main class="page">

  <div class="logo-lead" aria-label="YOUVAN.AI animated logo">
    <video autoplay muted playsinline preload="auto">
      <source src="/media/YOUVAN_AI_Logo_frame_complete.mp4" type="video/mp4">
      Your browser does not support HTML5 video.
    </video>
  </div>


  <div class="top-actions">
    <a
      class="button"
      href="<?= htmlspecialchars($githubUrl, ENT_QUOTES, 'UTF-8') ?>"
      target="_blank"
      rel="noopener"
    >
      Open-Source Research Code on GitHub
    </a>

    <a
      class="button"
      href="<?= htmlspecialchars($driveUrl, ENT_QUOTES, 'UTF-8') ?>"
      target="_blank"
      rel="noopener"
    >
      Open the Complete PDF Archive
    </a>
  </div>

  <header>
    <h1>Douglas C. Youvan</h1>

    <p class="subtitle">
      ~ 6,000 PDFs of Papers and Books
    </p>
  </header>

  <div class="actions">
    <a
      class="button"
      href="<?= htmlspecialchars($driveUrl, ENT_QUOTES, 'UTF-8') ?>"
      target="_blank"
      rel="noopener"
    >
      Open the Complete PDF Archive
    </a>
  </div>

  <section class="notice" aria-label="Archive information">
    <p>
      This page provides two views of the publication archive.
      The first is the locally mirrored server copy, with searchable title links.
      The second is the Google Drive copy, shown in a separate window below.
    </p>
  </section>

  <p class="sort-note">
    To see the newest papers first, open the complete archive and sort by
    <strong>Modified</strong> with the newest date at the top.
  </p>

  <section class="catalog-shell" aria-labelledby="catalogTitle">
    <div class="catalog-header">
      <div>
        <h2 id="catalogTitle">Local Server Archive — Search Publication Titles</h2>
        <p>
          Search the local server copy by words appearing in a paper or book title.
        </p>
      </div>
    </div>

    <?php if ($directoryError !== null): ?>
      <p class="error">
        <?= htmlspecialchars($directoryError, ENT_QUOTES, 'UTF-8') ?>
      </p>
    <?php else: ?>

      <div class="search-row">
        <input
          id="paperSearch"
          type="search"
          autocomplete="off"
          spellcheck="false"
          placeholder="Type any title word or phrase — e.g. algebra, genetic code, Logos, AI"
          aria-label="Search publication titles"
        >
        <span id="resultCount"><?= number_format($paperCount) ?> PDFs</span>
      </div>

      <ul id="paperList" class="paper-list">
        <?php foreach ($papers as $paper): ?>
          <li data-title="<?= htmlspecialchars(mb_strtolower($paper['title'], 'UTF-8'), ENT_QUOTES, 'UTF-8') ?>">
            <a
              href="pdf.php?file=<?= rawurlencode($paper['filename']) ?>"
              target="_blank"
            ><?= htmlspecialchars($paper['title'], ENT_QUOTES, 'UTF-8') ?></a>
          </li>
        <?php endforeach; ?>
      </ul>

      <p class="catalog-note">
        The title links above are ordinary crawlable web links. The list is generated
        automatically from the PDFs currently present in the server archive folder.
      </p>
    <?php endif; ?>
  </section>

  <h2 class="archive-heading">Google Drive Archive</h2>

  <div class="archive-shell">
    <iframe
      class="archive-frame"
      src="https://drive.google.com/embeddedfolderview?id=15Kd8bUjm7zVaKdVIwbPhqjjV68aUZQvc#list"
      title="Douglas C. Youvan public PDF archive"
      loading="lazy"
    ></iframe>
  </div>

  <p class="fallback">
    If the embedded archive does not load,
    <a
      href="<?= htmlspecialchars($driveUrl, ENT_QUOTES, 'UTF-8') ?>"
      target="_blank"
      rel="noopener"
    >
      open the complete archive directly in Google Drive
    </a>.
  </p>


  <section class="books-shell" aria-labelledby="books2026Title">
    <h2 id="books2026Title">2026 Youvan Books</h2>
    <p class="books-intro">Hyperlinks to Amazon, arranged approximately from mathematics to theology.</p>

    <ol class="books-list">
      <?php foreach ($books2026 as $book): ?>
        <li>
          <a
            href="<?= htmlspecialchars($book['url'], ENT_QUOTES, 'UTF-8') ?>"
            target="_blank"
            rel="noopener noreferrer"
          ><?= htmlspecialchars($book['title'], ENT_QUOTES, 'UTF-8') ?></a>
        </li>
      <?php endforeach; ?>
    </ol>
  </section>

  <footer>
    Douglas C. Youvan — Papers and Books
  </footer>

</main>

<script>
(function () {
  const input = document.getElementById('paperSearch');
  const list = document.getElementById('paperList');
  const counter = document.getElementById('resultCount');

  if (!input || !list || !counter) return;

  const items = Array.from(list.querySelectorAll('li'));
  const total = items.length;

  function update() {
    const query = input.value.trim().toLocaleLowerCase();
    let shown = 0;

    for (const item of items) {
      const title = item.dataset.title || '';
      const visible = query === '' || title.includes(query);
      item.hidden = !visible;
      if (visible) shown++;
    }

    counter.textContent =
      query === ''
        ? total.toLocaleString() + ' PDFs'
        : shown.toLocaleString() + ' of ' + total.toLocaleString() + ' PDFs';
  }

  input.addEventListener('input', update);
  update();
})();
</script>

</body>
</html>
