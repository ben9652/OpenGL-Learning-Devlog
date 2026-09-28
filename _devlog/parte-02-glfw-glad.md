---
title: "GLFW y GLAD"
title_en: "GLFW and GLAD"
part: 2
date: 2026-09-20
video: "2. Importo GLFW y GLAD"
linkedin: ""
---

<div class="lang-es" markdown="1">

Aquí me dedico solamente a importar GLFW, que, tal y como lo define su sitio web oficial, es una librería para desarrollo para escritorio de OpenGL (pero sirve para Vulkan también). Ofrece una API simple para crear ventanas y contextos, ofreciendo funciones también para dispositivos de entrada y eventos.

También importo GLAD, que sirve para cargar e inicializar las funciones de OpenGL en tiempo de ejecución.

Luego de cargarlas, hago un simple test en el bucle principal del programa especificando distintos colores en la función `glClearColor()` y finalmente con `glClear(GL_COLOR_BUFFER_BIT)` se configuran los bits de los colores previamente determinados con la otra función para que el conjunto de los 3 colores especificados (más el alpha 1.0, que no hace mucho por ahora porque es algo más avanzado) se haga efectivo en pantalla.

</div>

<div class="lang-en" markdown="1">

Here I just import GLFW which is, as its website tells us, a library for OpenGL and Vulkan development in the desktop. It provides a simple API for creating windows, contexts and surfaces, receiving input and events.

Also, I'm importing GLAD, that loads and initializes the OpenGL functions at runtime.

After loading them, I perform just a simple test in the main loop specifying some colors in the function `glClearColor()` and lastly with `glClear(GL_COLOR_BUFFER_BIT)` I set the bitplane area of the window to the values previously selected by `glClearColor()`.

</div>
