# Control de masas

`UnitStats.crowd_control` es una estadística porcentual independiente de Efectos.
Empieza en cero, se muestra en las estadísticas secundarias y no aparece en las
mejoras por nivel. Los ítems pueden modificarla con `add_stats_id = "crowd_control"`.

Cada punto aporta un 1% de potencia de control:

- Aumenta la fuerza del empuje normal y de Airbourne, no su daño de colisión.
- Aumenta la intensidad de las ralentizaciones, limitada a una reducción total.
- Aumenta la duración de las inmovilizaciones temporizadas. Las capturas ligadas
  a una animación, como el rallador, conservan su ciclo de ataque.

Efectos mantiene su comportamiento anterior. Sus modificadores de duración y los
modificadores específicos de empuje/ralentización se combinan con Control de masas.
Un bonus de Control de masas no modifica daño, radio ni velocidad de proyectiles.

Los impactos secundarios que copian una fuerza ya calculada no vuelven a aplicar
sus multiplicadores. Esto evita duplicar el bonus en explosiones.

La tag Control se reserva para Slow, Rooted y Airbourne. El empuje común no otorga
la tag, aunque esta estadística sigue aumentando su fuerza. Las tags son
consistentes entre los recursos de una misma arma.
