![PharmaFlaskCover](https://user-images.githubusercontent.com/43243319/110015281-4d3d0180-7ce9-11eb-9cf8-4599af87cd27.png)


PharmaFlask es un sistema de gestión de productos, especializado en la gestión de productos farmaceúticos. Cuenta con tres módulos completos: Productos, Proveedores y gestión de sintomas. 

La aplicación está desarrollada usando el lenguaje de programación python, con el framework web Flask, usando el SGBD PostgreSQL. 

# Gestión de productos
## Index
![Index productos](https://user-images.githubusercontent.com/43243319/110015453-7d84a000-7ce9-11eb-8d93-49ded7de7999.png)

## Formulario de registro

![Registro productos](https://user-images.githubusercontent.com/43243319/110015761-dce2b000-7ce9-11eb-86e7-a3f1c62c965e.png)

# Requerimientos

- Servidor posgreSQL
- Python version 3.x

# Instalación

## Proyecto
Clone este repositorio con el comando:


```python
git clone https://github.com/antoniotorresz/PharmaFlask.git
```

Cree el entorno virtual para el proyecto con el comando: 


```python
virtualenv venv
```

Active el entorno virtual con el comando: 


```python
source venv/bin/activate
```

Una vez dentro del entorno virtual, agregue las librerias necesarias usando pip, ejecute el siguiente comando: 


```python
pip install -r requirements.txt
```

## Base de datos
Ejecute el archivo *database.sql* en una consola de postgres con herramientas como [PgAdmin](https://www.pgadmin.org/), [Datagrip](https://www.jetbrains.com/es-es/datagrip/) o [Dbeaver](https://dbeaver.io/)

# Iniciar servidor flask
Para iniciar el servidor flask, y a su vez ejecutar la aplicación ejecute el siguente comando en la raíz del proyecto: 


```python
python app.py
```
