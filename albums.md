---
layout: default
title: Albums
permalink: /albums/
---

<h1 data-i18n="home.albums">Albums</h1>

{%- assign albums_all = site.pages | where: "layout", "album" -%}
{%- assign locs = albums_all | map: "location" | uniq | sort -%}

<div class="album-filters" id="albumLocFilters">
  <strong data-i18n="home.location">Location:</strong>
  <button type="button" data-loc="all" class="on" data-i18n="filters.all">All</button>
  {%- for loc in locs -%}
    {%- assign rep = albums_all | where: "location", loc | first -%}
    <button type="button" data-loc="{{ loc }}">{{ rep.location_name | default: loc }}</button>
  {%- endfor -%}
</div>

<div class="albums-grid" id="albumGrid">
  {%- assign cards = albums_all | sort: "date" | reverse -%}
  {%- for a in cards -%}
    <a class="album-card"
       href="{{ a.url | relative_url }}"
       data-location="{{ a.location | default: '' }}"
       data-title-zh="{{ a.title   | escape }}"
       data-title-en="{{ a.title_en | default: a.title | escape }}">
      {% if a.cover %}
        <img src="{{ a.cover | relative_url }}" alt="{{ a.title_en | default: a.title }}" loading="lazy" decoding="async">
      {% endif %}
      <div class="meta">
        <h3>{{ a.title_en | default: a.title }}</h3>
        {% if a.date %}<small>{{ a.date | date: "%Y-%m-%d" }}</small>{% endif %}
      </div>
    </a>
  {%- endfor -%}
</div>

<script>
/* --- 语言切换：专管相册卡片标题 --- */
(function(){
  const STORE = 'lang';
  function applyTitles(lang){
    document.querySelectorAll('.album-card').forEach(card=>{
      const zh = card.dataset.titleZh;
      const en = card.dataset.titleEn || zh;
      const h3 = card.querySelector('h3');
      if (h3) h3.textContent = (lang === 'zh') ? zh : en;
    });
  }
  const cur = localStorage.getItem(STORE) || 'en';
  applyTitles(cur);
  window.addEventListener('langchange', e => applyTitles(e.detail || 'en'));
})();

/* --- 地点筛选 --- */
(function(){
  const ag = document.getElementById('albumGrid');
  const ab = document.getElementById('albumLocFilters');
  if (!ag || !ab) return;
  const cards = Array.from(ag.querySelectorAll('.album-card'));
  const btns  = Array.from(ab.querySelectorAll('button[data-loc]'));
  function setActive(btn){ btns.forEach(b=>b.classList.toggle('on', b===btn)); }
  function apply(loc){
    cards.forEach(c=>{
      const v = c.getAttribute('data-location') || '';
      c.style.display = (loc === 'all' || v === loc) ? '' : 'none';
    });
    try{
      const u = new URL(window.location.href);
      if (loc === 'all') u.searchParams.delete('loc'); else u.searchParams.set('loc', loc);
      history.replaceState(null,'',u.toString());
    }catch(_){}
  }
  let init = 'all';
  try{
    const p = new URL(window.location.href).searchParams.get('loc');
    if (btns.some(b=>b.dataset.loc === p)) init = p;
  }catch(_){}
  const startBtn = btns.find(b=>b.dataset.loc === init) || btns[0];
  if (startBtn){ setActive(startBtn); apply(startBtn.dataset.loc); }
  ab.addEventListener('click', e=>{
    const btn = e.target.closest('button[data-loc]');
    if (!btn) return;
    setActive(btn); apply(btn.dataset.loc);
  });
})();
</script>