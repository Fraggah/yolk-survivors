# Último bocado (100)

Pasivo legendario disponible en tienda. Activo únicamente con vida positiva inferior al 25% del máximo. A partir del 25% se desactiva, sin duración fija ni cooldown de reactivación. Se comprueba inmediatamente ante cambios de vida, vida máxima y equipamiento.

- +50% a la fuerza final del empuje ordinario, incluyendo el empuje base del arma y la estadística plana de Empuje. No altera esa estadística plana ni Control de masas, Airbourne o tags.
- 50% menos cooldown de dash, aplicado después de la reducción plana de Guaraná. Cooldown mínimo 0,05 s.
- Cuando cambia la condición durante una recuperación, se conserva el porcentaje de recuperación completado: el tiempo restante se ajusta proporcionalmente en ambos sentidos.
- Las copias suman sus porcentajes: dos copias dan +100% de empuje y alcanzan el cooldown mínimo. Repetidas señales de vida no acumulan el efecto consigo mismo.
- Yema de oro aumenta el bonus de empuje y la reducción de cooldown. El umbral de vida permanece en 25%.

Parámetros editables `last_bite_health_threshold`, `last_bite_push_percent` y `last_bite_dash_reduction` en `resources/items/passives/catalogue/item_100.tres`.

Prueba: `tests/verify_last_bite.gd`.
