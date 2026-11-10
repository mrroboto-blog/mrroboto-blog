---
title: Tags
permalink: /tags/
---
{% assign posts = site.pages | where_exp: "p", "p.path contains 'lessons/'" %}
{% assign all_tags = posts | map: "tags" | join: "," | split: "," | uniq | sort %}
{% for tag in all_tags %}{% if tag != "" %}
<h2 id="{{ tag }}">{{ tag }}</h2>
<ul>
{% for p in posts %}{% if p.tags contains tag %}
  <li><a href="{{ p.url | relative_url }}">{{ p.title }}</a></li>
{% endif %}{% endfor %}
</ul>
{% endif %}{% endfor %}
