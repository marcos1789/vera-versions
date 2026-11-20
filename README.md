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

- **2026-11-21** · vera-qbox-phone 0.2.0: grupos de mensajes, borrar y buscar mensajes, compartir contactos, llamada en espera, buzón de voz y mensajes de voz, tonos de llamada, el móvil suena para los de alrededor, no molestar y bloquear números, app Reloj, linterna, bloqueo muerto o esposado, móvil mojado opcional, auricular propio en las cabinas e inglés.
- **2026-11-20** · vera-qbox-phone 0.1.0: primera versión del móvil VERA. Estilo iOS con viñetas para llamadas y avisos, llamadas con voz, mensajes con fotos, cámara y galería, PIN, móvil como objeto (robo y restaurar), dos móviles a la vez, cabinas con número fijo, emergencias con ubicación y API para apps de otros recursos.
- **2026-11-20** · vera-qbox-banking 0.8.0 (seguridad): revisión completa. Corrige fallos de seguridad y de dinero, funciona solo con `qbx_core` y `oxmysql`, empeño de vehículo como garantía, banca móvil preparada, facturas, impuestos, órdenes policiales, atracos, cheques y extracto impreso, hipotecas, bolsa simulada, inglés y sucursales configurables para MLO.
- **2026-11-20** · vera-qbox-inventory 1.7.15: tarjetas bancarias nuevas para los cinco bancos de GTA V.
- **2026-11-20** · vera-qbox-chat 1.5.4, vera-qbox-hud 4.1.5, vera-qbox-ui 1.2.5, vera-qbox-minigames 0.5.1 y vera-qbox-keys 0.10.1: el banner de consola vuelve a salir aunque el servidor tenga la carpeta original de `qbx_radialmenu` u otro recurso con `provide`.
- **2026-11-20** · vera-qbox-target 0.8.0: solo necesita `ox_lib` y `qbx_core`; los demás recursos son integraciones opcionales en el config. Textos editables en `shared/texts.lua` y opción `LensFrame` para quitar el cuadro de Lens.
- **2026-11-20** · vera-qbox-target 0.7.0: nueva interfaz Lens predeterminada, con marco sobre el objetivo y acciones en arco a su derecha; la clásica sigue disponible. Iconos SVG propios y `config.lua` editable.
- **2026-11-19** · vera-qbox-minigames 0.4.3: «ENTRADA» y «SALIDA» caben en su casilla; los símbolos ° y % se ven bien.
- **2026-11-19** · vera-qbox-minigames 0.4.2: licencia VERA definitiva y banner de consola al arrancar.
- **2026-11-19** · vera-qbox-chat 1.5.3, vera-qbox-hud 4.1.4 y vera-qbox-ui 1.2.4: el banner de consola vuelve a salir al arrancar el servidor.
- **2026-11-19** · vera-qbox-radialmenu 0.2.0 y vera-qbox-target 0.6.5: salir del maletero desde el menú radial, puertas desde fuera, extras, volcar coche y botón de emergencia.
- **2026-11-19** · Primera publicación: banner de consola común en todos los recursos VERA.
