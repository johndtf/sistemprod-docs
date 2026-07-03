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

### 1. Importar funciones

En el archivo JavaScript del formulario:

```javascript
import { insertarContenedorAlerta, mostrarAlerta } from "./funcionesComunes.js";
```

---

### 2. Insertar el contenedor de alertas

Dentro de `DOMContentLoaded`:

```javascript
document.addEventListener("DOMContentLoaded", () => {
  insertarContenedorAlerta();
});
```

Esta función crea automáticamente el HTML necesario para mostrar las alertas.

No es necesario agregar código HTML manualmente.

---

### 3. Reemplazar alert()

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

- Las alertas desaparecen automáticamente después de unos segundos.

- El usuario puede cerrarlas manualmente mediante el botón "×".

- Todas las nuevas pantallas deben utilizar este sistema de alertas desde su creación.
