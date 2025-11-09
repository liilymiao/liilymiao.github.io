---
layout: page
title: Albums Debug
permalink: /albums-debug/
---
<ul>
{% for a in site.albums %}
  <li>{{ a.title }} — <code>{{ a.url }}</code> — <a href="{{ a.url | relative_url }}">open</a></li>
{% endfor %}
</ul>
