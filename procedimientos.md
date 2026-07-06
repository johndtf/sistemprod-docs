# Procedimientos de Desarrollo

Este documento contiene procedimientos y estándares utilizados en SISTEMPROD para mantener uniformidad durante el desarrollo.

---

# Implementación de Alertas Personalizadas

## Objetivo

Reemplazar los mensajes nativos (`alert()`) por alertas visuales integradas con el diseño de la aplicación.

Tipos disponibles:

- info
- success
- warning
- error

---

## Requisitos

### 1. Cargar los estilos del componente

En el `<head>` del formulario, después de las demás hojas de estilo:

```html
<link rel="stylesheet" href="../../css/alertas.css" />
```

En `index.html`, la ruta es:

```html
<link rel="stylesheet" href="css/alertas.css" />
```

No se debe cargar `style.css` únicamente para mostrar alertas. Esa hoja contiene
estilos generales de la aplicación principal que pueden cambiar la apariencia de
los formularios. `alertas.css` está encapsulada bajo `#alerta-toast` y solo afecta
al componente de alerta.

### 2. Importar funciones

En el archivo JavaScript del formulario:

```javascript
import { insertarContenedorAlerta, mostrarAlerta } from "./funcionesComunes.js";
```

### 3. Enlazar el JavaScript como módulo

El archivo JavaScript del formulario debe enlazarse en el HTML con
`type="module"`, porque utiliza `import` para cargar las funciones comunes:

```html
<script type="module" src="../../js/perfiles.js"></script>
```

En `index.html`, la ruta correspondiente es:

```html
<script type="module" src="js/script.js"></script>
```

La ruta y el nombre del archivo deben ajustarse a cada formulario. Si se omite
`type="module"`, el navegador no podrá procesar las instrucciones `import` y el
script no ejecutará `insertarContenedorAlerta()` ni `mostrarAlerta()`.

---

### 4. Insertar el contenedor de alertas

Dentro de `DOMContentLoaded`:

```javascript
document.addEventListener("DOMContentLoaded", () => {
  insertarContenedorAlerta();
});
```

Esta función crea automáticamente el HTML necesario para mostrar las alertas.

No es necesario agregar código HTML manualmente.

---

### 5. Reemplazar alert()

#### Antes

```javascript
alert("Registro guardado correctamente");
```

#### Después

```javascript
mostrarAlerta("Éxito", "Registro guardado correctamente", "success");
```

---

## Tipos de alerta

### Información

```javascript
mostrarAlerta("Información", "Cargando datos...", "info");
```

---

### Éxito

```javascript
mostrarAlerta("Éxito", "Registro guardado correctamente", "success");
```

---

### Advertencia

```javascript
mostrarAlerta(
  "Atención",
  "Debe completar todos los campos obligatorios",
  "warning",
);
```

---

### Error

```javascript
mostrarAlerta("Error", "No fue posible conectar con el servidor", "error");
```

---

## Validación de formularios

### Campos obligatorios

#### Antes

```javascript
if (!nombre) {
  alert("Debe ingresar el nombre");
  return;
}
```

#### Después

```javascript
if (!nombre) {
  mostrarAlerta("Atención", "Debe ingresar el nombre", "warning");
  return;
}
```

---

### Validaciones de negocio

```javascript
if (cantidad <= 0) {
  mostrarAlerta("Atención", "La cantidad debe ser mayor que cero", "warning");
  return;
}
```

---

## Manejo de respuestas del backend

### Operación exitosa

```javascript
if (response.ok) {
  mostrarAlerta("Éxito", "Registro actualizado correctamente", "success");
}
```

---

### Error devuelto por API

```javascript
if (!response.ok) {
  const data = await response.json();

  mostrarAlerta("Error", data.message || "Error del servidor", "error");

  return;
}
```

---

### Error de conexión

```javascript
catch (error) {
  console.error(error);

  mostrarAlerta(
    "Error",
    "Problema de conexión con el servidor",
    "error"
  );
}
```

---

## Estándar de uso en SISTEMPROD

### Success

Se utiliza cuando:

- Se crea un registro.
- Se modifica un registro.
- Se elimina un registro.
- Se completa correctamente una operación.

Ejemplo:

```javascript
mostrarAlerta("Éxito", "Orden actualizada correctamente", "success");
```

---

### Warning

Se utiliza cuando:

- Faltan datos obligatorios.
- El usuario intenta realizar una acción inválida.
- Existe información incompleta.

Ejemplo:

```javascript
mostrarAlerta("Atención", "Debe seleccionar al menos una llanta", "warning");
```

---

### Error

Se utiliza cuando:

- Ocurre un error del servidor.
- Falla una consulta.
- Se pierde la conexión.

Ejemplo:

```javascript
mostrarAlerta("Error", "No se pudo guardar la información", "error");
```

---

### Info

Se utiliza cuando:

- Se desea informar algo al usuario.
- Se muestran mensajes neutrales.

Ejemplo:

```javascript
mostrarAlerta("Información", "La búsqueda no produjo resultados", "info");
```

---

## Formularios pendientes de migración

Reemplazar gradualmente todos los:

```javascript
alert(...)
```

por:

```javascript
mostrarAlerta(...)
```

Módulos prioritarios:

- Clientes
- Empleados
- Órdenes
- Inspección Inicial
- Producción
- Consultas

---

## Observaciones

- El HTML de la alerta se inserta automáticamente mediante:

```javascript
insertarContenedorAlerta();
```

- No debe agregarse código HTML manual para las alertas.

- La hoja `alertas.css` debe cargarse después de los estilos propios del formulario.

- Todo script que importe `funcionesComunes.js` debe enlazarse con `type="module"`.

- Las alertas desaparecen automáticamente después de unos segundos.

- El usuario puede cerrarlas manualmente mediante el botón "×".

- Todas las nuevas pantallas deben utilizar este sistema de alertas desde su creación.

---

# Búsquedas en formularios de producción

## Búsqueda de llantas

Los formularios deben buscar la llanta mediante:

- Un botón visible `Buscar`.
- La tecla `Enter` cuando el foco está en el campo tiquete.

No se debe ejecutar la búsqueda con el evento `blur`. Perder el foco puede ocurrir
de forma accidental y producir consultas inesperadas mientras el usuario llena el
formulario.

Durante la consulta, el botón debe quedar deshabilitado y mostrar un texto de
progreso. Al finalizar debe recuperar su estado original.

## Selección de operarios

Los subprocesos deben usar un selector buscable de empleados activos. Cada opción
debe mostrar:

```text
Código - Nombre Apellido
```

La búsqueda debe aceptar tanto el código como el nombre. El valor enviado al
backend siempre será `id_empleado`.

El backend debe volver a validar que el empleado exista y conserve el estado `A`
antes de registrar el proceso. El selector mejora la captura, pero no reemplaza
la validación de negocio del servidor.

## Menú lateral de subprocesos

Cada elemento del menú debe declarar su identificador mediante
`data-id-subproceso`. Al buscar una llanta, la API devuelve el arreglo
`subprocesos` con las etapas que tienen registros en el historial y el módulo
compartido `menuSubprocesos.js` aplica la clase `completed`.

La clase `current` identifica el formulario abierto y tiene prioridad visual
sobre `completed`. Cuando una búsqueda falla o se limpia el formulario, deben
retirarse los indicadores de la llanta anterior sin eliminar `current`.

Los enlaces laterales deben apuntar directamente a los formularios de
producción. De esta forma el usuario puede cambiar de subproceso sin regresar al
menú principal de producción.
