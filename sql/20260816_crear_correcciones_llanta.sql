-- Bitacora para el formulario "Correccion de llantas en proceso".
-- llantas conserva el valor vigente; esta tabla conserva antes/despues, motivo
-- y empleado, sin modificar el historial de procesos productivos.
CREATE TABLE IF NOT EXISTS correcciones_llanta (
  id_correccion INT UNSIGNED NOT NULL AUTO_INCREMENT,
  id_llanta INT UNSIGNED NOT NULL,
  fecha_registro DATETIME NOT NULL,
  id_empleado MEDIUMINT UNSIGNED NOT NULL,
  motivo VARCHAR(255) NOT NULL,
  datos_anteriores TEXT NOT NULL,
  datos_nuevos TEXT NOT NULL,
  PRIMARY KEY (id_correccion),
  KEY idx_correcciones_llanta_tiquete_fecha (id_llanta, fecha_registro),
  CONSTRAINT fk_correcciones_llanta_llanta FOREIGN KEY (id_llanta) REFERENCES llantas(id_llanta),
  CONSTRAINT fk_correcciones_llanta_empleado FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);
