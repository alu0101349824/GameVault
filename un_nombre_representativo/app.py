from flask import Flask, render_template,request,redirect,url_for
import psycopg2 


app = Flask(__name__)

DB_CONFIG = {
    "dbname": "GameVault",
    "user": "admin",
    "password": "78945",
    "host": "localhost",
    "port": "5432"
}




def get_db_connection():
    """Establece una conexión a la base de datos PostgreSQL."""
    return psycopg2.connect(**DB_CONFIG)


# Rutas
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/jugadores', methods=["GET"])
def get_jugadores():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM JUGADOR ;')
    jugadorres = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_jugadores.html', jugadorres=jugadorres )


@app.route('/addjugadores', methods=['GET', 'POST'])
def add_jugador():
    if request.method == 'POST':
        # Capturar datos del formulario
        nombre = request.form['nombre']
        contraseña = request.form['contraseña']
        correo = request.form['correo']
        pais = request.form['pais']
        imagen_perfil = request.form['imagen_perfil']
        descripcion = request.form['descripcion']
        tarjeta_credito = request.form['tarjeta_credito']


        # Validación básica
        if not all([nombre, contraseña, correo, pais]):
            return render_template('index.html', error_message="Los campos obligatorios no pueden estar vacíos.")
        
        
        # Conectar a la base de datos
        conn = get_db_connection()


        try:
            # Insertar datos
            cur = conn.cursor()

            # Insertar en JUGADOR
            cur.execute('''
                INSERT INTO JUGADOR (Nombre, Contraseña, Correo, Pais, Imagen_perfil, Descripcion, Tarjeta_credito)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            ''', (nombre, contraseña, correo, pais, imagen_perfil, descripcion, tarjeta_credito))
            conn.commit()

            # Recuperar el Id_jugador
            cur.execute('''
                SELECT Id_jugador FROM JUGADOR
                WHERE Tarjeta_credito = %s
            ''', (tarjeta_credito,))
            id_ = cur.fetchone()

            if id_:
                # Extraer el Id_jugador de la tupla
                id_jugador = id_[0]

                # Insertar en BIBLIOTECA
                cur.execute('''
                    INSERT INTO BIBLIOTECA (Id_jugador, Numero_juegos, Espacio_usado)
                    VALUES (%s, %s, %s)
                ''', (id_jugador, 0, 0.0))  # Inicia con 0 juegos y 0 espacio usado
                conn.commit()


            # Redirigir a página de éxito
            return redirect(url_for('get_jugadores'))
        except psycopg2.Error as e:
            return render_template('index.html', error_message=f"Error en la base de datos: {e}")
    
    # Mostrar formulario
    return render_template('add_jugadores.html')

# Ruta para mostrar y actualizar un jugador
@app.route('/updatejugadores', methods=['GET', 'POST'])
def update_jugador():


    if request.method == 'POST':
        jugador_id = request.form.get('id')

        
        try:
            # Convertir el ID a entero para evitar problemas
            jugador_id = int(jugador_id)


            # Conectar a la base de datos
            conn = get_db_connection()
            if conn is None:
                raise psycopg2.OperationalError("No se pudo establecer la conexión con la base de datos")


            cur = conn.cursor()


            if 'nombre' in request.form:
                # Obtener los datos del formulario para actualizar
                nombre = request.form['nombre']
                contraseña = request.form['contraseña']
                correo = request.form['correo']
                pais = request.form['pais']
                imagen_perfil = request.form.get('imagen_perfil', None)
                descripcion = request.form.get('descripcion', None)
                tarjeta_credito = request.form.get('tarjeta_credito', None)


                try:
                    # Actualizar el registro en la base de datos
                    cur.execute('''
                        UPDATE JUGADOR
                        SET Nombre = %s,
                            Contraseña = %s,
                            Correo = %s,
                            Pais = %s,
                            Imagen_perfil = %s,
                            Descripcion = %s,
                            Tarjeta_credito = %s
                        WHERE Id_jugador = %s;
                    ''', (nombre, contraseña, correo, pais, imagen_perfil, descripcion, tarjeta_credito, jugador_id))
                    
                    # Confirmar cambios
                    conn.commit()
                    cur.close()
                    conn.close()
                    print(f"Jugador con ID {jugador_id} actualizado exitosamente.")


                    return redirect(url_for('get_jugadores'))


                except psycopg2.Error as e:
                    conn.rollback()
                    return render_template('index.html', error_message=f"Error al actualizar el jugador: {e}")


            else:
                # Obtener los detalles del jugador para pre-rellenar el formulario
                cur.execute('SELECT * FROM JUGADOR WHERE Id_jugador = %s;', (jugador_id,))
                jugador = cur.fetchone()


                if not jugador:
                    return render_template('index.html', error_message=f"No se encontró el jugador con ID {jugador_id}")


                cur.close()
                conn.close()
                return render_template('update_jugadores.html', jugador=jugador)


        except ValueError:
            return render_template('index.html', error_message="ID inválido. Introduce un número válido.")


    # Renderizar el formulario inicial para pedir el ID
    return render_template('update_jugadores.html', jugador=None)

@app.route('/deletejugadores', methods=('GET', 'POST'))
def delete_jugadores():
    if request.method == 'POST':
        jugador_id = request.form['id']  # Obtener el ID del formulario
        try:
            # Conectar a la base de datos
            conn = get_db_connection()
            if conn is None:
                raise psycopg2.OperationalError("No se pudo establecer la conexión con la base de datos")
            cur = conn.cursor()
            try:
                # Eliminar el jugador con el ID proporcionado
                cur.execute('DELETE FROM JUGADOR WHERE Id_jugador = %s;', (int(jugador_id),))
                
                # Confirmar los cambios en la base de datos
                conn.commit()
                print(f"Jugador con ID {jugador_id} eliminado exitosamente.")
            except psycopg2.Error as e:
                # Capturar errores durante el borrado
                if conn:
                    conn.rollback()
                print(f"Error al eliminar el jugador: {e}")
                return render_template('index.html', error_message="Error al eliminar el jugador.")
            finally:
                # Cerrar cursor
                cur.close()
        except psycopg2.OperationalError as e:
            print(f"Error al conectarse a la base de datos: {e}")
            return render_template('index.html', error_message="No se pudo conectar a la base de datos.")
        finally:
            # Cerrar conexión
            if 'conn' in locals() and conn is not None:
                conn.close()
        # Redireccionar a la página principal después de eliminar el registro
        return redirect(url_for('get_jugadores'))
    return render_template('delete_jugadores.html')




@app.route('/deletedesarrolladores', methods=('GET', 'POST'))
def delete_desarrolladores():
    if request.method == 'POST':
        desarrollador_id = request.form['id']  # Obtener el ID del formulario


        try:
            # Conectar a la base de datos
            conn = get_db_connection()
            if conn is None:
                raise psycopg2.OperationalError("No se pudo establecer la conexión con la base de datos")


            cur = conn.cursor()
            try:
                # Eliminar el desarrollador con el ID proporcionado
                cur.execute('DELETE FROM DESARROLLADOR WHERE Id_desarrollador = %s;', (int(desarrollador_id),))


                # Confirmar los cambios en la base de datos
                conn.commit()
                print(f"Desarrollador con ID {desarrollador_id} eliminado exitosamente.")


            except psycopg2.Error as e:
                # Capturar errores durante el borrado
                if conn:
                    conn.rollback()
                print(f"Error al eliminar el desarrollador: {e}")
                return render_template('index.html', error_message="Error al eliminar el desarrollador.")


            finally:
                # Cerrar cursor
                cur.close()


        except psycopg2.OperationalError as e:
            print(f"Error al conectarse a la base de datos: {e}")
            return render_template('index.html', error_message="No se pudo conectar a la base de datos.")


        finally:
            # Cerrar conexión
            if 'conn' in locals() and conn is not None:
                conn.close()


        # Redireccionar a la página principal después de eliminar el registro
        return redirect(url_for('get_desarrolladores'))


    return render_template('delete_desarrolladores.html')







@app.route('/desarrollador', methods=["GET"])
def get_desarrolladores():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM DESARROLLADOR;')
    desarrolladores = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_desarrollador.html', desarrolladores=desarrolladores )   


@app.route('/adddesarrollador', methods=['GET', 'POST'])
def add_desarrollador():
    if request.method == 'POST':
        try:
            # Obtener datos del formulario
            contraseña = request.form['contraseña']
            nombre = request.form['nombre']
            imagen_perfil = request.form.get('imagen_perfil', None)
            correo = request.form['correo']
            pais = request.form['pais']
            descripcion = request.form.get('descripcion', None)
            numero_empleados = int(request.form['numero_empleados'])
            presentacion = request.form.get('presentacion', None)
            pagina_web = request.form.get('pagina_web', None)


            # Conexión a la base de datos
            conn = get_db_connection()
            cur = conn.cursor()


            # Insertar datos en la tabla
            cur.execute('''
                INSERT INTO DESARROLLADOR (Contraseña, Nombre, Imagen_perfil, Correo, Pais, Descripcion, 
                                           Numero_empleados, Presentacion, Pagina_web)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ''', (contraseña, nombre, imagen_perfil, correo, pais, descripcion, numero_empleados, presentacion, pagina_web))


            conn.commit()
            cur.close()
            conn.close()


            return redirect(url_for('get_desarrolladores'))


        except Exception as e:
            return render_template('index.html', error_message="Error a la hora de añadir.")
    
    return render_template('add_desarrollador.html')



@app.route('/updatedesarrollador/', methods=['GET', 'POST'])
def update_desarrollador():
    
    if request.method == 'POST':
        desarrollador_id = request.form.get('id')


        try:
            # Convertir el ID a entero para evitar problemas
            desarrollador_id = int(desarrollador_id)


            # Conectar a la base de datos
            conn = get_db_connection()
            if conn is None:
                raise psycopg2.OperationalError("No se pudo establecer la conexión con la base de datos")


            cur = conn.cursor()


            if 'nombre' in request.form:
                # Obtener los datos del formulario para actualizar
                contraseña = request.form['contraseña']
                nombre = request.form['nombre']
                imagen_perfil = request.form.get('imagen_perfil', None)
                correo = request.form['correo']
                pais = request.form['pais']
                descripcion = request.form.get('descripcion', None)
                numero_empleados = request.form.get('numero_empleados', None)
                presentacion = request.form.get('presentacion', None)
                pagina_web = request.form.get('pagina_web', None)


                try:
                    # Actualizar el registro en la base de datos
                    cur.execute('''
                        UPDATE DESARROLLADOR
                        SET Contraseña = %s,
                            Nombre = %s,
                            Imagen_perfil = %s,
                            Correo = %s,
                            Pais = %s,
                            Descripcion = %s,
                            Numero_empleados = %s,
                            Presentacion = %s,
                            Pagina_web = %s
                        WHERE Id_desarrollador = %s;
                    ''', (contraseña, nombre, imagen_perfil, correo, pais, descripcion, numero_empleados, presentacion, pagina_web, desarrollador_id))
                    
                    # Confirmar cambios
                    conn.commit()
                    cur.close()
                    conn.close()
                    print(f"Desarrollador con ID {desarrollador_id} actualizado exitosamente.")


                    return redirect(url_for('get_desarrolladores'))


                except psycopg2.Error as e:
                    conn.rollback()
                    return render_template('index.html', error_message=f"Error al actualizar el desarrollador: {e}")


            else:
                # Obtener los detalles del desarrollador para pre-rellenar el formulario
                cur.execute('SELECT * FROM DESARROLLADOR WHERE Id_desarrollador = %s;', (desarrollador_id,))
                desarrollador = cur.fetchone()


                if not desarrollador:
                    return render_template('index.html', error_message=f"No se encontró el desarrollador con ID {desarrollador_id}")


                cur.close()
                conn.close()
                return render_template('editar_desarrollador.html', desarrollador=desarrollador)


        except ValueError:
            return render_template('index.html', error_message="ID inválido. Introduce un número válido.")


    # Renderizar el formulario inicial para pedir el ID
    return render_template('editar_desarrollador.html', desarrollador=None)






@app.route('/videojuegos', methods=["GET"])
def get_videojuegos():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM VIDEOJUEGOS;')
    videojuegos = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_videojuegos.html', videojuegos=videojuegos ) 



@app.route('/addvideojuegos', methods=['GET', 'POST'])
def add_videojuego():
    if request.method == 'POST':
        # Obtener los datos del formulario
        nombre = request.form['nombre']
        fecha = request.form['fecha']
        descripcion = request.form.get('descripcion', None)
        precio = request.form['precio']
        duracion_oferta = request.form.get('duracion_oferta', None)
        descuento_oferta = request.form.get('descuento_oferta', None)
        tamaño = request.form['tamaño']
        id_desarrollador = request.form['id_desarrollador']
        id_distribuidor = request.form['id_distribuidor']


        try:
            conn = get_db_connection()
            cur = conn.cursor()


            # Insertar el videojuego en la tabla VIDEOJUEGOS
            cur.execute('''
                INSERT INTO VIDEOJUEGOS (Nombre, Fecha, Descripcion, Precio, Duracion_oferta, Descuento_oferta, Tamaño)
                VALUES (%s, %s, %s, %s, %s, %s, %s) RETURNING Id_videojuego
            ''', (nombre, fecha, descripcion, precio, duracion_oferta, descuento_oferta, tamaño))
            
            id_videojuego = cur.fetchone()[0]  # Obtener el ID del videojuego recién insertado


            # Insertar la relación en la tabla VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
            cur.execute('''
                INSERT INTO VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR (Id_desarrollador, Id_distribuidor, Id_videojuego)
                VALUES (%s, %s, %s)
            ''', (id_desarrollador, id_distribuidor, id_videojuego))
            
            # Confirmar cambios
            conn.commit()
            cur.close()
            conn.close()


        
            return redirect(url_for('get_videojuegos'))


        except Exception as e:
            if conn:
                conn.rollback()
            return render_template('index.html', error_message=f"Error al añadir el videojuego: {str(e)}")
        finally:
            if 'cur' in locals():
                cur.close()
            if 'conn' in locals() and conn:
                conn.close()


    return render_template('add_videojuego.html')



@app.route('/updatevideojuegos', methods=['GET', 'POST'])
def update_videojuego():
    if request.method == 'POST':
        # Obtener el ID del videojuego desde el formulario
        id_videojuego = request.form.get('id_videojuego')


        try:
            # Convertir el ID a entero para evitar problemas
            id_videojuego = int(id_videojuego)


            # Conectar a la base de datos
            conn = get_db_connection()
            cur = conn.cursor()


            if 'nombre' in request.form:
                # Obtener los datos del formulario para actualizar
                nombre = request.form['nombre']
                fecha = request.form['fecha']
                descripcion = request.form.get('descripcion', None)
                precio = request.form['precio']
                duracion_oferta = request.form.get('duracion_oferta', None)
                descuento_oferta = request.form.get('descuento_oferta', None)
                tamaño = request.form['tamaño']
                id_desarrollador = request.form['id_desarrollador']
                id_distribuidor = request.form['id_distribuidor']


                try:
                    # Actualizar los datos del videojuego
                    cur.execute('''
                        UPDATE VIDEOJUEGOS
                        SET Nombre = %s,
                            Fecha = %s,
                            Descripcion = %s,
                            Precio = %s,
                            Duracion_oferta = %s,
                            Descuento_oferta = %s,
                            Tamaño = %s
                        WHERE Id_videojuego = %s
                    ''', (nombre, fecha, descripcion, precio, duracion_oferta, descuento_oferta, tamaño, id_videojuego))


                    # Actualizar la relación en VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
                    cur.execute('''
                        UPDATE VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
                        SET Id_desarrollador = %s,
                            Id_distribuidor = %s
                        WHERE Id_videojuego = %s
                    ''', (id_desarrollador, id_distribuidor, id_videojuego))


                    conn.commit()
                    return redirect(url_for('get_videojuegos'))


                except psycopg2.Error as e:
                    conn.rollback()


            # Cargar los datos actuales del videojuego si no hay `POST`
            cur.execute('SELECT * FROM VIDEOJUEGOS WHERE Id_videojuego = %s', (id_videojuego,))
            videojuego = cur.fetchone()


            cur.execute('''
                SELECT Id_desarrollador, Id_distribuidor
                FROM VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
                WHERE Id_videojuego = %s
            ''', (id_videojuego,))
            relacion = cur.fetchone()


            cur.close()
            conn.close()


            return render_template('editar_videojuego.html', videojuego=videojuego, relacion=relacion)


        except ValueError:
            return render_template('editar_videojuego.html', videojuego=None, relacion=None)


        except Exception as e:
            return render_template('index.html', error_message=f"Error al añadir el videojuego: {str(e)}")


    # Renderizar formulario inicial para buscar el videojuego
    return render_template('editar_videojuego.html', videojuego=None, relacion=None)



@app.route('/deletevideojuegos', methods=['GET', 'POST'])
def delete_videojuego():
    if request.method == 'POST':
        # Obtener el ID del videojuego desde el formulario
        id_videojuego = request.form.get('id_videojuego')


        try:
            # Convertir el ID a entero para evitar problemas
            id_videojuego = int(id_videojuego)


            # Conectar a la base de datos
            conn = get_db_connection()
            cur = conn.cursor()


            try:
                # Eliminar la relación en VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
                cur.execute('''
                    DELETE FROM VIDEOJUEGO_DESARROLLADOR_DISTRIBUIDOR
                    WHERE Id_videojuego = %s
                ''', (id_videojuego,))


                # Eliminar el videojuego en VIDEOJUEGOS
                cur.execute('''
                    DELETE FROM VIDEOJUEGOS
                    WHERE Id_videojuego = %s
                ''', (id_videojuego,))


                # Confirmar cambios
                conn.commit()
                return redirect(url_for('get_videojuegos'))


            except psycopg2.Error as e:
                conn.rollback()
                return render_template('index.html', error_message=f"Error al añadir el videojuego: {str(e)}")


            finally:
                cur.close()
                conn.close()


        except ValueError:
            return render_template('index.html', error_message=f"Error al añadir el videojuego: {str(e)}")
        except Exception as e:
            return render_template('index.html', error_message=f"Error al añadir el videojuego: {str(e)}")


    # Renderizar el formulario inicial para eliminar el videojuego
    return render_template('delete_videojuego.html')






@app.route('/generos', methods=["GET"])
def get_generos():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM GENEROS')
    generos = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_generos.html', generos=generos )       

@app.route('/logros',methods=["GET"])
def get_logros():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM LOGROS')
    logros = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_logros.html', logros=logros)

@app.route('/addlogros', methods=['GET', 'POST'])
def add_logro():
    if request.method == 'POST':
        # Obtener los datos del formulario
        nombre = request.form['nombre']
        descripcion = request.form.get('descripcion', None)
        requisito = request.form.get('requisito', None)


        try:
            # Conectar a la base de datos
            conn = get_db_connection()
            cur = conn.cursor()


            # Insertar el logro en la base de datos
            cur.execute('''
                INSERT INTO LOGROS (Nombre, Descripcion, Requisito)
                VALUES (%s, %s, %s)
            ''', (nombre, descripcion, requisito))


            # Confirmar cambios
            conn.commit()
            return redirect(url_for('get_logros'))


        except psycopg2.Error as e:
            conn.rollback()


        finally:
            cur.close()
            conn.close()


    # Renderizar el formulario inicial
    return render_template('add_logro.html')



@app.route('/deletelogros', methods=['GET', 'POST'])
def delete_logro():
    if request.method == 'POST':
        # Obtener el ID del logro desde el formulario
        id_logro = request.form.get('id_logro')


        try:
            # Validar que el ID sea un número entero válido
            id_logro = int(id_logro)


            # Conectar a la base de datos
            conn = get_db_connection()
            cur = conn.cursor()


            try:
                # Eliminar el logro de la base de datos
                cur.execute('''
                    DELETE FROM LOGROS
                    WHERE Id_logro = %s
                ''', (id_logro,))


                # Confirmar cambios
                conn.commit()
                return redirect(url_for('get_logros'))


            except psycopg2.Error as e:
                conn.rollback()


            finally:
                cur.close()
                conn.close()


        except ValueError:
            return render_template('index.html', error_message=f"Error al borrar el logros: {str(e)}")
        except Exception as e:
            return render_template('index.html', error_message=f"Error al borrar el logros: {str(e)}")


    # Renderizar el formulario inicial
    return render_template('delete_logro.html')









@app.route('/comentarios',methods=["GET"])
def get_comentarios():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM COMENTARIOS')
    comentarios = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_comentarios.html', comentarios=comentarios)

@app.route('/dlc', methods=["GET"])
def get_dlc():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM DLC')
    dlc = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_dlc.html', dlc=dlc)

@app.route('/bibliotecas', methods=["GET"])
def get_bibliotecas():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM BIBLIOTECA')
    bibliotecas = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_bilbiotecas.html', bibliotecas=bibliotecas)

@app.route('/addtobiblioteca', methods=['GET', 'POST'])
def add_to_biblioteca():
    if request.method == 'POST':
        # Obtener los datos del formulario
        id_biblioteca = request.form['id_biblioteca']
        id_videojuego = request.form['id_videojuego']
        activo = request.form['activo'] == 'true'  # Convertir el valor a booleano
        tiempo = request.form.get('tiempo', None)
        fecha = request.form['fecha']
        fecha_guardado = request.form['fecha_guardado']


        try:
            # Conectar a la base de datos
            conn = get_db_connection()
            cur = conn.cursor()


            # Insertar el videojuego en la biblioteca
            cur.execute('''
                INSERT INTO BIBLIOTECA_VIDEOJUEGO (Id_videojuego, Id_biblioteca, Activo, Tiempo, Fecha, Fecha_guardado)
                VALUES (%s, %s, %s, %s, %s, %s)
            ''', (id_videojuego, id_biblioteca, activo, tiempo, fecha, fecha_guardado))


            # Actualizar el número de juegos en la biblioteca
            cur.execute('''
                UPDATE BIBLIOTECA
                SET Numero_juegos = Numero_juegos + 1
                WHERE Id_biblioteca = %s
            ''', (id_biblioteca,))


            # Confirmar cambios
            conn.commit()
            return redirect(url_for('get_bibliotecas'))


        except psycopg2.Error as e:
            conn.rollback()
            return render_template('index.html', error_message=f"Error al añadir el videojuego: {str(e)}")


        finally:
            cur.close()
            conn.close()


    # Renderizar el formulario inicial
    return render_template('add_to_biblioteca.html')




@app.route('/distribuidores', methods=["GET"])
def get_distribuidores():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM DISTRIBUIDOR ')
    distribuidores = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_distribuidores.html', distribuidores=distribuidores)



@app.route('/adddistribuidores', methods=['GET', 'POST'])
def add_distribuidor():
    if request.method == 'POST':
        nombre = request.form['nombre']
        numero_empleado = request.form['numero_empleado']
        pagina_web = request.form.get('pagina_web', None) or None
        presentacion = request.form.get('presentacion', None) or None


        if not nombre or not numero_empleado.isdigit() or int(numero_empleado) < 0:
            return render_template('index.html', error_message="Datos inválidos. Verifica los campos.")


        try:
            conn = get_db_connection()
            cur = conn.cursor()
            cur.execute('''
                INSERT INTO DISTRIBUIDOR (Nombre, Numero_Empleado, Pagina_web, Presentacion)
                VALUES (%s, %s, %s, %s)
            ''', (nombre, numero_empleado, pagina_web, presentacion))
            conn.commit()
        except Exception as e:
            if conn:
                conn.rollback()
            return render_template('index.html', error_message=f"Error al añadir distribuidor: {str(e)}")
        finally:
            if cur:
                cur.close()
            if conn:
                conn.close()


        return redirect(url_for('get_distribuidores'))


    return render_template('add_distribuidor.html')


@app.route('/updatedistribuidor/', methods=['GET', 'POST'])
def update_distribuidor():
    if request.method == 'POST':
        distribuidor_id = request.form.get('id')


        try:
            # Convertir el ID a entero para evitar problemas
            distribuidor_id = int(distribuidor_id)


            # Conectar a la base de datos
            conn = get_db_connection()
            if conn is None:
                raise psycopg2.OperationalError("No se pudo establecer la conexión con la base de datos")


            cur = conn.cursor()


            if 'nombre' in request.form:
                # Obtener los datos del formulario para actualizar
                nombre = request.form['nombre']
                numero_empleados = request.form.get('numero_empleados', None)
                pagina_web = request.form.get('pagina_web', None)
                presentacion = request.form.get('presentacion', None)


                try:
                    # Actualizar el registro en la base de datos
                    cur.execute('''
                        UPDATE DISTRIBUIDOR
                        SET Nombre = %s,
                            Numero_Empleado = %s,
                            Pagina_web = %s,
                            Presentacion = %s
                        WHERE Id_distribuidor = %s;
                    ''', (nombre, numero_empleados, pagina_web, presentacion, distribuidor_id))


                    # Confirmar cambios
                    conn.commit()
                    cur.close()
                    conn.close()
                    print(f"Distribuidor con ID {distribuidor_id} actualizado exitosamente.")


                    return redirect(url_for('get_distribuidores'))


                except psycopg2.Error as e:
                    conn.rollback()
                    return render_template('index.html', error_message=f"Error al actualizar el distribuidor: {e}")


            else:
                # Obtener los detalles del distribuidor para pre-rellenar el formulario
                cur.execute('SELECT * FROM DISTRIBUIDOR WHERE Id_distribuidor = %s;', (distribuidor_id,))
                distribuidor = cur.fetchone()


                if not distribuidor:
                    return render_template('index.html', error_message=f"No se encontró el distribuidor con ID {distribuidor_id}")


                cur.close()
                conn.close()
                return render_template('update_distribuidor.html', distribuidor=distribuidor)


        except ValueError:
            return render_template('index.html', error_message="ID inválido. Introduce un número válido.")


    # Renderizar el formulario inicial para pedir el ID
    return render_template('update_distribuidor.html', distribuidor=None)



@app.route('/deletedistribuidores', methods=('GET', 'POST'))
def delete_distribuidores():
    if request.method == 'POST':
        distribuidor_id = request.form['id']  # Obtener el ID del formulario


        try:
            # Conectar a la base de datos
            conn = get_db_connection()
            if conn is None:
                raise psycopg2.OperationalError("No se pudo establecer la conexión con la base de datos")


            cur = conn.cursor()
            try:
                # Eliminar el distribuidor con el ID proporcionado
                cur.execute('DELETE FROM DISTRIBUIDOR WHERE Id_distribuidor = %s;', (int(distribuidor_id),))


                # Confirmar los cambios en la base de datos
                conn.commit()
                print(f"Distribuidor con ID {distribuidor_id} eliminado exitosamente.")


            except psycopg2.Error as e:
                # Capturar errores durante el borrado
                if conn:
                    conn.rollback()
                print(f"Error al eliminar el distribuidor: {e}")
                return render_template('index.html', error_message="Error al eliminar el distribuidor.")


            finally:
                # Cerrar cursor
                cur.close()


        except psycopg2.OperationalError as e:
            print(f"Error al conectarse a la base de datos: {e}")
            return render_template('index.html', error_message="No se pudo conectar a la base de datos.")


        finally:
            # Cerrar conexión
            if 'conn' in locals() and conn is not None:
                conn.close()


        # Redireccionar a la página principal después de eliminar el registro
        return redirect(url_for('get_distribuidores'))


    return render_template('delete_distribuidores.html')


















if __name__ == '__main__':
    app.run(debug=True)
