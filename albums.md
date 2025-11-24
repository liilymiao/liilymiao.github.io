---
layout: default
---

<article class="album-page">
  <header class="album-header">
    <h1>
      {{ page.title_en | default: page.title }}
    </h1>
    <p class="album-meta-line">
      {% if page.date %}
        <span>{{ page.date | date: "%Y-%m-%d" }}</span>
      {% endif %}
      {% if page.location_name %}
        {% if page.date %} · {% endif %}
        <span>{{ page.location_name }}</span>
      {% endif %}
    </p>

    {% if page.cover %}
      <div class="album-cover-wide">
        <img src="{{ page.cover | relative_url }}"
             alt="{{ page.title_en | default: page.title }}"
             loading="lazy" decoding="async">
      </div>
    {% endif %}
  </header>

  {% if page.photos %}
    <section class="album-photos">
      <h2 class="album-photos-title">Photos</h2>

      <style>
        .album-header h1{
          margin-bottom:.2rem;
        }
        .album-meta-line{
          margin:0 0 1rem;
          font-size:.9rem;
          color:var(--muted);
        }
        .album-cover-wide img{
          width:100%;
          height:auto;
          display:block;
          border-radius:12px;
          object-fit:cover;
          max-height:420px; /* 超过就按比例裁一点，但不变形 */
          overflow:hidden;
        }

        .album-photos{
          margin-top:1.5rem;
        }
        .album-photos-title{
          font-size:1.1rem;
          margin:0 0 .75rem;
        }

        .album-photos-grid{
          display:grid;
          grid-template-columns:repeat(auto-fill,minmax(240px,1fr));
          gap:14px;
        }
        .album-photo-card{
          position:relative;
          display:block;
          text-decoration:none;
          color:inherit;
          border-radius:10px;
          overflow:hidden;
          background:var(--card-bg);
          border:var(--card-border);
          box-shadow:var(--card-shadow);
          transition:transform .15s ease, box-shadow .15s ease;
        }
        .album-photo-card:hover{
          transform:translateY(-2px);
          box-shadow:0 10px 26px rgba(0,0,0,.22);
        }
        .album-photo-card img{
          display:block;
          width:100%;
          height:auto;      /* ✅ 等比缩放，不拉伸 */
          object-fit:cover; /* 超出就裁，不变形 */
        }
        .album-photo-meta{
          padding:6px 8px 8px;
          font-size:.8rem;
          display:flex;
          justify-content:space-between;
          gap:6px;
          color:var(--muted);
        }
        .album-photo-meta small{
          white-space:nowrap;
        }

        /* 简单 Lightbox，仅本页面使用 */
        #albumLightbox{
          position:fixed;
          inset:0;
          background:rgba(0,0,0,.9);
          display:flex;
          align-items:center;
          justify-content:center;
          z-index:9999;
        }
        #albumLightbox[hidden]{
          display:none;
        }
        #albumLightbox img{
          max-width:90vw;
          max-height:90vh;
          object-fit:contain; /* ✅ 原图比例，不拉伸 */
          box-shadow:0 0 30px rgba(0,0,0,.6);
          border-radius:8px;
        }
        #albumLightbox .pl-inner{
          position:relative;
        }
      </style>

      <div class="album-photos-grid" id="albumPhotoGrid">
        {%- for p in page.photos -%}
          {%- assign src = p.src -%}
          {%- assign base = src | replace:'/assets/img/albums/','/assets/thumbs/albums/' -%}
          {%- assign thumb = base
            | replace: '.JPG','-thumb.JPG'
            | replace: '.JPEG','-thumb.JPEG'
            | replace: '.jpg','-thumb.jpg'
            | replace: '.jpeg','-thumb.jpeg' -%}
          {%- assign large = base
            | replace: '.JPG','-large.JPG'
            | replace: '.JPEG','-large.JPEG'
            | replace: '.jpg','-large.jpg'
            | replace: '.jpeg','-large.jpeg' -%}

          <a class="album-photo-card"
             href="{{ src | relative_url }}"
             data-full="{{ large | relative_url }}"
             title="{{ p.caption | default: page.title }}">
            <img src="{{ thumb | relative_url }}"
                 alt="{{ p.caption | default: page.title }}"
                 loading="lazy" decoding="async">

            <div class="album-photo-meta">
              <small>
                {%- assign when_raw = p.taken_at | default: page.date -%}
                {%- if when_raw -%}
                  {{ when_raw | date: "%Y-%m-%d" }}
                {%- endif -%}
              </small>
              <small>
                {%- if p.lens -%}
                  {%- if p.lens.first -%}
                    {{ p.lens | join: ', ' }}
                  {%- else -%}
                    {{ p.lens }}
                  {%- endif -%}
                {%- endif -%}
              </small>
            </div>
          </a>
        {%- endfor -%}
      </div>

      <!-- 本相册 Lightbox 容器 -->
      <div id="albumLightbox" hidden>
        <div class="pl-inner">
          <img id="albumLightboxImg" src="" alt="">
        </div>
      </div>
    </section>
  {% endif %}
</article>

<script>
(function(){
  /* 简易 Lightbox：点击相册里的缩略图 → 显示对应 large 图，原比例 contain */
  const grid = document.getElementById('albumPhotoGrid');
  const box  = document.getElementById('albumLightbox');
  const img  = document.getElementById('albumLightboxImg');
  if (!grid || !box || !img) return;

  grid.addEventListener('click', function(e){
    const card = e.target.closest('.album-photo-card');
    if (!card) return;
    e.preventDefault();
    const full = card.getAttribute('data-full') || card.getAttribute('href');
    if (!full) return;
    img.src = full;
    box.hidden = false;
  });

  box.addEventListener('click', function(){
    box.hidden = true;
    img.src = '';
  });

  document.addEventListener('keydown', function(e){
    if (e.key === 'Escape' && !box.hidden){
      box.hidden = true;
      img.src = '';
    }
  });
})();
</script>