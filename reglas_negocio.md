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

id_resolucion = 2

La llanta queda:

Estado = APTA

Si la resolución corresponde a cualquier código de rechazo:

Estado = RECHAZADA

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
