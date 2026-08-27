-- Usa este archivo SOLO si migracion_catalogos.sql se detuvo en el error 1175 de Workbench.
-- Las tablas de catalogo y usuarios.tipo_id ya fueron creadas antes de que ocurriera ese error.

START TRANSACTION;

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
