# Música

En `scenes/arena/arena.tscn`, seleccionar **MusicManager → Music**:

- **Menu Music**: track fijo para inicio, selección, opciones, créditos y resultados.
- **Shop Music**: track fijo para la tienda y las recompensas entre oleadas.
- **Wave Music Tracks**: lista de música de combate normal.
- **Boss Music Tracks**: lista independiente para bosses, incluida la prueba aislada.

Un elemento en una lista fuerza ese track; varios sortean uno al comenzar la oleada. Las entradas vacías se ignoran. La música de menú y tienda nunca se sortea.

Para una excepción, asignar **Music Tracks** al recurso de la oleada (`resources/wave/data/wave_XX.tres`) o de la arena (`resources/environments/stages/`). Prioridad: oleada → arena → lista de oleadas o bosses del MusicManager. Una lista vacía hereda la siguiente; si no hay ningún track válido, queda en silencio.

Por ahora los cuatro valores generales usan el track existente como provisional; reemplazarlos por los nuevos audios desde el inspector. No es necesario cambiar código. El ambiente de cocina continúa separado y solo acompaña el combate.

El nodo MusicManager reproduce la música por el bus Music, respetando su volumen y la pausa. No reinicia si se pide el mismo audio al cambiar de pantalla y repite los tracks aunque el archivo importado no tenga loop habilitado. El volumen propio del nodo permanece en la escena.
