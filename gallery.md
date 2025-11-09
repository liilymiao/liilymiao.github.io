---
layout: page
title: Gallery
permalink: /gallery/
---

<div class="gallery">
  {%- assign pics = site.static_files | where_exp: "f", "f.path contains '/assets/img/gallery/'" -%}
  {%- for f in pics -%}
  <figure class="gallery-item">
    <img src="{{ f.path | relative_url }}" alt="{{ f.name | split:'.' | first | replace:'-',' ' }}" loading="lazy">
    <figcaption>{{ f.name | split:'.' | first | replace:'-',' ' }}</figcaption>
  </figure>
  {%- endfor -%}
</div>

> Drop images into `assets/img/gallery/` and push. Filenames become captions automatically.
