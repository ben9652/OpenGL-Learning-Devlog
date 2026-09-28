---
layout: default
title: Inicio
---

<h1 data-es="Ruta OpenGL desde cero" data-en="OpenGL path from scratch">Ruta OpenGL desde cero</h1>

<p data-es="Este es el devlog de mi aprendizaje de OpenGL desde cero. Cada parte tiene su video y su texto completo en español e inglés."
   data-en="This is the devlog of my OpenGL learning from scratch. Every part has its video and its full text in Spanish and English.">Este es el devlog de mi aprendizaje de OpenGL desde cero. Cada parte tiene su video y su texto completo en español e inglés.</p>

<ul class="part-list">
{% assign parts = site.devlog | sort: "part" %}
{% for p in parts %}
  <li>
    <a href="{{ p.url | relative_url }}"
       data-es="Parte {{ p.part }} — {{ p.title }}"
       data-en="Part {{ p.part }} — {{ p.title_en }}">Parte {{ p.part }} — {{ p.title }}</a>
    <span class="part-date">{{ p.date | date: "%Y-%m-%d" }}</span>
  </li>
{% endfor %}
</ul>
