# Base de datos

## Tabla estados

Contiene los estados posibles de una llanta.

Valores principales:

0 = Pendiente
1 = Apta
2 = Rechazada

---

## Tabla llantas

Contiene la información actual de cada llanta.

La tabla llantas representa el estado actual del proceso.

Campos importantes:

### id_estado

Estado actual de la llanta.

### nivel_reencauche

Número de reencauche actual.

Ejemplos:

1 = Primer reencauche
2 = Segundo reencauche
3 = Tercer reencauche

### Estado actual de Preparación

Preparación no produce mediciones propias. La última ejecución queda resumida
en `llantas` mediante:

- `fecha_preparacion`
- `fecha_registro_preparacion`
- `id_operario_preparacion`
- `id_resolucion_preparacion`

Estos campos no reemplazan el historial. Cada ejecución, incluidos los
reprocesos, genera una fila independiente en `procesos`.

### Estado actual de Reparación

La última actualización se conserva en `llantas` mediante:

- `fecha_reparacion`
- `fecha_registro_reparacion`
- `id_operario_reparacion`
- `id_resolucion_reparacion`

El catálogo `reparaciones` contiene `id_reparacion`, `referencia` y `nombre`.
La tabla `reparaciones_proceso` relaciona cada parche y su cantidad con una fila
histórica de `procesos`. Su clave compuesta impide repetir una referencia dentro
de la misma ejecución.

### Estado actual de Relleno

Relleno no produce mediciones propias. La ultima ejecucion queda resumida en
`llantas` mediante:

- `fecha_relleno`
- `fecha_registro_relleno`
- `id_operario_relleno`
- `id_resolucion_relleno`

Cada ejecucion crea una fila independiente en `procesos` con
`id_subproceso = 5`.

### Estado actual de Corte de Banda

Corte de Banda trabaja como operacion por lote. La ultima ejecucion queda
resumida en `llantas` mediante:

- `fecha_corte`
- `fecha_registro_corte`
- `id_operario_corte`

El diseno de banda viene de la orden mediante `id_banda`. El ancho y el largo
que se muestran para cortar la banda provienen del ultimo Raspado aprobado:

- `ancho`
- `perimetro`

Cada banda marcada como cortada crea una fila en `procesos` con
`id_subproceso = 6`.

### Parametros de planta

La tabla `parametros_planta` guarda ajustes operativos configurables por planta.
El parametro `tiempo_secado_relleno_minutos` define los minutos orientativos de
secado que se muestran en Relleno.

---

## Tabla subprocesos

Catálogo de etapas productivas.

Campos:

- id_subproceso
- nombre
- orden (la secuencia del subproceso es decir si está de segundo o tercero, etc)

Ejemplo:

1 = Inspección Inicial
2 = Raspado
3 = Preparación
4 = Reparación
5 = Relleno
6 = Corte de Banda
7 = Embandado
8 = Vulcanización
9 = Inspección Final
10 = Terminación

Nota: Escariado corresponde al subproceso **Preparación** y no se registra como una etapa independiente.

---

## Tabla procesos

Historial de ejecución de subprocesos.

Cada registro representa una ejecución de un subproceso para una llanta.

Una misma llanta puede tener múltiples registros para un mismo subproceso.

Esto permite manejar reprocesos sin perder historial.
