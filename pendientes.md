# Pendientes

## Producción

Implementados:

- Inspección Inicial.
- Raspado.
- Preparación.
- Reparación.
- Relleno.
- Corte de Banda.
- Embandado.
- Vulcanización.
- Inspección Final.
- Terminación.

Pendientes:

- Reportes imprimibles de salidas procesadas.
- Recosteo mensual de reencauchadas con costo/kg real.
- Formulario de traslados entre bodegas para actualizar `id_bodega_actual`
  conservando la bodega registrada en la salida original.

---

## Reprocesos

Pendiente crear catálogo:

motivos_reproceso

Objetivo:

Registrar causas codificadas para análisis estadístico.

---

## Consultas

### Modernizar consulta general de llantas

Pendiente reemplazar la tabla manual de la consulta general por una rejilla de
datos basada en **Tabulator**.

Objetivo:

- Reordenar columnas mediante arrastre.
- Mostrar u ocultar columnas segun la necesidad de cada usuario.
- Ajustar el ancho de columnas en tiempo real.
- Mantener visibles las columnas de identificacion importantes.
- Conservar la configuracion elegida por el usuario entre sesiones.
- Exportar a Excel solamente las columnas visibles, respetando su orden.

La consulta y sus filtros actuales se conservan; Tabulator solo reemplazara la
forma de presentar los resultados.

### Separar consultas, reportes y dashboards

Pendiente organizar estas tres clases de informacion para evitar mezclar
operacion diaria, documentos imprimibles y analisis:

- **Consultas:** tablas interactivas, filtros y exportacion de datos.
- **Reportes:** documentos de formato fijo para imprimir, firmar o entregar.
- **Dashboards:** indicadores y graficas para supervision de produccion.

Orden sugerido: modernizar la consulta general, crear el menu separado de
reportes y, cuando exista suficiente informacion real, construir dashboards.

Reporte:

Devueltas Sin Trabajar

Descripción:

Llantas rechazadas en Inspección Inicial.

---

Reporte:

Rechazos en Proceso

Descripción:

Llantas rechazadas en cualquier subproceso posterior.

Debe indicar:

- Llanta
- Subproceso
- Fecha
- Operario

---

## Mejoras futuras

- Dashboard de producción.
- Indicadores de rendimiento.
- Estadísticas por operario.
- Estadísticas por marca.
- Estadísticas por diseño.
- Estadísticas por resolución.
- Estadísticas de reproceso.
