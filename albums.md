---
layout: default
---

<article class="page">
  <h1 data-i18n="albums.title">Albums</h1>

  <div class="albums-grid">
    {%- assign albums = site.pages | where: "layout", "album" | sort: "date" | reverse -%}

    {%- for a in albums -%}
      <a class="album-card" href="{{ a.url | relative_url }}">
        <div class="album-cover">
          {%- if a.cover -%}
            <img src="{{ a.cover | relative_url }}"
                 alt="{{ a.title_en | default: a.title }}"
                 loading="lazy" decoding="async">
          {%- else -%}
            <div class="album-cover-placeholder"></div>
          {%- endif -%}
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
  .albums-grid{
    display:grid;
    grid-template-columns:repeat(auto-fill,minmax(240px,1fr));
    gap:18px;
    margin-top:16px;
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