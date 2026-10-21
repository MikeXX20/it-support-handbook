(() => {
  'use strict';
  const chinese = document.documentElement.lang === 'zh-CN';
  const text = chinese ? {
    copy: '复制', copied: '已复制', select: '请选择代码复制', copyLabel: '复制代码块',
    searching: '正在搜索…', count: n => `找到 ${n} 篇指南`,
    empty: '未找到相关指南。试试“磁盘”、“锁”或“备份”。',
    unavailable: '搜索暂不可用，请通过目录浏览。'
  } : {
    copy: 'Copy', copied: 'Copied', select: 'Select code to copy', copyLabel: 'Copy code block',
    searching: 'Searching…', count: n => `${n} matching guides`,
    empty: 'No matching guides. Try “disk”, “locks”, or “backup”.',
    unavailable: 'Search is temporarily unavailable. Browse the topics instead.'
  };
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
    button.textContent = text.copy;
    button.setAttribute('aria-label', text.copyLabel);
    button.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(code.textContent);
        button.textContent = text.copied;
      } catch {
        button.textContent = text.select;
      }
      window.setTimeout(() => { button.textContent = text.copy; }, 2200);
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
    status.textContent = text.searching;
    list.replaceChildren();
    try {
      const pages = await getIndex();
      if (generation !== searchGeneration || input.value.trim() !== query) return;
      const terms = query.toLowerCase().split(/\s+/);
      const matches = pages.map(page => {
        const title = page.title.toLowerCase();
        const body = page.body.toLowerCase();
        const searchable = `${title} ${body}`;
        const score = terms.every(term => searchable.includes(term))
          ? terms.reduce((n, term) => n + (title.includes(term) ? 5 : 1), 0) : 0;
        return { ...page, score };
      }).filter(page => page.score > 0).sort((a, b) => b.score - a.score).slice(0, 8);
      status.textContent = matches.length ? text.count(matches.length) : text.empty;
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
      if (generation === searchGeneration && input.value.trim() === query) status.textContent = text.unavailable;
    }
  };
  form.addEventListener('submit', event => { event.preventDefault(); clearTimeout(timer); search(); });
  input.addEventListener('input', () => { clearTimeout(timer); timer = setTimeout(search, 160); });
  input.addEventListener('focus', () => { if (input.value.trim().length >= 2) search(); });
  form.addEventListener('keydown', event => { if (event.key === 'Escape') results.hidden = true; });
  document.addEventListener('click', event => { if (!form.contains(event.target)) results.hidden = true; });
})();
