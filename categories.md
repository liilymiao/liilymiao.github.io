---
layout: page
title: Categories
permalink: /categories/
---

{% assign cats = site.categories %}
{% for c in cats %}
<h3 id="{{ c[0] | downcase | url_encode }}">{{ c[0] }}</h3>
<ul>
  {% for post in c[1] %}
    <li><a href="{{ post.url | relative_url }}">{{ post.title }}</a> <small>— {{ post.date | date: "%Y-%m-%d" }}</small></li>
  {% endfor %}
</ul>
{% endfor %}
