--
-- PostgreSQL database dump
--

-- Dumped from database version 13.2
-- Dumped by pg_dump version 13.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: farmacia_flask; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE farmacia_flask WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';


ALTER DATABASE farmacia_flask OWNER TO postgres;

\connect farmacia_flask

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: farmacia; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA farmacia;


ALTER SCHEMA farmacia OWNER TO postgres;

--
-- Name: delete_producto(integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.delete_producto(_id_producto integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    --ELIMINAMOS LOS REGISTROS EN LA TABLA INTERMEDIA
    DELETE FROM farmacia.producto_indicaciones WHERE id_producto = _id_producto;
    DELETE FROM farmacia.producto WHERE id_producto = _id_producto;
END;
$$;


ALTER PROCEDURE public.delete_producto(_id_producto integer) OWNER TO postgres;

--
-- Name: insert_producto(text, text, money, money, text, integer, integer[], text[]); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.insert_producto(_nombre text, _descripcion text, _precio_compra money, _precio_venta money, _imagen text, _id_proveedor integer, _indicaciones integer[], _sustancias text[])
    LANGUAGE plpgsql
    AS $$
DECLARE
    last_product_id int;
BEGIN
    INSERT INTO farmacia.producto(nombre, descripcion, precio_compra, precio_venta, imagen, id_proveedor, sustancias)
    VALUES (_nombre, _descripcion, _precio_compra, _precio_venta, _imagen, _id_proveedor, _sustancias)
    RETURNING id_producto INTO last_product_id;

    FOR i IN 1 .. array_upper(_indicaciones, 1)
        LOOP
            INSERT INTO farmacia.producto_indicaciones (id_producto, id_indicaciones)
            VALUES (last_product_id, CAST(_indicaciones[i] AS INTEGER));
        END LOOP;
END;
$$;


ALTER PROCEDURE public.insert_producto(_nombre text, _descripcion text, _precio_compra money, _precio_venta money, _imagen text, _id_proveedor integer, _indicaciones integer[], _sustancias text[]) OWNER TO postgres;

--
-- Name: update_producto(integer, text, text, money, money, text, integer, integer[], text[]); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_producto(_id_producto integer, _nombre text, _descripcion text, _precio_compra money, _precio_venta money, _imagen text, _id_proveedor integer, _indicaciones integer[], _sustancias text[])
    LANGUAGE plpgsql
    AS $$
BEGIN
    --Hacemos el update de producto
    UPDATE farmacia.producto
    SET nombre        = _nombre,
        descripcion   = _descripcion,
        precio_compra = _precio_compra,
        precio_venta  = _precio_venta,
        imagen        = _imagen,
        id_proveedor  = _id_proveedor,
        sustancias    = _sustancias
    WHERE id_producto = _id_producto;

    --Eliminamos registros existentes de indicaciones del producto en la tabla producto indicaciones
    DELETE FROM farmacia.producto_indicaciones WHERE id_producto = _id_producto;

    --volvemos a insertar en la tabla intermedia

    FOR j in 1 .. array_upper(_indicaciones, 1)
        LOOP
            INSERT INTO farmacia.producto_indicaciones(id_producto, id_indicaciones)
            VALUES (_id_producto, CAST(_indicaciones[j] AS INTEGER));
        END LOOP;
END
$$;


ALTER PROCEDURE public.update_producto(_id_producto integer, _nombre text, _descripcion text, _precio_compra money, _precio_venta money, _imagen text, _id_proveedor integer, _indicaciones integer[], _sustancias text[]) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: indicacion; Type: TABLE; Schema: farmacia; Owner: postgres
--

CREATE TABLE farmacia.indicacion (
    id_indicacion integer NOT NULL,
    nombre character varying(20) NOT NULL,
    descripcion character varying(255)
);


ALTER TABLE farmacia.indicacion OWNER TO postgres;

--
-- Name: TABLE indicacion; Type: COMMENT; Schema: farmacia; Owner: postgres
--

COMMENT ON TABLE farmacia.indicacion IS 'Aqui podemos guardar registros de la utilidad de un medicamento, ejemplo: tos, gripe, gastritis, diarrera etc';


--
-- Name: indicacion_id_indicacion_seq; Type: SEQUENCE; Schema: farmacia; Owner: postgres
--

CREATE SEQUENCE farmacia.indicacion_id_indicacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE farmacia.indicacion_id_indicacion_seq OWNER TO postgres;

--
-- Name: indicacion_id_indicacion_seq; Type: SEQUENCE OWNED BY; Schema: farmacia; Owner: postgres
--

ALTER SEQUENCE farmacia.indicacion_id_indicacion_seq OWNED BY farmacia.indicacion.id_indicacion;


--
-- Name: producto; Type: TABLE; Schema: farmacia; Owner: postgres
--

CREATE TABLE farmacia.producto (
    id_producto integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text NOT NULL,
    precio_compra money NOT NULL,
    precio_venta money NOT NULL,
    imagen text,
    id_proveedor integer NOT NULL,
    sustancias text[] DEFAULT '{}'::text[]
);


ALTER TABLE farmacia.producto OWNER TO postgres;

--
-- Name: producto_indicaciones; Type: TABLE; Schema: farmacia; Owner: postgres
--

CREATE TABLE farmacia.producto_indicaciones (
    id_producto integer NOT NULL,
    id_indicaciones integer
);


ALTER TABLE farmacia.producto_indicaciones OWNER TO postgres;

--
-- Name: TABLE producto_indicaciones; Type: COMMENT; Schema: farmacia; Owner: postgres
--

COMMENT ON TABLE farmacia.producto_indicaciones IS 'relacion N:N entre producto e indicaciones';


--
-- Name: proveedor; Type: TABLE; Schema: farmacia; Owner: postgres
--

CREATE TABLE farmacia.proveedor (
    id_proveedor integer NOT NULL,
    nombre character varying(50) NOT NULL,
    rfc character varying(15) DEFAULT 'N/A'::character varying,
    direccion character varying(100),
    telefono character varying(15)
);


ALTER TABLE farmacia.proveedor OWNER TO postgres;

--
-- Name: TABLE proveedor; Type: COMMENT; Schema: farmacia; Owner: postgres
--

COMMENT ON TABLE farmacia.proveedor IS 'guardamos informacion de la fisica o moral que provee el medicamento';


--
-- Name: listar_productos; Type: VIEW; Schema: farmacia; Owner: postgres
--

CREATE VIEW farmacia.listar_productos AS
 SELECT p.nombre,
    p.descripcion,
    p.precio_venta,
    p.imagen,
    p.sustancias,
    pr.nombre AS nombreproveedor,
    array_agg(i.nombre) AS indicaciones
   FROM (((farmacia.producto p
     JOIN farmacia.proveedor pr ON ((p.id_proveedor = pr.id_proveedor)))
     JOIN farmacia.producto_indicaciones pi ON ((p.id_producto = pi.id_producto)))
     JOIN farmacia.indicacion i ON ((pi.id_indicaciones = i.id_indicacion)))
  GROUP BY p.nombre, p.descripcion, p.precio_venta, p.imagen, p.sustancias, pr.nombre;


ALTER TABLE farmacia.listar_productos OWNER TO postgres;

--
-- Name: producto_id_producto_seq; Type: SEQUENCE; Schema: farmacia; Owner: postgres
--

CREATE SEQUENCE farmacia.producto_id_producto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE farmacia.producto_id_producto_seq OWNER TO postgres;

--
-- Name: producto_id_producto_seq; Type: SEQUENCE OWNED BY; Schema: farmacia; Owner: postgres
--

ALTER SEQUENCE farmacia.producto_id_producto_seq OWNED BY farmacia.producto.id_producto;


--
-- Name: proveedor_id_proveedor_seq; Type: SEQUENCE; Schema: farmacia; Owner: postgres
--

CREATE SEQUENCE farmacia.proveedor_id_proveedor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE farmacia.proveedor_id_proveedor_seq OWNER TO postgres;

--
-- Name: proveedor_id_proveedor_seq; Type: SEQUENCE OWNED BY; Schema: farmacia; Owner: postgres
--

ALTER SEQUENCE farmacia.proveedor_id_proveedor_seq OWNED BY farmacia.proveedor.id_proveedor;


--
-- Name: listar_productos_inicio; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.listar_productos_inicio AS
SELECT
    NULL::integer AS id_producto,
    NULL::character varying(100) AS nombre,
    NULL::text AS descripcion,
    NULL::numeric AS precio_venta,
    NULL::text AS imagen,
    NULL::text[] AS sustancias,
    NULL::character varying(50) AS nombreproveedor,
    NULL::character varying[] AS indicaciones,
    NULL::numeric AS precio_compra,
    NULL::integer AS id_proveedor;


ALTER TABLE public.listar_productos_inicio OWNER TO postgres;

--
-- Name: indicacion id_indicacion; Type: DEFAULT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.indicacion ALTER COLUMN id_indicacion SET DEFAULT nextval('farmacia.indicacion_id_indicacion_seq'::regclass);


--
-- Name: producto id_producto; Type: DEFAULT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.producto ALTER COLUMN id_producto SET DEFAULT nextval('farmacia.producto_id_producto_seq'::regclass);


--
-- Name: proveedor id_proveedor; Type: DEFAULT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.proveedor ALTER COLUMN id_proveedor SET DEFAULT nextval('farmacia.proveedor_id_proveedor_seq'::regclass);


--
-- Data for Name: indicacion; Type: TABLE DATA; Schema: farmacia; Owner: postgres
--

COPY farmacia.indicacion (id_indicacion, nombre, descripcion) FROM stdin;
2	Gripe	Enfermedad viral
4	Infección urinaria	Dolor en vías urinarias
5	Fiebre	Temperatura corporal mayor a 37.5 C
3	Diarrea	Cuando vas mucho al baño
1	Tos seca	Cuando toses
7	Dolor de cabeza	Cuando sientes que te duele la cabeza 
8	Acné	Irritaciones en la piel, las cuales provocan erupciones. 
\.


--
-- Data for Name: producto; Type: TABLE DATA; Schema: farmacia; Owner: postgres
--

COPY farmacia.producto (id_producto, nombre, descripcion, precio_compra, precio_venta, imagen, id_proveedor, sustancias) FROM stdin;
1	Tempra forte	Un medicamento muy popular, funciona para muchas cosas	$75.00	$75.00	tempra.png	2	{Paracetamol}
5	Aspirina	Una de las principales funciones de la aspirina es aliviar el dolor, es un analgésico muy potente por lo que reduce el dolor considerablemente.	$160.00	$160.00	Aspirina.png	3	{Acido,Carbón}
9	Retin-A 0.5%	Crema con 100g de contenido, vía de administración cutánea	$150.00	$220.00	Retin-A 0.5%.png	2	{Tretinoina}
\.


--
-- Data for Name: producto_indicaciones; Type: TABLE DATA; Schema: farmacia; Owner: postgres
--

COPY farmacia.producto_indicaciones (id_producto, id_indicaciones) FROM stdin;
1	1
1	2
5	7
9	8
\.


--
-- Data for Name: proveedor; Type: TABLE DATA; Schema: farmacia; Owner: postgres
--

COPY farmacia.proveedor (id_proveedor, nombre, rfc, direccion, telefono) FROM stdin;
2	Phizer	PHIZ384938HGT	Empresa mundial	72929100001
3	Distribuidora de medicamentos Queretaro SA de CV	DISMED38298QT	Calle benito juarez 102 Santiago de Querétaro	2020
1	Distribuidora de medicamentos Leon SA de CV	DISMED38298QT	Blvd. Torres landa 1002, Leon de los aldama	4661274739
\.


--
-- Name: indicacion_id_indicacion_seq; Type: SEQUENCE SET; Schema: farmacia; Owner: postgres
--

SELECT pg_catalog.setval('farmacia.indicacion_id_indicacion_seq', 8, true);


--
-- Name: producto_id_producto_seq; Type: SEQUENCE SET; Schema: farmacia; Owner: postgres
--

SELECT pg_catalog.setval('farmacia.producto_id_producto_seq', 9, true);


--
-- Name: proveedor_id_proveedor_seq; Type: SEQUENCE SET; Schema: farmacia; Owner: postgres
--

SELECT pg_catalog.setval('farmacia.proveedor_id_proveedor_seq', 4, true);


--
-- Name: indicacion indicacion_pk; Type: CONSTRAINT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.indicacion
    ADD CONSTRAINT indicacion_pk PRIMARY KEY (id_indicacion);


--
-- Name: producto producto_pk; Type: CONSTRAINT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.producto
    ADD CONSTRAINT producto_pk PRIMARY KEY (id_producto);


--
-- Name: proveedor proveedor_pk; Type: CONSTRAINT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.proveedor
    ADD CONSTRAINT proveedor_pk PRIMARY KEY (id_proveedor);


--
-- Name: indicacion_nombre_uindex; Type: INDEX; Schema: farmacia; Owner: postgres
--

CREATE UNIQUE INDEX indicacion_nombre_uindex ON farmacia.indicacion USING btree (nombre);


--
-- Name: producto_nombre_uindex; Type: INDEX; Schema: farmacia; Owner: postgres
--

CREATE UNIQUE INDEX producto_nombre_uindex ON farmacia.producto USING btree (nombre);


--
-- Name: proveedor_nombre_uindex; Type: INDEX; Schema: farmacia; Owner: postgres
--

CREATE UNIQUE INDEX proveedor_nombre_uindex ON farmacia.proveedor USING btree (nombre);


--
-- Name: listar_productos_inicio _RETURN; Type: RULE; Schema: public; Owner: postgres
--

CREATE OR REPLACE VIEW public.listar_productos_inicio AS
 SELECT p.id_producto,
    p.nombre,
    p.descripcion,
    (p.precio_venta)::numeric AS precio_venta,
    p.imagen,
    p.sustancias,
    pr.nombre AS nombreproveedor,
    array_agg(i.nombre) AS indicaciones,
    (p.precio_compra)::numeric AS precio_compra,
    pr.id_proveedor
   FROM (((farmacia.producto p
     JOIN farmacia.proveedor pr ON ((p.id_proveedor = pr.id_proveedor)))
     JOIN farmacia.producto_indicaciones pi ON ((p.id_producto = pi.id_producto)))
     JOIN farmacia.indicacion i ON ((pi.id_indicaciones = i.id_indicacion)))
  GROUP BY p.id_producto, p.nombre, p.descripcion, p.precio_venta, p.imagen, p.sustancias, pr.id_proveedor, pr.nombre;


--
-- Name: producto producto___fk_id_proveedor; Type: FK CONSTRAINT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.producto
    ADD CONSTRAINT producto___fk_id_proveedor FOREIGN KEY (id_proveedor) REFERENCES farmacia.proveedor(id_proveedor);


--
-- Name: producto_indicaciones producto_indicaciones___fk_id_indicaciones; Type: FK CONSTRAINT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.producto_indicaciones
    ADD CONSTRAINT producto_indicaciones___fk_id_indicaciones FOREIGN KEY (id_indicaciones) REFERENCES farmacia.indicacion(id_indicacion);


--
-- Name: producto_indicaciones producto_indicaciones___fk_id_producto; Type: FK CONSTRAINT; Schema: farmacia; Owner: postgres
--

ALTER TABLE ONLY farmacia.producto_indicaciones
    ADD CONSTRAINT producto_indicaciones___fk_id_producto FOREIGN KEY (id_producto) REFERENCES farmacia.producto(id_producto);


--
-- PostgreSQL database dump complete
--

