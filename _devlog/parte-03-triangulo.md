---
title: "Triángulo"
title_en: "Triangle"
part: 3
date: 2026-09-28
video_file: "parte-03.mp4"
linkedin: ""
---

<div class="lang-es" markdown="1">

¡Finalmente voy a hacer la primera renderización! Es un simple triángulo blanco.

En resumen, para lograr esto se tiene que armar un programa shader obligatoriamente, que llamaremos simplemente "shader". Este es un programita con un lenguaje muy parecido a C++ llamado GLSL (OpenGL Shading Language) que se ejecuta directamente en la GPU, y nuestra tarea es pasarle los datos de las posiciones de los vértices que conformarán el triángulo para que luego, mediante un conjunto de etapas que conforman el pipeline de OpenGL, se termine renderizando lo que corresponde según los datos provistos. Con estos programas además se puede aprovechar todo el poder de la GPU, ya que ahí se realizan operaciones matriciales de forma paralela, por ejemplo.

Un shader está compuesto, de manera obligatoria, por dos tipos de shaders que luego se enlazan para conformar el programa: vertex shader y fragment shader. El primero se encarga de procesar las posiciones de los vértices, y el segundo de los colores de esos vértices. Cabe aclarar que en OpenGL se le llama "vértice" a un objeto que tiene un conjunto de atributos: posición, color, posición de textura o normal, por ejemplo.

Para la preparación de los datos, que en este caso simplemente serán los vértices del triángulo, primero se crea un Vertex Buffer Object (VBO), un objeto que vive globalmente en toda la aplicación OpenGL (todo aquí son objetos globales, y esta API es una máquina de estados finita) y es el encargado de almacenar datos de un vértice. Con `glGenBuffers()` se le dice a OpenGL que prepare algún espacio de memoria para luego yo mandarle datos, y se nos devuelve un ID de ese, o esos, buffers. En este caso es solo uno.

Cabe aclarar por qué las posiciones tienen esas coordenadas, y es que el espacio disponible en OpenGL conforma un sistema de coordenadas con rango [-1.0,1.0], tanto en el eje X como en el eje Y, y en el Z. ¿Cómo se hace entonces para usar cualquier tipo de resolución que tengamos en pantalla? Se configura el llamado "viewport" en OpenGL con la función `glViewport()` para que que el punto extremo derecho 1.0, por ejemplo, sea el extremo derecho del viewport configurado. Esto NO significa que ahora nuestro sistema de coordenadas cambió, sino que ahora las renderizaciones saldrán deformadas pero adaptadas al tamaño de la ventana. Para efectivamente tener un nuevo sistema de coordenadas, se debe realizar una transformación ortogonal sobre todos nuestros vértices. Pero ello es para después.

Siguiendo, con `glBindBuffer()` se ingresa el ID de un buffer ya generado para especificar que todo lo que se hará de aquí en adelante relacionado a operaciones con buffers se lo hará con el buffer del ID proporcionado.

Con `glBufferData()` finalmente se asocian los datos que tengo en el arreglo `triangle_positions` al buffer asociado con `glBindBuffer()`.

Existe en OpenGL también el concepto de Vertex Array Object (VAO), que es obligatorio en OpenGL moderno, y aquí se guarda el estado de todos los VBOs asociados actualmente, y otras especificaciones como una que daré más adelante. Estos se crean con `glGenVertexArrays()` y con `glBindVertexArray()` se especifica que todo lo relacionado que se haga de ahora en adelante se guardará en el VAO actual.

Con `glVertexAttribPointer()` se le enseña a OpenGL cómo debe interpretar los datos guardados en el VBO, y con `glEnableVertexAttribArray()` se habilita el atributo especificado con la función anterior, en este caso, el 0, que es la posición (ya que lo especificamos en el shader con `layout (location = 0)`). Realmente este índice puede ser cualquier atributo que se nos ocurra, pero yo decidí que 0 represente la posición. Esta información también se guarda en el VAO.

Finalmente en el bucle, se dibujan los datos especificados dentro del VAO habilitado y tenemos nuestro triángulo blanco (color que especifiqué en el Fragment Shader, como pueden ver con ese `vec4(1.0)`, que crea un vector de tamaño 4 con todos los elementos en 1, cuyas componentes son: Red, Green, Blue, y Alpha.

Un pequeño detalle del que me perdí mientras escribía el código es el hecho de que podría haber disociado el VAO antes de disociar el VBO justo antes de entrar al bucle. Luego dentro del bucle habría bastado con asociar el VAO antes de llamar a la función de dibujado. Sinceramente, no sabía qué estaba haciendo hasta ahora, que reforcé el concepto del Vertex Array Object y cómo funciona.

El VAO puede ser asociado también justo antes de comenzar el bucle, por supuesto. Pero normalmente se lo hace cada vez que se itera, y antes de llamar a la función de dibujado, porque en un motor real no tenemos un solo VAO para pintar, sino muchos de ellos esperando su turno. Por lo que lo correcto es asociar el VAO deseado antes del `glDrawArrays()`.

</div>

<div class="lang-en" markdown="1">

Finally, I'm going to do my first rendering! It's a simple white triangle.

In summary, to achieve this, a shader program has to be built, which we will just call "shader". This is a little program with a language very similar to C++ called GLSL (OpenGL Shading Language) that runs directly on the GPU, and our task is to pass it the position data of the vertices that will form the triangle so that then, through a set of stages that form the OpenGL pipeline, it ends up rendering what corresponds according to the provided data. With these programs you can also take advantage of all the GPU power, since matrix operations are done in parallel, for example.

A shader is imperatively composed of two types of shaders that are then linked to build the program: vertex shader and fragment shader. The first one is in charge of processing the positions of the vertices, and the second one the colors of those vertices. It's worth clarifying that in OpenGL a "vertex" is called an object that has a set of attributes: position, color, texture position or normal, for example.

For the sake of data preparing, which in this case are the triangle vertex positions, a Vertex Buffer Object (VBO) is created first, an object that lives globally in the whole OpenGL application (everything here are global objects, and this API is a finite state machine) and it's the one in charge of storing the data of a vertex. With `glGenBuffers()` you tell OpenGL to prepare some memory space to then send data to it, and we get back an ID of that buffer.

It's worth clarifying why the positions have those coordinates. The available space in OpenGL makes a coordinate system with the range [-1.0,1.0] in the three axes. How do we use any resolution we desire in our window then? We configure the OpenGL _viewport_ with the function `glViewport()` so that the right end x=1.0 will be the configured viewport right end, for instance. This DOESN'T mean that our coordinates system changed, but that the renders will may now be deformed but adapted to the window size. For a truly new coordinate system, we have to apply an orthogonal transformation over all our vertices. But, we'll see that later.

Going back with the data, with `glBindBuffer()` you pass the ID of an already generated buffer to specify that everything that will be done from now on related to buffer operations will be done with the buffer of the provided ID.

With `glBufferData()` the data from `triangle_positions` is finally associated to the buffer bound with `glBindBuffer()`.

In OpenGL we have the concept of Vertex Array Object (VAO), which is mandatory in modern OpenGL, and here the state of all the currently bound VBOs is saved, and other specifications like one that I will explain below. These are created with `glGenVertexArrays()` and with `glBindVertexArray()` you specify that everything related that is done from now on will be saved in the current VAO.

With `glVertexAttribPointer()` you teach OpenGL how it should interpret the data saved in the VBO, and with `glEnableVertexAttribArray()` the first attribute specified with the previous function is enabled, in this case, 0, which is the position (since we specified it in the shader with `layout (location = 0)`). Honestly, this index can be any attribute that we come up with, but I decided that 0 represents the position. This information is also saved in the VAO.

Finally in the loop, the data specified within the enabled VAO is drawn and we have our white triangle, color that I specified in the Fragment Shader, as you can see with that `vec4(1.0)`, which creates a vector of size 4 with all the elements in 1, whose components are: Red, Green, Blue, and Alpha.

One small detail that I missed in the code is that I could have just unbind the VAO before unbinding the VBO right before starting the loop. Then in the loop, it could have been enough to just bind the VAO before calling the draw function. Honestly, I didn't know what I was doing until now, that I re-enforced the concept of the Vertex Array Object.

The VAO can be bound right before starting the loop, of course. But we normally do it every time the loop iterates because in a real engine we don't have just one VAO to draw, but many of them waiting to be drawn. So the right approach is binding the desired VAO right before calling `glDrawArrays()`.

</div>
