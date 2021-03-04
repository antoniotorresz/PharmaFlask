from flask import Flask, render_template, url_for, request, redirect, flash
import psycopg2
import os
from os.path import join, dirname, realpath

UPLOAD_FOLDER = join(dirname(realpath(__file__)), 'static/product_images')

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/Productos')
def index_productos():
    return render_template('Productos/index_productos.html', productos=db_consulta("SELECT * FROM listar_productos_inicio"))


@app.route('/Productos/Save', methods=["GET", "POST"])
def producto_guardar():
    if request.method == "GET":
        return render_template('Productos/agregar_producto.html',
                               proveedores=db_consulta("select id_proveedor, nombre from farmacia.proveedor"),
                               indicaciones=db_consulta("select id_indicacion, nombre from farmacia.indicacion"))
    if request.method == "POST":
        nombre = request.form['nombre']
        desc = request.form['descripcion']
        p_compra = request.form['precio_compra']
        p_venta = request.form['precio_venta']
        proveedor_id = request.form['proveedor']
        sustancias = str(request.form['sustancia']).split(',')
        indicaciones = request.form.getlist('indicaciones')

        imagen = request.files['imagen']
        filename = 'no_image.png'

        if imagen:
            filename = nombre + '.png'
            basedir = os.path.abspath(os.path.dirname(__file__))
            imagen.save(os.path.join(basedir, app.config['UPLOAD_FOLDER'], filename))

        pg_sustancias_array = str(sustancias).replace('[', '{').replace(']', '}').replace('\"', "").replace("\'", "")
        pg_indicaciones_array = str(indicaciones).replace('[', '{').replace(']', '}').replace('\"', "").replace("\'", "")

        query = "call insert_producto(CAST('{}' AS TEXT), " \
                "CAST('{}' AS TEXT), " \
                "CAST({} AS MONEY), " \
                "CAST({} AS MONEY), " \
                "CAST('{}' AS TEXT), " \
                "CAST({} AS INTEGER), " \
                "'{}', " \
                "CAST('{}' AS TEXT[]));".format(nombre, desc, p_compra, p_venta, filename, int(proveedor_id), pg_indicaciones_array, pg_sustancias_array)
        db_modificacion(query)
        return redirect(url_for('index_productos'))


@app.route('/Productos/Edit/<int:id>', methods=["GET", "POST"])
def producto_update(id):
    if request.method == "GET":
        prod = db_consulta("SELECT * FROM listar_productos_inicio WHERE id_producto = {} ".format(id))[0]
        sustancias = str(prod[5]).replace("[", "").replace("]", "").replace("\'", "")
        proveedores = db_consulta("select id_proveedor, nombre from farmacia.proveedor")
        indicaciones = db_consulta("select id_indicacion, nombre from farmacia.indicacion")

        return render_template('Productos/editar_producto.html',
                               producto = prod, sustancias = sustancias, proveedores=proveedores,
                               indicaciones=indicaciones)

    if request.method == "POST":
        nombre = request.form['nombre']
        desc = request.form['descripcion']
        p_compra = request.form['precio_compra']
        p_venta = request.form['precio_venta']
        proveedor_id = request.form['proveedor']
        sustancias = str(request.form['sustancia']).split(',')
        indicaciones = request.form.getlist('indicaciones')

        filename = request.form['filename']

        pg_sustancias_array = str(sustancias).replace('[', '{').replace(']', '}').replace('\"', "").replace("\'", "")
        pg_indicaciones_array = str(indicaciones).replace('[', '{').replace(']', '}').replace('\"', "").replace("\'", "")

        print(pg_indicaciones_array)
        query = "call update_producto(" \
                "CAST({} AS INTEGER)," \
                "CAST('{}' AS TEXT), " \
                "CAST('{}' AS TEXT), " \
                "CAST({} AS MONEY), " \
                "CAST({} AS MONEY), " \
                "CAST('{}' AS TEXT), " \
                "CAST({} AS INTEGER), " \
                "'{}', " \
                "CAST('{}' AS TEXT[]));".format(id, nombre, desc, p_compra, p_venta, filename, int(proveedor_id), pg_indicaciones_array, pg_sustancias_array)
        print(query)
        db_modificacion(query)
        return redirect(url_for('index_productos'))

@app.route('/Productos/Remove/<int:id>')
def producto_remove(id):
    if id:
        #removiendo registro de la base de datos
        db_modificacion("CALL delete_producto(CAST({} AS INTEGER))".format(id))
        #eliminando foto del servidor, si es que existe
        try:
            prod = db_consulta("SELECT * FROM listar_productos_inicio WHERE id_producto = {} ".format(id))[0]
            basedir = os.path.abspath(os.path.dirname(__file__))
            product_image = os.path.join(basedir, app.config['UPLOAD_FOLDER'], prod[4])
            print(product_image)
            os.remove(product_image)
        except Exception as e:
            print("Error eliminando la imagen, probablemente no esté el recurso disponible -> {}".format(e))
        return redirect(url_for('index_productos'))

@app.route('/Proveedor/Save', methods=["POST", "GET"])
def proveedor_guardar():
    if request.method == "POST":
        nombre = request.form['nombre']
        rfc = request.form['rfc']
        direccion = request.form['direccion']
        telefono = request.form['telefono']

        query = "INSERT INTO farmacia.proveedor(nombre, rfc, direccion, telefono) VALUES ('{}', '{}', '{}', '{}')" \
            .format(nombre, rfc, direccion, telefono)
        print(query)
        db_modificacion(query)
        return redirect(url_for('index_proveedores'))
    if request.method == "GET":
        return render_template('Proveedores/agregar_proveedor.html')


@app.route('/Proveedores/Edit/<int:id>', methods=['GET', 'POST'])
def proveedor_editar(id):
    if request.method == "GET":
        proveedor = db_consulta("SELECT * FROM farmacia.proveedor WHERE id_proveedor = {}".format(id))
        return render_template('Proveedores/editar_proveedor.html', p=proveedor[0])
    if request.method == "POST":
        nombre = request.form['nombre']
        rfc = request.form['rfc']
        direccion = request.form['direccion']
        telefono = request.form['telefono']

        query = "UPDATE farmacia.proveedor SET nombre = '{}', rfc = '{}', direccion = '{}', telefono = '{}' WHERE id_proveedor = {}" \
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
    return render_template('Indicaciones/index_indicaciones.html',
                           indicaciones=db_consulta("SELECT * FROM farmacia.indicacion order by id_indicacion desc "))


@app.route('/Indicaciones/Save', methods=["GET", "POST"])
def indicacion_guardar():
    if request.method == "GET":
        return render_template('Indicaciones/agregar_indicacion.html')
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
        return render_template('Indicaciones/editar_indicacion.html', i=indicacion)
    if request.method == "POST":
        nombre = request.form['nombre']
        desc = request.form['descripcion']
        query = "UPDATE farmacia.indicacion SET nombre = '{}', descripcion = '{}' WHERE id_indicacion = {}".format(
            nombre, desc, id)
        db_modificacion(query)
        return redirect(url_for('index_indicaciones'))


@app.route('/Indicaciones/Delete/<int:id>', methods=["GET"])
def indicacion_eliminar(id):
    if id:
        db_modificacion("DELETE FROM farmacia.indicacion WHERE id_indicacion = {}".format(id))
        return redirect(url_for('index_indicaciones'))


@app.route('/Proveedores')
def index_proveedores():
    return render_template('Proveedores/index_proveedores.html',
                           provedores=db_consulta("SELECT * FROM farmacia.proveedor order by id_proveedor desc"))


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
