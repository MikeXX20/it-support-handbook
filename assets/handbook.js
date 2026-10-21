(() => {
  'use strict';
  const menu = document.querySelector('.menu-toggle');
  const sidebar = document.querySelector('.sidebar');
  menu?.addEventListener('click', () => {
    const open = menu.getAttribute('aria-expanded') !== 'true';
    menu.setAttribute('aria-expanded', String(open));
    sidebar?.classList.toggle('is-open', open);
  });

  document.querySelectorAll('main pre').forEach(pre => {
    const code = pre.querySelector('code');
    if (!code || !navigator.clipboard) return;
    const button = document.createElement('button');
    button.className = 'copy-button';
    button.type = 'button';
    button.textContent = 'Copy';
    button.setAttribute('aria-label', 'Copy code block');
    button.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(code.textContent);
        button.textContent = 'Copied';
      } catch {
        button.textContent = 'Select code to copy';
      }
      window.setTimeout(() => { button.textContent = 'Copy'; }, 2200);
    });
    pre.append(button);
  });

  const form = document.querySelector('.search');
  const input = document.querySelector('#handbook-search');
  const results = document.querySelector('#search-results');
  const status = results?.querySelector('.search-status');
  const list = results?.querySelector('ul');
  if (!form || !input || !results || !status || !list) return;
  let indexPromise;
  let timer;
  let searchGeneration = 0;
  const getIndex = () => {
    if (!indexPromise) {
      indexPromise = fetch(document.body.dataset.searchUrl)
        .then(response => {
          if (!response.ok) throw new Error('Search index unavailable');
          return response.json();
        })
        .catch(error => { indexPromise = null; throw error; });
    }
    return indexPromise;
  };
  const search = async () => {
    const generation = ++searchGeneration;
    const query = input.value.trim();
    if (query.length < 2) { results.hidden = true; return; }
    results.hidden = false;
    status.textContent = 'Searching…';
    list.replaceChildren();
    try {
      const pages = await getIndex();
      if (generation !== searchGeneration || input.value.trim() !== query) return;
      const terms = query.toLowerCase().split(/\s+/);
      const matches = pages.map(page => {
        const title = page.title.toLowerCase();
        const body = page.body.toLowerCase();
        const text = `${title} ${body}`;
        const score = terms.every(term => text.includes(term))
          ? terms.reduce((n, term) => n + (title.includes(term) ? 5 : 1), 0) : 0;
        return { ...page, score };
      }).filter(page => page.score > 0).sort((a, b) => b.score - a.score).slice(0, 8);
      status.textContent = matches.length ? `${matches.length} matching guides` : 'No matching guides. Try “disk”, “locks”, or “backup”.';
      for (const page of matches) {
        const li = document.createElement('li');
        const link = document.createElement('a');
        link.href = page.url;
        const title = document.createElement('strong');
        title.textContent = page.title;
        const snippet = document.createElement('span');
        const hit = page.body.toLowerCase().indexOf(terms[0]);
        const start = Math.max(0, hit - 35);
        snippet.textContent = `${start ? '…' : ''}${page.body.slice(start, start + 135)}…`;
        link.append(title, snippet);
        li.append(link);
        list.append(li);
      }
    } catch {
      if (generation === searchGeneration && input.value.trim() === query) status.textContent = 'Search is temporarily unavailable. Browse the topics instead.';
    }
  };
  form.addEventListener('submit', event => { event.preventDefault(); clearTimeout(timer); search(); });
  input.addEventListener('input', () => { clearTimeout(timer); timer = setTimeout(search, 160); });
  input.addEventListener('focus', () => { if (input.value.trim().length >= 2) search(); });
  form.addEventListener('keydown', event => { if (event.key === 'Escape') results.hidden = true; });
  document.addEventListener('click', event => { if (!form.contains(event.target)) results.hidden = true; });
})();
