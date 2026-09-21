# Reglas de negocio

## Estado inicial

Toda llanta ingresada al sistema debe quedar:

Estado = PENDIENTE

---

## Tipos de ingreso y compra de cascos

El tipo de ingreso se selecciona por llanta al crearla dentro de una orden. Una
misma orden puede contener llantas para reencauche, reparacion y venta de casco.

Una llanta con `tipo_ingreso = VENTA_CASCO` puede comprarse desde que tenga una
Inspeccion Inicial aprobada. No necesita esperar la Inspeccion Final.

Cada documento de compra solo puede incluir llantas de un mismo vendedor. Al
actualizar la compra, el sistema valida que las llantas sigan disponibles, crea
la cabecera y sus detalles, incrementa el consecutivo y cambia el propietario
actual al cliente configurado como empresa propietaria. Todo ocurre en una sola
transaccion para evitar compras parciales o duplicadas.

La empresa propietaria de la planta no puede figurar como vendedora en una
compra de cascos. La regla se valida en el formulario y nuevamente en el
servidor antes de crear el documento.

La compra no cambia el cliente de la orden: esa relacion conserva quien entrego
la llanta inicialmente. Tampoco se compra una llanta dos veces, porque el
detalle de compra exige una llanta unica.

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
- Si su tipo de ingreso es `REENCAUCHE` o `VENTA_CASCO`, tengan Embandado
  aprobado en `procesos`.
- Si su tipo de ingreso es `REPARACION`, tengan Reparacion aprobada en
  `procesos`; no requieren Relleno, Corte de Banda ni Embandado.

Esto permite que una llanta recibida exclusivamente para reparar avance desde
la aplicacion de sus parches hacia Vulcanizado, sin forzar subprocesos que no
corresponden a su flujo.

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

# Salidas de Llantas Procesadas

## Tipos de salida

El formulario de salidas procesadas permite trabajar con:

- llantas `REENCAUCHADAS`
- llantas `REPARADAS`

Las llantas `REENCAUCHADAS` se costean al salir. Las llantas `REPARADAS` no se
costean por ahora.

## Documento de salida

El numero de documento se genera automaticamente al confirmar una o varias
llantas con `Actualizar salida`. El consecutivo se guarda en
`parametros_planta` con el codigo `documento_salida_procesadas_actual` dentro
de la misma transaccion que actualiza las llantas. Por ello una salida fallida o
abandonada no consume un numero de documento.

## Salida individual y por bloque

Una salida puede armarse de dos formas:

- Individual: digitando el tiquete y buscando la llanta.
- Por bloque: cargando todas las llantas que estan en ubicacion `P` y tienen el
  estado seleccionado.

La carga por bloque solo prepara la tabla visible. La base de datos cambia
cuando el usuario confirma con `Actualizar salida`.

Al confirmar una salida desde planta, la llanta pasa de ubicacion `P` a `B`.
El documento conserva su bodega destino en `id_bodega_salida` y asigna la misma
como `id_bodega_actual`. Los traslados futuros entre bodegas cambiaran solo la
bodega actual, manteniendo el dato historico del documento.

## Validaciones para reencauchadas

Para una llanta `REENCAUCHADA`, la salida exige:

- ubicacion `P`
- estado `REENCAUCHADA`
- combinacion dimension + diseno registrada en `pesos_banda`
- costo/kg promedio configurado en `parametros_planta`, con dos decimales
- fecha de Terminacion para definir mes y anio de proceso

Si falta una combinacion de peso, el sistema informa el problema y la salida no
se completa hasta crear el registro en el catalogo.

## Validaciones para reparadas

Para una llanta `REPARADA`, la salida exige:

- ubicacion `P`
- estado `REPARADA`

No se calcula costo estimado en esta etapa.

---

# Actualizacion de Ventas

La actualizacion de ventas registra en Sistemprod una factura que fue emitida
previamente por el programa contable. Un documento corresponde a un solo
cliente comprador y a una sola bodega de origen, pero puede incluir varias
llantas procesadas.

Solo se pueden facturar llantas con ubicacion `B` y estado `REENCAUCHADA` o
`REPARADA`. Al confirmar, todas las llantas seleccionadas pasan a ubicacion
`C`, `id_bodega_actual` se establece en `NULL` y se conserva la bodega de la
salida original de produccion. El propietario actual no cambia: el comprador
de la factura se almacena por separado en el documento de venta.

La cabecera conserva numero de factura, fecha, comprador, empleado, bodega y
observacion. El detalle conserva precio de venta e IVA por llanta. El numero de
factura lo digita el usuario y es unico, porque proviene de contabilidad.

El parametro `iva_predeterminado_ventas` propone un IVA inicial al agregar una
llanta a la factura. Cada fila permite modificarlo antes de confirmar; por eso
el valor definitivo queda almacenado individualmente en el detalle de venta.

El comprobante de venta se genera desde las tablas de ventas, no desde el
estado actual de las llantas. Por ello continua mostrando la evidencia de la
entrega aun si una llanta vuelve posteriormente a planta por garantia.

---

# Salidas de Llantas Rechazadas

Las llantas rechazadas salen inicialmente de Planta hacia una Bodega. Las
entregas posteriores a cada cliente se manejaran desde el modulo de Ventas.

Una salida rechazada exige estado `RECHAZADA` y ubicacion `P`. Al confirmar un
documento, una o varias llantas pasan a ubicacion `B` y se guardan bodega,
fecha, empleado y tipo de salida `RECHAZADA`.

El consecutivo usa `documento_salida_rechazadas_actual` en
`parametros_planta`, independiente de las salidas procesadas. La tabla muestra
tiquete, orden-consecutivo, dimension, propietario y causa de rechazo; esta se
toma del ultimo proceso que registro resultado rechazado.

Las copias de Planta y Bodega son iguales y no incluyen costos: solo cambia la
etiqueta de la copia. Se imprimen en hoja carta horizontal con firmas de Planta
y Bodega.

## Reporte de Planta

Los reportes **Planta** y **Bodega** comparten el mismo formato operativo de un
documento de salida ya confirmado. Se usan para verificar las llantas fisicas
durante la entrega a bodega y no incluyen costos; solo cambia la etiqueta de
la copia impresa.

El reporte se disena para una hoja tamano carta en orientacion horizontal.
Muestra empresa, numero y fecha del documento, bodega destino, tipo de salida,
empleado que registro la entrega y el detalle de tiquete, orden-consecutivo,
dimension, diseno, marca, fecha de proceso y propietario actual. Al final deja
espacio para las firmas de quien entrega por Planta y quien recibe por Bodega.

La vista previa y la impresion consultan el documento por su numero. Si una
llanta se traslada posteriormente a otra bodega, el reporte conserva la bodega
original almacenada en `id_bodega_salida`.

## Reporte de Facturacion Completa

El reporte **Facturacion completa** usa hoja carta horizontal. Muestra tiquete,
orden-consecutivo, dimension, diseno, fecha de proceso, propietario, costo de
reencauche y costo del casco; no muestra marca.

El costo de reencauche corresponde a `costo_real` si ya se realizo recosteo
mensual y, de lo contrario, a `costo_estimado`. El costo del casco se toma del
valor de compra registrado para la llanta y es cero si no existe compra.

Al pie de las columnas de costo se imprimen los totales de costo de reencauche
y costo de cascos correspondientes a todas las llantas del documento.

Las llantas cuyo propietario actual es la empresa configurada se imprimen
primero. Despues se incluyen las llantas de otros propietarios; dentro de ambos
grupos se ordenan por dimension y diseno.

## Reporte de Facturacion Simplificada

El reporte **Facturacion simplificada** usa hoja carta horizontal y resume el
documento en dos secciones: llantas de la empresa propietaria y llantas de
servicio. Cada seccion agrupa las llantas por dimension y diseno, mostrando
cantidad, costo de reencauche y costo de casco. Al final de cada seccion se
imprimen sus totales de cantidad y costos.

---

# Ordenes de Entrada

Las llantas conservan un consecutivo manual dentro de la orden. Puede haber
saltos para reflejar tachones o lineas anuladas del documento fisico.

Una llanta puede modificar sus datos de entrada o cambiarse de orden solo antes
de registrar Inspeccion Inicial. Desde ese subproceso se conserva la trazabilidad
de dimension, diseno, cliente y orden. Una orden tampoco puede cambiar cliente,
fecha o numero si alguna de sus llantas ya tiene Inspeccion Inicial.

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

## Inspeccion final segun tipo de ingreso

Al aprobar la inspeccion final, el resultado permitido depende del campo
`llantas.tipo_ingreso`:

- `REPARACION`: la llanta queda `REPARADA`.
- `REENCAUCHE`: la llanta queda `REENCAUCHADA`.
- `VENTA_CASCO`: la llanta queda `REENCAUCHADA`, porque el casco adquirido por
  la empresa sigue el flujo de reencauche para convertirse en una llanta de
  inventario propio.

El formulario oculta el resultado incompatible para evitar errores de captura.
El backend repite la validacion antes de guardar el proceso, por lo que la regla
se conserva incluso fuera de la interfaz.

Un rechazo durante inspeccion final sigue disponible para cualquier tipo de
ingreso y cambia el estado de la llanta a `RECHAZADA`.

## Correccion de llantas en proceso

Los datos de identificacion de una llanta pueden corregirse despues de iniciar
produccion cuando se detecte un error de ingreso, por ejemplo una dimension o
un diseno de banda equivocado. Esta operacion actualiza solamente el registro
vigente de `llantas`; no modifica las filas historicas de `procesos` ni altera
la orden original.

La correccion permite actualizar marca, dimension, diseno, serie, prioridad,
nivel de reencauche y observacion. El tipo de ingreso se conserva, porque
define el flujo permitido y el resultado de Inspeccion Final.

No se permite corregir cuando la llanta ya tiene costo estimado, costo real,
documento o fecha de salida, o cuando ya no se encuentra en planta. Cada cambio
exige un motivo y crea una fila en `correcciones_llanta` con empleado, fecha,
valores anteriores y valores nuevos.

Si se cambia dimension o diseno despues de Corte de Banda o de un subproceso
posterior, el usuario debe confirmar que los valores corregidos coinciden con
la llanta fisica.

## Estados de empleados

A = Activo

- Puede ser asignado a procesos productivos.

I = Inactivo

- Aparece en consultas y reportes.
- No puede ser asignado a nuevos procesos.

R = Retirado

- Sólo visible para consultas históricas y administración de empleados.
- No puede ser asignado a nuevos procesos.
