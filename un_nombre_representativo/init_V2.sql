
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
('Password654', 'Dev5', 'imagen5.png', 'dev5@mail.com', 'Colombia', 'Desarrollo de aventuras', 12, 'Narrativas envolventes', 'http://www.dev5.com'),
('Pass1111', 'Dev6', 'imagen6.png', 'dev6@mail.com', 'Chile', 'Expertos en juegos de plataformas', 8, 'Plataformas creativas y desafiantes', 'http://www.dev6.cl'),
('Pass2222', 'Dev7', 'imagen7.png', 'dev7@mail.com', 'Peru', 'Desarrolladores VR', 25, 'Realidad virtual inmersiva', 'https://www.dev7vr.com'),
('Pass3333', 'Dev8', 'imagen8.png', 'dev8@mail.com', 'Brasil', 'Juegos multijugador', 50, 'Lideramos en multijugador online', 'http://www.dev8.com.br'),
('Pass4444', 'Dev9', 'imagen9.png', 'dev9@mail.com', 'Uruguay', 'Desarrollo de survival', 18, 'Juegos survival en tiempo real', 'http://www.dev9survival.com'),
('Pass5555', 'Dev10', 'imagen10.png', 'dev10@mail.com', 'Paraguay', 'Simuladores de construcción', 10, 'Simulación de construcción avanzada', 'https://dev10simulacion.com'),
('Pass6566', 'Dev11', 'imagen11.png', 'dev11@mail.com', 'España', 'Juegos de puzzles', 6, 'Innovación en puzzles y lógica', 'http://www.dev11puzzle.es'),
('Pass77237', 'Dev12', 'imagen12.png', 'dev12@mail.com', 'Bolivia', 'Juegos educativos', 15, 'Educación a través del juego', 'http://www.dev12edu.com'),
('Pass8838', 'Dev13', 'imagen13.png', 'dev13@mail.com', 'Venezuela', 'RPG clásicos', 20, 'Creadores de RPG nostálgicos', 'https://www.dev13rpg.net'),
('Pass9599', 'Dev14', 'imagen14.png', 'dev14@mail.com', 'USA', 'Juegos de terror', 30, 'Terror psicológico innovador', 'https://dev14horror.com'),
('Pass0300', 'Dev15', 'imagen15.png', 'dev15@mail.com', 'México', 'MMORPG de fantasía', 40, 'Explora mundos de fantasía masivos', 'http://www.dev15mmo.mx'),
('Pass15116', 'Dev16', 'imagen16.png', 'dev16@mail.com', 'Ecuador', 'Desarrolladores de carreras', 22, 'Velocidad y adrenalina en cada juego', 'https://www.dev16race.com'),
('Pass11517', 'Dev17', 'imagen17.png', 'dev17@mail.com', 'España', 'Juegos deportivos', 35, 'Lideres en simulación deportiva', 'http://www.dev17sports.es'),
('Pass11318', 'Dev18', 'imagen18.png', 'dev18@mail.com', 'Portugal', 'Desarrollo de sandbox', 12, 'Mundos abiertos llenos de libertad', 'https://dev18sandbox.pt'),
('Pass153119', 'Dev19', 'imagen19.png', 'dev19@mail.com', 'Alemania', 'Estrategia en tiempo real', 28, 'RTS innovadores y competitivos', 'http://www.dev19rts.de'),
('Pass13120', 'Dev20', 'imagen20.png', 'dev20@mail.com', 'Francia', 'Simuladores de vida', 30, 'Vida virtual como nunca antes', 'https://www.dev20sim.fr'),
('Pass11521', 'Dev21', 'imagen21.png', 'dev21@mail.com', 'Italia', 'Desarrolladores de roguelike', 10, 'Roguelike desafiantes y adictivos', 'http://www.dev21rogue.it'),
('Pass13122', 'Dev22', 'imagen22.png', 'dev22@mail.com', 'Reino Unido', 'Juegos de acción', 50, 'Acción frenética para todos', 'http://www.dev22action.uk'),
('Pass115523', 'Dev23', 'imagen23.png', 'dev23@mail.com', 'Rusia', 'Shooters tácticos', 40, 'Estrategia y disparos realistas', 'https://dev23shooter.ru'),
('Pass11234', 'Dev24', 'imagen24.png', 'dev24@mail.com', 'China', 'Desarrolladores móviles', 60, 'Experiencias únicas en móviles', 'https://www.dev24mobile.cn'),
('Pass15125', 'Dev25', 'imagen25.png', 'dev25@mail.com', 'Japón', 'JRPG clásicos', 45, 'Reviviendo la magia de los JRPG', 'http://www.dev25jrpg.jp'),
('Pass13126', 'Dev26', 'imagen26.png', 'dev26@mail.com', 'Corea del Sur', 'MMORPG innovadores', 70, 'Mundos online espectaculares', 'https://www.dev26mmo.kr'),
('Pass11257', 'Dev27', 'imagen27.png', 'dev27@mail.com', 'India', 'Juegos de aventura', 33, 'Narrativas y aventuras épicas', 'http://www.dev27adventure.in'),
('Pass13128', 'Dev28', 'imagen28.png', 'dev28@mail.com', 'Australia', 'Survival horror', 18, 'Experiencias aterradoras únicas', 'http://www.dev28horror.au'),
('Pass11329', 'Dev29', 'imagen29.png', 'dev29@mail.com', 'Nueva Zelanda', 'Juegos de exploración', 12, 'Explora mundos desconocidos', 'https://dev29explore.nz'),
('Pass11530', 'Dev30', 'imagen30.png', 'dev30@mail.com', 'Sudáfrica', 'Juegos de estrategia', 25, 'Estrategia que desafía mentes', 'http://www.dev30strategy.za'),
('Pass11331', 'Dev31', 'imagen31.png', 'dev31@mail.com', 'Nigeria', 'Educación gamificada', 20, 'Aprende jugando', 'http://www.dev31edu.ng'),
('Pass11332', 'Dev32', 'imagen32.png', 'dev32@mail.com', 'Egipto', 'Juegos históricos', 15, 'Historia traída a la vida', 'https://www.dev32history.eg'),
('Pass13133', 'Dev33', 'imagen33.png', 'dev33@mail.com', 'Turquía', 'Juegos de misterio', 14, 'Resuelve enigmas y misterios', 'http://www.dev33mystery.tr'),
('Pass12134', 'Dev34', 'imagen34.png', 'dev34@mail.com', 'Grecia', 'Juegos mitológicos', 10, 'Explora la mitología griega', 'https://www.dev34myth.gr'),
('Pass15135', 'Dev35', 'imagen35.png', 'dev35@mail.com', 'Canadá', 'Juegos narrativos', 28, 'Historias cautivadoras', 'http://www.dev35story.ca'),
('Pass15136', 'Dev36', 'imagen36.png', 'dev36@mail.com', 'Suecia', 'Juegos cooperativos', 16, 'Diversión en equipo asegurada', 'https://www.dev36coop.se'),
('Pass16137', 'Dev37', 'imagen37.png', 'dev37@mail.com', 'Noruega', 'Juegos de supervivencia', 22, 'Supervivencia extrema', 'http://www.dev37survival.no'),
('Pass16138', 'Dev38', 'imagen38.png', 'dev38@mail.com', 'Finlandia', 'Roguelite modernos', 13, 'Innovación en roguelites', 'https://www.dev38rogue.fi'),
('Pass11439', 'Dev39', 'imagen39.png', 'dev39@mail.com', 'Polonia', 'Juegos de ciencia ficción', 35, 'Futuro y tecnología en juegos', 'http://www.dev39sci-fi.pl'),
('Pass13140', 'Dev40', 'imagen40.png', 'dev40@mail.com', 'Austria', 'Juegos familiares', 12, 'Diversión para toda la familia', 'https://www.dev40family.at'),
('Pass11341', 'Dev41', 'imagen41.png', 'dev41@mail.com', 'Bélgica', 'Juegos indie innovadores', 8, 'Creatividad sin límites', 'http://www.dev41indie.be'),
('Pass14142', 'Dev42', 'imagen42.png', 'dev42@mail.com', 'Suiza', 'Juegos de simulación', 30, 'Simulación precisa y realista', 'https://www.dev42sim.ch'),
('Pass13143', 'Dev43', 'imagen43.png', 'dev43@mail.com', 'Países Bajos', 'Desarrollo de shooters', 50, 'Shooters para todas las plataformas', 'http://www.dev43shoot.nl'),
('Pass15144', 'Dev44', 'imagen44.png', 'dev44@mail.com', 'Dinamarca', 'Juegos de estrategia táctica', 18, 'Estrategia con táctica avanzada', 'https://www.dev44tactics.dk'),
('Pass11345', 'Dev45', 'imagen45.png', 'dev45@mail.com', 'Hungría', 'Desarrollo de plataformas 2D', 10, 'Plataformas que encantan', 'http://www.dev45platform.hu'),
('Pass11446', 'Dev46', 'imagen46.png', 'dev46@mail.com', 'República Checa', 'Juegos medievales', 22, 'Revive la era medieval', 'http://www.dev46medieval.cz'),
('Pass11547', 'Dev47', 'imagen47.png', 'dev47@mail.com', 'Rumanía', 'Juegos de combate', 17, 'Combates realistas e intensos', 'https://www.dev47combat.ro'),
('Pass11648', 'Dev48', 'imagen48.png', 'dev48@mail.com', 'Bulgaria', 'Juegos de horror psicológico', 20, 'Miedo que te envuelve', 'http://www.dev48horror.bg'),
('Pass13149', 'Dev49', 'imagen49.png', 'dev49@mail.com', 'Serbia', 'Juegos retro', 12, 'Revive la nostalgia retro', 'https://www.dev49retro.rs'),
('Pass14150', 'Dev50', 'imagen50.png', 'dev50@mail.com', 'Croacia', 'Juegos futuristas', 25, 'Explora el mañana', 'http://www.dev50future.hr');

-- Tabla DISTRIBUIDOR
INSERT INTO DISTRIBUIDOR (Nombre, Numero_Empleado, Pagina_web, Presentacion)
VALUES
('Distribuidor1', 50, 'https://www.dist1.com', 'Distribuidor global de videojuegos'),
('Distribuidor2', 100, 'http://www.dist2.org', 'Juegos AAA y más'),
('Distribuidor3', 80, 'http://www.dist3.net', 'Distribuidor exclusivo de indies'),
('Distribuidor4', 60, 'https://www.dist4.com', 'Lider en America'),
('Distribuidor5', 40, 'http://www.dist5.org', 'Especializados en ediciones fisicas'),
('Distribuidor6', 70, 'https://www.dist6.net', 'Distribuidor digital líder en Europa'),
('Distribuidor7', 90, 'http://www.dist7.com', 'Apasionados por los videojuegos retro'),
('Distribuidor8', 55, 'https://www.dist8.org', 'Distribuidor de software interactivo'),
('Distribuidor9', 120, 'http://www.dist9.net', 'Grandes éxitos en juegos AAA'),
('Distribuidor10', 45, 'https://www.dist10.com', 'Distribución de juegos independientes'),
('Distribuidor11', 75, 'http://www.dist11.org', 'Juegos de PC y consolas'),
('Distribuidor12', 65, 'https://www.dist12.net', 'Distribuidor regional en Asia'),
('Distribuidor13', 85, 'http://www.dist13.com', 'Distribución en mercados emergentes'),
('Distribuidor14', 95, 'https://www.dist14.org', 'Plataforma global de distribución'),
('Distribuidor15', 110, 'http://www.dist15.net', 'Distribuidor de contenido premium'),
('Distribuidor16', 50, 'https://www.dist16.com', 'Distribuidor exclusivo de VR'),
('Distribuidor17', 130, 'http://www.dist17.org', 'Líder mundial en juegos digitales'),
('Distribuidor18', 35, 'https://www.dist18.net', 'Ediciones especiales y limitadas'),
('Distribuidor19', 60, 'http://www.dist19.com', 'Distribuidor de arcade clásicos'),
('Distribuidor20', 40, 'https://www.dist20.org', 'Distribuidor de juegos móviles'),
('Distribuidor21', 85, 'http://www.dist21.net', 'Distribuidor de títulos multiplataforma'),
('Distribuidor22', 90, 'https://www.dist22.com', 'Juegos casuales y de familia'),
('Distribuidor23', 100, 'http://www.dist23.org', 'Distribuidor AAA en América Latina'),
('Distribuidor24', 45, 'https://www.dist24.net', 'Plataforma indie y creativa'),
('Distribuidor25', 70, 'http://www.dist25.com', 'Distribución global de shooters'),
('Distribuidor26', 120, 'https://www.dist26.org', 'Líder en juegos deportivos'),
('Distribuidor27', 55, 'http://www.dist27.net', 'Distribuidor de aventuras gráficas'),
('Distribuidor28', 65, 'https://www.dist28.com', 'Simuladores y juegos educativos'),
('Distribuidor29', 75, 'http://www.dist29.org', 'Distribuidor de títulos exclusivos'),
('Distribuidor30', 110, 'https://www.dist30.net', 'Especializados en juegos cooperativos'),
('Distribuidor31', 95, 'http://www.dist31.com', 'Distribuidor global de RPGs'),
('Distribuidor32', 40, 'https://www.dist32.org', 'Distribuidor local en Europa del Este'),
('Distribuidor33', 130, 'http://www.dist33.net', 'Distribuidor de mundos abiertos'),
('Distribuidor34', 100, 'https://www.dist34.com', 'Plataforma para estudios AAA'),
('Distribuidor35', 60, 'http://www.dist35.org', 'Especializados en terror psicológico'),
('Distribuidor36', 85, 'https://www.dist36.net', 'Distribuidor de juegos de estrategia'),
('Distribuidor37', 55, 'http://www.dist37.com', 'Distribuidor de juegos casuales'),
('Distribuidor38', 120, 'https://www.dist38.org', 'Líder en juegos de acción'),
('Distribuidor39', 90, 'http://www.dist39.net', 'Distribuidor en mercados digitales'),
('Distribuidor40', 35, 'https://www.dist40.com', 'Distribución de juegos para móviles'),
('Distribuidor41', 45, 'http://www.dist41.org', 'Distribuidor de ediciones físicas exclusivas'),
('Distribuidor42', 70, 'https://www.dist42.net', 'Distribuidor de juegos de carreras'),
('Distribuidor43', 100, 'http://www.dist43.com', 'Distribuidor especializado en VR'),
('Distribuidor44', 85, 'https://www.dist44.org', 'Plataforma de juegos educativos'),
('Distribuidor45', 65, 'http://www.dist45.net', 'Distribuidor de RPGs de culto'),
('Distribuidor46', 50, 'https://www.dist46.com', 'Distribuidor de juegos de puzzles'),
('Distribuidor47', 110, 'http://www.dist47.org', 'Distribuidor de aventuras narrativas'),
('Distribuidor48', 90, 'https://www.dist48.net', 'Distribuidor de títulos exclusivos de consola'),
('Distribuidor49', 75, 'http://www.dist49.com', 'Distribuidor de juegos retro-modernizados'),
('Distribuidor50', 130, 'https://www.dist50.org', 'Distribuidor internacional líder en innovación');

-- Tabla JUGADOR
INSERT INTO JUGADOR (Nombre, Contraseña, Correo, Pais, Imagen_perfil, Descripcion, Tarjeta_credito)
VALUES
('Jugador1', 'Pass12345', 'jugador1@mail.com', 'España', 'perfil1.png', 'Amante de RPGs y aventuras', '1234-5678-9012-3456'),
('Jugador2', 'Pass54321', 'jugador2@mail.com', 'Mexico', 'perfil2.png', 'Fanático de shooters', '1111-2222-3333-4444'),
('Jugador3', 'Pass78910', 'jugador3@mail.com', 'Argentina', 'perfil3.png', 'Explorador de mundos abiertos', '2222-3333-4444-5555'),
('Jugador4', 'Pass00000', 'jugador4@mail.com', 'USA', 'perfil4.png', 'Jugador competitivo', '3333-4444-5555-6666'),
('Jugador5', 'Clave1234', 'jugador5@mail.com', 'Colombia', 'perfil5.png', 'Cazador de logros', '4444-5555-6666-7777'),
('Jugador6', 'Gamer9876', 'jugador6@mail.com', 'Brasil', 'perfil6.png', 'Coleccionista de skins', '5555-6666-7777-8888'),
('Jugador7', 'SecurePass7', 'jugador7@mail.com', 'Chile', 'perfil7.png', 'Fan de juegos retro', '6666-7777-8888-9999'),
('Jugador8', 'Pass2023', 'jugador8@mail.com', 'Perú', 'perfil8.png', 'Amante de survival horror', '7777-8888-9999-0000'),
('Jugador9', 'Clave2024', 'jugador9@mail.com', 'Ecuador', 'perfil9.png', 'Jugador casual', '8888-9999-0000-1111'),
('Jugador10', 'GameTime10', 'jugador10@mail.com', 'Venezuela', 'perfil10.png', 'Streamer de juegos indie', '9999-0000-1111-2222'),
('Jugador11', 'TopPlayer11', 'jugador11@mail.com', 'Uruguay', 'perfil11.png', 'Fanático de deportes virtuales', '0000-1111-2222-3333'),
('Jugador12', 'PassForFun12', 'jugador12@mail.com', 'Paraguay', 'perfil12.png', 'Competidor en shooters tácticos', '1111-2222-3333-4444'),
('Jugador13', 'SecurePlay13', 'jugador13@mail.com', 'Bolivia', 'perfil13.png', 'Explorador de mundos MMORPG', '2222-3333-4444-5555'),
('Jugador14', 'MyPass14', 'jugador14@mail.com', 'Panama', 'perfil14.png', 'Coleccionista de logros', '3333-4444-5555-6666'),
('Jugador15', 'PlaySafe15', 'jugador15@mail.com', 'Cuba', 'perfil15.png', 'Amante de los sandbox', '4444-5555-6666-7777'),
('Jugador16', 'UltraGamer16', 'jugador16@mail.com', 'Puerto Rico', 'perfil16.png', 'Jugador de estrategia', '5555-6666-7777-8888'),
('Jugador17', 'PassHero17', 'jugador17@mail.com', 'México', 'perfil17.png', 'Competidor en esports', '6666-7777-8888-9999'),
('Jugador18', 'SafeCode18', 'jugador18@mail.com', 'España', 'perfil18.png', 'Fan de juegos narrativos', '7777-8888-9999-0000'),
('Jugador19', 'GamerPass19', 'jugador19@mail.com', 'Colombia', 'perfil19.png', 'Coleccionista de ediciones físicas', '8888-9999-0000-1111'),
('Jugador20', 'StrongPass20', 'jugador20@mail.com', 'Argentina', 'perfil20.png', 'Amante de los juegos de terror', '9999-0000-1111-2222'),
('Jugador21', 'KeyGame21', 'jugador21@mail.com', 'Brasil', 'perfil21.png', 'Jugador de MOBAs', '0000-1111-2222-3333'),
('Jugador22', 'GamerSecure22', 'jugador22@mail.com', 'USA', 'perfil22.png', 'Streamer de juegos casuales', '1111-2222-3333-4444'),
('Jugador23', 'HardPass23', 'jugador23@mail.com', 'Chile', 'perfil23.png', 'Jugador de simuladores', '2222-3333-4444-5555'),
('Jugador24', 'EpicCode24', 'jugador24@mail.com', 'Perú', 'perfil24.png', 'Creador de contenido RPG', '3333-4444-5555-6666'),
('Jugador25', 'MegaPass25', 'jugador25@mail.com', 'Ecuador', 'perfil25.png', 'Jugador de carreras', '4444-5555-6666-7777'),
('Jugador26', 'PassUltra26', 'jugador26@mail.com', 'Venezuela', 'perfil26.png', 'Competidor en Battle Royale', '5555-6666-7777-8888'),
('Jugador27', 'PlaySafe27', 'jugador27@mail.com', 'Uruguay', 'perfil27.png', 'Streamer de juegos retro', '6666-7777-8888-9999'),
('Jugador28', 'GameZone28', 'jugador28@mail.com', 'Paraguay', 'perfil28.png', 'Cazador de logros difíciles', '7777-8888-9999-0000'),
('Jugador29', 'StrongGame29', 'jugador29@mail.com', 'Bolivia', 'perfil29.png', 'Fanático de survival', '8888-9999-0000-1111'),
('Jugador30', 'ProPass30', 'jugador30@mail.com', 'Panamá', 'perfil30.png', 'Amante de los juegos narrativos', '9999-0000-1111-2222'),
('Jugador31', 'TopSecure31', 'jugador31@mail.com', 'Cuba', 'perfil31.png', 'Coleccionista de skins raras', '0000-1111-2222-3333'),
('Jugador32', 'EpicGamer32', 'jugador32@mail.com', 'Puerto Rico', 'perfil32.png', 'Jugador de estrategia avanzada', '1111-2222-3333-4444'),
('Jugador33', 'UltraKey33', 'jugador33@mail.com', 'México', 'perfil33.png', 'Fanático de la ciencia ficción', '2222-3333-4444-5555'),
('Jugador34', 'SafePlayer34', 'jugador34@mail.com', 'España', 'perfil34.png', 'Jugador de mundos abiertos', '3333-4444-5555-6666'),
('Jugador35', 'PassMax35', 'jugador35@mail.com', 'Colombia', 'perfil35.png', 'Fan de peleas arcade', '4444-5555-6666-7777'),
('Jugador36', 'HardCode36', 'jugador36@mail.com', 'Argentina', 'perfil36.png', 'Cazador de secretos en juegos', '5555-6666-7777-8888'),
('Jugador37', 'SecureTop37', 'jugador37@mail.com', 'Brasil', 'perfil37.png', 'Amante de desafíos RPG', '6666-7777-8888-9999'),
('Jugador38', 'MaxPlayer38', 'jugador38@mail.com', 'USA', 'perfil38.png', 'Jugador de shooters competitivos', '7777-8888-9999-0000'),
('Jugador39', 'StrongGamer39', 'jugador39@mail.com', 'Chile', 'perfil39.png', 'Creador de contenido retro', '8888-9999-0000-1111'),
('Jugador40', 'GameSecure40', 'jugador40@mail.com', 'Perú', 'perfil40.png', 'Fanático de VR', '9999-0000-1111-2222'),
('Jugador41', 'SafeCode41', 'jugador41@mail.com', 'Ecuador', 'perfil41.png', 'Coleccionista de logros', '0000-1111-2222-3333'),
('Jugador42', 'TopPass42', 'jugador42@mail.com', 'Venezuela', 'perfil42.png', 'Streamer de MOBAs', '1111-2222-3333-4444'),
('Jugador43', 'SecurePlay43', 'jugador43@mail.com', 'Uruguay', 'perfil43.png', 'Competidor de juegos retro', '2222-3333-4444-5555'),
('Jugador44', 'EpicZone44', 'jugador44@mail.com', 'Paraguay', 'perfil44.png', 'Fan de juegos de plataformas', '3333-4444-5555-6666'),
('Jugador45', 'ProGamer45', 'jugador45@mail.com', 'Bolivia', 'perfil45.png', 'Jugador de puzzles', '4444-5555-6666-7777'),
('Jugador46', 'PassEpic46', 'jugador46@mail.com', 'Panamá', 'perfil46.png', 'Amante de shooters tácticos', '5555-6666-7777-8888'),
('Jugador47', 'KeyZone47', 'jugador47@mail.com', 'Cuba', 'perfil47.png', 'Fan de juegos de cartas', '6666-7777-8888-9999'),
('Jugador48', 'UltraGame48', 'jugador48@mail.com', 'Puerto Rico', 'perfil48.png', 'Creador de contenido indie', '7777-8888-9999-0000'),
('Jugador49', 'ProSafe49', 'jugador49@mail.com', 'México', 'perfil49.png', 'Jugador de arcade clásicos', '8888-9999-0000-1111'),
('Jugador50', 'SecureMax50', 'jugador50@mail.com', 'España', 'perfil50.png', 'Competidor en juegos sandbox', '9999-0000-1111-2222'),
('Jugador51', 'GamerHero51', 'jugador51@mail.com', 'España', 'perfil51.png', 'Fan de aventuras gráficas', '6666-7777-8888-9999'),
('Jugador52', 'UltraSafe52', 'jugador52@mail.com', 'Colombia', 'perfil52.png', 'Cazador de logros difíciles', '7777-8888-9999-0000'),
('Jugador53', 'MegaCode53', 'jugador53@mail.com', 'Argentina', 'perfil53.png', 'Explorador de mundos abiertos', '8888-9999-0000-1111'),
('Jugador54', 'EpicGame54', 'jugador54@mail.com', 'Brasil', 'perfil54.png', 'Coleccionista de skins exclusivas', '9999-0000-1111-2222'),
('Jugador55', 'PlaySecure55', 'jugador55@mail.com', 'USA', 'perfil55.png', 'Competidor en shooters tácticos', '0000-1111-2222-3333'),
('Jugador56', 'GameHero56', 'jugador56@mail.com', 'Chile', 'perfil56.png', 'Amante de los sandbox creativos', '1111-2222-3333-4444'),
('Jugador57', 'SafeGamer57', 'jugador57@mail.com', 'Perú', 'perfil57.png', 'Jugador casual de indies', '2222-3333-4444-5555'),
('Jugador58', 'CodeMaster58', 'jugador58@mail.com', 'Ecuador', 'perfil58.png', 'Creador de contenido retro', '3333-4444-5555-6666'),
('Jugador59', 'UltraPlay59', 'jugador59@mail.com', 'Venezuela', 'perfil59.png', 'Fanático de juegos de terror', '4444-5555-6666-7777'),
('Jugador60', 'HardGame60', 'jugador60@mail.com', 'Uruguay', 'perfil60.png', 'Jugador competitivo en FPS', '5555-6666-7777-8888'),
('Jugador61', 'PassEpic61', 'jugador61@mail.com', 'Paraguay', 'perfil61.png', 'Streamer de aventuras gráficas', '6666-7777-8888-9999'),
('Jugador62', 'SafeZone62', 'jugador62@mail.com', 'Bolivia', 'perfil62.png', 'Cazador de misiones secundarias', '7777-8888-9999-0000'),
('Jugador63', 'TopCode63', 'jugador63@mail.com', 'Panamá', 'perfil63.png', 'Amante de los desafíos RPG', '8888-9999-0000-1111'),
('Jugador64', 'StrongPlay64', 'jugador64@mail.com', 'Cuba', 'perfil64.png', 'Fan de peleas competitivas', '9999-0000-1111-2222'),
('Jugador65', 'GameMaster65', 'jugador65@mail.com', 'Puerto Rico', 'perfil65.png', 'Jugador de carreras arcade', '0000-1111-2222-3333'),
('Jugador66', 'UltraHero66', 'jugador66@mail.com', 'México', 'perfil66.png', 'Fanático de juegos retro', '1111-2222-3333-4444'),
('Jugador67', 'SafeGamer67', 'jugador67@mail.com', 'España', 'perfil67.png', 'Competidor en esports', '2222-3333-4444-5555'),
('Jugador68', 'MaxPass68', 'jugador68@mail.com', 'Colombia', 'perfil68.png', 'Coleccionista de ediciones limitadas', '3333-4444-5555-6666'),
('Jugador69', 'CodeHero69', 'jugador69@mail.com', 'Argentina', 'perfil69.png', 'Streamer de shooters', '4444-5555-6666-7777'),
('Jugador70', 'GamerZone70', 'jugador70@mail.com', 'Brasil', 'perfil70.png', 'Fan de juegos de estrategia', '5555-6666-7777-8888'),
('Jugador71', 'SafePass71', 'jugador71@mail.com', 'USA', 'perfil71.png', 'Amante de los survival horror', '6666-7777-8888-9999'),
('Jugador72', 'GameEpic72', 'jugador72@mail.com', 'Chile', 'perfil72.png', 'Jugador de simuladores avanzados', '7777-8888-9999-0000'),
('Jugador73', 'HeroPass73', 'jugador73@mail.com', 'Perú', 'perfil73.png', 'Cazador de secretos en RPGs', '8888-9999-0000-1111'),
('Jugador74', 'UltraSafe74', 'jugador74@mail.com', 'Ecuador', 'perfil74.png', 'Jugador competitivo en MOBAs', '9999-0000-1111-2222'),
('Jugador75', 'EpicPlay75', 'jugador75@mail.com', 'Venezuela', 'perfil75.png', 'Streamer de aventuras narrativas', '0000-1111-2222-3333'),
('Jugador76', 'MegaPass76', 'jugador76@mail.com', 'Uruguay', 'perfil76.png', 'Competidor en torneos FPS', '1111-2222-3333-4444'),
('Jugador77', 'CodeZone77', 'jugador77@mail.com', 'Paraguay', 'perfil77.png', 'Fan de juegos de carreras', '2222-3333-4444-5555'),
('Jugador78', 'TopHero78', 'jugador78@mail.com', 'Bolivia', 'perfil78.png', 'Jugador casual de shooters', '3333-4444-5555-6666'),
('Jugador79', 'GameKey79', 'jugador79@mail.com', 'Panamá', 'perfil79.png', 'Fanático de peleas retro', '4444-5555-6666-7777'),
('Jugador80', 'SecureEpic80', 'jugador80@mail.com', 'Cuba', 'perfil80.png', 'Creador de contenido sandbox', '5555-6666-7777-8888'),
('Jugador81', 'UltraSafe81', 'jugador81@mail.com', 'Puerto Rico', 'perfil81.png', 'Explorador de mundos MMORPG', '6666-7777-8888-9999'),
('Jugador82', 'PassZone82', 'jugador82@mail.com', 'México', 'perfil82.png', 'Cazador de logros RPG', '7777-8888-9999-0000'),
('Jugador83', 'SafeHero83', 'jugador83@mail.com', 'España', 'perfil83.png', 'Fanático de shooters arcade', '8888-9999-0000-1111'),
('Jugador84', 'MaxCode84', 'jugador84@mail.com', 'Colombia', 'perfil84.png', 'Streamer de simuladores', '9999-0000-1111-2222'),
('Jugador85', 'HeroPass85', 'jugador85@mail.com', 'Argentina', 'perfil85.png', 'Competidor de juegos retro', '0000-1111-2222-3333'),
('Jugador86', 'UltraPlay86', 'jugador86@mail.com', 'Brasil', 'perfil86.png', 'Jugador casual de RPGs', '1111-2222-3333-4444'),
('Jugador87', 'EpicPass87', 'jugador87@mail.com', 'USA', 'perfil87.png', 'Fan de aventuras cooperativas', '2222-3333-4444-5555'),
('Jugador88', 'MegaSafe88', 'jugador88@mail.com', 'Chile', 'perfil88.png', 'Explorador de mundos sandbox', '3333-4444-5555-6666'),
('Jugador89', 'GameHero89', 'jugador89@mail.com', 'Perú', 'perfil89.png', 'Fanático de MOBAs competitivos', '4444-5555-6666-7777'),
('Jugador90', 'CodeEpic90', 'jugador90@mail.com', 'Ecuador', 'perfil90.png', 'Jugador de peleas arcade', '5555-6666-7777-8888'),
('Jugador91', 'PassZone91', 'jugador91@mail.com', 'Venezuela', 'perfil91.png', 'Coleccionista de skins', '6666-7777-8888-9999'),
('Jugador92', 'SafePlay92', 'jugador92@mail.com', 'Uruguay', 'perfil92.png', 'Creador de contenido RPG', '7777-8888-9999-0000'),
('Jugador93', 'TopPass93', 'jugador93@mail.com', 'Paraguay', 'perfil93.png', 'Competidor en shooters tácticos', '8888-9999-0000-1111'),
('Jugador94', 'HeroCode94', 'jugador94@mail.com', 'Bolivia', 'perfil94.png', 'Jugador casual de aventuras', '9999-0000-1111-2222'),
('Jugador95', 'UltraKey95', 'jugador95@mail.com', 'Panamá', 'perfil95.png', 'Fanático de simuladores', '0000-1111-2222-3333'),
('Jugador96', 'MegaPass96', 'jugador96@mail.com', 'Cuba', 'perfil96.png', 'Coleccionista de logros difíciles', '1111-2222-3333-4444'),
('Jugador97', 'SafeHero97', 'jugador97@mail.com', 'Puerto Rico', 'perfil97.png', 'Jugador competitivo de MOBAs', '2222-3333-4444-5555'),
('Jugador98', 'EpicCode98', 'jugador98@mail.com', 'México', 'perfil98.png', 'Amante de los juegos retro', '3333-4444-5555-6666'),
('Jugador99', 'TopGame99', 'jugador99@mail.com', 'España', 'perfil99.png', 'Competidor de simuladores de vuelo', '4444-5555-6666-7777'),
('Jugador100', 'SecurePass100', 'jugador100@mail.com', 'Colombia', 'perfil100.png', 'Streamer de juegos narrativos', '5555-6666-7777-8888'),
('Jugador101', 'PassSecure101', 'jugador101@mail.com', 'Argentina', 'perfil101.png', 'Fanático de aventuras y RPGs', '1111-2222-3333-4444'),
('Jugador102', 'UltraGame102', 'jugador102@mail.com', 'México', 'perfil102.png', 'Jugador casual de FPS', '2222-3333-4444-5555'),
('Jugador103', 'GamerPass103', 'jugador103@mail.com', 'España', 'perfil103.png', 'Competidor de MOBAs', '3333-4444-5555-6666'),
('Jugador104', 'SafeZone104', 'jugador104@mail.com', 'Colombia', 'perfil104.png', 'Streamer de juegos de terror', '4444-5555-6666-7777'),
('Jugador105', 'MegaHero105', 'jugador105@mail.com', 'Brasil', 'perfil105.png', 'Amante de peleas arcade', '5555-6666-7777-8888'),
('Jugador106', 'EpicSafe106', 'jugador106@mail.com', 'Chile', 'perfil106.png', 'Fan de mundos abiertos', '6666-7777-8888-9999'),
('Jugador107', 'UltraZone107', 'jugador107@mail.com', 'Perú', 'perfil107.png', 'Cazador de logros difíciles', '7777-8888-9999-0000'),
('Jugador108', 'CodeMaster108', 'jugador108@mail.com', 'Ecuador', 'perfil108.png', 'Competidor de shooters tácticos', '8888-9999-0000-1111'),
('Jugador109', 'GamerZone109', 'jugador109@mail.com', 'Uruguay', 'perfil109.png', 'Fanático de carreras arcade', '9999-0000-1111-2222'),
('Jugador110', 'SafeGame110', 'jugador110@mail.com', 'Venezuela', 'perfil110.png', 'Streamer de juegos retro', '0000-1111-2222-3333'),
('Jugador111', 'HeroCode111', 'jugador111@mail.com', 'Paraguay', 'perfil111.png', 'Jugador de aventuras cooperativas', '1111-2222-3333-4444'),
('Jugador112', 'TopPass112', 'jugador112@mail.com', 'Bolivia', 'perfil112.png', 'Explorador de mundos MMORPG', '2222-3333-4444-5555'),
('Jugador113', 'UltraSafe113', 'jugador113@mail.com', 'Panamá', 'perfil113.png', 'Competidor de MOBAs', '3333-4444-5555-6666'),
('Jugador114', 'SecurePlay114', 'jugador114@mail.com', 'Cuba', 'perfil114.png', 'Cazador de tesoros en RPGs', '4444-5555-6666-7777'),
('Jugador115', 'EpicHero115', 'jugador115@mail.com', 'Puerto Rico', 'perfil115.png', 'Fan de simuladores de vuelo', '5555-6666-7777-8888'),
('Jugador116', 'CodeSafe116', 'jugador116@mail.com', 'México', 'perfil116.png', 'Streamer de shooters tácticos', '6666-7777-8888-9999'),
('Jugador117', 'UltraPass117', 'jugador117@mail.com', 'España', 'perfil117.png', 'Competidor de carreras arcade', '7777-8888-9999-0000'),
('Jugador118', 'MegaZone118', 'jugador118@mail.com', 'Argentina', 'perfil118.png', 'Fanático de juegos narrativos', '8888-9999-0000-1111'),
('Jugador119', 'GameHero119', 'jugador119@mail.com', 'Brasil', 'perfil119.png', 'Jugador de peleas competitivas', '9999-0000-1111-2222'),
('Jugador120', 'SafeMaster120', 'jugador120@mail.com', 'Colombia', 'perfil120.png', 'Creador de contenido RPG', '0000-1111-2222-3333'),
('Jugador121', 'SecurePass121', 'jugador121@mail.com', 'Chile', 'perfil121.png', 'Fan de juegos de terror', '1111-2222-3333-4444'),
('Jugador122', 'EpicCode122', 'jugador122@mail.com', 'Perú', 'perfil122.png', 'Explorador de mundos abiertos', '2222-3333-4444-5555'),
('Jugador123', 'MegaSafe123', 'jugador123@mail.com', 'Ecuador', 'perfil123.png', 'Streamer de MOBAs competitivos', '3333-4444-5555-6666'),
('Jugador124', 'GamerZone124', 'jugador124@mail.com', 'Uruguay', 'perfil124.png', 'Competidor en juegos de estrategia', '4444-5555-6666-7777'),
('Jugador125', 'UltraHero125', 'jugador125@mail.com', 'Venezuela', 'perfil125.png', 'Jugador casual de aventuras', '5555-6666-7777-8888'),
('Jugador126', 'CodeEpic126', 'jugador126@mail.com', 'Paraguay', 'perfil126.png', 'Cazador de logros RPG', '6666-7777-8888-9999'),
('Jugador127', 'SafePlay127', 'jugador127@mail.com', 'Bolivia', 'perfil127.png', 'Fanático de sandbox creativos', '7777-8888-9999-0000'),
('Jugador128', 'TopZone128', 'jugador128@mail.com', 'Panamá', 'perfil128.png', 'Competidor de peleas retro', '8888-9999-0000-1111'),
('Jugador129', 'EpicSafe129', 'jugador129@mail.com', 'Cuba', 'perfil129.png', 'Streamer de carreras arcade', '9999-0000-1111-2222'),
('Jugador130', 'SecureHero130', 'jugador130@mail.com', 'Puerto Rico', 'perfil130.png', 'Explorador de secretos RPG', '0000-1111-2222-3333'),
('Jugador131', 'MegaPlay131', 'jugador131@mail.com', 'México', 'perfil131.png', 'Cazador de logros difíciles', '1111-2222-3333-4444'),
('Jugador132', 'SafePass132', 'jugador132@mail.com', 'España', 'perfil132.png', 'Competidor de simuladores de vuelo', '2222-3333-4444-5555'),
('Jugador133', 'TopCode133', 'jugador133@mail.com', 'Argentina', 'perfil133.png', 'Fan de peleas competitivas', '3333-4444-5555-6666'),
('Jugador134', 'GamerSafe134', 'jugador134@mail.com', 'Brasil', 'perfil134.png', 'Competidor en shooters tácticos', '4444-5555-6666-7777'),
('Jugador135', 'EpicHero135', 'jugador135@mail.com', 'Colombia', 'perfil135.png', 'Fanático de aventuras narrativas', '5555-6666-7777-8888'),
('Jugador136', 'MegaZone136', 'jugador136@mail.com', 'Chile', 'perfil136.png', 'Streamer de juegos sandbox', '6666-7777-8888-9999'),
('Jugador137', 'SecureEpic137', 'jugador137@mail.com', 'Perú', 'perfil137.png', 'Jugador casual de FPS', '7777-8888-9999-0000'),
('Jugador138', 'GameSafe138', 'jugador138@mail.com', 'Ecuador', 'perfil138.png', 'Creador de contenido retro', '8888-9999-0000-1111'),
('Jugador139', 'HeroCode139', 'jugador139@mail.com', 'Uruguay', 'perfil139.png', 'Competidor en MOBAs', '9999-0000-1111-2222'),
('Jugador140', 'TopHero140', 'jugador140@mail.com', 'Venezuela', 'perfil140.png', 'Fanático de simuladores RPG', '0000-1111-2222-3333'),
('Jugador141', 'SafeEpic141', 'jugador141@mail.com', 'Paraguay', 'perfil141.png', 'Cazador de tesoros en RPGs', '1111-2222-3333-4444'),
('Jugador142', 'UltraSafe142', 'jugador142@mail.com', 'Bolivia', 'perfil142.png', 'Jugador casual de carreras', '2222-3333-4444-5555'),
('Jugador143', 'MegaPass143', 'jugador143@mail.com', 'Panamá', 'perfil143.png', 'Streamer de aventuras gráficas', '3333-4444-5555-6666'),
('Jugador144', 'SecureZone144', 'jugador144@mail.com', 'Cuba', 'perfil144.png', 'Competidor de shooters tácticos', '4444-5555-6666-7777'),
('Jugador145', 'HeroSafe145', 'jugador145@mail.com', 'Puerto Rico', 'perfil145.png', 'Amante de los juegos de terror', '5555-6666-7777-8888'),
('Jugador146', 'UltraCode146', 'jugador146@mail.com', 'México', 'perfil146.png', 'Fanático de sandbox creativos', '6666-7777-8888-9999'),
('Jugador147', 'GameZone147', 'jugador147@mail.com', 'España', 'perfil147.png', 'Competidor de peleas arcade', '7777-8888-9999-0000'),
('Jugador148', 'TopSafe148', 'jugador148@mail.com', 'Argentina', 'perfil148.png', 'Cazador de secretos en RPGs', '8888-9999-0000-1111'),
('Jugador149', 'EpicMaster149', 'jugador149@mail.com', 'Brasil', 'perfil149.png', 'Fanático de MOBAs competitivos', '9999-0000-1111-2222'),
('Jugador150', 'CodeHero150', 'jugador150@mail.com', 'Colombia', 'perfil150.png', 'Streamer de juegos retro', '0000-1111-2222-3333'),
('Jugador151', 'PassHero151', 'jugador151@mail.com', 'México', 'perfil151.png', 'Explorador de mundos MMORPG', '1111-2222-3333-4444'),
('Jugador152', 'EpicSafe152', 'jugador152@mail.com', 'España', 'perfil152.png', 'Competidor en juegos de peleas', '2222-3333-4444-5555'),
('Jugador153', 'MegaZone153', 'jugador153@mail.com', 'Argentina', 'perfil153.png', 'Fanático de aventuras narrativas', '3333-4444-5555-6666'),
('Jugador154', 'SafePass154', 'jugador154@mail.com', 'Colombia', 'perfil154.png', 'Cazador de logros RPG', '4444-5555-6666-7777'),
('Jugador155', 'UltraPlay155', 'jugador155@mail.com', 'Chile', 'perfil155.png', 'Streamer de simuladores', '5555-6666-7777-8888'),
('Jugador156', 'SecureHero156', 'jugador156@mail.com', 'Perú', 'perfil156.png', 'Amante de shooters tácticos', '6666-7777-8888-9999'),
('Jugador157', 'GameEpic157', 'jugador157@mail.com', 'Ecuador', 'perfil157.png', 'Competidor en MOBAs', '7777-8888-9999-0000'),
('Jugador158', 'SafeZone158', 'jugador158@mail.com', 'Uruguay', 'perfil158.png', 'Fanático de carreras arcade', '8888-9999-0000-1111'),
('Jugador159', 'HeroCode159', 'jugador159@mail.com', 'Venezuela', 'perfil159.png', 'Jugador casual de RPGs', '9999-0000-1111-2222'),
('Jugador160', 'MegaHero160', 'jugador160@mail.com', 'Paraguay', 'perfil160.png', 'Explorador de mundos abiertos', '0000-1111-2222-3333'),
('Jugador161', 'UltraSafe161', 'jugador161@mail.com', 'Bolivia', 'perfil161.png', 'Cazador de logros difíciles', '1111-2222-3333-4444'),
('Jugador162', 'SecurePlay162', 'jugador162@mail.com', 'Panamá', 'perfil162.png', 'Fanático de juegos de terror', '2222-3333-4444-5555'),
('Jugador163', 'TopHero163', 'jugador163@mail.com', 'Cuba', 'perfil163.png', 'Competidor en peleas arcade', '3333-4444-5555-6666'),
('Jugador164', 'EpicMaster164', 'jugador164@mail.com', 'Puerto Rico', 'perfil164.png', 'Cazador de tesoros RPG', '4444-5555-6666-7777'),
('Jugador165', 'GameSafe165', 'jugador165@mail.com', 'México', 'perfil165.png', 'Streamer de shooters tácticos', '5555-6666-7777-8888'),
('Jugador166', 'PassHero166', 'jugador166@mail.com', 'España', 'perfil166.png', 'Fan de aventuras cooperativas', '6666-7777-8888-9999'),
('Jugador167', 'SafeZone167', 'jugador167@mail.com', 'Argentina', 'perfil167.png', 'Jugador de peleas retro', '7777-8888-9999-0000'),
('Jugador168', 'CodeMega168', 'jugador168@mail.com', 'Brasil', 'perfil168.png', 'Amante de juegos narrativos', '8888-9999-0000-1111'),
('Jugador169', 'HeroEpic169', 'jugador169@mail.com', 'Colombia', 'perfil169.png', 'Competidor en carreras arcade', '9999-0000-1111-2222'),
('Jugador170', 'MegaPlay170', 'jugador170@mail.com', 'Chile', 'perfil170.png', 'Streamer de aventuras gráficas', '0000-1111-2222-3333'),
('Jugador171', 'TopZone171', 'jugador171@mail.com', 'Perú', 'perfil171.png', 'Cazador de logros RPG', '1111-2222-3333-4444'),
('Jugador172', 'SafeMaster172', 'jugador172@mail.com', 'Ecuador', 'perfil172.png', 'Fanático de sandbox creativos', '2222-3333-4444-5555'),
('Jugador173', 'UltraHero173', 'jugador173@mail.com', 'Uruguay', 'perfil173.png', 'Competidor en MOBAs', '3333-4444-5555-6666'),
('Jugador174', 'SecureZone174', 'jugador174@mail.com', 'Venezuela', 'perfil174.png', 'Jugador de shooters competitivos', '4444-5555-6666-7777'),
('Jugador175', 'CodeSafe175', 'jugador175@mail.com', 'Paraguay', 'perfil175.png', 'Streamer de simuladores RPG', '5555-6666-7777-8888'),
('Jugador176', 'HeroPass176', 'jugador176@mail.com', 'Bolivia', 'perfil176.png', 'Fanático de juegos retro', '6666-7777-8888-9999'),
('Jugador177', 'GameZone177', 'jugador177@mail.com', 'Panamá', 'perfil177.png', 'Explorador de mundos RPG', '7777-8888-9999-0000'),
('Jugador178', 'MegaSafe178', 'jugador178@mail.com', 'Cuba', 'perfil178.png', 'Cazador de secretos', '8888-9999-0000-1111'),
('Jugador179', 'TopHero179', 'jugador179@mail.com', 'Puerto Rico', 'perfil179.png', 'Competidor de peleas arcade', '9999-0000-1111-2222'),
('Jugador180', 'UltraEpic180', 'jugador180@mail.com', 'México', 'perfil180.png', 'Jugador casual de aventuras', '0000-1111-2222-3333'),
('Jugador181', 'SafePlay181', 'jugador181@mail.com', 'España', 'perfil181.png', 'Fanático de shooters tácticos', '1111-2222-3333-4444'),
('Jugador182', 'SecureMega182', 'jugador182@mail.com', 'Argentina', 'perfil182.png', 'Cazador de tesoros RPG', '2222-3333-4444-5555'),
('Jugador183', 'CodeHero183', 'jugador183@mail.com', 'Brasil', 'perfil183.png', 'Competidor de carreras retro', '3333-4444-5555-6666'),
('Jugador184', 'PassEpic184', 'jugador184@mail.com', 'Colombia', 'perfil184.png', 'Amante de aventuras narrativas', '4444-5555-6666-7777'),
('Jugador185', 'MegaPass185', 'jugador185@mail.com', 'Chile', 'perfil185.png', 'Fan de sandbox creativos', '5555-6666-7777-8888'),
('Jugador186', 'UltraMaster186', 'jugador186@mail.com', 'Perú', 'perfil186.png', 'Cazador de logros difíciles', '6666-7777-8888-9999'),
('Jugador187', 'HeroPlay187', 'jugador187@mail.com', 'Ecuador', 'perfil187.png', 'Explorador de mundos abiertos', '7777-8888-9999-0000'),
('Jugador188', 'EpicSafe188', 'jugador188@mail.com', 'Uruguay', 'perfil188.png', 'Streamer de simuladores RPG', '8888-9999-0000-1111'),
('Jugador189', 'TopZone189', 'jugador189@mail.com', 'Venezuela', 'perfil189.png', 'Competidor en MOBAs', '9999-0000-1111-2222'),
('Jugador190', 'SecureHero190', 'jugador190@mail.com', 'Paraguay', 'perfil190.png', 'Fanático de peleas arcade', '0000-1111-2222-3333'),
('Jugador191', 'SafeCode191', 'jugador191@mail.com', 'Bolivia', 'perfil191.png', 'Jugador casual de FPS', '1111-2222-3333-4444'),
('Jugador192', 'MegaPlay192', 'jugador192@mail.com', 'Panamá', 'perfil192.png', 'Cazador de secretos RPG', '2222-3333-4444-5555'),
('Jugador193', 'HeroSafe193', 'jugador193@mail.com', 'Cuba', 'perfil193.png', 'Fan de aventuras gráficas', '3333-4444-5555-6666'),
('Jugador194', 'UltraHero194', 'jugador194@mail.com', 'Puerto Rico', 'perfil194.png', 'Streamer de shooters competitivos', '4444-5555-6666-7777'),
('Jugador195', 'CodeSafe195', 'jugador195@mail.com', 'México', 'perfil195.png', 'Explorador de mundos RPG', '5555-6666-7777-8888'),
('Jugador196', 'PassMega196', 'jugador196@mail.com', 'España', 'perfil196.png', 'Cazador de logros retro', '6666-7777-8888-9999'),
('Jugador197', 'EpicZone197', 'jugador197@mail.com', 'Argentina', 'perfil197.png', 'Fanático de sandbox creativos', '7777-8888-9999-0000'),
('Jugador198', 'SafeHero198', 'jugador198@mail.com', 'Brasil', 'perfil198.png', 'Competidor de MOBAs competitivos', '8888-9999-0000-1111'),
('Jugador199', 'MegaSafe199', 'jugador199@mail.com', 'Colombia', 'perfil199.png', 'Cazador de tesoros narrativos', '9999-0000-1111-2222'),
('Jugador200', 'UltraPlay200', 'jugador200@mail.com', 'Chile', 'perfil200.png', 'Streamer de aventuras gráficas', '0000-1111-2222-3333');

-- Tabla BIBLIOTECA
INSERT INTO BIBLIOTECA (Id_jugador, Numero_juegos, Espacio_usado)
VALUES
(1, 10, 50.25),
(2, 7, 30.50),
(3, 15, 75.75),
(4, 3, 12.10),
(5, 20, 100.00),
(6, 8, 40.75),
(7, 12, 60.20),
(8, 4, 15.30),
(9, 17, 85.50),
(10, 5, 22.10),
(11, 9, 45.60),
(12, 6, 25.40),
(13, 14, 70.80),
(14, 11, 55.90),
(15, 2, 8.20),
(16, 18, 90.00),
(17, 7, 35.70),
(18, 13, 65.30),
(19, 5, 23.50),
(20, 16, 80.40),
(21, 9, 45.00),
(22, 8, 40.00),
(23, 15, 75.00),
(24, 4, 18.25),
(25, 20, 99.90),
(26, 3, 10.10),
(27, 11, 55.00),
(28, 12, 60.00),
(29, 7, 30.00),
(30, 19, 95.80),
(31, 13, 65.70),
(32, 5, 25.00),
(33, 10, 50.00),
(34, 6, 27.50),
(35, 18, 92.50),
(36, 14, 72.00),
(37, 4, 16.40),
(38, 16, 80.90),
(39, 3, 12.00),
(40, 20, 99.00),
(41, 2, 7.80),
(42, 9, 45.10),
(43, 17, 87.20),
(44, 6, 26.80),
(45, 12, 62.10),
(46, 8, 35.30),
(47, 15, 77.40),
(48, 10, 48.50),
(49, 3, 11.90),
(50, 7, 34.50),
(51, 13, 64.70),
(52, 20, 100.10),
(53, 9, 44.30),
(54, 8, 38.00),
(55, 11, 52.10),
(56, 16, 81.40),
(57, 6, 28.60),
(58, 12, 60.30),
(59, 5, 24.70),
(60, 17, 85.90),
(61, 3, 10.20),
(62, 10, 50.70),
(63, 20, 99.50),
(64, 4, 19.40),
(65, 7, 32.60),
(66, 14, 71.30),
(67, 8, 39.40),
(68, 15, 78.90),
(69, 12, 60.10),
(70, 5, 25.30),
(71, 18, 89.80),
(72, 6, 27.00),
(73, 11, 55.40),
(74, 4, 16.90),
(75, 19, 94.50),
(76, 7, 31.70),
(77, 3, 9.80),
(78, 9, 44.60),
(79, 14, 70.20),
(80, 15, 77.10),
(81, 11, 56.00),
(82, 8, 37.70),
(83, 20, 100.00),
(84, 5, 23.80),
(85, 10, 50.00),
(86, 9, 45.20),
(87, 4, 17.10),
(88, 16, 82.00),
(89, 6, 26.20),
(90, 18, 91.70),
(91, 7, 33.10),
(92, 10, 49.80),
(93, 11, 53.90),
(94, 14, 72.50),
(95, 4, 15.70),
(96, 12, 61.20),
(97, 19, 96.30),
(98, 8, 36.20),
(99, 7, 31.50),
(100, 13, 63.70),
(101, 2, 7.50),
(102, 6, 26.40),
(103, 10, 50.60),
(104, 5, 22.00),
(105, 15, 75.50),
(106, 8, 36.90),
(107, 12, 60.50),
(108, 18, 92.20),
(109, 9, 45.30),
(110, 14, 71.40),
(111, 13, 65.60),
(112, 3, 11.30),
(113, 17, 84.90),
(114, 7, 33.80),
(115, 10, 49.90),
(116, 20, 100.00),
(117, 9, 44.10),
(118, 11, 53.40),
(119, 5, 25.50),
(120, 15, 76.40),
(121, 3, 12.10),
(122, 19, 95.90),
(123, 8, 38.40),
(124, 17, 86.10),
(125, 14, 70.80),
(126, 6, 29.50),
(127, 4, 15.90),
(128, 11, 56.50),
(129, 5, 22.80),
(130, 16, 82.30),
(131, 12, 59.80),
(132, 13, 66.40),
(133, 7, 30.40),
(134, 6, 28.30),
(135, 20, 99.70),
(136, 9, 43.90),
(137, 18, 88.10),
(138, 8, 36.70),
(139, 4, 16.00),
(140, 10, 47.50),
(141, 17, 85.20),
(142, 12, 59.50),
(143, 3, 11.00),
(144, 16, 81.00),
(145, 15, 77.30),
(146, 8, 38.10),
(147, 18, 89.10),
(148, 6, 27.10),
(149, 9, 42.50),
(150, 13, 67.30),
(151, 7, 31.80),
(152, 10, 50.00),
(153, 20, 99.00),
(154, 8, 37.00),
(155, 5, 23.40),
(156, 18, 90.00),
(157, 14, 70.00),
(158, 6, 26.90),
(159, 9, 43.70),
(160, 12, 58.00),
(161, 15, 74.10),
(162, 4, 17.40),
(163, 10, 50.20),
(164, 19, 96.40),
(165, 5, 22.30),
(166, 7, 32.10),
(167, 8, 37.90),
(168, 13, 65.20),
(169, 11, 54.10),
(170, 4, 18.00),
(171, 6, 28.00),
(172, 10, 50.10),
(173, 14, 72.00),
(174, 20, 98.50),
(175, 17, 85.50),
(176, 6, 29.10),
(177, 7, 32.00),
(178, 5, 23.90),
(179, 10, 49.40),
(180, 9, 43.00),
(181, 18, 88.50),
(182, 12, 60.70),
(183, 13, 67.80),
(184, 4, 16.30),
(185, 11, 55.30),
(186, 8, 36.30),
(187, 15, 75.20),
(188, 3, 12.20),
(189, 17, 84.10),
(190, 6, 27.40),
(191, 10, 47.90),
(192, 20, 99.20),
(193, 7, 31.10),
(194, 4, 15.80),
(195, 14, 70.60),
(196, 8, 35.60),
(197, 9, 44.80),
(198, 12, 61.10),
(199, 19, 97.00),
(200, 15, 75.00);

-- Tabla VIDEOJUEGOS
INSERT INTO VIDEOJUEGOS (Nombre, Fecha, Descripcion, Precio, Duracion_oferta, Descuento_oferta, Tamaño)
VALUES
('Aventura Magica', '01/01/2023', 'Juego de rol magico y aventuras', 49.99, '01/01/2023 - 10/01/2023', 10, 20.5),
('Shooter Extremo', '15/02/2023', 'Shooter en primera persona competitivo', 59.99, '15/02/2023 - 25/02/2023', 20, 35.0),
('Mundo Abierto X', '10/03/2023', 'Explora un mundo abierto sin limites', 69.99, '10/03/2023 - 20/03/2023', 15, 50.0),
('Plataformas Retro', '05/04/2023', 'Clasico plataformas con desafios modernos', 29.99, '05/04/2023 - 15/04/2023', 25, 15.0),
('Aventura Grafica Pro', '20/05/2023', 'Juego narrativo con graficos impresionantes', 39.99, '20/05/2023 - 30/05/2023', 30, 18.5),
('Carreras Futuristas', '15/06/2023', 'Carreras en vehículos futuristas en entornos 3D', 49.99, '15/06/2023 - 25/06/2023', 15, 25.0),
('Tacticas de Guerra', '01/07/2023', 'Estrategia en tiempo real con un enfoque militar', 59.99, '01/07/2023 - 10/07/2023', 20, 40.0),
('Simulador Espacial', '20/07/2023', 'Explora el espacio en una simulación realista', 69.99, '20/07/2023 - 30/07/2023', 10, 50.0),
('RPG Medieval', '05/08/2023', 'Juego de rol ambientado en un mundo medieval', 39.99, '05/08/2023 - 15/08/2023', 25, 30.0),
('Batalla en el Desierto', '15/09/2023', 'Juego de supervivencia en el desierto con acción constante', 29.99, '15/09/2023 - 25/09/2023', 15, 20.5),
('Aventura Espacial', '01/10/2023', 'Explora nuevas galaxias en una aventura épica', 49.99, '01/10/2023 - 10/10/2023', 30, 40.0),
('Conquista Medieval', '20/11/2023', 'Simulador de estrategia en la época medieval', 59.99, '20/11/2023 - 30/11/2023', 20, 35.0),
('Supervivencia Zombi', '10/12/2023', 'Sobrevive a un apocalipsis zombi en una ciudad desierta', 69.99, '10/12/2023 - 20/12/2023', 15, 55.0),
('Mundo Virtual VR', '25/01/2023', 'Un juego de realidad virtual donde puedes ser quien quieras', 79.99, '25/01/2023 - 05/02/2023', 10, 60.0),
('Aventura en la Jungla', '15/02/2023', 'Aventuras y exploración en una jungla peligrosa', 49.99, '15/02/2023 - 25/02/2023', 20, 28.0),
('Escape de la Ciudad', '05/03/2023', 'Juego de puzzles y escape ambientado en una ciudad futurista', 39.99, '05/03/2023 - 15/03/2023', 25, 22.0),
('Combate en la Arena', '01/04/2023', 'Juego de combate en una arena de gladiadores', 59.99, '01/04/2023 - 10/04/2023', 10, 30.0),
('Ciudad de Ciberpunk', '20/04/2023', 'Juego de rol en una ciudad futurista con elementos de ciberpunk', 69.99, '20/04/2023 - 30/04/2023', 15, 45.0),
('Viajero del Tiempo', '15/05/2023', 'Juego de aventuras donde viajas a través del tiempo', 49.99, '15/05/2023 - 25/05/2023', 20, 35.0),
('La Guerra de los Dioses', '10/06/2023', 'Juego de acción y estrategia basado en mitología', 39.99, '10/06/2023 - 20/06/2023', 30, 42.0),
('Carreras de Motos', '01/07/2023', 'Carreras de motos en circuitos extremos', 29.99, '01/07/2023 - 10/07/2023', 15, 25.0),
('Aventura Submarina', '15/08/2023', 'Explora las profundidades del océano en una misión submarina', 69.99, '15/08/2023 - 25/08/2023', 20, 50.0),
('Supervivencia en la Isla', '10/09/2023', 'Sobrevive en una isla desierta con recursos limitados', 59.99, '10/09/2023 - 20/09/2023', 10, 40.0),
('Guerra Medieval', '05/10/2023', 'Simulador de guerra en la Edad Media con batallas épicas', 79.99, '05/10/2023 - 15/10/2023', 25, 45.0),
('Aventura Celestial', '20/11/2023', 'Explora el cielo y las estrellas en una aventura celestial', 69.99, '20/11/2023 - 30/11/2023', 30, 48.0),
('Asalto al Planeta', '10/12/2023', 'Juego de acción en el que asaltas un planeta lejano', 49.99, '10/12/2023 - 20/12/2023', 20, 60.0),
('Aventuras del Caballero', '01/01/2024', 'Juego de rol con un caballero que explora tierras medievales', 39.99, '01/01/2024 - 10/01/2024', 15, 30.0),
('Conquista Galáctica', '15/02/2024', 'Juega como un comandante de flotas galácticas en una guerra estelar', 59.99, '15/02/2024 - 25/02/2024', 25, 55.0),
('Guerrero de la Tierra', '05/03/2024', 'Lucha contra monstruos y criaturas en un mundo medieval', 49.99, '05/03/2024 - 15/03/2024', 10, 40.0),
('Cazador de Dragones', '01/04/2024', 'Caza dragones en un mundo fantástico lleno de magia', 69.99, '01/04/2024 - 10/04/2024', 20, 50.0),
('Batalla Espacial', '20/04/2024', 'Lucha en batallas espaciales con naves futuristas', 79.99, '20/04/2024 - 30/04/2024', 15, 60.0),
('Carreras Nocturnas', '10/05/2024', 'Juego de carreras nocturnas en las calles de la ciudad', 29.99, '10/05/2024 - 20/05/2024', 25, 35.0),
('Aventuras Arqueológicas', '15/06/2024', 'Explora tumbas y ruinas antiguas en una aventura arqueológica', 39.99, '15/06/2024 - 25/06/2024', 20, 30.0),
('Misterio en la Mansión', '01/07/2024', 'Resuelve misterios en una mansión llena de secretos', 59.99, '01/07/2024 - 10/07/2024', 10, 40.0),
('El Último Samurai', '15/08/2024', 'Juego de acción y combate samurái en el Japón feudal', 69.99, '15/08/2024 - 25/08/2024', 15, 45.0),
('Supervivencia Postapocalíptica', '05/09/2024', 'Sobrevive en un mundo devastado después de un apocalipsis', 49.99, '05/09/2024 - 15/09/2024', 25, 50.0),
('Explorador de Mazmorras', '20/10/2024', 'Explora mazmorras en busca de tesoros y secretos perdidos', 39.99, '20/10/2024 - 30/10/2024', 20, 33.0),
('Defensores de la Tierra', '10/11/2024', 'Defiende el planeta de ataques extraterrestres en una misión de defensa', 59.99, '10/11/2024 - 20/11/2024', 15, 45.0),
('Viaje a la Luna', '01/12/2024', 'Explora la luna y otros planetas en un viaje intergaláctico', 49.99, '01/12/2024 - 10/12/2024', 20, 38.0),
('El Último Explorador', '10/01/2024', 'Explora planetas desconocidos y recoge artefactos misteriosos', 49.99, '10/01/2024 - 20/01/2024', 20, 45.0),
('Monstruos y Magia', '25/01/2024', 'Aventura de rol en un mundo lleno de magia y monstruos', 39.99, '25/01/2024 - 05/02/2024', 15, 40.0),
('Survivor X', '15/02/2024', 'Juego de supervivencia en un mundo postapocalíptico', 59.99, '15/02/2024 - 25/02/2024', 10, 50.0),
('El Enigma del Laberinto', '01/03/2024', 'Juego de puzzles en un antiguo laberinto', 29.99, '01/03/2024 - 10/03/2024', 25, 20.0),
('Cazadores de Fantasmas', '20/03/2024', 'Juega como un cazador de fantasmas en un mundo paranormal', 49.99, '20/03/2024 - 30/03/2024', 15, 30.0),
('Vikings of Valhalla', '05/04/2024', 'Lucha como un vikingo en la mitología nórdica', 69.99, '05/04/2024 - 15/04/2024', 20, 60.0),
('Camino del Guerrero', '25/04/2024', 'Juego de acción y combate basado en el arte marcial', 39.99, '25/04/2024 - 05/05/2024', 10, 35.0),
('Zombie Wars', '10/05/2024', 'Sobrevive en un mundo lleno de zombis en una guerra interminable', 59.99, '10/05/2024 - 20/05/2024', 20, 45.0),
('Cielo de Titanes', '20/06/2024', 'Juego de batallas aéreas en el cielo entre titanes', 69.99, '20/06/2024 - 30/06/2024', 15, 55.0),
('Héroes de la Luz', '01/07/2024', 'Juego de aventuras épicas donde los héroes luchan por salvar el reino', 49.99, '01/07/2024 - 10/07/2024', 25, 40.0),
('El Último Samurai II', '15/08/2024', 'Secuela del juego de acción samurái en el Japón feudal', 79.99, '15/08/2024 - 25/08/2024', 10, 65.0),
('Dragones del Infierno', '01/09/2024', 'Juego de rol con batallas épicas contra dragones y demonios', 59.99, '01/09/2024 - 10/09/2024', 30, 50.0),
('Cazadores de Tesoros', '20/09/2024', 'Aventura en busca de tesoros perdidos en tierras exóticas', 39.99, '20/09/2024 - 30/09/2024', 25, 45.0),
('Batalla Contra el Tiempo', '05/10/2024', 'Un juego de acción donde el tiempo es tu mayor enemigo', 49.99, '05/10/2024 - 15/10/2024', 15, 60.0),
('Asesinos del Futuro', '20/10/2024', 'Juego de acción en un futuro distópico con asesinos cibernéticos', 69.99, '20/10/2024 - 30/10/2024', 20, 50.0),
('La Conquista del Espacio', '01/11/2024', 'Juega como comandante en una guerra intergaláctica', 79.99, '01/11/2024 - 10/11/2024', 10, 60.0),
('Fuerzas Especiales', '15/11/2024', 'Juego de disparos tácticos en escenarios de guerra moderna', 59.99, '15/11/2024 - 25/11/2024', 25, 40.0),
('Carreras 3D Extreme', '01/12/2024', 'Carreras a alta velocidad con vehículos futuristas', 49.99, '01/12/2024 - 10/12/2024', 20, 55.0),
('Leyenda del Ninja', '10/01/2024', 'Juego de acción de sigilo ambientado en el Japón feudal', 59.99, '10/01/2024 - 20/01/2024', 15, 50.0),
('Las Crónicas de Fantasia', '01/02/2024', 'Aventura de rol en un mundo de fantasía con magia y criaturas míticas', 69.99, '01/02/2024 - 10/02/2024', 20, 60.0),
('La Fuga del Imperio', '15/02/2024', 'Juego de estrategia en el que debes escapar de un imperio opresor', 39.99, '15/02/2024 - 25/02/2024', 30, 45.0),
('La Guerra de los Elementos', '05/03/2024', 'Juego de acción basado en las batallas entre los elementos naturales', 59.99, '05/03/2024 - 15/03/2024', 10, 35.0),
('Exploración Polar', '25/03/2024', 'Sobrevive en el frío extremo mientras exploras el Ártico', 29.99, '25/03/2024 - 05/04/2024', 20, 25.0),
('Revolución Cibernética', '10/04/2024', 'Juego de acción donde te enfrentas a una revolución cibernética en el futuro', 69.99, '10/04/2024 - 20/04/2024', 15, 50.0),
('Luchadores del Infierno', '01/05/2024', 'Lucha en el infierno contra demonios en combates épicos', 39.99, '01/05/2024 - 10/05/2024', 20, 40.0),
('Fuerzas Especiales II', '15/06/2024', 'Secuela del juego de disparos tácticos con más armas y misiones', 49.99, '15/06/2024 - 25/06/2024', 25, 45.0),
('Simulador de Granjas', '01/07/2024', 'Simulador de vida en la granja donde puedes sembrar, cosechar y criar animales', 29.99, '01/07/2024 - 10/07/2024', 15, 30.0),
('Leyenda de los Guerreros', '20/07/2024', 'Aventura de acción en la que luchas para convertirte en leyenda', 59.99, '20/07/2024 - 30/07/2024', 10, 50.0),
('Terror en la Mansión', '10/08/2024', 'Juego de terror en una mansión antigua llena de secretos oscuros', 39.99, '10/08/2024 - 20/08/2024', 20, 35.0),
('Reino Caído', '25/08/2024', 'Juego de rol donde debes restaurar un reino caído a su antiguo esplendor', 49.99, '25/08/2024 - 05/09/2024', 25, 45.0),
('Cyborgs en Guerra', '10/09/2024', 'Juego de disparos futuristas donde eres un cyborg en una guerra cibernética', 69.99, '10/09/2024 - 20/09/2024', 30, 50.0),
('Cuentos Oscuros', '01/10/2024', 'Juego de aventuras oscuras donde exploras cuentos y leyendas siniestras', 59.99, '01/10/2024 - 10/10/2024', 10, 55.0),
('Aventura en el Espacio Profundo', '15/10/2024', 'Viaja a través del espacio en una misión para salvar la galaxia', 69.99, '15/10/2024 - 25/10/2024', 15, 50.0),
('Jinetes del Apocalipsis', '01/11/2024', 'Lucha como uno de los jinetes del apocalipsis en un juego lleno de acción', 79.99, '01/11/2024 - 10/11/2024', 20, 60.0),
('Guerra Secreta', '20/11/2024', 'Juego de espionaje y tácticas secretas en una guerra de inteligencia', 59.99, '20/11/2024 - 30/11/2024', 10, 45.0),
('Supervivencia del Más Fuerte', '05/12/2024', 'Sobrevive en un mundo lleno de peligros y criaturas hostiles', 39.99, '05/12/2024 - 15/12/2024', 20, 35.0),
('Mundo de Leyendas', '15/12/2024', 'Explora un mundo lleno de leyendas y criaturas mitológicas', 69.99, '15/12/2024 - 25/12/2024', 15, 50.0),
('Cazadores del Más Allá', '01/01/2025', 'Juega como un cazador en un mundo lleno de monstruos sobrenaturales', 49.99, '01/01/2025 - 10/01/2025', 20, 55.0),
('La Rebelión del Futuro', '15/01/2025', 'Juego de ciencia ficción y acción en una rebelión contra el imperio galáctico', 59.99, '15/01/2025 - 25/01/2025', 25, 50.0),
('Samuráis del Fin del Mundo', '01/02/2025', 'Juego de rol y lucha en un mundo distópico de samuráis', 39.99, '01/02/2025 - 10/02/2025', 30, 45.0),
('El Viaje del Héroe', '10/02/2025', 'Aventura épica en la que juegas el papel de un héroe que busca salvar su mundo', 69.99, '10/02/2025 - 20/02/2025', 15, 50.0),
('Conquista del Océano', '20/02/2025', 'Juego de exploración naval y combate en altamar', 49.99, '20/02/2025 - 01/03/2025', 10, 40.0),
('Guerra de Civilizaciones', '01/03/2025', 'Juego de estrategia en tiempo real, donde construyes y lideras una civilización', 59.99, '01/03/2025 - 10/03/2025', 20, 55.0),
('Cuentos de Magia y Héroes', '10/03/2025', 'Juego de aventura donde la magia y los héroes se unen para enfrentar oscuros enemigos', 39.99, '10/03/2025 - 20/03/2025', 25, 30.0),
('Carrera Extrema 2', '20/03/2025', 'Juego de carreras futuristas a alta velocidad en circuitos imposibles', 59.99, '20/03/2025 - 30/03/2025', 15, 45.0),
('Misterios Subterráneos', '01/04/2025', 'Explora cavernas y resuelve misterios subterráneos en un juego de aventuras', 29.99, '01/04/2025 - 10/04/2025', 10, 35.0),
('La Guerra de los Dioses', '15/04/2025', 'Juego de rol en el que participas en una guerra entre los dioses de diversas mitologías', 69.99, '15/04/2025 - 25/04/2025', 20, 60.0),
('Prisión Virtual', '01/05/2025', 'Juega como un prisionero que lucha por escapar de una prisión virtual', 49.99, '01/05/2025 - 10/05/2025', 25, 40.0),
('Desafío Total', '10/05/2025', 'Juego de supervivencia en el que cada decisión puede ser fatal', 59.99, '10/05/2025 - 20/05/2025', 15, 50.0),
('Caminos del Destino', '01/06/2025', 'Aventura narrativa donde tus elecciones determinan el destino del mundo', 39.99, '01/06/2025 - 10/06/2025', 30, 45.0),
('Estrategia Épica', '15/06/2025', 'Juego de estrategia militar en el que lideras un ejército para conquistar imperios', 69.99, '15/06/2025 - 25/06/2025', 20, 55.0),
('Supervivencia Z', '01/07/2025', 'Sobrevive en un mundo post-apocalíptico lleno de zombis y criaturas mutantes', 49.99, '01/07/2025 - 10/07/2025', 10, 45.0),
('Luchadores Interdimensionales', '15/07/2025', 'Lucha contra guerreros de diferentes dimensiones en un torneo intergaláctico', 59.99, '15/07/2025 - 25/07/2025', 25, 50.0),
('El Último Caballero', '01/08/2025', 'Juego de acción medieval donde eres el último caballero en pie para salvar el reino', 69.99, '01/08/2025 - 10/08/2025', 20, 55.0),
('Aventuras en el Desierto', '15/08/2025', 'Juega como un explorador que atraviesa vastos desiertos en busca de tesoros', 39.99, '15/08/2025 - 25/08/2025', 30, 40.0),
('El Reino Perdido', '01/09/2025', 'Aventura de rol en busca de un reino perdido lleno de secretos y riquezas', 59.99, '01/09/2025 - 10/09/2025', 10, 50.0),
('Dimensiones Oscuras', '10/09/2025', 'Un juego de terror en el que te adentras en dimensiones paralelas oscuras', 49.99, '10/09/2025 - 20/09/2025', 15, 45.0),
('Robots contra Humanos', '01/10/2025', 'Enfrenta a robots rebeldes en una guerra por la supervivencia de la humanidad', 59.99, '01/10/2025 - 10/10/2025', 25, 60.0),
('Aliens vs Humanos', '15/10/2025', 'Juego de disparos futuristas donde los humanos luchan contra una invasión alienígena', 49.99, '15/10/2025 - 25/10/2025', 20, 50.0),
('El Último Refugio', '01/11/2025', 'Sobrevive en un refugio durante un apocalipsis y defiende lo que queda de la humanidad', 69.99, '01/11/2025 - 10/11/2025', 10, 60.0),
('Renegados de la Galaxia', '20/11/2025', 'Juego de aventuras y acción en el que te unes a una banda de renegados en la galaxia', 59.99, '20/11/2025 - 30/11/2025', 30, 45.0),
('Bajo el Agua', '05/12/2025', 'Explora las profundidades del océano en un mundo submarino lleno de criaturas misteriosas', 39.99, '05/12/2025 - 15/12/2025', 20, 35.0),
('La Última Fortaleza', '15/12/2025', 'Defiende tu fortaleza de una invasión masiva de monstruos y criaturas oscuras', 49.99, '15/12/2025 - 25/12/2025', 15, 45.0),
('La Rebelión del Cyberespacio', '01/01/2026', 'Juego de acción y estrategia en el que te enfrentas a una rebelión cibernética en el espacio', 59.99, '01/01/2026 - 10/01/2026', 10, 50.0),
('Renacimiento del Imperio', '20/01/2026', 'Juego de construcción y estrategia en el que debes renacer un imperio caído', 69.99, '20/01/2026 - 30/01/2026', 20, 60.0),
('La Isla Secreta', '01/02/2026', 'Sobrevive en una isla secreta llena de enigmas y criaturas exóticas', 39.99, '01/02/2026 - 10/02/2026', 30, 50.0),
('Cazadores de Sombras', '10/02/2026', 'Juego de rol y acción donde eres un cazador de sombras en un mundo oscuro', 49.99, '10/02/2026 - 20/02/2026', 25, 45.0),
('Dimensiones Paralelas', '01/03/2026', 'Aventura épica en la que viajas a través de dimensiones paralelas y desentrañas misterios', 59.99, '01/03/2026 - 10/03/2026', 15, 50.0),
('Fuerzas de la Naturaleza', '15/03/2026', 'Juega como un elemento de la naturaleza luchando por salvar el planeta', 39.99, '15/03/2026 - 25/03/2026', 20, 35.0),
('La Fortaleza Inexpugnable', '01/04/2026', 'Juego de defensa de torre en el que debes proteger tu fortaleza de hordas enemigas', 49.99, '01/04/2026 - 10/04/2026', 10, 45.0),
('La Odisea del Hombre', '15/04/2026', 'Un juego de aventura que narra la épica odisea de un hombre en busca de la verdad', 69.99, '15/04/2026 - 25/04/2026', 25, 55.0),
('La Guerra Secreta', '01/05/2026', 'Juego de espionaje donde juegas un agente secreto en medio de una guerra cibernética', 59.99, '01/05/2026 - 10/05/2026', 30, 50.0),
('Sobreviviente del Abismo', '10/05/2026', 'Sobrevive en un abismo lleno de peligros y criaturas hostiles', 39.99, '10/05/2026 - 20/05/2026', 20, 40.0),
('Eclipse Solar', '01/06/2026', 'Juego de ciencia ficción donde la humanidad lucha por sobrevivir a un eclipse solar mundial', 59.99, '01/06/2026 - 10/06/2026', 15, 50.0);

-- Tabla DLC
INSERT INTO DLC (Id_videojuego, Nombre, Descripcion, Precio)
VALUES
(12, 'Expansion magica', 'Nuevas misiones magicas y zonas', 9.99),
(38, 'Mapas adicionales', 'Nuevos mapas para competir', 4.99),
(45, 'Pack de explorador', 'Objetos exclusivos para explorar', 5.99),
(20, 'Retro DLC', 'Niveles clasicos adicionales', 2.99),
(30, 'Final alternativo', 'Desbloquea un final alternativo', 7.99),
(7, 'Pack de supervivencia', 'Nuevos desafíos y objetos para supervivientes', 6.99),
(22, 'DLC de eventos especiales', 'Accede a eventos únicos y limitados', 3.99),
(50, 'Pack de armas especiales', 'Nuevas armas y habilidades', 8.99),
(17, 'DLC de historia extra', 'Misiones adicionales con historia exclusiva', 9.99),
(27, 'Aventuras ocultas', 'Nuevas zonas para explorar', 4.49),
(62, 'Modo Hardcore', 'Desafíos más difíciles y recompensas exclusivas', 5.49),
(10, 'Mundo alternativo', 'Explora un mundo paralelo con nuevos enemigos', 6.99),
(35, 'Accesorios cosméticos', 'Nuevas skins y objetos cosméticos', 2.49),
(15, 'Expansión navideña', 'Accede a contenido navideño exclusivo', 3.99),
(80, 'Escenarios personalizados', 'Crea tus propios escenarios y desafíos', 5.99),
(25, 'DLC de desafíos épicos', 'Desafíos extremadamente difíciles con recompensas épicas', 7.99),
(18, 'Pack de vehículos', 'Nuevos vehículos y personalización', 4.99),
(40, 'Misterios del abismo', 'Explora nuevas profundidades llenas de misterio', 8.49),
(60, 'Pack de criaturas', 'Nuevas criaturas para cazar y entrenar', 6.49),
(33, 'Expansión del mapa', 'Nuevo mapa para explorar con más misiones', 9.49),
(13, 'DLC de temática zombie', 'Nuevas misiones y enemigos zombies', 5.99),
(50, 'Retro pack', 'Vuelve a los viejos tiempos con mapas retro', 3.49),
(28, 'DLC de la ciudad perdida', 'Descubre los secretos de una ciudad antigua', 7.49),
(8, 'Modificaciones extremas', 'Cambia el estilo del juego con nuevas modificaciones', 4.29),
(71, 'Desafío mortal', 'Supera desafíos imposibles para desbloquear recompensas', 6.99),
(49, 'Paquete de criaturas mitológicas', 'Hazte con nuevas criaturas legendarias', 5.59),
(41, 'Actualización de clanes', 'Crea y personaliza tu propio clan', 8.19),
(65, 'Pack de superviviente', 'Todo lo necesario para sobrevivir en el juego', 6.79),
(26, 'Reto de velocidad', 'Compite contra el tiempo en nuevas carreras', 4.79),
(57, 'Pack de mascotas', 'Adopta nuevas mascotas para acompañarte', 3.99),
(36, 'Héroes legendarios', 'Desbloquea héroes míticos con habilidades especiales', 7.59),
(63, 'DLC de combate aéreo', 'Vuela en nuevas aeronaves y participa en batallas aéreas', 9.49),
(42, 'Misiones secretas', 'Accede a misiones ocultas para jugadores avanzados', 6.59),
(72, 'La ciudad sumergida', 'Una nueva ciudad bajo el agua con misiones inéditas', 5.99),
(68, 'Pack de habilidades especiales', 'Nuevas habilidades y poderes para tu personaje', 4.99),
(9, 'DLC de aventuras medievales', 'Explora castillos y luchas en escenarios medievales', 7.29),
(64, 'Modo infinito', 'Juega sin fin en un modo donde la dificultad aumenta continuamente', 8.99),
(31, 'Aventuras espaciales', 'Misiones en el espacio exterior con nuevas naves y enemigos', 9.29),
(34, 'Temporada de invierno', 'Accede a contenido exclusivo durante el invierno', 3.99),
(29, 'Pack de armas futuristas', 'Nuevas armas avanzadas para combatir enemigos', 6.29),
(39, 'Zona prohibida', 'Explora una zona cerrada y llena de enemigos misteriosos', 5.49),
(56, 'DLC de magia avanzada', 'Nuevas técnicas mágicas para dominar el arte', 6.99),
(73, 'Héroes del pasado', 'Desbloquea héroes históricos con habilidades únicas', 7.79),
(61, 'Cazadores de monstruos', 'Nuevo contenido sobre monstruos que podrás cazar', 4.89),
(70, 'DLC de la batalla final', 'Prepárate para la batalla más épica de todas', 9.99),
(66, 'Pack de robots', 'Incorpora nuevos robots y compañeros de combate', 5.99),
(46, 'Modo destructivo', 'Juega en un modo donde todo se destruye a tu alrededor', 8.49),
(51, 'Expansión del desierto', 'Aventura en un desierto inhóspito lleno de secretos', 6.59),
(11, 'DLC de supervivencia extrema', 'Sobrevive en condiciones extremas en entornos hostiles', 9.29),
(59, 'Cuentos de horror', 'Un paquete de misiones de terror que pondrán a prueba tus nervios', 7.99),
(48, 'Expansión de combate', 'Nuevas mecánicas de combate y enemigos', 5.49);


-- Tabla GENEROS
INSERT INTO GENEROS (Nombre, Descripcion)
VALUES
('RPG', 'Juegos de rol con historias epicas'),
('FPS', 'Shooters en primera persona competitivos'),
('Sandbox', 'Exploracion en mundos abiertos'),
('Plataformas', 'Juegos clasicos de plataformas'),
('Narrativo', 'Experiencias narrativas interactivas'),
('Aventura', 'Juegos con énfasis en la exploración y resolución de acertijos'),
('Acción', 'Juegos dinámicos con énfasis en combate y destrezas físicas'),
('Deportes', 'Juegos basados en disciplinas deportivas'),
('Simulación', 'Simulación realista de diversas actividades'),
('Estrategia', 'Juegos que requieren planificación y toma de decisiones'),
('Música', 'Juegos que incluyen mecánicas musicales y ritmo'),
('Lucha', 'Juegos centrados en combates uno contra uno o en equipo'),
('Terror', 'Juegos de suspenso y miedo con elementos de horror'),
('Carreras', 'Juegos de velocidad y competición en vehículos'),
('MMO', 'Juegos multijugador masivos en línea'),
('Beat em up', 'Juegos de lucha en desplazamiento lateral'),
('Realidad virtual', 'Juegos diseñados para ser jugados con VR'),
('Simulador de vida', 'Juegos que simulan la vida cotidiana de los personajes'),
('Indie', 'Juegos independientes con enfoques innovadores'),
('Metroidvania', 'Juegos con exploración en mapas interconectados y habilidades desbloqueables'),
('Táctico', 'Juegos que requieren habilidades de estrategia y planificación'),
('Ciencia ficción', 'Juegos ambientados en futuros distópicos o en el espacio'),
('Aventura gráfica', 'Juegos que combinan narrativa y resolución de puzzles'),
('Survival', 'Juegos donde el jugador debe sobrevivir en condiciones extremas'),
('Construcción', 'Juegos centrados en la construcción de mundos o estructuras'),
('Hacking', 'Juegos que giran en torno al arte del hackeo y la tecnología'),
('Cooperativo', 'Juegos donde los jugadores deben trabajar juntos para lograr objetivos'),
('Táctico en tiempo real', 'Juegos que requieren acción rápida y estrategia simultánea'),
('Ciberpunk', 'Juegos ambientados en futuros cyberpunk, con alta tecnología y desorden social'),
('Aventura de texto', 'Juegos narrativos donde las decisiones se toman mediante texto'),
('Simulador de vuelo', 'Juegos que simulan la experiencia de volar aviones o naves'),
('Mundo abierto', 'Juegos donde los jugadores pueden explorar libremente un mundo extenso'),
('Juegos de mesa', 'Juegos inspirados en los clásicos juegos de mesa'),
('Aventura interactiva', 'Juegos centrados en elecciones narrativas y desarrollo de historias'),
('Mochila de supervivencia', 'Juegos que incluyen mecánicas de supervivencia y recursos limitados'),
('Escapismo', 'Juegos donde el objetivo es escapar de situaciones difíciles o peligrosas'),
('Pixel art', 'Juegos con estilo gráfico de píxeles en 2D'),
('Fighting game', 'Juegos de lucha entre personajes con combos y movimientos especiales'),
('Simulación deportiva', 'Juegos que simulan competiciones deportivas de manera realista'),
('Realismo', 'Juegos que buscan imitar la realidad de manera fidedigna'),
('Comedia', 'Juegos con un tono humorístico y situaciones cómicas'),
('Juego de cartas', 'Juegos basados en la estrategia de cartas y habilidades especiales'),
('Survival horror', 'Juegos de terror donde la supervivencia es el foco principal'),
('Acción Aventura', 'Combinación de acción dinámica y narrativa de aventura'),
('Juegos de rol online', 'Juegos de rol en línea donde los jugadores interactúan en mundos persistentes'),
('Realidad aumentada', 'Juegos que combinan el mundo real con elementos digitales'),
('Hack and slash', 'Juegos donde el combate rápido y directo es el enfoque principal'),
('Estrategia en tiempo real', 'Juegos que requieren acción táctica mientras se desarrolla la acción en tiempo real'),
('Plataformas 3D', 'Juegos de plataformas con gráficos en 3D y control de cámara'),
('Juegos de disparos arcade', 'Juegos con acción rápida de disparos en un estilo retro'),
('Aventura de acción', 'Juegos de aventura con elementos de acción rápida y dinámicas de combate'),
('Juego de supervivencia multijugador', 'Juegos de supervivencia donde los jugadores colaboran o compiten entre sí'),
('Juegos de misterio', 'Juegos que se centran en resolver acertijos y desentrañar enigmas'),
('Simulador de deportes extremos', 'Juegos de simulación con deportes extremos como snowboard, skateboarding, etc.'),
('Juego de puzzle', 'Juegos que desafían las habilidades de resolución de acertijos y lógica');


-- Tabla LOGROS
INSERT INTO LOGROS (Nombre, Descripcion, Requisito)
VALUES
('Termina la historia', 'Completa la historia principal', 'Finalizar todas las misiones principales'),
('Explorador', 'Descubre todas las areas del mapa', 'Visita cada rincon del mundo'),
('Coleccionista', 'Recolecta todos los objetos', 'Obten todos los coleccionables'),
('Sin derrotas', 'Completa sin morir', 'No mueras durante el juego'),
('Maestro del tiempo', 'Completa en menos de 2 horas', 'Finaliza el juego en tiempo record'),
('Superviviente', 'Sobrevive 30 días en el modo difícil', 'Mantente con vida durante 30 dias en modo dificil'),
('Destructor', 'Destruye 100 enemigos', 'Elimina 100 enemigos durante la partida'),
('Genio táctico', 'Usa todas las habilidades del personaje', 'Desbloquea y usa todas las habilidades de tu personaje'),
('Explorador nocturno', 'Explora un área peligrosa de noche', 'Visita un lugar peligroso en horas nocturnas'),
('Amigo fiel', 'Haz todas las misiones secundarias con tu compañero', 'Completa todas las misiones secundarias con tu companero'),
('Sin piedad', 'Derrota a un jefe en el menor tiempo posible', 'Acaba con un jefe en menos de 5 minutos'),
('Forajido', 'Comete 50 delitos en el juego', 'Realiza 50 acciones ilegales en el mundo del juego'),
('Gourmet', 'Come todos los platos del juego', 'Prueba todos los alimentos que puedas encontrar'),
('Todo un experto', 'Alcanza el nivel máximo de habilidad', 'Desarrolla todas las habilidades hasta su nivel maximo'),
('Cazador de logros', 'Desbloquea 50 logros', 'Consigue 50 logros diferentes en el juego'),
('Pesadilla viviente', 'Gana sin utilizar armas', 'Finaliza el juego sin usar armas de fuego ni de combate'),
('Viajero del tiempo', 'Usa todos los portales del juego', 'Viaja a todos los portales disponibles en el juego'),
('Maestro del combate', 'Gana 100 combates consecutivos', 'Gana 100 batallas sin perder'),
('Veterano', 'Juega 100 horas en total', 'Juega un total de 100 horas en el juego'),
('Vampiro', 'Bebe sangre de 50 enemigos', 'Obten 50 victorias y alimentate de tus enemigos'),
('Solucionador', 'Resuelve todos los acertijos del juego', 'Encuentra todas las soluciones de los puzzles'),
('Héroe solitario', 'Completa el juego sin ayuda de aliados', 'Finaliza el juego sin que ningun aliado participe'),
('Explorador aéreo', 'Vuela por todos los puntos altos del mapa', 'Vuela a todos los puntos elevados del mapa'),
('Reparador', 'Repara todos los vehículos en el juego', 'Haz reparaciones completas en todos los vehuculos disponibles'),
('Asesino sigiloso', 'Elimina a 50 enemigos sin ser detectado', 'Acaba con 50 enemigos sin que te vean'),
('Rey de la colina', 'Domina una ubicación estratégica durante 24 horas', 'Manten el control de un lugar importante durante 24 horas de juego'),
('Campamento base', 'Construye 10 bases diferentes', 'Levanta al menos 10 bases en distintas ubicaciones'),
('Ciberexperto', 'Hackea 100 sistemas', 'Realiza 100 hackeos en diferentes sistemas de seguridad'),
('Arma secreta', 'Desbloquea todas las armas del juego', 'Consigue todas las armas posibles'),
('Maestro de la defensa', 'Construye 50 fortificaciones exitosas', 'Levanta 50 estructuras defensivas con exito'),
('Navegante experto', 'Cruza todos los mares del juego', 'Navega por todos los oceanos disponibles en el mapa'),
('Peleador imbatible', 'Derrota a 10 jefes sin recibir daño', 'Acaba con 10 jefes sin perder vida'),
('Corredor de la muerte', 'Corre durante 100 km en total', 'Suma un total de 100 km corriendo dentro del juego'),
('Mago poderoso', 'Desbloquea todos los hechizos', 'Obten todos los hechizos disponibles en el juego'),
('Destructor de vehículos', 'Destruye 50 vehículos enemigos', 'Acaba con 50 vehiculos de tus enemigos'),
('Explorador submarino', 'Descubre todos los puntos bajo el agua', 'Visita todas las localizaciones submarinas del mapa'),
('Aventurero intrépido', 'Haz una travesía en todas las zonas peligrosas', 'Recorre todas las areas de alto riesgo del juego'),
('Comerciante exitoso', 'Gana 100000 monedas', 'Consigue una suma de 100000 monedas durante la partida'),
('Defensor del pueblo', 'Protege a 50 NPCs en peligro', 'Rescata a 50 NPCs de situaciones peligrosas'),
('Ladrón hábil', 'Roba 100 objetos sin ser detectado', 'Lleva a cabo 100 robos exitosos sin ser visto'),
('Creador de historia', 'Escribe una historia completa en el juego', 'Genera tu propia narrativa completa dentro del juego'),
('Coleccionista de rarezas', 'Recoge todas las armas raras', 'Hazte con todas las armas de coleccion disponibles'),
('Cazador de tesoros', 'Encuentra todos los cofres escondidos', 'Localiza todos los cofres ocultos en el mapa'),
('Estratega militar', 'Gana 50 batallas con más de 50 enemigos', 'Derrota a mas de 50 enemigos en 50 batallas diferentes'),
('Gurú de las habilidades', 'Maximiza todas las habilidades del personaje', 'Haz que todas las habilidades de tu personaje alcancen el nivel maximo'),
('Justiciero', 'Vengate de 100 enemigos', 'Elimina a 100 enemigos como venganza de tus caidos'),
('Luchador de la arena', 'Gana 100 batallas en la arena', 'Participa y gana 100 combates en la arena'),
('Ninja sigiloso', 'Completa 5 misiones sin ser detectado', 'Realiza 5 misiones completas sin ser visto'),
('Táctico perfecto', 'Gana una batalla sin perder ninguna unidad', 'Gana una batalla perdiendo ninguna de tus unidades'),
('Conquistador', 'Captura todas las ciudades del mapa', 'Controla todas las ciudades dentro del juego'),
('Viajero incansable', 'Recorre 1000 km a pie', 'Pasea por el mapa un total de 1000 km caminando'),
('Rey del combate', 'Gana 1000 combates en total', 'Acumula 1000 victorias en combates durante el juego'),
('Superhéroe', 'Desbloquea todas las mejoras del héroe', 'Mejora todas las caracteristicas de tu heroe al maximo'),
('Hermano leal', 'Ayuda a tus compañeros en 50 misiones', 'Completa 50 misiones en las que ayudas a tus companeros'),
('Desafiante', 'Acepta 50 desafíos en el juego', 'Participa en 50 desafios dentro del juego'),
('Conquistador de mundos', 'Gana todos los niveles del juego', 'Completa todos los niveles de dificultad disponibles'),
('Fuerza imparable', 'Realiza 100 ataques críticos consecutivos', 'Haz 100 ataques criticos seguidos sin fallar'),
('Salvador', 'Salva a todos los rehenes en el juego', 'Rescata a todos los prisioneros dentro del juego'),
('Maestro de los puzzles', 'Resuelve todos los acertijos del juego', 'Resuelve todos los puzzles disponibles'),
('Perfeccionista', 'Completa todas las misiones al 100%', 'Finaliza todas las misiones del juego con todos los objetivos cumplidos'),
('Rey de la caza', 'Caza 500 criaturas diferentes', 'Elimina 500 criaturas unicas del juego'),
('Escapista', 'Escapa de una trampa mortal', 'Logra escapar de una trampa peligrosa en el juego'),
('El regreso del héroe', 'Vuelve a completar el juego después de haberlo terminado', 'Juega y termina el juego nuevamente despues de completar la historia'),
('Master de la estrategia', 'Gana una batalla sin perder ningún soldado', 'Gana una batalla en un juego de estrategia sin perder tropas'),
('Troleador', 'Realiza una broma exitosa a un NPC', 'Engana a un NPC de manera exitosa durante el juego'),
('Explorador del cosmos', 'Visita todos los planetas disponibles', 'Explora todos los planetas dentro del juego'),
('Invencible', 'No recibas daño durante una misión completa', 'Completa una mision sin recibir dano alguno'),
('Vampiro virtual', 'Bebe sangre de 100 enemigos', 'Consigue 100 victorias en las que alimentas a tu personaje de sangre'),
('Cazador de monstruos', 'Derrota 50 jefes monstruosos', 'Elimina a 50 jefes monstruosos en el juego'),
('Jardinero', 'Planta y cuida 100 plantas', 'Planta y cuida exitosamente 100 plantas en el juego'),
('Corredor de resistencia', 'Corre sin parar durante 5 horas de juego', 'Suma 5 horas continuas corriendo sin descansar'),
('Explorador urbano', 'Recorre todas las ciudades del mapa', 'Visita todas las ciudades disponibles en el mundo del juego'),
('Luchador incansable', 'Gana 200 combates en total', 'Participa en y gana 200 combates dentro del juego'),
('Forjador', 'Fabrica 100 piezas de equipo únicas', 'Crea 100 articulos de equipo exclusivos en el juego'),
('Luchador honorario', 'Gana un combate sin usar habilidades especiales', 'Gana una batalla sin usar ninguna habilidad especial'),
('Conquistador de reinos', 'Conquista todas las fortalezas en el mapa', 'Captura y controla todas las fortalezas disponibles'),
('Invencible en el combate', 'No pierdas ninguna pelea durante una temporada completa', 'Manten un record de invicto durante 10 combates consecutivos'),
('Espectro mortal', 'Escóndete y derrota 100 enemigos sin ser visto', 'Elimina 100 enemigos sin que te detecten'),
('Secretos del pasado', 'Encuentra todos los secretos ocultos en el juego', 'Descubre todos los secretos y areas ocultas dentro del mapa'),
('Sentencia de hierro', 'Desbloquea todas las armas de alto nivel', 'Consigue todas las armas mas poderosas del juego'),
('El último samurái', 'Gana 50 duelos en el modo historia', 'Participa y gana 50 duelos en la historia principal del juego'),
('Multitarea', 'Completa tres misiones al mismo tiempo', 'Realiza y termina tres misiones simulaaneamente'),
('Chico de los recados', 'Entrega 50 misiones a los NPCs', 'Completa 50 misiones en las que entregas objetos o mensajes'),
('Asesino a sueldo', 'Elimina a 100 enemigos sin ser detectado', 'Mata a 100 enemigos sin ser visto o alertar a los demas'),
('Táctico experto', 'Haz 50 movimientos tácticos perfectos', 'Realiza 50 movimientos estrategicos perfectos durante las batallas'),
('Rompe cadenas', 'Escapa de 50 prisioneros sin ayuda', 'Libera 50 prisioneros sin que nadie mas te asista'),
('Supervivencia avanzada', 'Sobrevive 100 días sin morir en modo difícil', 'Vive 100 dias en el juego sin morir en un nivel de dificultad alta'),
('Maestro de la invasión', 'Invade 10 bases enemigas', 'Toma y destruye 10 bases enemigas exitosamente'),
('El gran consejero', 'Ayuda a 100 personajes con sus problemas', 'Proporciona consejos o ayuda a 100 personajes dentro del juego'),
('Cazador de reliquias', 'Encuentra todos los artefactos antiguos', 'Descubre todas las reliquias y artefactos historicos del juego'),
('Reina del combate', 'Gana 100 combates consecutivos contra otros jugadores', 'Participa y gana 100 batallas contra otros jugadores sin perder'),
('La memoria del héroe', 'Recoge todos los recuerdos importantes del protagonista', 'Obten y conserva todos los recuerdos o trofeos de la historia principal'),
('Cazador de secretos', 'Encuentra todas las habitaciones secretas del juego', 'Descubre todas las habitaciones ocultas y secretos dentro del mapa'),
('Maestro de las trampas', 'Desactiva 50 trampas letales', 'Desarma 50 trampas mortales durante tu exploracion'),
('Fuerza de la naturaleza', 'Desbloquea el poder de la naturaleza', 'Desbloquea todas las habilidades relacionadas con la naturaleza'),
('Cuentista', 'Escribe 100 historias dentro del juego', 'Crea 100 relatos o historias dentro del mundo del juego'),
('Comerciante astuto', 'Realiza 100 transacciones exitosas en el mercado', 'Vende o compra articulos de forma exitosa 100 veces'),
('El último superviviente', 'Sé el último en pie en una batalla masiva', 'Gana una batalla masiva donde el objetivo es sobrevivir'),
('Juez implacable', 'Realiza 100 juicios y decisiones difíciles', 'Toma 100 decisiones de gran impacto dentro del juego'),
('Explorador interdimensional', 'Viaja a todas las dimensiones alternativas', 'Visita todas las dimensiones y realidades alternativas disponibles'),
('Alquimista supremo', 'Crea 100 pociones raras', 'Elabora 100 pociones raras durante el transcurso del juego'),
('Jinete legendario', 'Monta todas las criaturas del juego', 'Domina todas las criaturas y bestias en el mundo del juego'),
('Cazador nocturno', 'Caza 50 criaturas nocturnas', 'Caza 50 enemigos que solo aparecen de noche'),
('Vidente', 'Desbloquea todas las visiones y habilidades especiales', 'Desbloquea todas las habilidades ocultas dentro del juego'),
('Comandante estratégico', 'Dirige 50 batallas y gana todas', 'Participa y gana 50 batallas de estrategia sin perder ninguna'),
('Maestro de la espada', 'Gana 100 batallas con solo un tipo de arma', 'Gana 100 combates usando solo un tipo de arma en especifico'),
('Generador de caos', 'Causa el caos en una ciudad completa', 'Crea un desastre total en una de las ciudades del juego'),
('Eres el elegido', 'Recibe la bendición de un dios', 'Obten la bendicion de un ser divino dentro de la narrativa del juego');


-- Tabla COMENTARIOS
INSERT INTO COMENTARIOS (Id_jugador, Id_videojuego, Votacion, Gusto, Opinion)
VALUES
(7, 15, 9, TRUE, 'Un juego con una historia impresionante, me encantó'),
(10, 22, 6, FALSE, 'El juego tiene mucho potencial, pero necesita mejorar'),
(12, 25, 8, TRUE, 'Gráficos geniales, aunque la jugabilidad es un poco lenta'),
(14, 30, 7, TRUE, 'El multijugador es muy divertido, pero los servidores no siempre funcionan bien'),
(16, 33, 10, TRUE, 'La mejor experiencia de sandbox que he tenido'),
(17, 35, 5, FALSE, 'Demasiado repetitivo, no me enganchó'),
(18, 38, 9, TRUE, 'Gran juego, aunque el precio es un poco alto'),
(20, 40, 7, TRUE, 'Entretenido, pero le faltan más características'),
(22, 42, 8, TRUE, 'Me encantó el diseño de los niveles, aunque a veces es algo confuso'),
(24, 45, 6, FALSE, 'Los controles no son tan buenos como esperaba'),
(26, 48, 9, TRUE, 'Una gran aventura, me divertí muchísimo jugando'),
(28, 50, 7, TRUE, 'Buen juego, pero podría mejorar en algunos aspectos'),
(30, 52, 8, TRUE, 'Una buena experiencia de lucha, con grandes enemigos'),
(32, 55, 6, FALSE, 'El juego tiene muchas fallas, especialmente en el modo historia'),
(34, 57, 10, TRUE, 'El mejor juego de todos, no tiene competencia'),
(35, 60, 7, TRUE, 'Un juego muy entretenido, pero se vuelve repetitivo'),
(37, 62, 9, TRUE, 'Me encantaron las mecánicas, muy innovador'),
(39, 64, 6, FALSE, 'Me esperaba más de este título, no cumplió mis expectativas'),
(41, 66, 8, TRUE, 'El combate es muy divertido, pero falta contenido'),
(43, 68, 9, TRUE, 'Excelente juego, me hizo sentir como un verdadero héroe'),
(45, 70, 8, TRUE, 'Un buen juego, pero la historia podría ser mejor'),
(47, 72, 10, TRUE, 'Juegazo, me enganchó de principio a fin'),
(49, 74, 7, TRUE, 'Divertido pero con algunas mecánicas que pueden ser mejoradas'),
(51, 76, 6, FALSE, 'No me gustó, me aburrí muy rápido'),
(53, 78, 9, TRUE, 'Un juego muy original, diferente a lo que he jugado antes'),
(55, 80, 7, TRUE, 'Buena jugabilidad, pero los gráficos dejan que desear'),
(57, 82, 8, TRUE, 'Muy buen juego, aunque el mapa podría ser más grande'),
(59, 85, 6, FALSE, 'No es lo que esperaba, no lo recomendaría'),
(61, 88, 10, TRUE, 'Es increíble, la mejor experiencia de aventura que he tenido'),
(63, 90, 9, TRUE, 'El juego tiene una jugabilidad increíble, muy recomendable'),
(65, 92, 8, TRUE, 'Aunque tiene sus fallas, la historia me atrapó'),
(67, 94, 6, FALSE, 'No me gustó la mecánica de combate, fue frustrante'),
(69, 96, 7, TRUE, 'El juego tiene buenas ideas, pero aún se siente incompleto'),
(71, 98, 9, TRUE, 'Gran juego, aunque tiene algunos bugs que deberían corregir'),
(73, 100, 10, TRUE, 'Un juego perfecto en todos los sentidos, totalmente recomendable'),
(75, 102, 8, TRUE, 'Me gustó mucho, pero hay algunos detalles que podrían mejorar'),
(77, 104, 7, TRUE, 'Un juego divertido, aunque le faltan más opciones de personalización'),
(79, 106, 6, FALSE, 'La historia no me atrapó y los gráficos no son muy buenos'),
(81, 108, 9, TRUE, 'Un juego con mucha acción y muy entretenido'),
(83, 110, 8, TRUE, 'Muy buen juego, aunque podría haber más variedad en las misiones'),
(85, 112, 7, TRUE, 'Un juego entretenido, pero el sistema de combate es algo complicado'),
(87, 102, 4,FALSE, 'El juego me pareció aburrido y demasiado largo'),
(89, 110, 8, TRUE, 'Muy buen juego, pero algunas misiones son demasiado repetitivas'),
(91, 105, 9, TRUE, 'Me encantaron los gráficos, muy detallados y realistas'),
(93, 100, 6, FALSE, 'No cumplió con mis expectativas, esperaba mucho más'),
(95, 85, 8, TRUE, 'Un juego de estrategia muy entretenido y desafiante'),
(97, 15, 7, TRUE, 'Está bien, pero no es tan bueno como esperaba'),
(99, 12, 9, TRUE, 'Excelente juego, gran experiencia de combate y aventura'),
(100, 45, 10, TRUE, 'El mejor juego de aventuras que he jugado en años'),
(6, 5, 9, TRUE, 'Gran juego, con mucha libertad y diversión'),
(8, 7, 7, TRUE, 'Interesante, pero el ritmo es algo lento al principio'),
(10, 9, 8, TRUE, 'Entretenido, pero le falta algo de pulido en las mecánicas'),
(11, 11, 6, FALSE, 'Me aburrió bastante, esperaba más acción'),
(12, 13, 9, TRUE, 'Espectacular historia y jugabilidad, muy recomendable'),
(14, 15, 8, TRUE, 'Buen juego, aunque las misiones secundarias podrían ser más variadas'),
(16, 17, 7, TRUE, 'Un buen juego, pero la curva de dificultad es demasiado alta'),
(18, 19, 9, TRUE, 'Muy divertido y adictivo, lo he jugado durante horas'),
(20, 21, 6, FALSE, 'No me convenció, los controles son un poco torpes'),
(22, 23, 8, TRUE, 'Un excelente juego de aventura, me encantó el mundo abierto'),
(24, 25, 9, TRUE, 'Muy buen juego, aunque algunos bugs deben ser corregidos'),
(26, 27, 7, TRUE, 'Entretenido, pero con algunas mecánicas que podrían mejorar'),
(28, 29, 10, TRUE, 'Me encanta todo de este juego, definitivamente lo volveré a jugar'),
(30, 31, 8, TRUE, 'Buena experiencia, pero le falta algo de originalidad'),
(32, 33, 6, FALSE, 'No lo disfruté, no me enganchó en absoluto'),
(34, 35, 9, TRUE, 'Gran título, muy divertido, lo recomiendo a todos los fanáticos de RPG'),
(36, 37, 8, TRUE, 'La historia es increíble, aunque las misiones son un poco repetitivas'),
(38, 39, 7, TRUE, 'Un buen juego, pero los gráficos pueden ser mejorados'),
(40, 41, 10, TRUE, 'Impresionante juego, realmente me sumergió en su mundo'),
(42, 43, 6, FALSE, 'No es lo que esperaba, no me atrajo como pensaba'),
(44, 45, 8, TRUE, 'Muy divertido, aunque el sistema de combate podría ser más dinámico'),
(46, 47, 9, TRUE, 'Uno de los mejores juegos que he jugado este año, simplemente excelente'),
(48, 49, 7, TRUE, 'Entretenido, pero algunas mecánicas no están bien implementadas'),
(50, 51, 10, TRUE, 'Es uno de los mejores juegos de acción, muy recomendable'),
(52, 53, 8, TRUE, 'Divertido y con buenas ideas, aunque podría profundizar más en la historia'),
(54, 55, 6, FALSE, 'No me enganchó, tiene muchos elementos que no me gustan'),
(56, 57, 9, TRUE, 'Me encantó, aunque algunas misiones son bastante difíciles'),
(58, 59, 7, TRUE, 'Buen juego, pero podría haber sido mejor con más opciones de personalización'),
(60, 61, 8, TRUE, 'Entretenido y con buena historia, pero con fallos técnicos'),
(62, 63, 9, TRUE, 'Gran juego, con una historia apasionante y unos gráficos impresionantes'),
(64, 65, 7, TRUE, 'Es un buen juego, pero esperaba más interacción con los personajes'),
(66, 67, 9, TRUE, 'Me sorprendió, lo disfruté mucho más de lo que pensaba'),
(68, 69, 8, TRUE, 'Muy buen juego, aunque algunas zonas del mapa son repetitivas'),
(70, 71, 6, FALSE, 'No fue de mi agrado, no logró atraparme'),
(72, 73, 10, TRUE, 'Uno de los mejores juegos que he jugado, no me cansé de jugarlo'),
(74, 75, 9, TRUE, 'Excelente juego, aunque la dificultad es algo elevada en algunas partes'),
(76, 77, 8, TRUE, 'Gran juego, aunque la historia es un poco predecible en algunos momentos'),
(78, 79, 7, TRUE, 'Divertido, pero hay ciertos aspectos que se sienten desbalanceados'),
(80, 81, 6, FALSE, 'Me pareció muy monótono, no me enganchó'),
(82, 83, 8, TRUE, 'Es un juego que vale la pena, pero le falta algo de variedad en las misiones'),
(84, 85, 7, TRUE, 'Buen juego en general, pero los gráficos podrían ser mejores'),
(86, 87, 9, TRUE, 'Muy buen juego, con un combate que me dejó impresionado'),
(88, 89, 6, FALSE, 'El juego se siente vacío, no logró atraparme'),
(90, 91, 9, TRUE, 'Excelente historia, con una jugabilidad muy sólida'),
(92, 93, 8, TRUE, 'Divertido, pero el final del juego me dejó algo decepcionado'),
(94, 95, 10, TRUE, 'Juego increíble, no puedo esperar para la siguiente entrega'),
(96, 97, 7, TRUE, 'Es un buen juego, pero algunas mecánicas se sienten anticuadas'),
(98, 99, 8, TRUE, 'Disfruté mucho el juego, aunque los tiempos de carga son largos'),
(100, 101, 9, TRUE, 'Un título muy divertido, con grandes gráficos y un mundo amplio'),
(102, 103, 6, FALSE, 'No logró cautivarme, me aburrí después de unas horas de juego'),
(104, 105, 8, TRUE, 'Buen juego, con muchas posibilidades, pero le faltan más misiones'),
(106, 107, 9, TRUE, 'Me sorprendió para bien, tiene una historia que te mantiene enganchado'),
(108, 109, 7, TRUE, 'Divertido, pero algo corto'),
(110, 111, 6, FALSE, 'No es lo que esperaba, me decepcionó un poco'),
(112, 113, 10, TRUE, 'Una de las mejores experiencias que he tenido, altamente recomendable'),
(114, 109, 8, TRUE, 'Un buen juego, aunque algunas mecánicas son confusas al principio');

-- Tabla VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
INSERT INTO VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR (Id_desarrollador, Id_distribuidor, Id_videojuego)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(1, 1, 6),
(2, 2, 7),
(3, 3, 8),
(4, 4, 9),
(5, 5, 10),
(6, 1, 11),
(7, 2, 12),
(8, 3, 13),
(9, 4, 14),
(10, 5, 15),
(6, 2, 16),
(7, 3, 17),
(8, 4, 18),
(9, 5, 19),
(10, 1, 20),
(11, 2, 21),
(12, 3, 22),
(13, 4, 23),
(14, 5, 24),
(11, 1, 25),
(12, 2, 26),
(13, 3, 27),
(14, 4, 28),
(15, 5, 29),
(16, 1, 30),
(17, 2, 31),
(18, 3, 32),
(19, 4, 33),
(20, 5, 34),
(16, 2, 35),
(17, 3, 36),
(18, 4, 37),
(19, 5, 38),
(20, 1, 39),
(21, 2, 40),
(22, 3, 41),
(23, 4, 42),
(24, 5, 43),
(21, 1, 44),
(22, 2, 45),
(23, 3, 46),
(24, 4, 47),
(25, 5, 48),
(26, 1, 49),
(27, 2, 50),
(28, 3, 51),
(29, 4, 52),
(30, 5, 53),
(26, 2, 54),
(27, 3, 55),
(28, 4, 56),
(29, 5, 57),
(30, 1, 58),
(31, 2, 59),
(32, 3, 60),
(33, 4, 61),
(34, 5, 62),
(31, 1, 63),
(32, 2, 64),
(33, 3, 65),
(34, 4, 66),
(35, 5, 67),
(36, 1, 68),
(37, 2, 69),
(38, 3, 70),
(39, 4, 71),
(40, 5, 72),
(36, 2, 73),
(37, 3, 74),
(38, 4, 75),
(39, 5, 76),
(40, 1, 77),
(41, 2, 78),
(42, 3, 79),
(43, 4, 80),
(44, 5, 81),
(41, 1, 82),
(42, 2, 83),
(43, 3, 84),
(44, 4, 85),
(45, 5, 86),
(46, 1, 87),
(47, 2, 88),
(48, 3, 89),
(49, 4, 90),
(50, 5, 91),
(46, 2, 92),
(47, 3, 93),
(48, 4, 94),
(49, 5, 95),
(50, 1, 96),
(1, 2, 97),
(2, 3, 98),
(3, 4, 99),
(4, 5, 100),
(1, 1, 101),
(2, 2, 102),
(3, 3, 103),
(4, 4, 104),
(5, 5, 105),
(6, 1, 106),
(7, 2, 107),
(8, 3, 108),
(9, 4, 109),
(10, 5, 110),
(6, 2, 111),
(7, 3, 112),
(8, 4, 113);

-- Tabla GENEROS_JUGADOR
INSERT INTO GENEROS_JUGADOR (Id_jugador, Id_genero)
VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(3, 6),
(4, 7),
(4, 8),
(5, 9),
(5, 10),
(6, 11),
(6, 12),
(7, 13),
(7, 14),
(8, 15),
(8, 16),
(9, 17),
(9, 18),
(10, 19),
(10, 20),
(11, 21),
(11, 22),
(12, 23),
(12, 24),
(13, 25),
(13, 26),
(14, 27),
(14, 28),
(15, 29),
(15, 30),
(16, 31),
(16, 32),
(17, 33),
(17, 34),
(18, 35),
(18, 36),
(19, 37),
(19, 38),
(20, 39),
(20, 40),
(21, 41),
(21, 42),
(22, 43),
(22, 44),
(23, 45),
(23, 46),
(24, 47),
(24, 48),
(25, 49),
(25, 50),
(26, 1),
(26, 2),
(27, 3),
(27, 4),
(28, 5),
(28, 6),
(29, 7),
(29, 8),
(30, 9),
(30, 10),
(31, 11),
(31, 12),
(32, 13),
(32, 14),
(33, 15),
(33, 16),
(34, 17),
(34, 18),
(35, 19),
(35, 20),
(36, 21),
(36, 22),
(37, 23),
(37, 24),
(38, 25),
(38, 26),
(39, 27),
(39, 28),
(40, 29),
(40, 30),
(41, 31),
(41, 32),
(42, 33),
(42, 34),
(43, 35),
(43, 36),
(44, 37),
(44, 38),
(45, 39),
(45, 40),
(46, 41),
(46, 42),
(47, 43),
(47, 44),
(48, 45),
(48, 46),
(49, 47),
(49, 48),
(50, 49),
(50, 50),
(51, 1),
(51, 2),
(52, 3),
(52, 4),
(53, 5),
(53, 6),
(54, 7),
(54, 8),
(55, 9),
(55, 10),
(34, 1),
(102, 2),
(157, 3),
(82, 4),
(90, 5),
(120, 6),
(50, 7),
(168, 8),
(39, 9),
(160, 10),
(74, 11),
(110, 12),
(25, 13),
(185, 14),
(48, 15),
(56, 16),
(33, 17),
(13, 18),
(146, 19),
(119, 20),
(103, 21),
(65, 22),
(7, 23),
(184, 24),
(78, 25),
(143, 26),
(152, 27),
(38, 28),
(150, 29),
(26, 30),
(160, 31),
(121, 32),
(68, 33),
(106, 34),
(122, 35),
(94, 36),
(116, 37),
(77, 38),
(164, 39),
(110, 40),
(80, 41),
(172, 42),
(109, 43),
(167, 44),
(61, 45),
(51, 46),
(28, 47),
(171, 48),
(5, 49),
(142, 50),
(114, 1),
(18, 2),
(88, 3),
(49, 4),
(174, 5),
(112, 6),
(61, 7),
(21, 8),
(155, 9),
(148, 10),
(72, 11),
(41, 12),
(130, 13),
(164, 14),
(96, 15),
(59, 16),
(146, 17),
(113, 18),
(115, 19),
(16, 20),
(93, 21),
(76, 22),
(31, 23),
(69, 24),
(143, 25),
(9, 26),
(40, 27),
(97, 28),
(166, 29),
(158, 30),
(111, 31),
(154, 32),
(153, 33),
(30, 34),
(147, 35),
(154, 36),
(83, 37),
(38, 38),
(35, 39),
(18, 40),
(128, 41),
(120, 42),
(37, 43),
(85, 44);


-- Tabla LISTA_DESEADOS
INSERT INTO LISTA_DESEADOS (Id_jugador, Id_videojuego)
VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 6),
(6, 7),
(7, 8),
(8, 9),
(9, 10),
(10, 11),
(11, 12),
(12, 13),
(13, 14),
(14, 15),
(15, 16),
(16, 17),
(17, 18),
(18, 19),
(19, 20),
(20, 21),
(21, 22),
(22, 23),
(23, 24),
(24, 25),
(25, 26),
(26, 27),
(27, 28),
(28, 29),
(29, 30),
(30, 31),
(31, 32),
(32, 33),
(33, 34),
(34, 35),
(35, 36),
(36, 37),
(37, 38),
(38, 39),
(39, 40),
(40, 41),
(41, 42),
(42, 43),
(43, 44),
(44, 45),
(45, 46),
(46, 47),
(47, 48),
(48, 49),
(49, 50),
(50, 51);

-- Tabla BIBLIOTECA_VIDEOJUEGO
INSERT INTO BIBLIOTECA_VIDEOJUEGO (Id_videojuego, Id_biblioteca, Tiempo, Fecha, Activo, Fecha_guardado)
VALUES
(1, 5, 120, '30/12/2023', TRUE, '29/12/2023'),
(2, 10, 100, '01/12/2023', TRUE, '30/11/2023'),
(3, 15, 80, '01/12/2023', TRUE, '30/11/2023'),
(4, 20, 60, '01/07/2023', FALSE, '30/06/2023'),
(5, 25, 150, '01/11/2024', TRUE, '31/10/2024'),
(6, 30, 110, '12/12/2023', TRUE, '11/12/2023'),
(7, 35, 95, '15/01/2024', TRUE, '14/01/2024'),
(8, 40, 120, '20/02/2024', TRUE, '19/02/2024'),
(9, 45, 130, '25/03/2024', FALSE, '24/03/2024'),
(10, 50, 140, '30/04/2024', TRUE, '29/04/2024'),
(11, 55, 100, '05/05/2024', TRUE, '04/05/2024'),
(12, 60, 110, '10/06/2024', TRUE, '09/06/2024'),
(13, 65, 90, '15/07/2024', TRUE, '14/07/2024'),
(14, 70, 120, '20/08/2024', TRUE, '19/08/2024'),
(15, 75, 105, '25/09/2024', TRUE, '24/09/2024'),
(16, 80, 135, '01/10/2024', FALSE, '30/09/2024'),
(17, 85, 125, '05/11/2024', TRUE, '04/11/2024'),
(18, 90, 100, '10/12/2024', TRUE, '09/12/2024'),
(19, 95, 110, '15/01/2025', TRUE, '14/01/2025'),
(20, 100, 120, '20/02/2025', TRUE, '19/02/2025'),
(21, 105, 105, '25/03/2025', FALSE, '24/03/2025'),
(22, 110, 130, '01/04/2025', TRUE, '31/03/2025'),
(23, 115, 90, '05/05/2025', TRUE, '04/05/2025'),
(24, 120, 140, '10/06/2025', TRUE, '09/06/2025'),
(25, 125, 100, '15/07/2025', TRUE, '14/07/2025'),
(26, 130, 110, '20/08/2025', TRUE, '19/08/2025'),
(27, 135, 120, '25/09/2025', TRUE, '24/09/2025'),
(28, 140, 130, '01/10/2025', TRUE, '30/09/2025'),
(29, 145, 105, '05/11/2025', FALSE, '04/11/2025'),
(30, 150, 115, '10/12/2025', TRUE, '09/12/2025'),
(31, 5, 100, '15/01/2026', TRUE, '14/01/2026'),
(32, 10, 120, '20/02/2026', TRUE, '19/02/2026'),
(33, 15, 130, '25/03/2026', TRUE, '24/03/2026'),
(34, 20, 105, '01/04/2026', TRUE, '31/03/2026'),
(35, 25, 140, '05/05/2026', TRUE, '04/05/2026'),
(36, 30, 115, '10/06/2026', TRUE, '09/06/2026'),
(37, 35, 130, '15/07/2026', FALSE, '14/07/2026'),
(38, 40, 110, '20/08/2026', TRUE, '19/08/2026'),
(39, 45, 95, '25/09/2026', TRUE, '24/09/2026'),
(40, 50, 125, '01/10/2026', TRUE, '30/09/2026'),
(41, 55, 135, '05/11/2026', TRUE, '04/11/2026'),
(42, 60, 100, '10/12/2026', TRUE, '09/12/2026'),
(43, 65, 110, '15/01/2027', TRUE, '14/01/2027'),
(44, 70, 120, '20/02/2027', FALSE, '19/02/2027'),
(45, 75, 130, '25/03/2027', TRUE, '24/03/2027'),
(46, 80, 105, '01/04/2027', TRUE, '31/03/2027'),
(47, 85, 140, '05/05/2027', TRUE, '04/05/2027'),
(48, 90, 100, '10/06/2027', TRUE, '09/06/2027'),
(49, 95, 110, '15/07/2027', TRUE, '14/07/2027'),
(50, 100, 120, '20/08/2027', TRUE, '19/08/2027');

-- Tabla LOGROS_VIDEOJUEGOS
INSERT INTO LOGROS_VIDEOJUEGOS (Id_videojuego, Id_logro)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30),
(31, 31),
(32, 32),
(33, 33),
(34, 34),
(35, 35),
(36, 36),
(37, 37),
(38, 38),
(39, 39),
(40, 40),
(41, 41),
(42, 42),
(43, 43),
(44, 44),
(45, 45),
(46, 46),
(47, 47),
(48, 48),
(49, 49),
(50, 50);

-- Tabla LOGROS_JUGADOR
INSERT INTO LOGROS_JUGADOR (Id_logro, Id_jugador)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(21, 21),
(22, 22),
(23, 23),
(24, 24),
(25, 25),
(26, 26),
(27, 27),
(28, 28),
(29, 29),
(30, 30),
(31, 31),
(32, 32),
(33, 33),
(34, 34),
(35, 35),
(36, 36),
(37, 37),
(38, 38),
(39, 39),
(40, 40),
(41, 41),
(42, 42),
(43, 43),
(44, 44),
(45, 45),
(46, 46),
(47, 47),
(48, 48),
(49, 49),
(50, 50);

-- Para eliminar la vista si ya existe antes de crearla
DROP VIEW IF EXISTS V_Nombres_Videojuegos_Totales;
CREATE VIEW V_Nombres_Videojuegos_Totales AS
SELECT 
    j.Nombre AS nombre_jugador,
    v.Nombre AS nombre_videojuego
FROM 
    BIBLIOTECA_VIDEOJUEGO bv
JOIN 
    BIBLIOTECA b ON bv.Id_biblioteca = b.Id_biblioteca
JOIN 
    JUGADOR j ON b.Id_jugador = j.Id_jugador
JOIN 
    VIDEOJUEGOS v ON bv.Id_videojuego = v.Id_videojuego;

-- Vista: Nombres de los videojuegos activos en las bibliotecas de cada jugador
DROP VIEW IF EXISTS V_Nombres_Videojuegos_Activos;
CREATE VIEW V_Nombres_Videojuegos_Activos AS
SELECT 
    j.Nombre AS nombre_jugador,
    v.Nombre AS nombre_videojuego
FROM 
    BIBLIOTECA_VIDEOJUEGO bv
JOIN 
    BIBLIOTECA b ON bv.Id_biblioteca = b.Id_biblioteca
JOIN 
    JUGADOR j ON b.Id_jugador = j.Id_jugador
JOIN 
    VIDEOJUEGOS v ON bv.Id_videojuego = v.Id_videojuego
WHERE 
    bv.Activo = TRUE;

-- Vista: Cuántos videojuegos ha comprado cada jugador
DROP VIEW IF EXISTS V_Videojuegos_Comprados;
CREATE VIEW V_Videojuegos_Comprados AS
SELECT 
    j.Nombre AS nombre_jugador,
    b.Numero_juegos AS numero_videojuegos_comprados
FROM 
    BIBLIOTECA b
JOIN 
    JUGADOR j ON b.Id_jugador = j.Id_jugador;

-- Vista: Jugadores que tienen videojuegos con descuentos activos
DROP VIEW IF EXISTS V_Jugadores_Con_Descuentos_Activos;
CREATE VIEW V_Jugadores_Con_Descuentos_Activos AS
SELECT 
    j.Nombre AS nombre_jugador,
    v.Nombre AS nombre_videojuego,
    v.Descuento_oferta AS descuento_activo
FROM 
    BIBLIOTECA_VIDEOJUEGO bv
JOIN 
    BIBLIOTECA b ON bv.Id_biblioteca = b.Id_biblioteca
JOIN 
    JUGADOR j ON b.Id_jugador = j.Id_jugador
JOIN 
    VIDEOJUEGOS v ON bv.Id_videojuego = v.Id_videojuego
WHERE 
    v.Descuento_oferta IS NOT NULL
    AND bv.Activo = TRUE;

-- Vista: Total de espacio usado por cada jugador en sus bibliotecas
DROP VIEW IF EXISTS V_Espacio_Usado_Total;
CREATE VIEW V_Espacio_Usado_Total AS
SELECT 
    j.Nombre AS nombre_jugador,
    b.Espacio_usado AS espacio_usado_total
FROM 
    BIBLIOTECA b
JOIN 
    JUGADOR j ON b.Id_jugador = j.Id_jugador;

-- Vista: Videojuegos más populares (en el mayor número de bibliotecas)
DROP VIEW IF EXISTS V_Videojuegos_Mas_Populares;
CREATE VIEW V_Videojuegos_Mas_Populares AS
SELECT 
    v.Nombre AS nombre_videojuego,
    COUNT(bv.Id_biblioteca) AS numero_bibliotecas
FROM 
    BIBLIOTECA_VIDEOJUEGO bv
JOIN 
    VIDEOJUEGOS v ON bv.Id_videojuego = v.Id_videojuego
GROUP BY 
    v.Nombre
ORDER BY 
    numero_bibliotecas DESC;

-- Vista: Jugadores con más logros obtenidos
DROP VIEW IF EXISTS V_Jugadores_Mas_Logros;
CREATE VIEW V_Jugadores_Mas_Logros AS
SELECT 
    j.Nombre AS nombre_jugador,
    COUNT(lj.Id_logro) AS numero_logros
FROM 
    LOGROS_JUGADOR lj
JOIN 
    JUGADOR j ON lj.Id_jugador = j.Id_jugador
GROUP BY 
    j.Nombre
ORDER BY 
    numero_logros DESC;

-- Vista: Lista de deseos de cada jugador
DROP VIEW IF EXISTS V_Lista_De_Deseos;
CREATE VIEW V_Lista_De_Deseos AS
SELECT 
    j.Nombre AS nombre_jugador,
    v.Nombre AS nombre_videojuego
FROM 
    LISTA_DESEADOS ld
JOIN 
    JUGADOR j ON ld.Id_jugador = j.Id_jugador
JOIN 
    VIDEOJUEGOS v ON ld.Id_videojuego = v.Id_videojuego;

-- Vista: Ventas totales de la plataforma
DROP VIEW IF EXISTS V_Ventas_Totales;
CREATE VIEW V_Ventas_Totales AS
SELECT 
    SUM(b.Numero_juegos) AS ventas_totales
FROM 
    BIBLIOTECA b;

-- Vista: Para cada distribuidor una lista de los desarrolladores asociados
DROP VIEW IF EXISTS V_Distribuidores_Desarrolladores;
CREATE VIEW V_Distribuidores_Desarrolladores AS
SELECT 
    d.Nombre AS nombre_distribuidor,
    dev.Nombre AS nombre_desarrollador
FROM 
    VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR vdd
JOIN 
    DISTRIBUIDOR d ON vdd.Id_distribuidor = d.Id_distribuidor
JOIN 
    DESARROLLADOR dev ON vdd.Id_desarrollador = dev.Id_desarrollador
GROUP BY 
    d.Nombre, dev.Nombre
ORDER BY 
    d.Nombre;

-- Vista: Para cada videojuego dame el nombre del videojuego, el distribuidor, el desarrollador y sus géneros
DROP VIEW IF EXISTS V_Videojuego_Distribuidor_Desarrollador_Generos;
CREATE VIEW V_Videojuego_Distribuidor_Desarrollador_Generos AS
SELECT 
    v.Nombre AS nombre_videojuego,
    d.Nombre AS nombre_distribuidor,
    dev.Nombre AS nombre_desarrollador,
    g.Nombre AS nombre_genero
FROM 
    VIDEOJUEGOS v
JOIN 
    VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR vdd ON v.Id_videojuego = vdd.Id_videojuego
JOIN 
    DISTRIBUIDOR d ON vdd.Id_distribuidor = d.Id_distribuidor
JOIN 
    DESARROLLADOR dev ON vdd.Id_desarrollador = dev.Id_desarrollador
LEFT JOIN 
    GENEROS_JUGADOR gj ON v.Id_videojuego = gj.Id_genero
LEFT JOIN 
    GENEROS g ON gj.Id_genero = g.Id_genero
GROUP BY 
    v.Nombre, d.Nombre, dev.Nombre, g.Nombre;

-- Vista: Para cada desarrollador una lista de los videojuegos que ha desarrollado
DROP VIEW IF EXISTS V_Desarrolladores_Videojuegos;
CREATE VIEW V_Desarrolladores_Videojuegos AS
SELECT 
    dev.Nombre AS nombre_desarrollador,
    v.Nombre AS nombre_videojuego
FROM 
    VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR vdd
JOIN 
    DESARROLLADOR dev ON vdd.Id_desarrollador = dev.Id_desarrollador
JOIN 
    VIDEOJUEGOS v ON vdd.Id_videojuego = v.Id_videojuego
GROUP BY 
    dev.Nombre, v.Nombre
ORDER BY 
    dev.Nombre;

-- Vista: Para cada distribuidor una lista de los videojuegos que distribuye
DROP VIEW IF EXISTS V_Distribuidores_Videojuegos;
CREATE VIEW V_Distribuidores_Videojuegos AS
SELECT 
    d.Nombre AS nombre_distribuidor,
    v.Nombre AS nombre_videojuego
FROM 
    VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR vdd
JOIN 
    DISTRIBUIDOR d ON vdd.Id_distribuidor = d.Id_distribuidor
JOIN 
    VIDEOJUEGOS v ON vdd.Id_videojuego = v.Id_videojuego
GROUP BY 
    d.Nombre, v.Nombre
ORDER BY 
    d.Nombre;

-- Vista: Para cada videojuego, qué DLCs tiene
DROP VIEW IF EXISTS V_Videojuego_DLCs;
CREATE VIEW V_Videojuego_DLCs AS
SELECT 
    v.Nombre AS nombre_videojuego,
    d.Nombre AS nombre_dlc
FROM 
    DLC d
JOIN 
    VIDEOJUEGOS v ON d.Id_videojuego = v.Id_videojuego
ORDER BY 
    v.Nombre, d.Nombre;

-- Vista: Cuántos videojuegos hay con descuentos, cuál es el valor de ese descuento y cuánto durará ese descuento
DROP VIEW IF EXISTS V_Videojuegos_Con_Descuento;
CREATE VIEW V_Videojuegos_Con_Descuento AS
SELECT 
    v.Id_videojuego AS videojuegos_con_descuento,
    v.Descuento_oferta AS valor_descuento,
    v.Duracion_oferta AS duracion_descuento
FROM 
    VIDEOJUEGOS v
WHERE 
    v.Descuento_oferta IS NOT NULL
GROUP BY 
    Id_videojuego, v.Descuento_oferta, v.Duracion_oferta
ORDER BY 
    valor_descuento DESC;

-- Vista: Para cada jugador, una lista de los comentarios que ha hecho y sobre qué videojuegos los ha hecho
DROP VIEW IF EXISTS V_Comentarios_Jugadores;
CREATE VIEW V_Comentarios_Jugadores AS
SELECT 
    j.Nombre AS nombre_jugador,
    v.Nombre AS nombre_videojuego,
    c.Opinion AS comentario
FROM 
    COMENTARIOS c
JOIN 
    JUGADOR j ON c.Id_jugador = j.Id_jugador
JOIN 
    VIDEOJUEGOS v ON c.Id_videojuego = v.Id_videojuego
ORDER BY 
    j.Nombre, v.Nombre;
