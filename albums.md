---
layout: default
title: Albums
permalink: /albums/
---

<article class="page">
  <h1 data-i18n="albums.title">Albums</h1>

  {%- comment -%}
    收集所有 album 页面，并去重
  {%- endcomment -%}
  {%- assign raw = site.pages | where: "layout", "album" -%}
  {%- assign grouped = raw | group_by: "url" -%}
  {%- assign albums_all = "" | split: "" -%}
  {%- for g in grouped -%}
    {%- assign albums_all = albums_all | push: g.items.first -%}
  {%- endfor -%}

  {%- comment -%}
    只用有 location 的相册生成筛选按钮，避免 nil 参与 sort
  {%- endcomment -%}
  {%- assign albums_with_loc = albums_all | where_exp: "a", "a.location" -%}
  {%- assign locs = albums_with_loc | map: "location" | uniq | sort -%}

  <div class="album-filters" id="albumLocFilters">
    <strong data-i18n="home.location">Location:</strong>
    <button type="button" data-loc="all" class="on" data-i18n="filters.all">All</button>
    {%- for loc in locs -%}
      {%- assign rep = albums_with_loc | where: "location", loc | first -%}
      <button type="button" data-loc="{{ loc }}">
        {{ rep.location_name | default: loc }}
      </button>
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
  const grid = document.getElementById('albumGrid');
  const bar  = document.getElementById('albumLocFilters');
  if (!grid || !bar) return;

  const cards = Array.from(grid.querySelectorAll('.album-card'));
  const btns  = Array.from(bar.querySelectorAll('button[data-loc]'));

  function setActive(btn) {
    btns.forEach(b => b.classList.toggle('on', b === btn));
  }

  function applyFilter(loc) {
    cards.forEach(card => {
      const v = card.getAttribute('data-location') || '';
      card.style.display = (loc === 'all' || v === loc) ? '' : 'none';
    });

    // URL 上带上 ?loc=xxx，方便分享
    try {
      const u = new URL(window.location.href);
      if (loc === 'all') {
        u.searchParams.delete('loc');
      } else {
        u.searchParams.set('loc', loc);
      }
      history.replaceState(null, '', u.toString());
    } catch (e) {
      // ignore
    }
  }

  // 初始状态：看 URL 里有没有 ?loc
  let initLoc = 'all';
  try {
    const u = new URL(window.location.href);
    const q = u.searchParams.get('loc');
    if (q && btns.some(b => b.dataset.loc === q)) {
      initLoc = q;
    }
  } catch (e) {}

  const initBtn = btns.find(b => b.dataset.loc === initLoc) || btns[0];
  if (initBtn) {
    setActive(initBtn);
    applyFilter(initBtn.dataset.loc);
  }

  bar.addEventListener('click', (e) => {
    const btn = e.target.closest('button[data-loc]');
    if (!btn) return;
    setActive(btn);
    applyFilter(btn.dataset.loc);
  });
})();
</script>