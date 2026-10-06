---
title: "Usando Index Buffers"
title_en: "Using Index Buffers"
part: 5
date: 2026-10-06
video_file: "parte-05.mp4"
linkedin: ""
---

<div class="lang-es" markdown="1">

Primero, simplemente adapto la renderización al tamaño de mi ventana, y hago esto dentro del bucle así cada vez que redimensiono la ventana las coordenadas se siguen mapeando a los nuevos tamaños de ventana. Para ello uso `glViewport()`.

Luego, renderizo un triángulo adicional con vértices comunes al primero. Al principio lo hago creando los datos de cada uno de los vértices de los dos triángulos. Pero luego uso un Index Buffer, o Element Buffer Object (EBO, aunque en el código lo llamo IBO), como lo llama OpenGL.

Digamos que tengo los vértices (v1, v2, v3, v4, v5, v6), siendo los primeros tres los vértices del triángulo 1, y los últimos tres del triángulo 2. Digamos también que v2=v4 y v3=v5 ya que ambos triángulos son adyacentes. Bueno, acá hay al menos 2 vértices repetidos, o sea, 6 floats (6*4 bytes) desperdiciados.

Para no realizar ese desperdicio de datos tenemos el Index Buffer, donde se guarda un conjunto de índices que apuntan a vértices para formar un triángulo. Así, se necesitan 3 índices, mínimo, para formar un triángulo.

Entonces la modificación que hago respecto a la primera renderización de los dos triángulos es crear solo los 4 vértices que necesito, y con los índices apuntar a cada uno de los vértices para formar el triángulo 1 y el triángulo 2.

</div>

<div class="lang-en" markdown="1">

First, I just adapt the render to the window size. I do this in the main loop so that every time I resize the window the normalized OpenGL coordinates keep being mapped to new window sizes. I'm using `glViewport()` for that.

After that, I'm rendering an additional triangle that is adjacent to the first one. I'm doing this at the beginning by creating the 3 vertices of both triangles. After that I use an Index Buffer.

Say that we have the vertices (v1, v2, v3, v4, v5, v6), being the first three the triangle 1 vertices, and the last three the corresponding ones for the triangle 2. Additionally, we have v2=v4 and v3=v5, as both triangles are adjacent. So here we have 2 repeated vertices, that is, 6 wasted floats (6*4 bytes).

In order of not making this waste of data we have the Index Buffer, where we store a set of indices that point to vertices to build up a triangle.

So the change I do unlike the first two triangles render is to just creating the 4 vertices I need, and using the indices to point to each one of those to build both triangles.

</div>
