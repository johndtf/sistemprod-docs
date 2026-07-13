# Reglas de negocio

## Estado inicial

Toda llanta ingresada al sistema debe quedar:

Estado = PENDIENTE

---

## Inspección inicial

Resultado posible:

- Apta
- Rechazada

Si la resolución corresponde a:

id_resolucion = 1

La llanta queda:

Estado = APTA

Si la resolución corresponde a cualquier código de rechazo distinto de 0 y 1:

Estado = RECHAZADA

---

## Raspado

Solo pueden ingresar a Raspado las llantas que:

- Tengan estado `APTA` (`id_estado = 1`).
- Tengan una Inspección Inicial aprobada en la tabla `procesos`.

Cada ejecución registra:

- Radio de raspado.
- Perímetro.
- Ancho.
- Retiro de cinturón.
- Operario activo.
- Fecha del proceso y fecha de registro.

La tabla `llantas` conserva los últimos valores de raspado. La tabla `procesos`
conserva una copia de los valores de cada ejecución para mantener la trazabilidad.

Cuando una llanta repite Raspado, no se modifica el registro histórico anterior:
se crea un nuevo registro con `id_subproceso = 2` y `reproceso = 1`.

### Resultado apto

- La llanta conserva el estado `APTA`.
- Se registra `id_resolucion = 1` e `id_estado_resultado = 1`.

### Rechazo durante raspado

- Se utilizan los motivos del catálogo `resoluciones_i`, excepto PENDIENTE y APTA.
- La llanta pasa a estado `RECHAZADA` (`id_estado = 2`).
- Se registra una nueva fila en `procesos` con `id_subproceso = 2`.

El subproceso registrado permite distinguir este rechazo de una devolución sin
trabajar, la cual ocurre durante la Inspección Inicial.

### Operarios

Solo los empleados con estado `A` pueden ser seleccionados como operarios de
Raspado.

---

## Preparación

Escariado forma parte de Preparación y no se registra como un subproceso
independiente.

Solo pueden ingresar a Preparación las llantas que:

- Tengan estado `APTA` (`id_estado = 1`).
- Tengan un Raspado aprobado en la tabla `procesos`.

Preparación no genera mediciones propias. Cada ejecución registra:

- Operario activo.
- Fecha del proceso y fecha de registro.
- Resolución y estado resultante.
- Observación cuando se rechaza la llanta.

La tabla `llantas` conserva los datos de la última Preparación. La tabla
`procesos` conserva todas las ejecuciones con `id_subproceso = 3`.

Cuando una llanta repite Preparación, no se modifica el registro anterior: se
crea uno nuevo con `reproceso = 1`.

### Resultado apto

- La llanta conserva el estado `APTA`.
- Se registra `id_resolucion = 1` e `id_estado_resultado = 1`.

### Rechazo durante preparación

- Se usan los motivos de `resoluciones_i`, excepto PENDIENTE y APTA.
- La llanta pasa a estado `RECHAZADA` (`id_estado = 2`).
- Se agrega una fila en `procesos` con `id_subproceso = 3`.

### Operarios

Solo los empleados con estado `A` pueden seleccionarse. El backend vuelve a
validar su estado al guardar el proceso.

---

## Reparación

Reparación es un subproceso opcional. Una llanta que no necesite parches no crea
un registro de Reparación en `procesos`.

Puede ingresar a Reparación cualquier llanta con estado `APTA`; no es obligatorio
que tenga Raspado o Preparación. Esto permite que un reproceso requiera solamente
Inspección Inicial y Reparación.

Una Reparación aprobada debe registrar al menos una referencia y una cantidad
entera positiva. Una referencia no puede repetirse dentro de la misma ejecución.
Para cambiarla en el formulario se sustrae y se adiciona nuevamente antes de
actualizar.

Cada ejecución crea una fila en `procesos` con `id_subproceso = 4`. Sus parches
se guardan en `reparaciones_proceso` usando el `id_proceso` recién creado. Cuando
se repite el subproceso, se crea otra fila con `reproceso = 1`.

### Resultado apto

- La llanta conserva el estado `APTA`.
- Se registra la resolución APTA y los parches utilizados.

### Rechazo durante reparación

- Usa los motivos de `resoluciones_i`, excepto PENDIENTE y APTA.
- Cambia la llanta a `RECHAZADA`.
- Puede registrarse sin parches.

La tabla `llantas` conserva únicamente la última fecha, fecha de registro,
operario y resolución de Reparación. El ingreso exclusivo para reparación se
definirá posteriormente como un flujo especial.

---

## Relleno

Solo pueden ingresar a Relleno las llantas que:

- Esten en estado `APTA`.
- Tengan una Preparacion aprobada en `procesos`.

Reparacion es opcional. Para la ayuda de secado, si la llanta tiene Reparacion
aprobada se calcula la diferencia desde la fecha de Reparacion; si no tiene
Reparacion, se calcula desde la fecha de Preparacion.

El tiempo minimo de secado no queda fijo en codigo. Se consulta desde
`parametros_planta`, mediante el parametro
`tiempo_secado_relleno_minutos`, porque depende de condiciones de cada planta.

El formulario muestra:

- Fecha y hora de Preparacion.
- Fecha y hora de Reparacion, si existe.
- Fecha y hora actual.
- Diferencia en minutos.

La diferencia es una ayuda visual. El boton de registro no se bloquea por esta
regla.

Cada ejecucion crea una fila en `procesos` con `id_subproceso = 5`. Si se repite
el subproceso, se crea otra fila con `reproceso = 1`.

### Rechazo durante relleno

- Usa los motivos de `resoluciones_i`, excepto PENDIENTE y APTA.
- Cambia la llanta a `RECHAZADA`.

La tabla `llantas` conserva unicamente la ultima fecha, fecha de registro,
operario y resolucion de Relleno.

---

## Corte de Banda

Corte de Banda es una operacion por lote. No se busca una sola llanta para
registrar datos propios; el formulario muestra las llantas pendientes de cortar
su banda.

Una llanta aparece pendiente cuando:

- Esta en estado `APTA`.
- Tiene un Raspado aprobado en `procesos`.
- No tiene un Corte aprobado posterior a ese ultimo Raspado.

El formulario muestra:

- Tiquete.
- Orden.
- Diseno o banda definido en la orden.
- Ancho registrado en Raspado.
- Largo tomado del perimetro registrado en Raspado.
- Dimension.
- Fecha/hora de Raspado.
- Minutos transcurridos desde el registro de Raspado.

Antes de actualizar las bandas, se debe seleccionar:

- Operario activo que realiza el corte.
- Fecha y hora del corte.

El ordenamiento operativo permite:

- Ordenar por banda/diseno y ancho, para cortar varias bandas iguales.
- Ordenar por tiempo transcurrido desde Raspado, para priorizar las llantas que
  llevan mas tiempo esperando corte.

Al marcar las casillas y usar `Actualizar bandas`, cada llanta seleccionada:

- No modifica el estado actual de la llanta.
- No modifica ni registra una resolucion de la llanta.
- Registra operario, fecha de corte y fecha de registro.
- Crea una fila en `procesos` con `id_subproceso = 6`.
- Actualiza en `llantas` la ultima fecha, fecha de registro y operario de
  Corte.

Si una llanta repite Corte de Banda, se crea una nueva fila en `procesos` con
`reproceso = 1`.

### Deshacer corte

Si una banda fue marcada como cortada por error, se puede buscar por tiquete y
usar `Deshacer corte`.

La operacion elimina el ultimo registro de Corte de Banda y restaura en
`llantas` el corte anterior si existia. Si no existia, deja los campos de Corte
en `NULL`.

No se permite deshacer cuando la llanta ya tiene procesos posteriores al Corte,
porque se romperia la trazabilidad.

### Reproceso de corte

El mismo resultado de busqueda permite registrar un reproceso de Corte. Esta
accion crea una nueva fila en `procesos` con `reproceso = 1` y actualiza la
informacion vigente en `llantas`.

El reproceso tambien requiere operario activo y fecha/hora del nuevo corte.

No se permite reprocesar Corte si la llanta ya tiene procesos posteriores al
ultimo Corte registrado.

---

## Embandado

Solo pueden ingresar a Embandado las llantas que:

- Esten en estado `APTA`.
- Tengan Relleno aprobado en `procesos`.
- Tengan Corte de Banda registrado despues del ultimo Relleno aprobado.

Si el Corte de Banda fue deshecho, la llanta vuelve a quedar pendiente de Corte
y no puede ingresar a Embandado.

Embandado no tiene datos tecnicos propios. El formulario muestra informacion
contextual para verificar la llanta antes de registrar:

- Tiquete.
- Orden.
- Cliente.
- Marca.
- Dimension.
- Diseno o banda.
- Serie.
- Estado.
- Nivel de reencauche.
- Ancho.
- Largo tomado del perimetro.
- Fecha y hora del ultimo Corte de Banda.
- Fecha y hora actual.
- Diferencia en minutos desde el Corte de Banda.
- Operario que realizo el Corte de Banda.

El tiempo minimo de secado usa el mismo parametro de planta de Relleno:
`tiempo_secado_relleno_minutos`.

La diferencia de secado es una ayuda visual. El boton de registro no se bloquea
por esta regla.

Cada ejecucion aprobada crea una fila en `procesos` con `id_subproceso = 7` y
mantiene la llanta en estado `APTA`. Si el subproceso se repite, se crea otra
fila con `reproceso = 1`.

### Rechazo durante embandado

- Usa los motivos de `resoluciones_i`, excepto PENDIENTE y APTA.
- Cambia la llanta a `RECHAZADA`.
- Registra una fila en `procesos` con `id_subproceso = 7`.

La tabla `llantas` conserva unicamente la ultima fecha, fecha de registro,
operario y resolucion de Embandado.

---

## Vulcanizado

Solo pueden ingresar a Vulcanizado las llantas que:

- Esten en estado `APTA`.
- Tengan Embandado aprobado en `procesos`.

Vulcanizado no tiene datos tecnicos propios ni control de tiempo previo. El
formulario muestra informacion contextual de la llanta para confirmar que se
esta registrando el tiquete correcto.

Cada ejecucion aprobada:

- Mantiene la llanta en estado `APTA`.
- Registra `id_resolucion = 1` e `id_estado_resultado = 1`.
- Crea una fila en `procesos` con `id_subproceso = 8`.
- Actualiza en `llantas` la ultima fecha, fecha de registro, operario y
  resolucion de Vulcanizado.

Si el subproceso se repite, se crea otra fila en `procesos` con
`reproceso = 1`.

### Rechazo durante vulcanizado

- Usa los motivos de `resoluciones_i`, excepto PENDIENTE y APTA.
- Cambia la llanta a `RECHAZADA`.
- Registra una fila en `procesos` con `id_subproceso = 8`.

---

## Inspeccion Final

Solo pueden ingresar a Inspeccion Final las llantas que:

- Tengan Vulcanizado aprobado en `procesos`.
- Esten en estado `APTA`, `REPARADA` o `REENCAUCHADA`.
- No tengan Terminacion registrada.

Inspeccion Final registra:

- Inspector activo.
- Fecha y hora de inspeccion.
- Resultado final: `Reencauchada` o `Reparada`.

Una llanta marcada como `Reencauchada` queda con estado `REENCAUCHADA`.
Una llanta marcada como `Reparada` queda con estado `REPARADA`; este caso aplica
a llantas que ingresaron solamente para reparacion y pasan por Inspeccion
Inicial, Reparacion, Vulcanizacion y Terminacion.

Tanto las llantas `REENCAUCHADAS` como las `REPARADAS` salen hacia Terminacion.

Cada ejecucion crea una fila en `procesos` con `id_subproceso = 9`. Si se repite
la Inspeccion Final antes de Terminacion, se crea otra fila con `reproceso = 1`.

### Rechazo durante inspeccion final

- Usa los motivos de `resoluciones_i`, excepto PENDIENTE y APTA.
- Cambia la llanta a `RECHAZADA`.
- Registra una fila en `procesos` con `id_subproceso = 9`.

### Deshacer inspeccion final

Se permite deshacer la ultima Inspeccion Final siempre que la llanta no tenga
Terminacion registrada. Al deshacer, se elimina la ultima fila de
`id_subproceso = 9` y se restaura en `llantas` el resultado anterior. Si no hay
una inspeccion final anterior, la llanta vuelve a estado `APTA`.

---

## Terminacion

Solo pueden ingresar a Terminacion las llantas que:

- Tengan Inspeccion Final aprobada en `procesos`.
- Esten en estado `REPARADA` o `REENCAUCHADA`.

Terminacion no tiene datos tecnicos propios. Registra:

- Operario activo.
- Fecha y hora de terminacion.
- Resolucion y estado resultante.

Un registro aprobado conserva el estado vigente de la llanta:

- Si llega `REPARADA`, queda `REPARADA`.
- Si llega `REENCAUCHADA`, queda `REENCAUCHADA`.

Cada ejecucion crea una fila en `procesos` con `id_subproceso = 10`. Si se
repite Terminacion, se crea otra fila con `reproceso = 1`.

### Rechazo durante terminacion

- Usa los motivos de `resoluciones_i`, excepto PENDIENTE y APTA.
- Cambia la llanta a `RECHAZADA`.
- Registra una fila en `procesos` con `id_subproceso = 10`.

---

# Costeo de Reencauchadas

## Peso promedio de banda

El costo de una llanta reencauchada se calculara usando el peso promedio de la
banda procesada para su combinacion de dimension y diseno.

El catalogo `pesos_banda` debe contener una fila por cada combinacion:

- dimension
- diseno
- peso promedio de banda en kg

Cuando se implemente la salida de llantas reencauchadas, el sistema debera
buscar esta combinacion antes de permitir la salida. Si no existe, debe informar
al usuario para que calcule el peso promedio, cree el registro en el catalogo y
repita la salida.

Las llantas reparadas no se costean con este catalogo por ahora. Su costeo se
definira posteriormente, probablemente con base en tipo y cantidad de
reparaciones usadas.

---

# Nivel de Reencauche

## Definición

El campo `nivel_reenc` representa el nivel de reencauche que se pretende realizar sobre una llanta al momento de ingresar al proceso.

No representa la cantidad de reencauches efectivamente realizados.

---

## Valores válidos

- 1 = Primer reencauche
- 2 = Segundo reencauche
- 3 = Tercer reencauche
- N = N-ésimo reencauche

No se permiten valores negativos.

No se utiliza el valor 0.

---

## Relación con la inspección inicial

El valor de `nivel_reenc` debe registrarse independientemente del resultado de la inspección inicial.

Una llanta puede ser rechazada durante la inspección inicial y conservar el nivel de reencauche para el cual fue presentada.

### Ejemplos

| Situación                                             | Nivel Reencauche | Estado  |
| ----------------------------------------------------- | ---------------- | ------- |
| Llanta presentada para primer reencauche y aprobada   | 1                | APTA    |
| Llanta presentada para primer reencauche y rechazada  | 1                | RECHAZO |
| Llanta presentada para segundo reencauche y aprobada  | 2                | APTA    |
| Llanta presentada para segundo reencauche y rechazada | 2                | RECHAZO |

---

## Justificación

El rechazo de una llanta es una condición del proceso y no modifica el nivel de reencauche solicitado.

La información de rechazo se encuentra registrada mediante:

- `id_inspec`
- `estado`

Por lo tanto, no es necesario utilizar valores especiales en `nivel_reenc` para indicar rechazos.

---

## Ventajas

Este criterio permite generar estadísticas como:

- Cantidad de llantas recibidas para primer reencauche.
- Cantidad de llantas recibidas para segundo reencauche.
- Rechazos por nivel de reencauche.
- Tasa de aprobación por nivel.
- Históricos de producción.

---

## Implementación

### Frontend

- Valor por defecto: `1`.
- Solo se permiten números enteros positivos.

### Backend

Validar que:

- Sea un número entero.
- Sea mayor o igual a 1.

### Base de Datos

```sql
nivel_reenc TINYINT UNSIGNED NOT NULL DEFAULT 1
```

---

## Pendientes

- Definir el máximo nivel de reencauche permitido por la empresa.
- Implementar validación del límite máximo en frontend y backend cuando se defina la política de negocio correspondiente.

## Historial de procesos

La tabla llantas guarda únicamente el estado actual.

La tabla procesos guarda el historial completo.

---

## Reprocesos

Cuando una llanta deba repetir un subproceso:

NO se modifica el registro anterior.

Se crea un nuevo registro en la tabla procesos.

De esta forma se conserva la trazabilidad completa.

---

# Deshacer Inspección Inicial

## Objetivo

Permitir revertir una inspección inicial registrada por error, devolviendo la llanta al estado previo a la inspección.

---

## Regla General

Una inspección inicial solamente podrá deshacerse cuando la llanta no tenga procesos posteriores registrados.

Esto garantiza la integridad de la trazabilidad del proceso de reencauche.

---

## Estado de una llanta sin inspección

Se considera que una llanta nunca ha sido inspeccionada cuando:

- `codigo_inspeccion = 0`
- `id_estado = 0` (PENDIENTE)
- `nivel_reenc = 0`
- `fecha_inspeccion_inicial = NULL`
- `fecha_registro_inspinicial = NULL`
- `id_inspector_inicial = NULL`
- `observaciones_inicial = NULL`

---

## Validaciones para permitir deshacer

Antes de ejecutar la reversión se debe verificar:

### 1. Que la llanta exista

Si el tiquete no existe:

- Mostrar mensaje de error.
- No realizar ninguna actualización.

### 2. Que la llanta tenga una inspección registrada

No se debe permitir deshacer cuando:

```sql
codigo_inspeccion = 0
```

porque significa que nunca ha sido inspeccionada.

### 3. Que no existan procesos posteriores

La operación debe bloquearse cuando existan registros asociados a la llanta en la tabla `procesos`.

Ejemplos:

- Raspado
- Preparación
- Reparación
- Relleno
- Embandado
- Vulcanización
- Inspección final
- Terminación

Si existe al menos un proceso posterior:

- No se permite deshacer.
- Mostrar mensaje informativo al usuario.

Ejemplo:

> No es posible deshacer la inspección inicial porque la llanta ya tiene procesos posteriores registrados.

---

## Información que debe restaurarse

Al deshacer una inspección inicial se actualizará la tabla `llantas` con los siguientes valores:

```sql
nivel_reenc = 0
codigo_inspeccion = 0
observaciones_inicial = NULL
id_inspector_inicial = NULL
fecha_inspeccion_inicial = NULL
fecha_registro_inspinicial = NULL
id_estado = 0
```

---

## Trazabilidad

La acción de deshacer inspección inicial debe considerarse una operación excepcional.

En una versión futura se recomienda registrar:

- Usuario que realizó la reversión.
- Fecha y hora de la reversión.
- Motivo de la reversión.

Esto permitirá auditoría y seguimiento de cambios.

---

## Corrección de datos después de procesos posteriores

Cuando una llanta ya tenga procesos posteriores registrados, la inspección inicial no debe eliminarse.

En estos casos se recomienda:

### Opción 1 (Recomendada)

Permitir la modificación controlada de los datos de inspección inicial:

- Nivel de reencauche.
- Observaciones.
- Inspector.
- Fecha de inspección.

Registrando la modificación en una bitácora.

### Opción 2

Solicitar autorización administrativa para realizar la corrección.

### Opción 3

Crear una funcionalidad futura de "Corrección de proceso" con trazabilidad completa.

---

## Justificación

Eliminar una inspección inicial cuando existen procesos posteriores genera inconsistencias históricas porque:

- Los procesos posteriores dependen de la inspección inicial.
- Se pierde la secuencia cronológica real.
- Se afecta la trazabilidad del proceso productivo.

Por esta razón la reversión queda bloqueada cuando existen procesos posteriores asociados a la llanta.

---

## Estados de empleados

A = Activo

- Puede ser asignado a procesos productivos.

I = Inactivo

- Aparece en consultas y reportes.
- No puede ser asignado a nuevos procesos.

R = Retirado

- Sólo visible para consultas históricas y administración de empleados.
- No puede ser asignado a nuevos procesos.
