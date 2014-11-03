--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: safecast; Tablespace: 
--

CREATE TABLE admins (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.admins OWNER TO safecast;

--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: safecast
--

CREATE SEQUENCE admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.admins_id_seq OWNER TO safecast;

--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safecast
--

ALTER SEQUENCE admins_id_seq OWNED BY admins.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: safecast
--

ALTER TABLE ONLY admins ALTER COLUMN id SET DEFAULT nextval('admins_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: safecast
--

COPY admins (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, created_at, updated_at) FROM stdin;
1	paul@rslw.com	$2a$10$pc79iqfJW8jlEQAsnfcJZu7PJsvwJ/Q8gnuJ1wTw34qLgqCKBMe.G	\N	\N	2012-04-19 10:55:05.609416	3	2012-04-24 10:42:27.392428	2012-04-20 16:23:22.092522	10.248.19.95	10.248.19.95	2012-04-19 10:54:56.265914	2012-04-24 10:42:27.393211
2	rob@yr-design.biz	$2a$10$RsyHkTMyxiIdtdmzWD6tYO9beBYuSUfQJdlydQgoJFbCHUupalJSi	\N	\N	\N	0	\N	\N	\N	\N	2013-12-19 03:07:25.854993	2013-12-19 03:07:25.854993
\.


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: safecast
--

SELECT pg_catalog.setval('admins_id_seq', 3, true);


--
-- Name: admins_pkey; Type: CONSTRAINT; Schema: public; Owner: safecast; Tablespace: 
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: safecast; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_email ON admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: safecast; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON admins USING btree (reset_password_token);


--
-- PostgreSQL database dump complete
--

