-- Tabla DESARROLLADOR
CREATE TABLE DESARROLLADOR (
   Id_desarrollador INT PRIMARY KEY,
   Contraseña VARCHAR(255),
   Nombre VARCHAR(255),
   Imagen_perfil VARCHAR(255),
   Correo VARCHAR(255),
   Pais VARCHAR(100),
   Descripción TEXT,
   Numero_empleados INT,
   Presentación TEXT,
   Pagina_web VARCHAR(255)
);


-- Tabla DISTRIBUIDOR
CREATE TABLE DISTRIBUIDOR (
   Id_distribuidor INT PRIMARY KEY,
   Nombre VARCHAR(255) NOT NULL,
   Numero_Empleado INT CHECK (Numero_Empleado >= 0),
   Pagina_web VARCHAR(255) CHECK (Pagina_web ~* '^(http://|https://)?(www\.)?[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
   Presentacion TEXT
);


-- Tabla JUGADOR
CREATE TABLE JUGADOR (
   Id_jugador INT PRIMARY KEY,
   Nombre VARCHAR(255),
   Contraseña VARCHAR(255),
   Imagen_perfil VARCHAR(255),
   Correo VARCHAR(255),
   Pais VARCHAR(100),
   Descripción TEXT,
   Tarjeta_Credito VARCHAR(20)
);


-- Tabla BIBLIOTECA
CREATE TABLE BIBLIOTECA (
   Id_biblioteca INT PRIMARY KEY,
   Id_jugador INT UNIQUE,
   Numero_juegos INT,
   Espacio_usado DECIMAL(10, 2),
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador)
);


-- Tabla VIDEOJUEGOS
CREATE TABLE VIDEOJUEGOS (
   Id_videojuego INT PRIMARY KEY,
   Nombre VARCHAR(255),
   Fecha DATE,
   Descripción TEXT,
   Precio DECIMAL(10, 2),
   Duración INT,
   Oferta BOOLEAN,
   Descuento DECIMAL(5, 2),
   Regalado BOOLEAN,
   Tamaño DECIMAL(10, 2)
);


-- Tabla VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
CREATE TABLE VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR (
   Id_desarrollador INT,
   Id_distribuidor INT,
   Id_videojuego INT,
   PRIMARY KEY (Id_desarrollador, Id_distribuidor, Id_videojuego),
   FOREIGN KEY (Id_desarrollador) REFERENCES DESARROLLADOR(Id_desarrollador),
   FOREIGN KEY (Id_distribuidor) REFERENCES DISTRIBUIDOR(Id_distribuidor),
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego)
);


-- Tabla GENEROS
CREATE TABLE GENEROS (
   Id_genero INT PRIMARY KEY,
   Nombre VARCHAR(100),
   Descripción TEXT
);


-- Tabla GENEROS_JUGADOR
CREATE TABLE GENEROS_JUGADOR (
   Id INT PRIMARY KEY,
   Id_jugador INT,
   Id_genero INT,
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador),
   FOREIGN KEY (Id_genero) REFERENCES GENEROS(Id_genero)
);


-- Tabla LISTA_DESEADOS
CREATE TABLE LISTA_DESEADOS (
   Id INT PRIMARY KEY,
   Id_jugador INT,
   Id_videojuego INT,
   Nombre_videojuego VARCHAR(255),
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador),
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego)
);


-- Tabla BIBLIOTECA_VIDEOJUEGO
CREATE TABLE BIBLIOTECA_VIDEOJUEGO (
   Id INT PRIMARY KEY,
   Id_videojuego INT,
   Id_biblioteca INT,
   Nombre_videojuego VARCHAR(255),
   Tiempo INT,
   Fecha DATE,
   Activo BOOLEAN,
   Fecha_guardado DATE,
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego),
   FOREIGN KEY (Id_biblioteca) REFERENCES BIBLIOTECA(Id_biblioteca)
);


-- Tabla LOGROS
CREATE TABLE LOGROS (
   Id_logro INT PRIMARY KEY,
   Nombre VARCHAR(255),
   Descripción TEXT,
   Requisito TEXT
);


-- Tabla LOGROS_VIDEOJUEGOS
CREATE TABLE LOGROS_VIDEOJUEGOS (
   Id INT PRIMARY KEY,
   Id_videojuego INT,
   Id_logro INT,
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego),
   FOREIGN KEY (Id_logro) REFERENCES LOGROS(Id_logro)
);


-- Tabla LOGROS_JUGADOR
CREATE TABLE LOGROS_JUGADOR (
   Id INT PRIMARY KEY,
   Id_logro INT,
   Id_jugador INT,
   FOREIGN KEY (Id_logro) REFERENCES LOGROS(Id_logro),
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador)
);


-- Tabla COMENTARIOS
CREATE TABLE COMENTARIOS (
   Id_comentario INT PRIMARY KEY,
   Valoracion INT,
   Gusto BOOLEAN,
   Opinion TEXT,
   Id_jugador INT,
   Id_videojuego INT,
   FOREIGN KEY (Id_jugador) REFERENCES JUGADOR(Id_jugador),
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego)
);


-- Tabla DLC
CREATE TABLE DLC (
   Id_DLC INT PRIMARY KEY,
   Descripción TEXT,
   Precio DECIMAL(10, 2),
   Nombre VARCHAR(255),
   Id_videojuego INT,
   FOREIGN KEY (Id_videojuego) REFERENCES VIDEOJUEGOS(Id_videojuego)
);




