from flask import Flask, render_template, url_for, request, redirect
import psycopg2
app = Flask(__name__)

@app.route('/')
def index():
    #Aqui se muestra una tabla con el detalle de productos
    return render_template('index.html')

@app.route('/Productos')
def index_productos():
    return render_template('index_productos.html')

@app.route('/Proveedor/Save', methods=["POST", "GET"])
def proveedor_guardar():
    if request.method == "POST":
        nombre = request.form['nombre']
        rfc = request.form['rfc']
        direccion = request.form['direccion']
        telefono = request.form['telefono']

        query = "INSERT INTO farmacia.proveedor(nombre, rfc, direccion, telefono) VALUES ('{}', '{}', '{}', '{}')"\
            .format(nombre, rfc, direccion, telefono)
        print(query)
        db_modificacion(query)
        return redirect(url_for('index_proveedores'))
    if request.method == "GET":
        return render_template('agregar_proveedor.html')

@app.route('/Proveedores/Edit/<int:id>',methods=['GET', 'POST'])
def proveedor_editar(id):
    if request.method == "GET":
        proveedor = db_consulta("SELECT * FROM farmacia.proveedor WHERE id_proveedor = {}".format(id))
        return render_template('editar_proveedor.html', p = proveedor[0])
    if request.method == "POST":
        nombre = request.form['nombre']
        rfc = request.form['rfc']
        direccion = request.form['direccion']
        telefono = request.form['telefono']

        query = "UPDATE farmacia.proveedor SET nombre = '{}', rfc = '{}', direccion = '{}', telefono = '{}' WHERE id_proveedor = {}"\
            .format(nombre, rfc, direccion, telefono, id)

        db_modificacion(query)
        return redirect(url_for('index_proveedores'))

@app.route('/Proveedor/Delete/<int:id>', methods=["GET"])
def proveedor_eliminar(id):
    if id:
        db_modificacion("DELETE FROM farmacia.proveedor WHERE id_proveedor = {}".format(id))
        return redirect(url_for('index_proveedores'))

@app.route('/Indicaciones')
def index_indicaciones():
    return "index indicaciones"

@app.route('/Proveedores')
def index_proveedores():
    return render_template('index_proveedores.html', provedores = db_consulta("SELECT * FROM farmacia.proveedor order by id_proveedor desc"))



def db_consulta(query):
    conn = psycopg2.connect("dbname='farmacia_flask' user='postgres' host='localhost' password=''")
    try:
        cur = conn.cursor()
        cur.execute(query)
        data = cur.fetchall()
        return data
    except Exception as e:
        print("Error en la consulta -> {}".format(e))
    finally:
        conn.close()


def db_modificacion(query):
    conn = psycopg2.connect("dbname='farmacia_flask' user='postgres' host='localhost' password=''")
    try:
        cur = conn.cursor()
        cur.execute(query)
        conn.commit()
    except Exception as e:
        print("Error modificando regristro -> {}".format(e))
    finally:
        conn.close()


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
