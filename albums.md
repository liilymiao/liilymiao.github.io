---
layout: default
title: Albums
permalink: /albums/
---

<div class="albums-grid">
  {% assign list = site.pages | where: "layout", "album" | sort: "path" %}
  {% for a in list %}
  <a class="album-card" href="{{ a.url | relative_url }}">
    <img src="{{ a.cover | relative_url }}" alt="{{ a.title }}" loading="lazy">
    <div class="meta">
      <h3>{{ a.title }}</h3>
      <small>{{ a.date | date: "%Y-%m-%d" }}</small>
    </div>
  </a>
  {% endfor %}
</div>
