---
title: "Armando un entorno con CMake"
part: 1
date: 2026-09-17
video: "1. Armando un entorno con CMake"
linkedin: ""
---

<div class="lang-es" markdown="1">

Este es el primer paso que me impuse para empezar con este proyecto para aprendizaje de OpenGL: aprender CMake para armarme un entorno en el que pueda tener submódulos o cualquier tipo de capa de abstracción que se me ocurra, y así organizar mucho mejor el proyecto.

Lo que hago con el `CMakeLists.txt` del directorio raíz en particular es:

- Ubicar mi programa principal, y otros archivos relacionados a este, dentro de `src` y hacer que este tenga ejecutable.
- Tener un directorio de inclusión global en `include`.
- Armarme una librería de prueba `math` que sirva para experimentar lo de crear una librería estática a partir de un sub-módulo completo e independiente del proyecto principal.

En la instrucción `add_subdirectory()` debe incluirse un directorio que tenga un `CMakeLists.txt` dentro, heredando así todos los archivos fuente para compilar y los directorios de inclusión especificados en el archivo CMake.

Finalmente, hago una prueba usando ese sub-módulo, y termina el armado de mi entorno.

Nota aparte: otra cosa que me encanta de esta capa de personalización Omarchy en mi sistema operativo es que tiene una radio con música lofi y es eso lo que escuchan de fondo y con lo que programo, y posiblemente esté también en el resto de videos que suba.

</div>

<div class="lang-en" markdown="1">

This is the first step I set for myself to start with this learning project on OpenGL: learn CMake in order to build an environment with submodules or any kind of abstraction layer I come up with, organizing in a better way the project.

What I do with the root `CMakeLists.txt` is:

- Setting my main program and related files within the `src` directory and make it an executable.
- Having a global inclusion directory.
- Making myself a test library `math` that helps on trying out the creation of a static library from a full and independent sub-module.

In the instruction `add_subdirectory()` from the root CMake file you gotta specify a directory that has a `CMakeLists.txt` inside, inheriting that way all the source files and the include directories included in that last CMake file.

Lastly, I make a test using that sub-module, and I'm done with the environment.

Side note: another thing I love about this customization layer "Omarchy" in this OS is the fact that it has an already installed radio with lo-fi music and that's what you're hearing in the background and what I code with, and it'll be possibly included in the rest of the videos I upload.

</div>
