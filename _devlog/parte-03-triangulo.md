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

Para la preparación de los datos, primero se crea un Vertex Buffer Object (VBO), que es un objeto que vive globalmente en toda la aplicación OpenGL (todo aquí son objetos globales, y esta API es una máquina de estados finita) y es el encargado de almacenar datos de un vértice. Con `glGenBuffers()` se le dice a OpenGL que prepare algún espacio de memoria para luego yo mandarle datos, y se nos devuelve un ID de ese, o esos, buffers.

Con `glBindBuffer()` se ingresa el ID de un buffer ya generado para especificar que todo lo que se hará de aquí en adelante relacionado a operaciones con buffers se lo hará con el buffer del ID proporcionado.

Con `glBufferData()` finalmente se asocian los datos al buffer asociado con `glBindBuffer()`.

Existe en OpenGL también el concepto de Vertex Array Object (VAO), que es obligatorio en OpenGL moderno, y aquí se guarda el estado de todos los VBOs asociados actualmente, y otras especificaciones como una que daré más adelante. Estos se crean con `glGenVertexArrays()` y con `glBindVertexArray()` se especifica que todo lo relacionado que se haga de ahora en adelante se guardará en el VAO actual.

Con `glVertexAttribPointer()` se le enseña a OpenGL cómo debe interpretar los datos guardados en el VBO, y con `glEnableVertexAttribArray()` se habilita el atributo especificado con la función anterior, en este caso, el 0, que es la posición (ya que lo especificamos en el shader con `layout (location = 0)`). Realmente este índice puede ser cualquier atributo que se nos ocurra, pero yo decidí que 0 represente la posición. Esta información también se guarda en el VAO.

Finalmente en el bucle, se dibujan los datos especificados dentro del VAO habilitado y tenemos nuestro triángulo blanco (color que especifiqué en el Fragment Shader, como pueden ver con ese `vec4(1.0)`, que crea un vector de tamaño 4 con todos los elementos en 1, cuyas componentes son: Red, Green, Blue, y Alpha.

</div>

<div class="lang-en" markdown="1">

Finally, I'm going to do my first rendering! It's a simple white triangle.

In summary, to achieve this, a shader program has to be built, which we will just call "shader". This is a little program with a language very similar to C++ called GLSL (OpenGL Shading Language) that runs directly on the GPU, and our task is to pass it the data of the positions of the vertices that will form the triangle so that then, through a set of stages that form the OpenGL pipeline, it ends up rendering what corresponds according to the data provided. With these programs you can also take advantage of all the GPU power, since there matrix operations are done in parallel, for example.

A shader is composed, in an obligatory way, of two types of shaders that are then linked to form the program: vertex shader and fragment shader. The first one is in charge of processing the positions of the vertices, and the second one of the colors of those vertices. It's worth clarifying that in OpenGL a "vertex" is called an object that has a set of attributes: position, color, texture position or normal, for example.

For the preparation of the data, first a Vertex Buffer Object (VBO) is created, which is an object that lives globally in the whole OpenGL application (everything here are global objects, and this API is a finite state machine) and it's the one in charge of storing the data of a vertex. With `glGenBuffers()` you tell OpenGL to prepare some memory space to then send data to it, and we get back an ID of that, or those, buffers.

With `glBindBuffer()` you enter the ID of an already generated buffer to specify that everything that will be done from here on related to buffer operations will be done with the buffer of the provided ID.

With `glBufferData()` finally the data is associated to the buffer associated with `glBindBuffer()`.

There's also in OpenGL the concept of Vertex Array Object (VAO), which is obligatory in modern OpenGL, and here the state of all the VBOs currently associated is saved, and other specifications like one that I will give later. These are created with `glGenVertexArrays()` and with `glBindVertexArray()` you specify that everything related that is done from now on will be saved in the current VAO.

With `glVertexAttribPointer()` you teach OpenGL how it should interpret the data saved in the VBO, and with `glEnableVertexAttribArray()` the attribute specified with the previous function is enabled, in this case, the 0, which is the position (since we specified it in the shader with `layout (location = 0)`). Really this index can be any attribute that we come up with, but I decided that 0 represents the position. This information is also saved in the VAO.

Finally in the loop, the data specified inside the enabled VAO is drawn and we have our white triangle (color that I specified in the Fragment Shader, as you can see with that `vec4(1.0)`, which creates a vector of size 4 with all the elements in 1, whose components are: Red, Green, Blue, and Alpha.

</div>
