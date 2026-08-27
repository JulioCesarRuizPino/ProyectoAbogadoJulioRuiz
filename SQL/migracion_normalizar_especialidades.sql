-- Ejecutar una sola vez sobre una base de datos existente antes de iniciar la version normalizada.
-- Convierte usuarios.especialidades (texto separado por comas) en una relacion muchos-a-muchos.

START TRANSACTION;

CREATE TABLE IF NOT EXISTS especialidades (
    id INT NOT NULL AUTO_INCREMENT,
    nombre VARCHAR(80) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_especialidad_nombre (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS abogado_especialidad (
    abogado_id INT NOT NULL,
    especialidad_id INT NOT NULL,
    PRIMARY KEY (abogado_id, especialidad_id),
    CONSTRAINT fk_abogado_especialidad_abogado
        FOREIGN KEY (abogado_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_abogado_especialidad_especialidad
        FOREIGN KEY (especialidad_id) REFERENCES especialidades(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO especialidades (nombre) VALUES
    ('familia'), ('laboral'), ('civil'), ('penal'), ('comercial'),
    ('inmobiliario'), ('migratorio');

-- Migra los valores antiguos. FIND_IN_SET evita coincidencias parciales, como "civil" en otro texto.
INSERT IGNORE INTO abogado_especialidad (abogado_id, especialidad_id)
SELECT u.id, e.id
FROM usuarios u
JOIN especialidades e
  ON FIND_IN_SET(e.nombre, REPLACE(COALESCE(u.especialidades, ''), ' ', '')) > 0
WHERE u.tipo = 'abogado';

ALTER TABLE usuarios DROP COLUMN especialidades;

COMMIT;
