--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.2
-- Dumped by pg_dump version 9.5.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgis; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA postgis;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA postgis;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: measurement_imports_subtype; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE measurement_imports_subtype AS ENUM (
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


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admins_id_seq OWNED BY admins.id;


--
-- Name: bgeigie_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE bgeigie_logs (
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
    md5sum character varying(255)
);


--
-- Name: bgeigie_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bgeigie_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bgeigie_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bgeigie_logs_id_seq OWNED BY bgeigie_logs.id;


--
-- Name: configurables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE configurables (
    id integer NOT NULL,
    name character varying(255),
    value character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: configurables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE configurables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configurables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE configurables_id_seq OWNED BY configurables.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
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

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE devices (
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

CREATE SEQUENCE devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE devices_id_seq OWNED BY devices.id;


--
-- Name: drive_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE drive_logs (
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
    gps_device_name character varying(255),
    measurement_type character varying(255),
    zoom_7_grid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    location postgis.geography(Point,4326),
    md5sum character varying(255)
);


--
-- Name: drive_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE drive_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drive_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE drive_logs_id_seq OWNED BY drive_logs.id;


--
-- Name: ioslastexport; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ioslastexport (
    lastmaxid integer,
    exportdate timestamp without time zone
);


--
-- Name: maps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE maps (
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

CREATE SEQUENCE maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE maps_id_seq OWNED BY maps.id;


--
-- Name: maps_measurements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE maps_measurements (
    map_id integer,
    measurement_id integer
);


--
-- Name: measurement_import_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE measurement_import_logs (
    id integer NOT NULL,
    measurement_import_id integer,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: measurement_import_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE measurement_import_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: measurement_import_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE measurement_import_logs_id_seq OWNED BY measurement_import_logs.id;


--
-- Name: measurement_imports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE measurement_imports (
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
    comment character varying(255),
    subtype measurement_imports_subtype DEFAULT 'None'::measurement_imports_subtype NOT NULL,
    rejected boolean DEFAULT false,
    rejected_by character varying(255)
);


--
-- Name: measurement_imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE measurement_imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: measurement_imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE measurement_imports_id_seq OWNED BY measurement_imports.id;


--
-- Name: measurements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE measurements (
    id integer NOT NULL,
    user_id integer,
    value double precision,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    unit character varying(255),
    location postgis.geography(Point,4326),
    location_name character varying(255),
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

CREATE SEQUENCE measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE measurements_id_seq OWNED BY measurements.id;


--
-- Name: rails_admin_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rails_admin_histories (
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

CREATE SEQUENCE rails_admin_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rails_admin_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rails_admin_histories_id_seq OWNED BY rails_admin_histories.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: uploader_contact_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE uploader_contact_histories (
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

CREATE SEQUENCE uploader_contact_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploader_contact_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE uploader_contact_histories_id_seq OWNED BY uploader_contact_histories.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
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

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins ALTER COLUMN id SET DEFAULT nextval('admins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bgeigie_logs ALTER COLUMN id SET DEFAULT nextval('bgeigie_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY configurables ALTER COLUMN id SET DEFAULT nextval('configurables_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices ALTER COLUMN id SET DEFAULT nextval('devices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY drive_logs ALTER COLUMN id SET DEFAULT nextval('drive_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps ALTER COLUMN id SET DEFAULT nextval('maps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY measurement_import_logs ALTER COLUMN id SET DEFAULT nextval('measurement_import_logs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY measurement_imports ALTER COLUMN id SET DEFAULT nextval('measurement_imports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY measurements ALTER COLUMN id SET DEFAULT nextval('measurements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rails_admin_histories ALTER COLUMN id SET DEFAULT nextval('rails_admin_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploader_contact_histories ALTER COLUMN id SET DEFAULT nextval('uploader_contact_histories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: bgeigie_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bgeigie_logs
    ADD CONSTRAINT bgeigie_logs_pkey PRIMARY KEY (id);


--
-- Name: configurables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY configurables
    ADD CONSTRAINT configurables_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: drive_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY drive_logs
    ADD CONSTRAINT drive_logs_pkey PRIMARY KEY (id);


--
-- Name: maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (id);


--
-- Name: measurement_import_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY measurement_import_logs
    ADD CONSTRAINT measurement_import_logs_pkey PRIMARY KEY (id);


--
-- Name: measurement_imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY measurement_imports
    ADD CONSTRAINT measurement_imports_pkey PRIMARY KEY (id);


--
-- Name: measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY measurements
    ADD CONSTRAINT measurements_pkey PRIMARY KEY (id);


--
-- Name: rails_admin_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rails_admin_histories
    ADD CONSTRAINT rails_admin_histories_pkey PRIMARY KEY (id);


--
-- Name: uploader_contact_histories uploader_contact_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY uploader_contact_histories
    ADD CONSTRAINT uploader_contact_histories_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: idx_bgeigie_logs_bgeigie_import_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bgeigie_logs_bgeigie_import_id_index ON bgeigie_logs USING btree (bgeigie_import_id);


--
-- Name: idx_bgeigie_logs_device_serial_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bgeigie_logs_device_serial_id_index ON bgeigie_logs USING btree (device_serial_id);


--
-- Name: idx_measurements_captured_at_unit_device_id_device_id_not_null; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_measurements_captured_at_unit_device_id_device_id_not_null ON measurements USING btree (captured_at, unit, device_id) WHERE (device_id IS NOT NULL);


--
-- Name: idx_measurements_value_device_id_device_id_not_null; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_measurements_value_device_id_device_id_not_null ON measurements USING btree (value, device_id) WHERE (device_id IS NOT NULL);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_email ON admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON admins USING btree (reset_password_token);


--
-- Name: index_bgeigie_logs_on_md5sum; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_bgeigie_logs_on_md5sum ON bgeigie_logs USING btree (md5sum);


--
-- Name: index_configurables_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_configurables_on_name ON configurables USING btree (name);


--
-- Name: index_drive_logs_on_md5sum; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_drive_logs_on_md5sum ON drive_logs USING btree (md5sum);


--
-- Name: index_drive_logs_on_measurement_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_drive_logs_on_measurement_import_id ON drive_logs USING btree (drive_import_id);


--
-- Name: index_maps_on_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maps_on_device_id ON maps USING btree (device_id);


--
-- Name: index_maps_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_maps_on_user_id ON maps USING btree (user_id);


--
-- Name: index_measurement_imports_on_id_and_subtype; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurement_imports_on_id_and_subtype ON measurement_imports USING btree (id, subtype);


--
-- Name: index_measurement_imports_on_subtype; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurement_imports_on_subtype ON measurement_imports USING btree (subtype);


--
-- Name: index_measurements_on_captured_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_captured_at ON measurements USING btree (captured_at);


--
-- Name: index_measurements_on_device_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_device_id ON measurements USING btree (device_id);


--
-- Name: index_measurements_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_location ON measurements USING gist (location);


--
-- Name: index_measurements_on_md5sum; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_measurements_on_md5sum ON measurements USING btree (md5sum);


--
-- Name: index_measurements_on_measurement_import_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_measurement_import_id ON measurements USING btree (measurement_import_id);


--
-- Name: index_measurements_on_original_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_original_id ON measurements USING btree (original_id);


--
-- Name: index_measurements_on_unit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_unit ON measurements USING btree (unit);


--
-- Name: index_measurements_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_measurements_on_user_id ON measurements USING btree (user_id);


--
-- Name: index_measurements_on_user_id_and_captured_at; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_measurements_on_user_id_and_captured_at ON measurements USING btree (user_id, captured_at);


--
-- Name: index_measurements_on_value_and_unit; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_measurements_on_value_and_unit ON measurements USING btree (value, unit);


--
-- Name: index_rails_admin_histories; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rails_admin_histories ON rails_admin_histories USING btree (item, "table", month, year);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20111123174941');

INSERT INTO schema_migrations (version) VALUES ('20111123190839');

INSERT INTO schema_migrations (version) VALUES ('20111124211843');

INSERT INTO schema_migrations (version) VALUES ('20111128163114');

INSERT INTO schema_migrations (version) VALUES ('20111128163317');

INSERT INTO schema_migrations (version) VALUES ('20111128171949');

INSERT INTO schema_migrations (version) VALUES ('20111130103929');

INSERT INTO schema_migrations (version) VALUES ('20111130104648');

INSERT INTO schema_migrations (version) VALUES ('20111130132854');

INSERT INTO schema_migrations (version) VALUES ('20111210075847');

INSERT INTO schema_migrations (version) VALUES ('20111210234133');

INSERT INTO schema_migrations (version) VALUES ('20111210235123');

INSERT INTO schema_migrations (version) VALUES ('20111210235206');

INSERT INTO schema_migrations (version) VALUES ('20111210235226');

INSERT INTO schema_migrations (version) VALUES ('20111210235259');

INSERT INTO schema_migrations (version) VALUES ('20111213000431');

INSERT INTO schema_migrations (version) VALUES ('20111214134716');

INSERT INTO schema_migrations (version) VALUES ('20111214154833');

INSERT INTO schema_migrations (version) VALUES ('20111214161111');

INSERT INTO schema_migrations (version) VALUES ('20111214162214');

INSERT INTO schema_migrations (version) VALUES ('20111214224431');

INSERT INTO schema_migrations (version) VALUES ('20111214224611');

INSERT INTO schema_migrations (version) VALUES ('20120103182931');

INSERT INTO schema_migrations (version) VALUES ('20120103213502');

INSERT INTO schema_migrations (version) VALUES ('20120110185237');

INSERT INTO schema_migrations (version) VALUES ('20120116133915');

INSERT INTO schema_migrations (version) VALUES ('20120116134744');

INSERT INTO schema_migrations (version) VALUES ('20120116144757');

INSERT INTO schema_migrations (version) VALUES ('20120116150229');

INSERT INTO schema_migrations (version) VALUES ('20120306150302');

INSERT INTO schema_migrations (version) VALUES ('20120306202021');

INSERT INTO schema_migrations (version) VALUES ('20120307130255');

INSERT INTO schema_migrations (version) VALUES ('20120307130803');

INSERT INTO schema_migrations (version) VALUES ('20120307150105');

INSERT INTO schema_migrations (version) VALUES ('20120307175658');

INSERT INTO schema_migrations (version) VALUES ('20120307232457');

INSERT INTO schema_migrations (version) VALUES ('20120315211955');

INSERT INTO schema_migrations (version) VALUES ('20120315220809');

INSERT INTO schema_migrations (version) VALUES ('20120323105044');

INSERT INTO schema_migrations (version) VALUES ('20120323115733');

INSERT INTO schema_migrations (version) VALUES ('20120323181147');

INSERT INTO schema_migrations (version) VALUES ('20120324025600');

INSERT INTO schema_migrations (version) VALUES ('20120324094455');

INSERT INTO schema_migrations (version) VALUES ('20120324100545');

INSERT INTO schema_migrations (version) VALUES ('20120417190549');

INSERT INTO schema_migrations (version) VALUES ('20120418231658');

INSERT INTO schema_migrations (version) VALUES ('20120521225350');

INSERT INTO schema_migrations (version) VALUES ('20120526101510');

INSERT INTO schema_migrations (version) VALUES ('20120614160337');

INSERT INTO schema_migrations (version) VALUES ('20120625212801');

INSERT INTO schema_migrations (version) VALUES ('20130114094100');

INSERT INTO schema_migrations (version) VALUES ('20130115032717');

INSERT INTO schema_migrations (version) VALUES ('20130115042245');

INSERT INTO schema_migrations (version) VALUES ('20130117110750');

INSERT INTO schema_migrations (version) VALUES ('20130117110817');

INSERT INTO schema_migrations (version) VALUES ('20130117111202');

INSERT INTO schema_migrations (version) VALUES ('20130118064024');

INSERT INTO schema_migrations (version) VALUES ('20130427160522');

INSERT INTO schema_migrations (version) VALUES ('20130429205209');

INSERT INTO schema_migrations (version) VALUES ('20130429205707');

INSERT INTO schema_migrations (version) VALUES ('20130606042505');

INSERT INTO schema_migrations (version) VALUES ('20130705092519');

INSERT INTO schema_migrations (version) VALUES ('20140718095222');

INSERT INTO schema_migrations (version) VALUES ('20150919060031');

INSERT INTO schema_migrations (version) VALUES ('20160208190731');

INSERT INTO schema_migrations (version) VALUES ('20160403092926');

INSERT INTO schema_migrations (version) VALUES ('20160531111906');

INSERT INTO schema_migrations (version) VALUES ('20160607005457');

INSERT INTO schema_migrations (version) VALUES ('20160614042818');

INSERT INTO schema_migrations (version) VALUES ('20160615215212');

INSERT INTO schema_migrations (version) VALUES ('20180603015430');

