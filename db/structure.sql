--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.14
-- Dumped by pg_dump version 9.5.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA postgis;


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA postgis;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: measurement_imports_subtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.measurement_imports_subtype AS ENUM (
    'None',
    'Drive',
    'Surface',
    'Cosmic'
);


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admins (
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


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: bgeigie_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bgeigie_logs (
    id integer NOT NULL,
    device_tag character varying(255),
    device_serial_id character varying(255),
    captured_at timestamp without time zone,
    cpm integer,
    counts_per_five_seconds integer,
    total_counts integer,
    cpm_validity character varying(255),
    latitude_nmea numeric,
    north_south_indicator character varying(255),
    longitude_nmea numeric,
    east_west_indicator character varying(255),
    altitude double precision,
    gps_fix_indicator character varying(255),
    horizontal_dilution_of_precision double precision,
    gps_fix_quality_indicator character varying(255),
    created_at timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    updated_at timestamp without time zone DEFAULT '1970-01-01 00:00:00'::timestamp without time zone NOT NULL,
    bgeigie_import_id integer,
    computed_location postgis.geography(Point,4326),
    md5sum character varying
);


--
-- Name: bgeigie_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bgeigie_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bgeigie_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bgeigie_logs_id_seq OWNED BY public.bgeigie_logs.id;


--
-- Name: configurables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configurables (
    id integer NOT NULL,
    name character varying(255),
    value character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: configurables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configurables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configurables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configurables_id_seq OWNED BY public.configurables.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0,
    attempts integer DEFAULT 0,
    handler text,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    queue character varying(255)
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.devices (
    id integer NOT NULL,
    manufacturer character varying(255),
    model character varying(255),
    sensor character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    measurements_count integer
);


--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- Name: drive_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.drive_logs (
    id integer NOT NULL,
    drive_import_id integer,
    reading_date timestamp without time zone,
    reading_value double precision,
    unit_id integer,
    alt_reading_value double precision,
    alt_unit_id integer,
    rolling_count integer,
    total_count integer,
    latitude double precision,
    longitude double precision,
    gps_quality_indicator integer,
    satellite_num integer,
    gps_precision double precision,
    gps_altitude double precision,
    gps_device_name character varying,
    measurement_type character varying,
    zoom_7_grid character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    location postgis.geography(Point,4326),
    md5sum character varying
);


--
-- Name: drive_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.drive_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drive_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.drive_logs_id_seq OWNED BY public.drive_logs.id;


--
-- Name: ioslastexport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ioslastexport (
    lastmaxid integer,
    exportdate timestamp without time zone
);


--
-- Name: maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maps (
    id integer NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer,
    device_id integer,
    name character varying(255)
);


--
-- Name: maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.maps_id_seq OWNED BY public.maps.id;


--
-- Name: maps_measurements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.maps_measurements (
    map_id integer,
    measurement_id integer
);


--
-- Name: measurement_import_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.measurement_import_logs (
    id integer NOT NULL,
    measurement_import_id integer,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: measurement_import_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.measurement_import_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: measurement_import_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.measurement_import_logs_id_seq OWNED BY public.measurement_import_logs.id;


--
-- Name: measurement_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.measurement_imports (
    id integer NOT NULL,
    user_id integer,
    source character varying(255),
    md5sum character varying(255),
    type character varying(255),
    status character varying(255),
    measurements_count integer,
    map_id integer,
    status_details text,
    approved boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255),
    description text,
    lines_count integer,
    credits text,
    height numeric(8,2),
    orientation character varying(255),
    cities text,
    subtype public.measurement_imports_subtype DEFAULT 'None'::public.measurement_imports_subtype NOT NULL,
    comment character varying,
    rejected boolean DEFAULT false,
    rejected_by character varying(255),
    approved_by character varying(255),
    would_auto_approve boolean DEFAULT false,
    auto_apprv_no_zero_cpm boolean,
    auto_apprv_no_high_cpm boolean,
    auto_apprv_gps_validity boolean,
    auto_apprv_frequent_bgeigie_id boolean,
    auto_apprv_good_bgeigie_id boolean
);


--
-- Name: measurement_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.measurement_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: measurement_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.measurement_imports_id_seq OWNED BY public.measurement_imports.id;


--
-- Name: measurements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.measurements (
    id integer NOT NULL,
    user_id integer,
    value double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    unit character varying,
    location postgis.geography(Point,4326),
    location_name character varying,
    device_id integer,
    original_id integer,
    expired_at timestamp without time zone,
    replaced_by integer,
    updated_by integer,
    measurement_import_id integer,
    md5sum character varying(255),
    captured_at timestamp without time zone,
    height integer,
    surface character varying(255),
    radiation character varying(255),
    devicetype_id character varying(255),
    sensor_id integer,
    station_id integer,
    channel_id integer
);


--
-- Name: measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.measurements_id_seq OWNED BY public.measurements.id;


--
-- Name: rails_admin_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rails_admin_histories (
    id integer NOT NULL,
    message text,
    username character varying(255),
    item integer,
    "table" character varying(255),
    month smallint,
    year bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rails_admin_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rails_admin_histories_id_seq OWNED BY public.rails_admin_histories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: uploader_contact_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploader_contact_histories (
    id integer NOT NULL,
    bgeigie_import_id integer,
    administrator_id integer NOT NULL,
    previous_status character varying(255) NOT NULL,
    content text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: uploader_contact_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploader_contact_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploader_contact_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploader_contact_histories_id_seq OWNED BY public.uploader_contact_histories.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(128) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    authentication_token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying(255),
    time_zone character varying(255),
    moderator boolean DEFAULT false,
    measurements_count integer,
    default_locale character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    authentication_token_created_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: bgeigie_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bgeigie_logs ALTER COLUMN id SET DEFAULT nextval('public.bgeigie_logs_id_seq'::regclass);


--
-- Name: configurables id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configurables ALTER COLUMN id SET DEFAULT nextval('public.configurables_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- Name: drive_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drive_logs ALTER COLUMN id SET DEFAULT nextval('public.drive_logs_id_seq'::regclass);


--
-- Name: maps id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maps ALTER COLUMN id SET DEFAULT nextval('public.maps_id_seq'::regclass);


--
-- Name: measurement_import_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_import_logs ALTER COLUMN id SET DEFAULT nextval('public.measurement_import_logs_id_seq'::regclass);


--
-- Name: measurement_imports id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_imports ALTER COLUMN id SET DEFAULT nextval('public.measurement_imports_id_seq'::regclass);


--
-- Name: measurements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurements ALTER COLUMN id SET DEFAULT nextval('public.measurements_id_seq'::regclass);


--
-- Name: rails_admin_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rails_admin_histories ALTER COLUMN id SET DEFAULT nextval('public.rails_admin_histories_id_seq'::regclass);


--
-- Name: uploader_contact_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploader_contact_histories ALTER COLUMN id SET DEFAULT nextval('public.uploader_contact_histories_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: bgeigie_logs bgeigie_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bgeigie_logs
    ADD CONSTRAINT bgeigie_logs_pkey PRIMARY KEY (id);


--
-- Name: configurables configurables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configurables
    ADD CONSTRAINT configurables_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: drive_logs drive_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.drive_logs
    ADD CONSTRAINT drive_logs_pkey PRIMARY KEY (id);


--
-- Name: maps maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- Name: measurement_import_logs measurement_import_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_import_logs
    ADD CONSTRAINT measurement_import_logs_pkey PRIMARY KEY (id);


--
-- Name: measurement_imports measurement_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurement_imports
    ADD CONSTRAINT measurement_imports_pkey PRIMARY KEY (id);


--
-- Name: measurements measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.measurements
    ADD CONSTRAINT measurements_pkey PRIMARY KEY (id);


--
-- Name: rails_admin_histories rails_admin_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rails_admin_histories
    ADD CONSTRAINT rails_admin_histories_pkey PRIMARY KEY (id);


--
-- Name: uploader_contact_histories uploader_contact_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploader_contact_histories
    ADD CONSTRAINT uploader_contact_histories_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: idx_bgeigie_logs_bgeigie_import_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bgeigie_logs_bgeigie_import_id_index ON public.bgeigie_logs USING btree (bgeigie_import_id);


--
-- Name: idx_bgeigie_logs_device_serial_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bgeigie_logs_device_serial_id_index ON public.bgeigie_logs USING btree (device_serial_id);


--
-- Name: idx_measurements_captured_at_unit_device_id_device_id_not_null; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_measurements_captured_at_unit_device_id_device_id_not_null ON public.measurements USING btree (captured_at, unit, device_id) WHERE (device_id IS NOT NULL);


--
-- Name: idx_measurements_value_device_id_device_id_not_null; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_measurements_value_device_id_device_id_not_null ON public.measurements USING btree (value, device_id) WHERE (device_id IS NOT NULL);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_email ON public.admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON public.admins USING btree (reset_password_token);


--
-- Name: index_bgeigie_logs_on_bgeigie_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bgeigie_logs_on_bgeigie_import_id ON public.bgeigie_logs USING btree (bgeigie_import_id);


--
-- Name: index_bgeigie_logs_on_device_serial_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bgeigie_logs_on_device_serial_id ON public.bgeigie_logs USING btree (device_serial_id);


--
-- Name: index_bgeigie_logs_on_md5sum; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bgeigie_logs_on_md5sum ON public.bgeigie_logs USING btree (md5sum);


--
-- Name: index_configurables_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_configurables_on_name ON public.configurables USING btree (name);


--
-- Name: index_drive_logs_on_md5sum; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_drive_logs_on_md5sum ON public.drive_logs USING btree (md5sum);


--
-- Name: index_drive_logs_on_measurement_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drive_logs_on_measurement_import_id ON public.drive_logs USING btree (drive_import_id);


--
-- Name: index_maps_on_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maps_on_device_id ON public.maps USING btree (device_id);


--
-- Name: index_maps_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maps_on_user_id ON public.maps USING btree (user_id);


--
-- Name: index_measurement_imports_on_id_and_subtype; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurement_imports_on_id_and_subtype ON public.measurement_imports USING btree (id, subtype);


--
-- Name: index_measurement_imports_on_subtype; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurement_imports_on_subtype ON public.measurement_imports USING btree (subtype);


--
-- Name: index_measurements_on_captured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_captured_at ON public.measurements USING btree (captured_at);


--
-- Name: index_measurements_on_captured_at_and_unit_and_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_captured_at_and_unit_and_device_id ON public.measurements USING btree (captured_at, unit, device_id) WHERE (device_id IS NOT NULL);


--
-- Name: index_measurements_on_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_device_id ON public.measurements USING btree (device_id);


--
-- Name: index_measurements_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_location ON public.measurements USING gist (location);


--
-- Name: index_measurements_on_md5sum; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_measurements_on_md5sum ON public.measurements USING btree (md5sum);


--
-- Name: index_measurements_on_measurement_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_measurement_import_id ON public.measurements USING btree (measurement_import_id);


--
-- Name: index_measurements_on_original_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_original_id ON public.measurements USING btree (original_id);


--
-- Name: index_measurements_on_unit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_unit ON public.measurements USING btree (unit);


--
-- Name: index_measurements_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_user_id ON public.measurements USING btree (user_id);


--
-- Name: index_measurements_on_user_id_and_captured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_user_id_and_captured_at ON public.measurements USING btree (user_id, captured_at);


--
-- Name: index_measurements_on_value_and_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_value_and_device_id ON public.measurements USING btree (value, device_id) WHERE (device_id IS NOT NULL);


--
-- Name: index_measurements_on_value_and_unit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_value_and_unit ON public.measurements USING btree (value, unit);


--
-- Name: index_rails_admin_histories; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rails_admin_histories ON public.rails_admin_histories USING btree (item, "table", month, year);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON public.users USING btree (authentication_token);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO public.schema_migrations (version) VALUES ('20111123174941');

INSERT INTO public.schema_migrations (version) VALUES ('20111123190839');

INSERT INTO public.schema_migrations (version) VALUES ('20111124211843');

INSERT INTO public.schema_migrations (version) VALUES ('20111128163114');

INSERT INTO public.schema_migrations (version) VALUES ('20111128163317');

INSERT INTO public.schema_migrations (version) VALUES ('20111128171949');

INSERT INTO public.schema_migrations (version) VALUES ('20111130103929');

INSERT INTO public.schema_migrations (version) VALUES ('20111130104648');

INSERT INTO public.schema_migrations (version) VALUES ('20111130132854');

INSERT INTO public.schema_migrations (version) VALUES ('20111210075847');

INSERT INTO public.schema_migrations (version) VALUES ('20111210234133');

INSERT INTO public.schema_migrations (version) VALUES ('20111210235123');

INSERT INTO public.schema_migrations (version) VALUES ('20111210235206');

INSERT INTO public.schema_migrations (version) VALUES ('20111210235226');

INSERT INTO public.schema_migrations (version) VALUES ('20111210235259');

INSERT INTO public.schema_migrations (version) VALUES ('20111213000431');

INSERT INTO public.schema_migrations (version) VALUES ('20111214134716');

INSERT INTO public.schema_migrations (version) VALUES ('20111214154833');

INSERT INTO public.schema_migrations (version) VALUES ('20111214161111');

INSERT INTO public.schema_migrations (version) VALUES ('20111214162214');

INSERT INTO public.schema_migrations (version) VALUES ('20111214224431');

INSERT INTO public.schema_migrations (version) VALUES ('20111214224611');

INSERT INTO public.schema_migrations (version) VALUES ('20120103182931');

INSERT INTO public.schema_migrations (version) VALUES ('20120103213502');

INSERT INTO public.schema_migrations (version) VALUES ('20120110185237');

INSERT INTO public.schema_migrations (version) VALUES ('20120116133915');

INSERT INTO public.schema_migrations (version) VALUES ('20120116134744');

INSERT INTO public.schema_migrations (version) VALUES ('20120116144757');

INSERT INTO public.schema_migrations (version) VALUES ('20120116150229');

INSERT INTO public.schema_migrations (version) VALUES ('20120306150302');

INSERT INTO public.schema_migrations (version) VALUES ('20120306202021');

INSERT INTO public.schema_migrations (version) VALUES ('20120307130255');

INSERT INTO public.schema_migrations (version) VALUES ('20120307130803');

INSERT INTO public.schema_migrations (version) VALUES ('20120307150105');

INSERT INTO public.schema_migrations (version) VALUES ('20120307175658');

INSERT INTO public.schema_migrations (version) VALUES ('20120307232457');

INSERT INTO public.schema_migrations (version) VALUES ('20120315211955');

INSERT INTO public.schema_migrations (version) VALUES ('20120315220809');

INSERT INTO public.schema_migrations (version) VALUES ('20120323105044');

INSERT INTO public.schema_migrations (version) VALUES ('20120323115733');

INSERT INTO public.schema_migrations (version) VALUES ('20120323181147');

INSERT INTO public.schema_migrations (version) VALUES ('20120324025600');

INSERT INTO public.schema_migrations (version) VALUES ('20120324094455');

INSERT INTO public.schema_migrations (version) VALUES ('20120324100545');

INSERT INTO public.schema_migrations (version) VALUES ('20120417190549');

INSERT INTO public.schema_migrations (version) VALUES ('20120418231658');

INSERT INTO public.schema_migrations (version) VALUES ('20120521225350');

INSERT INTO public.schema_migrations (version) VALUES ('20120526101510');

INSERT INTO public.schema_migrations (version) VALUES ('20120614160337');

INSERT INTO public.schema_migrations (version) VALUES ('20120625212801');

INSERT INTO public.schema_migrations (version) VALUES ('20130114094100');

INSERT INTO public.schema_migrations (version) VALUES ('20130115032717');

INSERT INTO public.schema_migrations (version) VALUES ('20130115042245');

INSERT INTO public.schema_migrations (version) VALUES ('20130117110750');

INSERT INTO public.schema_migrations (version) VALUES ('20130117110817');

INSERT INTO public.schema_migrations (version) VALUES ('20130117111202');

INSERT INTO public.schema_migrations (version) VALUES ('20130118064024');

INSERT INTO public.schema_migrations (version) VALUES ('20130427160522');

INSERT INTO public.schema_migrations (version) VALUES ('20130429205209');

INSERT INTO public.schema_migrations (version) VALUES ('20130429205707');

INSERT INTO public.schema_migrations (version) VALUES ('20130606042505');

INSERT INTO public.schema_migrations (version) VALUES ('20130705092519');

INSERT INTO public.schema_migrations (version) VALUES ('20140718095222');

INSERT INTO public.schema_migrations (version) VALUES ('20150919060031');

INSERT INTO public.schema_migrations (version) VALUES ('20160208190731');

INSERT INTO public.schema_migrations (version) VALUES ('20160403092926');

INSERT INTO public.schema_migrations (version) VALUES ('20160531111906');

INSERT INTO public.schema_migrations (version) VALUES ('20160607005457');

INSERT INTO public.schema_migrations (version) VALUES ('20160614042818');

INSERT INTO public.schema_migrations (version) VALUES ('20160615215212');

INSERT INTO public.schema_migrations (version) VALUES ('20180603015430');

INSERT INTO public.schema_migrations (version) VALUES ('20181130044638');

INSERT INTO public.schema_migrations (version) VALUES ('20191017054450');

INSERT INTO public.schema_migrations (version) VALUES ('20191022080113');

INSERT INTO public.schema_migrations (version) VALUES ('20191023060540');

INSERT INTO public.schema_migrations (version) VALUES ('20191025034816');

