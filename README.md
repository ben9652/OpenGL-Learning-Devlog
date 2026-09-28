# Ruta OpenGL desde cero — Devlog

Sitio estático (Jekyll + GitHub Pages) con el texto completo en español e inglés de cada parte de la serie.

## Estructura

```text
_config.yml            configuración del sitio
index.md               índice generado con la lista de partes
_layouts/              plantillas (default y post)
assets/css/style.css   tema oscuro
assets/img/            imágenes de los posts
assets/video/          videos de las partes (MP4 comprimido)
_devlog/               partes publicadas (una por archivo)
_drafts/               borradores (ignorados por git, no se publican)
```

## Escribir una parte nueva

1. Crear el borrador en `_drafts/parte-XX-tema.md` con este encabezado:

   ```yaml
   ---
   title: "Tema de la parte"
   title_en: "Part topic in English"
   part: X
   date: 2026-10-05
   video_file: "parte-XX.mp4"
   linkedin: ""
   ---
   ```

   El sitio usa `title` para español y `title_en` para inglés (título, pestaña y listado).

2. Escribir el contenido en dos bloques, uno por idioma (el selector de la página los alterna):

   ```html
   <div class="lang-es" markdown="1">

   Texto en español...

   </div>

   <div class="lang-en" markdown="1">

   Text in English...

   </div>
   ```
3. Para publicarla, mover el archivo a `_devlog/` y agregar el link de LinkedIn en `linkedin:`.
4. El índice se actualiza solo (recorre `_devlog` ordenado por `part`).

## Videos

El sitio arranca en inglés y el selector lo cambia todo a español; la elección se recuerda en el navegador.

Los videos se transcodifican a 1080p para que pesen poco y se muestran arriba del texto:

```bash
ffmpeg -i original.mp4 -vf "scale=1920:-2" -c:v libx264 -preset medium \
  -crf 24 -pix_fmt yuv420p -c:a aac -b:a 128k -movflags +faststart \
  assets/video/parte-XX.mp4
```

Cada parte lo referencia en su front matter con `video_file: "parte-XX.mp4"`.

## Imágenes

Subirlas a `assets/img/` y referenciarlas así:

```markdown
![Descripción]({{ '/assets/img/archivo.png' | relative_url }})
```

## Previsualización local

En Arch/CachyOS, Ruby trae separadas algunas gemas por defecto. Instalar Jekyll y las que faltan:

```bash
gem install --user-install jekyll erb webrick
```

Agregar los binarios de gemas al PATH (una vez, en `~/.bashrc`):

```bash
export PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"
```

Levantar el sitio, incluyendo los borradores de `_drafts/`:

```bash
jekyll serve --drafts
```

Se ve en `http://localhost:4000/` más el `baseurl` configurado.

## Publicar en GitHub Pages

1. Crear un repositorio **público** cuyo nombre coincida con `baseurl` en `_config.yml`.
2. Editar `_config.yml`: `url` debe ser `https://TU-USUARIO.github.io`.
3. Inicializar git, commitear y subir el contenido (GitHub te da los comandos exactos al crear el repositorio).
4. En el repo: **Settings → Pages → Deploy from a branch → master / (root) → Save**.
5. Esperar un minuto y abrir la URL que GitHub Pages indique.

## Enlazar desde LinkedIn

Cada parte queda en la URL del sitio más `devlog/parte-XX-tema/`.
Ese es el link que va en el primer comentario de la publicación.
