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

- Reportes de salida procesada: implementadas las copias de Planta, Bodega,
  Facturacion completa y Facturacion simplificada.
- Recosteo mensual de reencauchadas con costo/kg real.
- Formulario de traslados entre bodegas para actualizar `id_bodega_actual`
  conservando la bodega registrada en la salida original.

### Salidas de rechazadas

Implementada la salida general de rechazadas de Planta a Bodega. Queda
pendiente la entrega individual desde Bodega al cliente, dentro de Ventas.

### Garantias

Pendiente implementar el ingreso y la evaluacion de garantias despues de que
la actualizacion de ventas permita identificar las llantas entregadas al
cliente. Las garantias usaran una tabla propia de ajustes sin alterar el
historial productivo actual de `llantas`.

---

## Reprocesos

Pendiente crear catálogo:

motivos_reproceso

Objetivo:

Registrar causas codificadas para análisis estadístico.

---

## Consultas

### Consulta general de llantas con Tabulator

Implementado el reemplazo de la tabla manual de la consulta general por una
rejilla de datos basada en **Tabulator**.

Incluye:

- Reordenar columnas mediante arrastre.
- Mostrar u ocultar columnas segun la necesidad de cada usuario.
- Ajustar el ancho de columnas en tiempo real.
- Mantener visibles las columnas de identificacion importantes.
- Conservar la configuracion elegida por el usuario entre sesiones.
- Exportar a Excel solamente las columnas visibles, respetando su orden.

La consulta y sus filtros actuales se conservan; Tabulator reemplaza solamente
la forma de presentar los resultados.

### Separar consultas, reportes y dashboards

Pendiente organizar estas tres clases de informacion para evitar mezclar
operacion diaria, documentos imprimibles y analisis:

- **Consultas:** tablas interactivas, filtros y exportacion de datos.
- **Reportes:** documentos de formato fijo para imprimir, firmar o entregar.
- **Dashboards:** indicadores y graficas para supervision de produccion.

Orden sugerido: crear el menu separado de reportes y, cuando exista suficiente
informacion real, construir dashboards.

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
