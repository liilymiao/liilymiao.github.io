---
layout: default
title: Albums
permalink: /albums/
---

<article class="page">
  <h1 data-i18n="albums.title">Albums</h1>

  {%- assign raw = site.pages | where: "layout", "album" -%}
  {%- assign grouped = raw | group_by: "url" -%}
  {%- assign albums_all = "" | split: "" -%}
  {%- for g in grouped -%}
    {%- assign albums_all = albums_all | push: g.items.first -%}
  {%- endfor -%}

  {%- comment -%}
    只用有 location 的相册来生成筛选按钮，避免 nil 参与 sort
  {%- endcomment -%}
  {%- assign albums_with_loc = albums_all | where_exp: "a", "a.location" -%}
  {%- assign locs = albums_with_loc | map: "location" | uniq | sort -%}

  <div class="album-filters" id="albumLocFilters">
    <strong data-i18n="albums.location">Location:</strong>
    <button type="button" data-loc="all" class="on" data-i18n="filters.all">All</button>
    {%- for loc in locs -%}
      {%- if loc and loc != "" -%}
        {%- assign rep = albums_with_loc | where: "location", loc | first -%}
        <button type="button" data-loc="{{ loc }}">
          {{ rep.location_name | default: loc }}
        </button>
      {%- endif -%}
    {%- endfor -%}
  </div>

  <div class="albums-grid" id="albumGrid">
    {%- assign cards = albums_all | sort: "date" | reverse -%}
    {%- for a in cards -%}
      <a class="album-card"
         href="{{ a.url | relative_url }}"
         data-location="{{ a.location | default: '' }}"
         data-title-zh="{{ a.title | escape }}"
         data-title-en="{{ a.title_en | default: a.title | escape }}">
        <div class="album-cover">
          {% if a.cover %}
            <img
              src="{{ a.cover | relative_url }}"
              alt="{{ a.title_en | default: a.title }}"
              loading="lazy" decoding="async">
          {% else %}
            <div class="album-cover-placeholder"></div>
          {% endif %}
        </div>

        <div class="album-meta">
          <h2 class="album-title">
            {{ a.title_en | default: a.title }}
          </h2>

          <p class="album-sub">
            {%- if a.date -%}
              <span class="album-date">
                {{ a.date | date: "%Y-%m-%d" }}
              </span>
            {%- endif -%}

            {%- if a.location_name -%}
              {%- if a.date -%} · {% endif -%}
              <span class="album-location">
                {{ a.location_name }}
              </span>
            {%- endif -%}
          </p>
        </div>
      </a>
    {%- endfor -%}
  </div>
</article>

<style>
  .album-filters{
    display:flex;
    flex-wrap:wrap;
    align-items:center;
    gap:8px;
    margin:8px 0 14px;
    font-size:0.9rem;
  }
  .album-filters strong{
    margin-right:4px;
  }
  .album-filters button{
    border-radius:999px;
    border:1px solid var(--border-color, #444);
    padding:4px 10px;
    background:transparent;
    color:inherit;
    cursor:pointer;
    font-size:0.86rem;
  }
  .album-filters button.on{
    background:var(--accent, #ffd35c);
    color:#000;
    border-color:transparent;
  }

  .albums-grid{
    display:grid;
    grid-template-columns:repeat(auto-fill,minmax(240px,1fr));
    gap:18px;
    margin-top:8px;
  }
  .album-card{
    display:flex;
    flex-direction:column;
    text-decoration:none;
    background:var(--card-bg);
    border:var(--card-border);
    border-radius:12px;
    overflow:hidden;
    box-shadow:var(--card-shadow);
    transition:transform .15s ease, box-shadow .15s ease;
  }
  .album-card:hover{
    transform:translateY(-2px);
    box-shadow:0 12px 30px rgba(0,0,0,.16);
  }
  .album-cover img,
  .album-cover-placeholder{
    display:block;
    width:100%;
    height:180px;
    object-fit:cover;
    background:var(--bg-soft);
  }
  .album-meta{
    padding:10px 12px 12px;
  }
  .album-title{
    margin:0 0 4px;
    font-size:1rem;
  }
  .album-sub{
    margin:0;
    font-size:.86rem;
    color:var(--muted);
  }
</style>

<script>
(function () {
  const STORE = 'lang';

  const dict = {
    en: {
      "albums.title": "Albums",
      "albums.location": "Location:",
      "filters.all": "All"
    },
    zh: {
      "albums.title": "相册",
      "albums.location": "地点：",
      "filters.all": "全部"
    }
  };

  function applyText(lang){
    const map = dict[lang] || dict.en;
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (map[key] != null) el.textContent = map[key];
    });
  }

  function applyAlbumCardTitles(lang){
    document.querySelectorAll('.album-card').forEach(card => {
      const zh = card.dataset.titleZh;
      const en = card.dataset.titleEn || zh;
      const titleEl = card.querySelector('.album-title');
      if (!titleEl) return;

      if (lang === 'zh' && zh) {
        titleEl.textContent = zh;
      } else {
        titleEl.textContent = en || zh || titleEl.textContent;
      }
    });
  }

  // 初始化语言（跟首页逻辑一致）
  let lang = localStorage.getItem(STORE);
  if (!lang) { lang = 'en'; localStorage.setItem(STORE, lang); }
  document.documentElement.setAttribute('data-ui-lang', lang);
  applyText(lang);
  applyAlbumCardTitles(lang);

  // 监听全局语言切换事件（default.html 会 dispatch）
  window.addEventListener('langchange', e => {
    const next = e.detail || 'en';
    localStorage.setItem(STORE, next);
    document.documentElement.setAttribute('data-ui-lang', next);
    applyText(next);
    applyAlbumCardTitles(next);
  });

  // Location 筛选
  const ag = document.getElementById('albumGrid');
  const ab = document.getElementById('albumLocFilters');
  if (!ag || !ab) return;

  const cards = Array.from(ag.querySelectorAll('.album-card'));
  const btns  = Array.from(ab.querySelectorAll('button[data-loc]'));

  function setActive(btn){
    btns.forEach(b => b.classList.toggle('on', b === btn));
  }

  function applyLoc(loc){
    cards.forEach(c => {
      const v = c.getAttribute('data-location') || '';
      c.style.display = (loc === 'all' || v === loc) ? '' : 'none';
    });

    try {
      const u = new URL(window.location.href);
      if (loc === 'all') u.searchParams.delete('loc');
      else u.searchParams.set('loc', loc);
      history.replaceState(null, '', u.toString());
    } catch (_) {}
  }

  let init = 'all';
  try {
    const p = new URL(window.location.href).searchParams.get('loc');
    if (btns.some(b => b.dataset.loc === p)) init = p;
  } catch (_) {}

  const startBtn = btns.find(b => b.dataset.loc === init) || btns[0];
  if (startBtn) {
    setActive(startBtn);
    applyLoc(startBtn.dataset.loc);
  }

  ab.addEventListener('click', e => {
    const btn = e.target.closest('button[data-loc]');
    if (!btn) return;
    setActive(btn);
    applyLoc(btn.dataset.loc);
  });
})();
</script>