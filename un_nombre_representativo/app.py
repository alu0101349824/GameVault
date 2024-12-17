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
            return render_template('error.html', error_message="Los campos obligatorios no pueden estar vacíos.")


        # Conectar a la base de datos
        conn = get_db_connection()


        try:
            # Insertar datos
            cur = conn.cursor()
            cur.execute('''
                INSERT INTO JUGADOR (Nombre, Contraseña, Correo, Pais, Imagen_perfil, Descripcion, Tarjeta_credito)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            ''', (nombre, contraseña, correo, pais, imagen_perfil, descripcion, tarjeta_credito))


            conn.commit()
            cur.close()
            conn.close()


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






@app.route('/desarrollador', methods=["GET"])
def get_desarrolladores():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM DESARROLLADOR;')
    desarrolladores = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_desarrollador.html', desarrolladores=desarrolladores )    


@app.route('/videojuegos', methods=["GET"])
def get_videojuegos():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM VIDEOJUEGOS;')
    videojuegos = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_videojuegos.html', videojuegos=videojuegos ) 

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

@app.route('/distribuidores', methods=["GET"])
def get_distribuidores():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM DISTRIBUIDOR ')
    distribuidores = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('get_distribuidores.html', distribuidores=distribuidores)

    
if __name__ == '__main__':
    app.run(debug=True)
