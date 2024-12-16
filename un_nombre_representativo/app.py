from flask import Flask, render_template 
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
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM JUGADOR ;')
    jugadorres = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', jugadorres=jugadorres )

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
