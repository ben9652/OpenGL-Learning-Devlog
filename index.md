---
layout: default
title: Inicio
---

# Ruta OpenGL desde cero

Este es el devlog de mi aprendizaje de OpenGL desde cero. Cada parte tiene su video y su texto completo en **español e inglés**.

<ul class="part-list">
{% assign parts = site.devlog | sort: "part" %}
{% for p in parts %}
  <li>
    <a href="{{ p.url | relative_url }}">Parte {{ p.part }} — {{ p.title }}</a>
    <span class="part-date">{{ p.date | date: "%Y-%m-%d" }}</span>
  </li>
{% endfor %}
</ul>
