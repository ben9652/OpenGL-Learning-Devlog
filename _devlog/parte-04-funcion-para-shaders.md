---
title: "Separación de compilación de shaders"
title_en: "Separating shaders compilation"
part: 4
date: 2026-09-30
video_file: "parte-04.mp4"
linkedin: ""
---

<div class="lang-es" markdown="1">

En este video me dedico a poner en una sola función `BuildShaders()` la compilación de los shaders. Más adelante se realizarán mejoras, ordenando mejor las etapas, pero por ahora sirve separar esa funcionalidad, agregándola en un archivo de cabecera propio.

También se ve cómo reemplazo la variable que contiene el código fuente de los shaders por archivos directamente que leo desde esa nueva función. De esta manera me es más fácil escribirlos en archivos independientes.

Las partes 6, 7 y 8 seguirán siendo de organización del código para poder hacer más legible lo que hago y no crezcan demasiado los archivos.

Esto por ahora es aburrido, pero es parte del proceso para además aprender sobre mejores patrones de diseño y una arquitectura nueva para mí que implementaré en la parte 7.

La próxima parte será sobre index buffers, que es una manera más óptima de dibujar dos figuras con vértices en común.

</div>

<div class="lang-en" markdown="1">

Here I'm just separating shader compiling into an independent header file. Moving forward I'll be improving this way of doing it, splitting the process in clear independent stages.

Furthermore, you can see how I'm getting rid of the variable that stores the shader source code to put it into independent files. That way, it will be easier to write them.

Parts 6, 7 and 8 will keep consisting in code organization so that it is more readable and also I avoid very large files.

This is boring for now and not 100% focused on OpenGL, but I consider it important so that I learn about design patterns and a new architecture I'll be implementing in the 7th part.

The next part will be about Index Buffers: a way of optimize the drawing of two adjacent figures that share vertices.

</div>
