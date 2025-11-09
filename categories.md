---
layout: page
title: Categories
permalink: /categories/
---

{% assign cats = site.categories %}
{% for c in cats %}
### {{ c[0] }}
<ul>
  {% for post in c[1] %}
    <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> <small>— {{ post.date | date: "%Y-%m-%d" }}</small></li>
  {% endfor %}
</ul>
{% endfor %}
