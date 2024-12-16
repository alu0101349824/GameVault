-- Nombres de los videojuegos totales en las bibliotecas de cada jugador
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
    
-- Nombres de los videojuegos activos en las bibliotecas de cada jugador
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

--Cuántos videojuegos ha comprado cada jugador
SELECT 
    j.Nombre AS nombre_jugador,
    b.Numero_juegos AS numero_videojuegos_comprados
FROM 
    BIBLIOTECA b
JOIN 
    JUGADOR j ON b.Id_jugador = j.Id_jugador;

-- Jugadores que tienen videojuegos con descuentos activos
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

-- Total de espacio usado por cada jugador en sus bibliotecas
SELECT 
    j.Nombre AS nombre_jugador,
    b.Espacio_usado AS espacio_usado_total
FROM 
    BIBLIOTECA b
JOIN 
    JUGADOR j ON b.Id_jugador = j.Id_jugador;

-- Videojuegos más populares (en el mayor número de bibliotecas)
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

-- Jugadores con más logros obtenidos
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

-- Lista de deseos de cada jugador
SELECT 
    j.Nombre AS nombre_jugador,
    v.Nombre AS nombre_videojuego
FROM 
    LISTA_DESEADOS ld
JOIN 
    JUGADOR j ON ld.Id_jugador = j.Id_jugador
JOIN 
    VIDEOJUEGOS v ON ld.Id_videojuego = v.Id_videojuego;

-- Ventas totales de la plataforma
SELECT 
    SUM(b.Numero_juegos) AS ventas_totales
FROM 
    BIBLIOTECA b;

-- Para cada distribuidor una lista de los desarrolladores asociados
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

-- Para cada videojuego dame el nombre del videojuego, el distribuidor, el desarrollador y sus géneros
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

-- Para cada desarrollador una lista de los videojuegos que ha desarrollado
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

-- Para cada distribuidor una lista de los videojuegos que distribuye
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

-- Para cada videojuego, qué DLCs tiene
SELECT 
    v.Nombre AS nombre_videojuego,
    d.Nombre AS nombre_dlc
FROM 
    DLC d
JOIN 
    VIDEOJUEGOS v ON d.Id_videojuego = v.Id_videojuego
ORDER BY 
    v.Nombre, d.Nombre;

-- Cuántos videojuegos hay con descuentos, cuál es el valor de ese descuento y cuánto durará ese descuento
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

-- Para cada jugador, una lista de los comentarios que ha hecho y sobre qué videojuegos los ha hecho
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

