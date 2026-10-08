---
title: "Creando arquitectura en capas"
title_en: "Implementing layer architecture"
part: 6
date: 2026-10-08
video_file: "parte-06.mp4"
linkedin: ""
---

<div class="lang-es" markdown="1">

Decidí omitir la organización en diferentes funciones la compilación de los shaders. Realmente no aporta nada a esta serie de videos.

Para esta parte me estudié previamente una arquitectura típica en cualquier renderizador, y es la separación en capas de distintas renderizaciones. Esto me va a simplificar el código así no tengo que perderme en archivos largos. Además, me sirve como base para luego armar diferentes ejemplos de renderizaciones individuales.

La idea central es poder agregar a voluntad "capas" al motor. Capas que se comportan de la manera que uno quiera, definiendo una serie de funciones:
 - on\_attach(): función para inicializar la capa.
 - on\_events(): captura de eventos, como un tecleo, un movimiento de mouse, o un click.
 - on\_update(): actualiza la geometría.
 - on\_render(): renderiza la nueva geometría.
 - on\_detach(): desasigna los recursos de la capa.

Estas capas pueden ser cualquier cosa que se nos ocurra: una capa de la UI de un juego, un conjunto determinado de objetos que cumplen una función particular, algo de un sistema de audio, una animación, o lo que sea que intervenga en un motor gráfico. Luego seguro que haré más compleja esta arquitectura ya que las capas puede que tengan datos, puede que se puedan deshabilitar, o se deba medir el tiempo para una renderización animada.

Para un ejemplo simple, en mi función `main()` añado dos capas: una para renderizar un rectángulo y otra para los dos triángulos que rendericé en el video anterior. Así, tengo qué se hace en la renderización del rectángulo y en la de los triángulos de una manera totalmente modular y más legible.

</div>

<div class="lang-en" markdown="1">

I decided to skip the shader compilation rethinking. It really doesn't sum to this videos series.

For this part I previously studied a typical architecture used in any renderer, and that is the split of each render in individual layers. This will make things simpler when coding new features so that I don't miss in large files. Furthermore, it'll be useful as a solid codebase to then build different render examples.

The idea is having the ability of adding "layers" to the engine, and these behaving whatever we want to by defining some functions:
  - on\_attach(): function to initialize the layer.
  - on\_events(): captures events.
  - on\_update(): updates geometry.
  - on\_render(): renders new geometry.
  - on\_detach(): deallocates layer resources.

These layers may be anything we come up with: an UI from a game, a set of objects that have a particular behavior, an audio system, an animation, or whatever that we could have in a graphics engine. I'll make this architecture more complex for sure as these layers may have some data, it may be necessary to enable or disable them, and we'll need to measure time for an animated rendering.

To show the simplicity that this architecture gives us, I added two layers in my main function: one being for rendering a rectangle and the other one for the two triangles I've rendered in the prior video. That way, I break down into small pieces the behavior of each one of the drawings.

</div>
