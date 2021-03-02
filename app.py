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
    return render_template('index_indicaciones.html', indicaciones = db_consulta("SELECT * FROM farmacia.indicacion order by id_indicacion desc "))

@app.route('/Indicaciones/Save', methods=["GET", "POST"])
def indicacion_guardar():
    if request.method == "GET":
        return render_template('agregar_indicacion.html')
    if request.method == "POST":
        nombre = request.form['nombre']
        desc = request.form['descripcion']

        query = "INSERT INTO farmacia.indicacion(nombre, descripcion) VALUES ('{}', '{}')".format(nombre, desc)
        db_modificacion(query)
        return redirect(url_for('index_indicaciones'))

@app.route('/Indicaciones/Edit/<int:id>', methods=["GET", "POST"])
def indicacion_editar(id):
    if request.method == "GET":
        indicacion = db_consulta("SELECT * FROM farmacia.indicacion WHERE id_indicacion = {}".format(id))[0]
        return render_template('editar_indicacion.html', i = indicacion)
    if request.method == "POST":
        nombre = request.form['nombre']
        desc = request.form['descripcion']
        query = "UPDATE farmacia.indicacion SET nombre = '{}', descripcion = '{}' WHERE id_indicacion = {}".format(nombre, desc, id)
        db_modificacion(query)
        return redirect(url_for('index_indicaciones'))

@app.route('/Indicaciones/Delete/<int:id>', methods=["GET"])
def indicacion_eliminar(id):
    if id:
        db_modificacion("DELETE FROM farmacia.indicacion WHERE id_indicacion = {}".format(id))
        return redirect(url_for('index_indicaciones'))

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
        conn.rollback()
    finally:
        conn.close()


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
