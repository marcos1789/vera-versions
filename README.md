# VERA · versiones

Archivo público que consultan los recursos VERA al arrancar el servidor para avisar en la consola de parches y actualizaciones. Solo se lee una vez por arranque; no envía ningún dato del servidor.

## Formato de `versions.json`

```json
{
  "schema": 1,
  "updated": "AAAA-MM-DD",
  "download": "https://keymaster.fivem.net",
  "changelog": "https://github.com/marcos1789/vera-versions#novedades",
  "resources": {
    "vera-qbox-keys": {
      "version": "0.9.2",
      "security": true,
      "notes": "Corrige un abuso de la ganzúa en coches NPC."
    }
  }
}
```

| Campo | Qué hace |
|---|---|
| `version` | Última versión publicada del recurso. |
| `security` | `true` si la versión corrige un fallo de seguridad: el banner la marca como **parche de seguridad recomendado**. |
| `notes` | Una línea en español con lo que cambia; sale en el banner bajo la tabla. |

Si la versión instalada es menor que `version`, el banner muestra **Actualización disponible** (o **Parche** si solo cambia el último número).

## Publicar una versión

1. Sube la versión nueva a Tebex.
2. Cambia `version` (y `notes`, y `security` si procede) del recurso en `versions.json`.
3. Actualiza `updated` y la sección *Novedades* de este archivo.

## Banner

`banner/vera_banner.lua` es el módulo común que lleva cada recurso VERA (copia idéntica en todos). `banner/test_banner.py` lo prueba simulando varios recursos.

## Novedades

- **2026-11-20** · vera-qbox-target 0.7.0: nueva interfaz Lens predeterminada, con marco sobre el objetivo y acciones en arco a su derecha; la clásica sigue disponible. Iconos SVG propios y `config.lua` editable.
- **2026-11-19** · vera-qbox-minigames 0.4.3: «ENTRADA» y «SALIDA» caben en su casilla; los símbolos ° y % se ven bien.
- **2026-11-19** · vera-qbox-minigames 0.4.2: licencia VERA definitiva y banner de consola al arrancar.
- **2026-11-19** · vera-qbox-chat 1.5.3, vera-qbox-hud 4.1.4 y vera-qbox-ui 1.2.4: el banner de consola vuelve a salir al arrancar el servidor.
- **2026-11-19** · vera-qbox-radialmenu 0.2.0 y vera-qbox-target 0.6.5: salir del maletero desde el menú radial, puertas desde fuera, extras, volcar coche y botón de emergencia.
- **2026-11-19** · Primera publicación: banner de consola común en todos los recursos VERA.
