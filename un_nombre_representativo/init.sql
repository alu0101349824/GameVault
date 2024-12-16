/*
DROP TABLE IF EXISTS biblioteca_videojuego CASCADE;
DROP TABLE IF EXISTS biblioteca CASCADE;
DROP TABLE IF EXISTS comentarios CASCADE;
DROP TABLE IF EXISTS desarrollador CASCADE;
DROP TABLE IF EXISTS distribuidor CASCADE;
DROP TABLE IF EXISTS dlc CASCADE;
DROP TABLE IF EXISTS generos CASCADE;
DROP TABLE IF EXISTS generos_jugador CASCADE;
DROP TABLE IF EXISTS jugador CASCADE;
DROP TABLE IF EXISTS lista_deseados CASCADE;
DROP TABLE IF EXISTS logros CASCADE;
DROP TABLE IF EXISTS logros_jugador CASCADE;
DROP TABLE IF EXISTS logros_videojuegos CASCADE;
DROP TABLE IF EXISTS videojuego_desarrollador_distribuidor CASCADE;
DROP TABLE IF EXISTS videojuegos CASCADE;
DROP TRIGGER IF EXISTS trigger_fecha_formato_videojuegos ON VIDEOJUEGOS;
DROP TRIGGER IF EXISTS trigger_fecha_guardado_formato_biblioteca_videojuego ON BIBLIOTECA_VIDEOJUEGO;
DROP TRIGGER IF EXISTS trigger_actualizar_espacio_usado ON BIBLIOTECA_VIDEOJUEGO;
DROP TRIGGER IF EXISTS trigger_actualizar_numero_juegos ON BIBLIOTECA_VIDEOJUEGO;
DROP FUNCTION IF EXISTS check_fecha_formato();
DROP FUNCTION IF EXISTS check_fecha_guardado_formato();
DROP FUNCTION IF EXISTS actualizar_numero_juegos();
*/

-- Funciones
-- Función para actualizar Numero_juegos
CREATE OR REPLACE FUNCTION actualizar_numero_juegos()
RETURNS TRIGGER AS $$
BEGIN
   UPDATE BIBLIOTECA
   SET Numero_juegos = COALESCE((
      SELECT COUNT(bv.Id_videojuego)
      FROM BIBLIOTECA_VIDEOJUEGO bv
      WHERE bv.Id_biblioteca = NEW.Id_biblioteca
   ), 0)
   WHERE Id_biblioteca = NEW.Id_biblioteca;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Entidades
-- Tabla DESARROLLADOR
CREATE TABLE DESARROLLADOR (
    Id_desarrollador SERIAL PRIMARY KEY, -- Usamos SERIAL para auto incrementar
    Contraseña VARCHAR(255) NOT NULL CHECK (LENGTH(Contraseña) >= 8), -- Contraseña no nula y longitud mínima de 8 caracteres
    Nombre VARCHAR(255) NOT NULL CHECK (Nombre ~* '^[A-Za-zÀ-ÿ0-9% ]+$'), -- Nombre no puede ser nulo
    Imagen_perfil VARCHAR(255) DEFAULT NULL, -- Imagen opcional
    Correo VARCHAR(255) UNIQUE NOT NULL CHECK (Correo ~* '^[A-Za-z0-9.-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$'), -- Correo único, no nulo y validación de formato
    Pais VARCHAR(100) NOT NULL, -- País no puede ser nulo
    Descripcion TEXT DEFAULT NULL, -- Descripción opcional
    Numero_empleados INT CHECK (Numero_empleados >= 0), -- Número de empleados debe ser mayor o igual a 0
    Presentacion TEXT DEFAULT NULL, -- Presentación opcional
    Pagina_web VARCHAR(255) DEFAULT NULL CHECK (Pagina_web ~* '^(http://|https://)?(www.)?[A-Za-z0-9.-]+.[A-Za-z]{2,}$') -- Validación de formato para URLs opcionales
);

-- Tabla DISTRIBUIDOR
CREATE TABLE DISTRIBUIDOR (
   Id_distribuidor SERIAL PRIMARY KEY,
   Nombre VARCHAR(255) NOT NULL CHECK (Nombre ~* '^[A-Za-zÀ-ÿ0-9% ]+$'),
   Numero_Empleado INT CHECK (Numero_Empleado >= 0),
   Pagina_web VARCHAR(255) DEFAULT NULL CHECK (Pagina_web ~* '^(http://|https://)?(www.)?[A-Za-z0-9.-]+.[A-Za-z]{2,}$'),
    Presentacion TEXT DEFAULT NULL
);

-- Tabla JUGADOR
CREATE TABLE JUGADOR (
   Id_jugador SERIAL PRIMARY KEY,
   Nombre VARCHAR(255) NOT NULL CHECK (Nombre ~* '^[A-Za-zÀ-ÿ0-9% ]+$'),
   Contraseña VARCHAR(255) NOT NULL CHECK (LENGTH(Contraseña) >= 8),
   Correo VARCHAR(255) UNIQUE NOT NULL CHECK (Correo ~* '^[A-Za-z0-9.-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$'),
   Pais VARCHAR(100) NOT NULL,
   Imagen_perfil VARCHAR(255) DEFAULT NULL,
   Descripcion TEXT DEFAULT NULL,
   Tarjeta_credito VARCHAR(20) DEFAULT NULL CHECK (Tarjeta_credito ~* '^[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}$')
);

-- Tabla BIBLIOTECA
CREATE TABLE BIBLIOTECA (
   Id_biblioteca SERIAL PRIMARY KEY, -- Clave primaria auto incremental
   Id_jugador INT UNIQUE NOT NULL, -- Clave foránea referenciando a JUGADOR
   Numero_juegos INT CHECK (Numero_juegos >= 0), -- Número de juegos no negativo
   Espacio_usado DECIMAL(10, 2) CHECK (Espacio_usado >= 0), -- Espacio usado no negativo
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador) ON DELETE CASCADE -- Relación explícita con JUGADOR
);

-- Tabla VIDEOJUEGOS
CREATE TABLE VIDEOJUEGOS (
   Id_videojuego SERIAL PRIMARY KEY,
   Nombre VARCHAR(255) NOT NULL CHECK (Nombre ~* '^[A-Za-zÀ-ÿ0-9% ]+$'),
   Fecha VARCHAR(23) NOT NULL CHECK (Fecha ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'), -- Fecha debe ser DD/MM/AAAA
   Descripcion TEXT DEFAULT NULL,
   Precio DECIMAL(10, 2) CHECK (Precio >= 0), -- Precio debe ser positivo
   Duracion_oferta VARCHAR(23) CHECK (Duracion_oferta ~ '^([0-9]{2}/[0-9]{2}/[0-9]{4}) - ([0-9]{2}/[0-9]{2}/[0-9]{4})$'),
   Descuento_oferta INT DEFAULT NULL,
   Tamaño DECIMAL(10, 2) CHECK (Tamaño >= 0) -- Tamaño debe ser positivo
);

-- Tabla GENEROS
CREATE TABLE GENEROS (
   Id_genero SERIAL PRIMARY KEY,
   Nombre VARCHAR(100) NOT NULL CHECK (Nombre ~* '^[A-Za-zÀ-ÿ0-9% ]+$'),
   Descripcion TEXT DEFAULT NULL
);

-- Tabla LOGROS
CREATE TABLE LOGROS (
   Id_logro SERIAL PRIMARY KEY,
   Nombre VARCHAR(255) NOT NULL CHECK (Nombre ~* '^[A-Za-zÀ-ÿ0-9% ]+$'),
   Descripcion TEXT DEFAULT NULL,
   Requisito TEXT CHECK (Requisito ~* '^[A-Za-z0-9% ]+$')
);

-- Tabla COMENTARIOS
CREATE TABLE COMENTARIOS (
   Id_comentario SERIAL PRIMARY KEY,
   Id_jugador INT NOT NULL,
   Id_videojuego INT NOT NULL,
   Votacion INT CHECK (Votacion >= 0),
   Gusto BOOLEAN NOT NULL CHECK (Gusto IN (TRUE, FALSE)),
   Opinion TEXT NOT NULL,
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador) ON DELETE SET NULL,
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego) ON DELETE SET NULL
);

-- Tabla DLC
CREATE TABLE DLC (
   Id_DLC SERIAL PRIMARY KEY,
   Id_videojuego INT NOT NULL,
   Nombre VARCHAR(255) NOT NULL CHECK (Nombre ~* '^[A-Za-zÀ-ÿ0-9% ]+$'),
   Descripcion TEXT DEFAULT NULL,
   Precio DECIMAL(10, 2) CHECK (Precio >= 0),
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego) ON DELETE CASCADE
);

-- Relaciones
-- Tabla VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
CREATE TABLE VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR (
   Id_desarrollador INT,
   Id_distribuidor INT,
   Id_videojuego INT,
   PRIMARY KEY (Id_desarrollador, Id_distribuidor, Id_videojuego),
   FOREIGN KEY (Id_desarrollador) REFERENCES DESARROLLADOR(Id_desarrollador) ON DELETE SET NULL,
   FOREIGN KEY (Id_distribuidor) REFERENCES DISTRIBUIDOR(Id_distribuidor) ON DELETE SET NULL,
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego) ON DELETE SET NULL
);

-- Tabla GENEROS_JUGADOR
CREATE TABLE GENEROS_JUGADOR (
   Id SERIAL PRIMARY KEY,
   Id_jugador INT NOT NULL,
   Id_genero INT NOT NULL,
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador) ON DELETE CASCADE,
   FOREIGN KEY (Id_genero) REFERENCES GENEROS(Id_genero) ON DELETE CASCADE
);

-- Tabla LISTA_DESEADOS
CREATE TABLE LISTA_DESEADOS (
   Id SERIAL PRIMARY KEY,
   Id_videojuego INT NOT NULL,
   Id_jugador INT NOT NULL,
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador) ON DELETE SET NULL,
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego) ON DELETE SET NULL
);

-- Tabla BIBLIOTECA_VIDEOJUEGO
CREATE TABLE BIBLIOTECA_VIDEOJUEGO (
   Id SERIAL PRIMARY KEY,
   Id_videojuego INT NOT NULL,
   Id_biblioteca INT NOT NULL,
   Activo BOOLEAN NOT NULL CHECK (Activo IN (TRUE, FALSE)),
   Tiempo INT CHECK (Tiempo >= 0),
   Fecha VARCHAR(23) NOT NULL CHECK (Fecha ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$'), -- Fecha debe ser DD/MM/AAAA
   Fecha_guardado VARCHAR(23) NOT NULL CHECK (
      Fecha_guardado ~ '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' AND
      TO_DATE(Fecha_guardado, 'DD/MM/YYYY') <= TO_DATE(Fecha, 'DD/MM/YYYY')
   ),
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego) ON DELETE SET NULL,
   FOREIGN KEY (Id_biblioteca) REFERENCES BIBLIOTECA(Id_biblioteca) ON DELETE CASCADE
);

-- Tabla LOGROS_VIDEOJUEGOS
CREATE TABLE LOGROS_VIDEOJUEGOS (
   Id SERIAL PRIMARY KEY,
   Id_videojuego INT NOT NULL,
   Id_logro INT NOT NULL,
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego) ON DELETE SET NULL,
   FOREIGN KEY (Id_logro) REFERENCES LOGROS(Id_logro) ON DELETE CASCADE
);

-- Tabla LOGROS_JUGADOR
CREATE TABLE LOGROS_JUGADOR (
   Id SERIAL PRIMARY KEY,
   Id_logro INT NOT NULL,
   Id_jugador INT NOT NULL, 
   FOREIGN KEY (Id_logro) REFERENCES LOGROS(Id_logro) ON DELETE CASCADE,
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador) ON DELETE CASCADE
);

-- Disparadores
-- Función para actualizar Espacio_usado
CREATE OR REPLACE FUNCTION actualizar_espacio_usado()
RETURNS TRIGGER AS $$
BEGIN
   UPDATE BIBLIOTECA
   SET Espacio_usado = COALESCE((
      SELECT SUM(v.Tamaño)
      FROM BIBLIOTECA_VIDEOJUEGO bv
      JOIN VIDEOJUEGOS v ON bv.Id_videojuego = v.Id_videojuego
      WHERE bv.Id_biblioteca = NEW.Id_biblioteca AND bv.Activo = TRUE
   ), 0)
   WHERE Id_biblioteca = NEW.Id_biblioteca;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Trigger para actualizar Espacio_usado
CREATE TRIGGER trigger_actualizar_espacio_usado
AFTER INSERT OR UPDATE OR DELETE ON BIBLIOTECA_VIDEOJUEGO
FOR EACH ROW
EXECUTE FUNCTION actualizar_espacio_usado();

-- Trigger para actualizar Numero_juegos
CREATE TRIGGER trigger_actualizar_numero_juegos
AFTER INSERT OR UPDATE OR DELETE ON BIBLIOTECA_VIDEOJUEGO
FOR EACH ROW
EXECUTE FUNCTION actualizar_numero_juegos();

-- Inserciones
-- Tabla DESARROLLADOR
INSERT INTO DESARROLLADOR (Contraseña, Nombre, Imagen_perfil, Correo, Pais, Descripcion, Numero_empleados, Presentacion, Pagina_web)
VALUES
('Password123', 'Dev1', 'imagen1.png', 'dev1@mail.com', 'España', 'Desarrollador de RPG', 10, 'Somos lideres en RPG', 'https://www.dev1.com'),
('Password456', 'Dev2', 'imagen2.png', 'dev2@mail.com', 'Mexico', 'Especialistas en FPS', 20, 'FPS competitivos', 'http://www.dev2.com'),
('Password789', 'Dev3', 'imagen3.png', 'dev3@mail.com', 'Argentina', 'Indie developers', 5, 'Juegos independientes unicos', 'http://www.dev3.net'),
('Password321', 'Dev4', 'imagen4.png', 'dev4@mail.com', 'USA', 'Mundo abierto', 15, 'Creamos sandbox inmersivos', 'https://dev4.org'),
('Password654', 'Dev5', 'imagen5.png', 'dev5@mail.com', 'Colombia', 'Desarrollo de aventuras', 12, 'Narrativas envolventes', 'http://www.dev5.com');

-- Tabla DISTRIBUIDOR
INSERT INTO DISTRIBUIDOR (Nombre, Numero_Empleado, Pagina_web, Presentacion)
VALUES
('Distribuidor1', 50, 'https://www.dist1.com', 'Distribuidor global de videojuegos'),
('Distribuidor2', 100, 'http://www.dist2.org', 'Juegos AAA y más'),
('Distribuidor3', 80, 'http://www.dist3.net', 'Distribuidor exclusivo de indies'),
('Distribuidor4', 60, 'https://www.dist4.com', 'Lider en America'),
('Distribuidor5', 40, 'http://www.dist5.org', 'Especializados en ediciones fisicas');

-- Tabla JUGADOR
INSERT INTO JUGADOR (Nombre, Contraseña, Correo, Pais, Imagen_perfil, Descripcion, Tarjeta_credito)
VALUES
('Jugador1', 'Pass12345', 'jugador1@mail.com', 'España', 'perfil1.png', 'Amante de RPGs y aventuras', '1234-5678-9012-3456'),
('Jugador2', 'Pass54321', 'jugador2@mail.com', 'Mexico', 'perfil2.png', 'Fanático de shooters', '1111-2222-3333-4444'),
('Jugador3', 'Pass78910', 'jugador3@mail.com', 'Argentina', 'perfil3.png', 'Explorador de mundos abiertos', '2222-3333-4444-5555'),
('Jugador4', 'Pass00000', 'jugador4@mail.com', 'USA', 'perfil4.png', 'Jugador competitivo', '3333-4444-5555-6666'),
('Jugador5', 'Clave1234', 'jugador5@mail.com', 'Colombia', 'perfil5.png', 'Cazador de logros', '4444-5555-6666-7777');

-- Tabla BIBLIOTECA
INSERT INTO BIBLIOTECA (Id_jugador, Numero_juegos, Espacio_usado)
VALUES
(1, 10, 50.25),
(2, 7, 30.50),
(3, 15, 75.75),
(4, 3, 12.10),
(5, 20, 100.00);

-- Tabla VIDEOJUEGOS
INSERT INTO VIDEOJUEGOS (Nombre, Fecha, Descripcion, Precio, Duracion_oferta, Descuento_oferta, Tamaño)
VALUES
('Aventura Magica', '01/01/2023', 'Juego de rol magico y aventuras', 49.99, '01/01/2023 - 10/01/2023', 10, 20.5),
('Shooter Extremo', '15/02/2023', 'Shooter en primera persona competitivo', 59.99, '15/02/2023 - 25/02/2023', 20, 35.0),
('Mundo Abierto X', '10/03/2023', 'Explora un mundo abierto sin limites', 69.99, '10/03/2023 - 20/03/2023', 15, 50.0),
('Plataformas Retro', '05/04/2023', 'Clasico plataformas con desafios modernos', 29.99, '05/04/2023 - 15/04/2023', 25, 15.0),
('Aventura Grafica Pro', '20/05/2023', 'Juego narrativo con graficos impresionantes', 39.99, '20/05/2023 - 30/05/2023', 30, 18.5);

-- Tabla DLC
INSERT INTO DLC (Id_videojuego, Nombre, Descripcion, Precio)
VALUES
(1, 'Expansion magica', 'Nuevas misiones magicas y zonas', 9.99),
(2, 'Mapas adicionales', 'Nuevos mapas para competir', 4.99),
(3, 'Pack de explorador', 'Objetos exclusivos para explorar', 5.99),
(4, 'Retro DLC', 'Niveles clasicos adicionales', 2.99),
(5, 'Final alternativo', 'Desbloquea un final alternativo', 7.99);

-- Tabla GENEROS
INSERT INTO GENEROS (Nombre, Descripcion)
VALUES
('RPG', 'Juegos de rol con historias epicas'),
('FPS', 'Shooters en primera persona competitivos'),
('Sandbox', 'Exploracion en mundos abiertos'),
('Plataformas', 'Juegos clasicos de plataformas'),
('Narrativo', 'Experiencias narrativas interactivas');

-- Tabla LOGROS
INSERT INTO LOGROS (Nombre, Descripcion, Requisito)
VALUES
('Termina la historia', 'Completa la historia principal', 'Finalizar todas las misiones principales'),
('Explorador', 'Descubre todas las areas del mapa', 'Visita cada rincon del mundo'),
('Coleccionista', 'Recolecta todos los objetos', 'Obten todos los coleccionables'),
('Sin derrotas', 'Completa sin morir', 'No mueras durante el juego'),
('Maestro del tiempo', 'Completa en menos de 2 horas', 'Finaliza el juego en tiempo record');

-- Tabla COMENTARIOS
INSERT INTO COMENTARIOS (Id_jugador, Id_videojuego, Votacion, Gusto, Opinion)
VALUES
(1, 1, 10, TRUE, 'Increible juego, lo recomiendo'),
(2, 2, 8, TRUE, 'Buen multijugador'),
(3, 3, 7, TRUE, 'Clasico plataformas, divertido'),
(4, 4, 6, FALSE, 'Historia aburrida'),
(5, 5, 9, TRUE, 'El mejor sandbox que he jugado');

-- Tabla VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
INSERT INTO VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR (Id_desarrollador, Id_distribuidor, Id_videojuego)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5);

-- Tabla GENEROS_JUGADOR
INSERT INTO GENEROS_JUGADOR (Id_jugador, Id_genero)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Tabla LISTA_DESEADOS
INSERT INTO LISTA_DESEADOS (Id_jugador, Id_videojuego)
VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 1);

-- Tabla BIBLIOTECA_VIDEOJUEGO
INSERT INTO BIBLIOTECA_VIDEOJUEGO (Id_videojuego, Id_biblioteca, Tiempo, Fecha, Activo, Fecha_guardado)
VALUES
(1, 1, 120, '30/12/2023', TRUE, '29/12/2023'),
(2, 2, 100, '01/12/2023', TRUE, '30/11/2023'),
(3, 3, 80, '01/12/2023', TRUE, '30/11/2023'),
(4, 4, 60, '01/07/2023', FALSE, '30/06/2023'),
(5, 5, 150, '01/11/2024', TRUE, '31/10/2024');

-- Tabla LOGROS_VIDEOJUEGOS
INSERT INTO LOGROS_VIDEOJUEGOS (Id_videojuego, Id_logro)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Tabla LOGROS_JUGADOR
INSERT INTO LOGROS_JUGADOR (Id_logro, Id_jugador)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

