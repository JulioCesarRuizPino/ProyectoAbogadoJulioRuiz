-- Ejecutar despues de migracion_normalizar_especialidades.sql.
-- Lleva tipos de usuario, estados y palabras clave a tablas de catalogo.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS tipos_usuario (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(40) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_tipo_usuario_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS estados_consulta (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(40) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_estado_consulta_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS especialidad_palabra_clave (
    id INT NOT NULL AUTO_INCREMENT,
    especialidad_id INT NOT NULL,
    palabra VARCHAR(80) NOT NULL,
    peso_titulo TINYINT NOT NULL DEFAULT 3,
    peso_descripcion TINYINT NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE KEY uq_especialidad_palabra (especialidad_id, palabra),
    CONSTRAINT fk_palabra_clave_especialidad
        FOREIGN KEY (especialidad_id) REFERENCES especialidades(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO tipos_usuario (nombre) VALUES ('cliente'), ('abogado'), ('dueno');
INSERT IGNORE INTO estados_consulta (nombre) VALUES ('pendiente'), ('cerrado');

-- Los terminos de clasificacion son datos administrables, no un diccionario dentro de Python.
INSERT IGNORE INTO especialidad_palabra_clave (especialidad_id, palabra)
SELECT e.id, datos.palabra
FROM especialidades e
JOIN (
    SELECT 'familia' AS especialidad, 'divorcio' AS palabra UNION ALL SELECT 'familia', 'alimentos' UNION ALL SELECT 'familia', 'pension' UNION ALL SELECT 'familia', 'custodia' UNION ALL SELECT 'familia', 'visitas' UNION ALL SELECT 'familia', 'tuicion' UNION ALL SELECT 'familia', 'familia' UNION ALL SELECT 'familia', 'conyuge' UNION ALL SELECT 'familia', 'matrimonio' UNION ALL SELECT 'familia', 'hijos'
    UNION ALL SELECT 'laboral', 'despido' UNION ALL SELECT 'laboral', 'finiquito' UNION ALL SELECT 'laboral', 'sueldo' UNION ALL SELECT 'laboral', 'remuneracion' UNION ALL SELECT 'laboral', 'laboral' UNION ALL SELECT 'laboral', 'trabajo' UNION ALL SELECT 'laboral', 'empleador' UNION ALL SELECT 'laboral', 'contrato' UNION ALL SELECT 'laboral', 'cotizaciones' UNION ALL SELECT 'laboral', 'acoso'
    UNION ALL SELECT 'civil', 'contrato' UNION ALL SELECT 'civil', 'deuda' UNION ALL SELECT 'civil', 'arrendamiento' UNION ALL SELECT 'civil', 'arriendo' UNION ALL SELECT 'civil', 'indemnizacion' UNION ALL SELECT 'civil', 'civil' UNION ALL SELECT 'civil', 'propiedad' UNION ALL SELECT 'civil', 'incumplimiento' UNION ALL SELECT 'civil', 'cobranza'
    UNION ALL SELECT 'penal', 'delito' UNION ALL SELECT 'penal', 'denuncia' UNION ALL SELECT 'penal', 'querella' UNION ALL SELECT 'penal', 'robo' UNION ALL SELECT 'penal', 'estafa' UNION ALL SELECT 'penal', 'amenaza' UNION ALL SELECT 'penal', 'lesiones' UNION ALL SELECT 'penal', 'penal' UNION ALL SELECT 'penal', 'detencion' UNION ALL SELECT 'penal', 'violencia' UNION ALL SELECT 'penal', 'hurto'
    UNION ALL SELECT 'comercial', 'empresa' UNION ALL SELECT 'comercial', 'sociedad' UNION ALL SELECT 'comercial', 'factura' UNION ALL SELECT 'comercial', 'comercial' UNION ALL SELECT 'comercial', 'marca' UNION ALL SELECT 'comercial', 'proveedor' UNION ALL SELECT 'comercial', 'cliente' UNION ALL SELECT 'comercial', 'quiebra' UNION ALL SELECT 'comercial', 'startup' UNION ALL SELECT 'comercial', 'negocio'
    UNION ALL SELECT 'inmobiliario', 'inmueble' UNION ALL SELECT 'inmobiliario', 'casa' UNION ALL SELECT 'inmobiliario', 'departamento' UNION ALL SELECT 'inmobiliario', 'compraventa' UNION ALL SELECT 'inmobiliario', 'hipoteca' UNION ALL SELECT 'inmobiliario', 'condominio' UNION ALL SELECT 'inmobiliario', 'terreno' UNION ALL SELECT 'inmobiliario', 'inmobiliario' UNION ALL SELECT 'inmobiliario', 'escritura'
    UNION ALL SELECT 'migratorio', 'visa' UNION ALL SELECT 'migratorio', 'residencia' UNION ALL SELECT 'migratorio', 'extranjero' UNION ALL SELECT 'migratorio', 'migracion' UNION ALL SELECT 'migratorio', 'permiso' UNION ALL SELECT 'migratorio', 'nacionalidad' UNION ALL SELECT 'migratorio', 'expulsion'
) AS datos ON datos.especialidad = e.nombre;

ALTER TABLE usuarios ADD COLUMN tipo_id INT NULL;
UPDATE usuarios u
JOIN tipos_usuario tu ON tu.nombre = u.tipo
SET u.tipo_id = tu.id
WHERE u.id > 0;
ALTER TABLE usuarios
    MODIFY COLUMN tipo_id INT NOT NULL,
    ADD CONSTRAINT fk_usuario_tipo FOREIGN KEY (tipo_id) REFERENCES tipos_usuario(id),
    DROP COLUMN tipo;

ALTER TABLE consultas ADD COLUMN estado_id INT NULL;
UPDATE consultas c
JOIN estados_consulta ec ON ec.nombre = c.estado
SET c.estado_id = ec.id
WHERE c.id > 0;
ALTER TABLE consultas
    MODIFY COLUMN estado_id INT NOT NULL,
    ADD CONSTRAINT fk_consulta_estado FOREIGN KEY (estado_id) REFERENCES estados_consulta(id),
    DROP COLUMN estado;

COMMIT;
