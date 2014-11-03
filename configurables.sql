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
-- Name: configurables; Type: TABLE; Schema: public; Owner: safecast; Tablespace: 
--

CREATE TABLE configurables (
    id integer NOT NULL,
    name character varying(255),
    value character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


ALTER TABLE public.configurables OWNER TO safecast;

--
-- Name: configurables_id_seq; Type: SEQUENCE; Schema: public; Owner: safecast
--

CREATE SEQUENCE configurables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.configurables_id_seq OWNER TO safecast;

--
-- Name: configurables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: safecast
--

ALTER SEQUENCE configurables_id_seq OWNED BY configurables.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: safecast
--

ALTER TABLE ONLY configurables ALTER COLUMN id SET DEFAULT nextval('configurables_id_seq'::regclass);


--
-- Data for Name: configurables; Type: TABLE DATA; Schema: public; Owner: safecast
--

COPY configurables (id, name, value, created_at, updated_at) FROM stdin;
1	aws_access_key_id	AKIAIXGSQXW5GNBB4VCA	2012-03-07 23:31:12.280474	2012-09-21 19:12:40.609425
2	aws_secret_access_key	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	2012-03-07 23:31:29.214079	2012-09-21 19:12:40.622461
3	s3_bucket	safecast-production	2012-03-07 23:31:55.284212	2012-09-21 19:12:40.627301
4	intercom_app_id	ooxtxeid	2013-01-17 10:46:36.890671	2013-01-17 10:46:36.890671
5	intercom_api_secret	8uAZHnxWPqs1QZdy_NEXkVYGoR9cHgaijaTMhDt1	2013-01-17 10:46:46.125959	2013-01-17 10:46:46.125959
6	intercom_api_key	f81673db92046d5fc4017aafdfcd971b8baaf093	2013-01-17 10:46:54.431494	2013-01-17 10:46:54.431494
\.


--
-- Name: configurables_id_seq; Type: SEQUENCE SET; Schema: public; Owner: safecast
--

SELECT pg_catalog.setval('configurables_id_seq', 6, true);


--
-- Name: configurables_pkey; Type: CONSTRAINT; Schema: public; Owner: safecast; Tablespace: 
--

ALTER TABLE ONLY configurables
    ADD CONSTRAINT configurables_pkey PRIMARY KEY (id);


--
-- Name: index_configurables_on_name; Type: INDEX; Schema: public; Owner: safecast; Tablespace: 
--

CREATE INDEX index_configurables_on_name ON configurables USING btree (name);


--
-- PostgreSQL database dump complete
--

