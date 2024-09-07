--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 16.4

-- Started on 2024-09-06 19:45:50

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
-- TOC entry 265 (class 1255 OID 16612)
-- Name: adicionar_item_ao_inventario(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.adicionar_item_ao_inventario(p_idpersonagem integer, p_iditem integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_idInventario INTEGER;
    v_capAtual INTEGER;
    v_capMax INTEGER;
BEGIN
    -- ObtÃ©m o id do inventÃ¡rio do personagem
    SELECT idInventario INTO v_idInventario
    FROM inventario
    WHERE idPersonagem = p_idPersonagem;

    -- Verifica se o inventÃ¡rio foi encontrado
    IF v_idInventario IS NULL THEN
        RETURN 'InventÃ¡rio nÃ£o encontrado para o personagem.';
    END IF;

    -- Verifica a capacidade atual e mÃ¡xima do inventÃ¡rio
    SELECT capAtual, capMax INTO v_capAtual, v_capMax
    FROM inventario
    WHERE idInventario = v_idInventario;

    -- Verifica se hÃ¡ espaÃ§o suficiente no inventÃ¡rio
    IF v_capAtual >= v_capMax THEN
        RETURN 'O inventÃ¡rio estÃ¡ cheio.';
    END IF;

    -- Adiciona o item ao inventÃ¡rio
    INSERT INTO item_inventario (idInventario, idItem)
    VALUES (v_idInventario, p_idItem);

    -- Atualiza a capacidade atual do inventÃ¡rio
    UPDATE inventario
    SET capAtual = capAtual + 1
    WHERE idInventario = v_idInventario;

    RETURN 'Item adicionado com sucesso ao inventÃ¡rio.';
END;
$$;


ALTER FUNCTION public.adicionar_item_ao_inventario(p_idpersonagem integer, p_iditem integer) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 16611)
-- Name: criar_inventario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.criar_inventario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insere um novo inventÃ¡rio para o personagem recÃ©m-criado
    INSERT INTO inventario (idPersonagem)
    VALUES (NEW.idPersonagem);
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.criar_inventario() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 246 (class 1259 OID 16697)
-- Name: animal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.animal (
    idanimal integer NOT NULL,
    idpersonagem integer NOT NULL
);


ALTER TABLE public.animal OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16696)
-- Name: animal_idanimal_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.animal_idanimal_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.animal_idanimal_seq OWNER TO postgres;

--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 245
-- Name: animal_idanimal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.animal_idanimal_seq OWNED BY public.animal.idanimal;


--
-- TOC entry 225 (class 1259 OID 16528)
-- Name: arma; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.arma (
    idarma integer NOT NULL,
    iditem integer NOT NULL,
    descricao text DEFAULT ''::text,
    addano integer NOT NULL
);


ALTER TABLE public.arma OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 16527)
-- Name: arma_idarma_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.arma_idarma_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.arma_idarma_seq OWNER TO postgres;

--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 224
-- Name: arma_idarma_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.arma_idarma_seq OWNED BY public.arma.idarma;


--
-- TOC entry 248 (class 1259 OID 16709)
-- Name: bestante; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bestante (
    idbestante integer NOT NULL,
    idpersonagem integer NOT NULL,
    agilidade integer,
    nado integer,
    voo integer
);


ALTER TABLE public.bestante OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16708)
-- Name: bestante_idbestante_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bestante_idbestante_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bestante_idbestante_seq OWNER TO postgres;

--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 247
-- Name: bestante_idbestante_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bestante_idbestante_seq OWNED BY public.bestante.idbestante;


--
-- TOC entry 231 (class 1259 OID 16570)
-- Name: compartimento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compartimento (
    idcompartimento integer NOT NULL,
    iditem integer NOT NULL,
    adcapmax integer NOT NULL
);


ALTER TABLE public.compartimento OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16569)
-- Name: compartimento_idcompartimento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compartimento_idcompartimento_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.compartimento_idcompartimento_seq OWNER TO postgres;

--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 230
-- Name: compartimento_idcompartimento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compartimento_idcompartimento_seq OWNED BY public.compartimento.idcompartimento;


--
-- TOC entry 235 (class 1259 OID 16600)
-- Name: construtor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.construtor (
    idconstrutor integer NOT NULL,
    iditem integer NOT NULL
);


ALTER TABLE public.construtor OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16599)
-- Name: construtor_idconstrutor_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.construtor_idconstrutor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.construtor_idconstrutor_seq OWNER TO postgres;

--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 234
-- Name: construtor_idconstrutor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.construtor_idconstrutor_seq OWNED BY public.construtor.idconstrutor;


--
-- TOC entry 227 (class 1259 OID 16543)
-- Name: consumivel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consumivel (
    idconsumivel integer NOT NULL,
    iditem integer NOT NULL,
    adhid integer,
    adnut integer,
    adsta integer,
    adhp integer,
    adcalor integer
);


ALTER TABLE public.consumivel OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16542)
-- Name: consumivel_idconsumivel_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.consumivel_idconsumivel_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consumivel_idconsumivel_seq OWNER TO postgres;

--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 226
-- Name: consumivel_idconsumivel_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.consumivel_idconsumivel_seq OWNED BY public.consumivel.idconsumivel;


--
-- TOC entry 241 (class 1259 OID 16649)
-- Name: distrito; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.distrito (
    iddistrito integer NOT NULL,
    idpersonagem integer NOT NULL,
    popularidade integer DEFAULT 0,
    agilidade integer,
    forca integer,
    nado integer,
    carisma integer,
    combate integer,
    perspicacia integer,
    furtividade integer,
    sobrevivencia integer,
    precisao integer,
    descricao text DEFAULT ''::text
);


ALTER TABLE public.distrito OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16648)
-- Name: distrito_iddistrito_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.distrito_iddistrito_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.distrito_iddistrito_seq OWNER TO postgres;

--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 240
-- Name: distrito_iddistrito_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.distrito_iddistrito_seq OWNED BY public.distrito.iddistrito;


--
-- TOC entry 243 (class 1259 OID 16665)
-- Name: inventario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventario (
    idinventario integer NOT NULL,
    idpersonagem integer NOT NULL,
    capmax integer DEFAULT 2,
    capatual integer DEFAULT 0
);


ALTER TABLE public.inventario OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 16664)
-- Name: inventario_idinventario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventario_idinventario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventario_idinventario_seq OWNER TO postgres;

--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 242
-- Name: inventario_idinventario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventario_idinventario_seq OWNED BY public.inventario.idinventario;


--
-- TOC entry 221 (class 1259 OID 16499)
-- Name: item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item (
    iditem integer NOT NULL,
    nome character varying(50) NOT NULL
);


ALTER TABLE public.item OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16498)
-- Name: item_iditem_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.item_iditem_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_iditem_seq OWNER TO postgres;

--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 220
-- Name: item_iditem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.item_iditem_seq OWNED BY public.item.iditem;


--
-- TOC entry 252 (class 1259 OID 16740)
-- Name: item_inventario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_inventario (
    iditeminventario integer NOT NULL,
    idinventario integer NOT NULL,
    iditem integer NOT NULL
);


ALTER TABLE public.item_inventario OWNER TO postgres;

--
-- TOC entry 251 (class 1259 OID 16739)
-- Name: item_inventario_iditeminventario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.item_inventario_iditeminventario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_inventario_iditeminventario_seq OWNER TO postgres;

--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 251
-- Name: item_inventario_iditeminventario_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.item_inventario_iditeminventario_seq OWNED BY public.item_inventario.iditeminventario;


--
-- TOC entry 229 (class 1259 OID 16555)
-- Name: legivel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.legivel (
    idlegivel integer NOT NULL,
    iditem integer NOT NULL,
    conteudo text DEFAULT ''::text
);


ALTER TABLE public.legivel OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16554)
-- Name: legivel_idlegivel_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.legivel_idlegivel_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.legivel_idlegivel_seq OWNER TO postgres;

--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 228
-- Name: legivel_idlegivel_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.legivel_idlegivel_seq OWNED BY public.legivel.idlegivel;


--
-- TOC entry 215 (class 1259 OID 16400)
-- Name: mapa; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mapa (
    idmapa integer NOT NULL,
    nomem character varying(50) NOT NULL,
    descricao text DEFAULT ''::text
);


ALTER TABLE public.mapa OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16399)
-- Name: mapa_idmapa_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mapa_idmapa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mapa_idmapa_seq OWNER TO postgres;

--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 214
-- Name: mapa_idmapa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mapa_idmapa_seq OWNED BY public.mapa.idmapa;


--
-- TOC entry 237 (class 1259 OID 16617)
-- Name: personagem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personagem (
    idpersonagem integer NOT NULL,
    idsala integer DEFAULT 1,
    tipop character varying(25),
    nomep character varying(50) NOT NULL,
    hpmax integer DEFAULT 100,
    hpatual integer DEFAULT 100
);


ALTER TABLE public.personagem OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16616)
-- Name: personagem_idpersonagem_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personagem_idpersonagem_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personagem_idpersonagem_seq OWNER TO postgres;

--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 236
-- Name: personagem_idpersonagem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personagem_idpersonagem_seq OWNED BY public.personagem.idpersonagem;


--
-- TOC entry 244 (class 1259 OID 16678)
-- Name: personagem_jogavel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personagem_jogavel (
    idpersonagem integer NOT NULL,
    iddistrito integer
);


ALTER TABLE public.personagem_jogavel OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16410)
-- Name: regiao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.regiao (
    idregiao integer NOT NULL,
    idmapa integer,
    nomer character varying(50) NOT NULL,
    tempr real NOT NULL,
    descricao text DEFAULT ''::text
);


ALTER TABLE public.regiao OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16409)
-- Name: regiao_idregiao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.regiao_idregiao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.regiao_idregiao_seq OWNER TO postgres;

--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 216
-- Name: regiao_idregiao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.regiao_idregiao_seq OWNED BY public.regiao.idregiao;


--
-- TOC entry 219 (class 1259 OID 16425)
-- Name: sala; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sala (
    idsala integer NOT NULL,
    idregiao integer,
    nomes character varying(50) NOT NULL,
    descricao text DEFAULT ''::text
);


ALTER TABLE public.sala OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16424)
-- Name: sala_idsala_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sala_idsala_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sala_idsala_seq OWNER TO postgres;

--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 218
-- Name: sala_idsala_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sala_idsala_seq OWNED BY public.sala.idsala;


--
-- TOC entry 250 (class 1259 OID 16721)
-- Name: tributo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tributo (
    idtributo integer NOT NULL,
    idpersonagem integer NOT NULL,
    iddistrito integer NOT NULL,
    statust boolean DEFAULT false
);


ALTER TABLE public.tributo OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 16720)
-- Name: tributo_idtributo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tributo_idtributo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tributo_idtributo_seq OWNER TO postgres;

--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 249
-- Name: tributo_idtributo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tributo_idtributo_seq OWNED BY public.tributo.idtributo;


--
-- TOC entry 233 (class 1259 OID 16582)
-- Name: utilidade; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.utilidade (
    idutilidade integer NOT NULL,
    iditem integer NOT NULL,
    nome character varying(50) NOT NULL,
    descricao text DEFAULT ''::text,
    geraitem boolean DEFAULT false,
    capturainimigo boolean DEFAULT false,
    geracalor boolean DEFAULT false
);


ALTER TABLE public.utilidade OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16581)
-- Name: utilidade_idutilidade_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.utilidade_idutilidade_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.utilidade_idutilidade_seq OWNER TO postgres;

--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 232
-- Name: utilidade_idutilidade_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.utilidade_idutilidade_seq OWNED BY public.utilidade.idutilidade;


--
-- TOC entry 223 (class 1259 OID 16513)
-- Name: vestimenta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vestimenta (
    idvestimenta integer NOT NULL,
    iditem integer NOT NULL,
    descricao text DEFAULT ''::text,
    adcalor integer NOT NULL
);


ALTER TABLE public.vestimenta OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16512)
-- Name: vestimenta_idvestimenta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vestimenta_idvestimenta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vestimenta_idvestimenta_seq OWNER TO postgres;

--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 222
-- Name: vestimenta_idvestimenta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vestimenta_idvestimenta_seq OWNED BY public.vestimenta.idvestimenta;


--
-- TOC entry 239 (class 1259 OID 16632)
-- Name: vitalidade; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vitalidade (
    idvitalidade integer NOT NULL,
    idpersonagem integer NOT NULL,
    nutricao integer DEFAULT 100,
    hidratacao integer DEFAULT 100,
    stamina integer DEFAULT 100,
    calor integer DEFAULT 50,
    dano integer DEFAULT 0
);


ALTER TABLE public.vitalidade OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 16631)
-- Name: vitalidade_idvitalidade_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vitalidade_idvitalidade_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vitalidade_idvitalidade_seq OWNER TO postgres;

--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 238
-- Name: vitalidade_idvitalidade_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vitalidade_idvitalidade_seq OWNED BY public.vitalidade.idvitalidade;


--
-- TOC entry 3306 (class 2604 OID 16700)
-- Name: animal idanimal; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal ALTER COLUMN idanimal SET DEFAULT nextval('public.animal_idanimal_seq'::regclass);


--
-- TOC entry 3278 (class 2604 OID 16531)
-- Name: arma idarma; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma ALTER COLUMN idarma SET DEFAULT nextval('public.arma_idarma_seq'::regclass);


--
-- TOC entry 3307 (class 2604 OID 16712)
-- Name: bestante idbestante; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bestante ALTER COLUMN idbestante SET DEFAULT nextval('public.bestante_idbestante_seq'::regclass);


--
-- TOC entry 3283 (class 2604 OID 16573)
-- Name: compartimento idcompartimento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartimento ALTER COLUMN idcompartimento SET DEFAULT nextval('public.compartimento_idcompartimento_seq'::regclass);


--
-- TOC entry 3289 (class 2604 OID 16603)
-- Name: construtor idconstrutor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.construtor ALTER COLUMN idconstrutor SET DEFAULT nextval('public.construtor_idconstrutor_seq'::regclass);


--
-- TOC entry 3280 (class 2604 OID 16546)
-- Name: consumivel idconsumivel; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumivel ALTER COLUMN idconsumivel SET DEFAULT nextval('public.consumivel_idconsumivel_seq'::regclass);


--
-- TOC entry 3300 (class 2604 OID 16652)
-- Name: distrito iddistrito; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distrito ALTER COLUMN iddistrito SET DEFAULT nextval('public.distrito_iddistrito_seq'::regclass);


--
-- TOC entry 3303 (class 2604 OID 16668)
-- Name: inventario idinventario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario ALTER COLUMN idinventario SET DEFAULT nextval('public.inventario_idinventario_seq'::regclass);


--
-- TOC entry 3275 (class 2604 OID 16502)
-- Name: item iditem; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item ALTER COLUMN iditem SET DEFAULT nextval('public.item_iditem_seq'::regclass);


--
-- TOC entry 3310 (class 2604 OID 16743)
-- Name: item_inventario iditeminventario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_inventario ALTER COLUMN iditeminventario SET DEFAULT nextval('public.item_inventario_iditeminventario_seq'::regclass);


--
-- TOC entry 3281 (class 2604 OID 16558)
-- Name: legivel idlegivel; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legivel ALTER COLUMN idlegivel SET DEFAULT nextval('public.legivel_idlegivel_seq'::regclass);


--
-- TOC entry 3269 (class 2604 OID 16403)
-- Name: mapa idmapa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mapa ALTER COLUMN idmapa SET DEFAULT nextval('public.mapa_idmapa_seq'::regclass);


--
-- TOC entry 3290 (class 2604 OID 16620)
-- Name: personagem idpersonagem; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem ALTER COLUMN idpersonagem SET DEFAULT nextval('public.personagem_idpersonagem_seq'::regclass);


--
-- TOC entry 3271 (class 2604 OID 16413)
-- Name: regiao idregiao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regiao ALTER COLUMN idregiao SET DEFAULT nextval('public.regiao_idregiao_seq'::regclass);


--
-- TOC entry 3273 (class 2604 OID 16428)
-- Name: sala idsala; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sala ALTER COLUMN idsala SET DEFAULT nextval('public.sala_idsala_seq'::regclass);


--
-- TOC entry 3308 (class 2604 OID 16724)
-- Name: tributo idtributo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tributo ALTER COLUMN idtributo SET DEFAULT nextval('public.tributo_idtributo_seq'::regclass);


--
-- TOC entry 3284 (class 2604 OID 16585)
-- Name: utilidade idutilidade; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilidade ALTER COLUMN idutilidade SET DEFAULT nextval('public.utilidade_idutilidade_seq'::regclass);


--
-- TOC entry 3276 (class 2604 OID 16516)
-- Name: vestimenta idvestimenta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vestimenta ALTER COLUMN idvestimenta SET DEFAULT nextval('public.vestimenta_idvestimenta_seq'::regclass);


--
-- TOC entry 3294 (class 2604 OID 16635)
-- Name: vitalidade idvitalidade; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitalidade ALTER COLUMN idvitalidade SET DEFAULT nextval('public.vitalidade_idvitalidade_seq'::regclass);


--
-- TOC entry 3546 (class 0 OID 16697)
-- Dependencies: 246
-- Data for Name: animal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.animal (idanimal, idpersonagem) FROM stdin;
\.


--
-- TOC entry 3525 (class 0 OID 16528)
-- Dependencies: 225
-- Data for Name: arma; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.arma (idarma, iditem, descricao, addano) FROM stdin;
1	3	Arco feito de galhos e corda	5
2	4	Arco feito de metal	10
3	12	Flecha feita de galho e pedra lascada	5
4	13	Flecha feita de metal	10
5	5	Tridente longo feito de metal	20
6	6	Lança feita de metal	15
7	7	Lança feita de galho e pedra lascada	10
8	8	Espada grande feita de aço	20
9	9	Faca pequena feita de aço	5
\.


--
-- TOC entry 3548 (class 0 OID 16709)
-- Dependencies: 248
-- Data for Name: bestante; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bestante (idbestante, idpersonagem, agilidade, nado, voo) FROM stdin;
\.


--
-- TOC entry 3531 (class 0 OID 16570)
-- Dependencies: 231
-- Data for Name: compartimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compartimento (idcompartimento, iditem, adcapmax) FROM stdin;
1	30	10
2	31	20
\.


--
-- TOC entry 3535 (class 0 OID 16600)
-- Dependencies: 235
-- Data for Name: construtor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.construtor (idconstrutor, iditem) FROM stdin;
\.


--
-- TOC entry 3527 (class 0 OID 16543)
-- Dependencies: 227
-- Data for Name: consumivel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consumivel (idconsumivel, iditem, adhid, adnut, adsta, adhp, adcalor) FROM stdin;
1	17	10	10	10	10	5
2	18	20	20	15	15	10
3	19	15	15	10	10	5
4	20	5	10	0	5	0
5	21	10	15	0	10	0
6	22	20	20	20	20	0
7	23	0	10	0	10	0
8	24	0	0	10	5	0
\.


--
-- TOC entry 3541 (class 0 OID 16649)
-- Dependencies: 241
-- Data for Name: distrito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.distrito (iddistrito, idpersonagem, popularidade, agilidade, forca, nado, carisma, combate, perspicacia, furtividade, sobrevivencia, precisao, descricao) FROM stdin;
\.


--
-- TOC entry 3543 (class 0 OID 16665)
-- Dependencies: 243
-- Data for Name: inventario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventario (idinventario, idpersonagem, capmax, capatual) FROM stdin;
\.


--
-- TOC entry 3521 (class 0 OID 16499)
-- Dependencies: 221
-- Data for Name: item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item (iditem, nome) FROM stdin;
1	Uniforme
2	Casaco
3	Arco Artesanal
4	Arco Profissional
5	Tridente
6	Lança Profissional
7	Lança Artesanal
8	Espada
9	Faca
10	Galho Seco
11	Galho Longo
12	Flecha Artesanal
13	Flecha Profissional
14	Pedra
15	Pedra Lascada
16	Corda
17	Carne Crua
18	Carne Assada
19	Sopa
20	Amora
21	Amora Cadeado
22	Ração
23	Barra de Energia
24	Água
25	Armadilha Pequena
26	Armadilha Grande
27	Fogueira Grande
28	Fogueira Pequena
29	Bilhete
30	Mochila Pequena
31	Mochila Grande
\.


--
-- TOC entry 3552 (class 0 OID 16740)
-- Dependencies: 252
-- Data for Name: item_inventario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item_inventario (iditeminventario, idinventario, iditem) FROM stdin;
\.


--
-- TOC entry 3529 (class 0 OID 16555)
-- Dependencies: 229
-- Data for Name: legivel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.legivel (idlegivel, iditem, conteudo) FROM stdin;
1	29	Bilhete informativo que pode conter informações úteis para o jogador
\.


--
-- TOC entry 3515 (class 0 OID 16400)
-- Dependencies: 215
-- Data for Name: mapa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mapa (idmapa, nomem, descricao) FROM stdin;
1	Centro de Treinamento	O Centro de Treinamento é um arranha-céu onde os tributos moram, treinam e se preparam para os Jogos Vorazes
2	Arena	Aqui é onde os 24 tributos se enfrentarão até que reste apenas um vencedor
\.


--
-- TOC entry 3537 (class 0 OID 16617)
-- Dependencies: 237
-- Data for Name: personagem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personagem (idpersonagem, idsala, tipop, nomep, hpmax, hpatual) FROM stdin;
1	1	nj	Dominic	100	100
2	1	nj	Pandora	100	100
3	1	nj	Octavio	100	100
4	1	nj	June	100	100
5	1	nj	Pierre	100	100
6	1	nj	Gabrielle	100	100
7	1	nj	Icaro	100	100
8	1	nj	Zoe	100	100
10	1	nj	Marta	100	100
11	1	nj	Daniel	100	100
12	1	nj	Lucian	100	100
13	1	nj	Charlotte	100	100
14	1	nj	Benedict	100	100
15	1	nj	Daphine	100	100
16	1	nj	Maximilian	100	100
17	1	nj	Stefani	100	100
18	1	nj	Damon	100	100
19	1	nj	Selene	100	100
20	1	nj	Walter	100	100
21	1	nj	Skyler	100	100
22	1	nj	Nico	100	100
23	1	nj	Agnes	100	100
24	1	nj	Leslie	100	100
25	1	nj	Jesse	100	100
26	1	nj	Ceasar Flickerman	100	100
27	1	nj	Cashmere	100	100
28	1	nj	Brutus	100	100
29	1	nj	Beetee	100	100
30	1	nj	Finnick	100	100
31	1	nj	Columbae	100	100
32	1	nj	Hardie	100	100
33	1	nj	Johanna	100	100
34	1	nj	Woof	100	100
35	1	nj	Driff	100	100
36	1	nj	Magnus	100	100
37	1	nj	Seeder	100	100
38	1	nj	Haymitch	100	100
39	1	nj	Jennifer	100	100
40	1	nj	Josh	100	100
41	1	nj	Liam	100	100
42	1	nj	Sam	100	100
43	1	nj	Willow	100	100
\.


--
-- TOC entry 3544 (class 0 OID 16678)
-- Dependencies: 244
-- Data for Name: personagem_jogavel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personagem_jogavel (idpersonagem, iddistrito) FROM stdin;
\.


--
-- TOC entry 3517 (class 0 OID 16410)
-- Dependencies: 217
-- Data for Name: regiao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.regiao (idregiao, idmapa, nomer, tempr, descricao) FROM stdin;
1	1	Andar de Capacitação	24	O Andar de Capacitação é o lugar onde os tributos podem treinar e ter aulas
2	1	Andar Moradia	24	O Andar Moradia é onde os tributos e seus tutores comem e dormem
3	1	Andar Mídia	24	O Andar Mídia é onde os tributos fazem as suas entrevistas para a TV
\.


--
-- TOC entry 3519 (class 0 OID 16425)
-- Dependencies: 219
-- Data for Name: sala; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sala (idsala, idregiao, nomes, descricao) FROM stdin;
1	1	Hall de Entrada	Aqui é onde você irá poder fazer aulas e praticar
2	1	Aula de Combate	Pratique combate corpo a corpo e aumente a sua pontuação de combate
3	1	Aula de Técnicas de Sobrevivência	Aprenda sobre componentes do mundo natural e aumente sua pontuação de sobrevivência
4	1	Aula de Mira	Pratique a sua mira e aumente a sua pontuação de precisão
5	1	Aula de Natação	Pratique natação e aumente a sua pontuação de nado
6	1	Aula de Camuflagem	Aprenda sobre camuflagem e aumente a sua pontuação de furtividade
7	1	Área de Socialização	Aproveite a Área de Socialização para tentar fazer aliados de outros distritos
8	2	Sala de Jantar	Aqui é onde fará suas refeições, onde poderá pedir conselhos e conversar com seu colega de distrito
9	2	Dormitório	Aqui é onde você poderá recarregar suas energias para o próximo dia
10	3	Sala de Entrevistas	É aqui onde você fará a sua entrevista que te apresentará para todo o povo de Panem.
\.


--
-- TOC entry 3550 (class 0 OID 16721)
-- Dependencies: 250
-- Data for Name: tributo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tributo (idtributo, idpersonagem, iddistrito, statust) FROM stdin;
\.


--
-- TOC entry 3533 (class 0 OID 16582)
-- Dependencies: 233
-- Data for Name: utilidade; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilidade (idutilidade, iditem, nome, descricao, geraitem, capturainimigo, geracalor) FROM stdin;
\.


--
-- TOC entry 3523 (class 0 OID 16513)
-- Dependencies: 223
-- Data for Name: vestimenta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vestimenta (idvestimenta, iditem, descricao, adcalor) FROM stdin;
1	1	Vestimenta padrão de todos os tributos na Arena	5
2	2	Um casaco resistente que te protegerá contra o frio	20
\.


--
-- TOC entry 3539 (class 0 OID 16632)
-- Dependencies: 239
-- Data for Name: vitalidade; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vitalidade (idvitalidade, idpersonagem, nutricao, hidratacao, stamina, calor, dano) FROM stdin;
\.


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 245
-- Name: animal_idanimal_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.animal_idanimal_seq', 1, false);


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 224
-- Name: arma_idarma_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.arma_idarma_seq', 9, true);


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 247
-- Name: bestante_idbestante_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bestante_idbestante_seq', 1, false);


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 230
-- Name: compartimento_idcompartimento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compartimento_idcompartimento_seq', 2, true);


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 234
-- Name: construtor_idconstrutor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.construtor_idconstrutor_seq', 1, false);


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 226
-- Name: consumivel_idconsumivel_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.consumivel_idconsumivel_seq', 8, true);


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 240
-- Name: distrito_iddistrito_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.distrito_iddistrito_seq', 1, false);


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 242
-- Name: inventario_idinventario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventario_idinventario_seq', 1, false);


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 220
-- Name: item_iditem_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_iditem_seq', 31, true);


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 251
-- Name: item_inventario_iditeminventario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_inventario_iditeminventario_seq', 1, false);


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 228
-- Name: legivel_idlegivel_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.legivel_idlegivel_seq', 1, true);


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 214
-- Name: mapa_idmapa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mapa_idmapa_seq', 2, true);


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 236
-- Name: personagem_idpersonagem_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personagem_idpersonagem_seq', 43, true);


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 216
-- Name: regiao_idregiao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.regiao_idregiao_seq', 3, true);


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 218
-- Name: sala_idsala_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sala_idsala_seq', 10, true);


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 249
-- Name: tributo_idtributo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tributo_idtributo_seq', 1, false);


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 232
-- Name: utilidade_idutilidade_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utilidade_idutilidade_seq', 1, false);


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 222
-- Name: vestimenta_idvestimenta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vestimenta_idvestimenta_seq', 2, true);


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 238
-- Name: vitalidade_idvitalidade_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitalidade_idvitalidade_seq', 1, false);


--
-- TOC entry 3344 (class 2606 OID 16702)
-- Name: animal animal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_pkey PRIMARY KEY (idanimal);


--
-- TOC entry 3322 (class 2606 OID 16536)
-- Name: arma arma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma
    ADD CONSTRAINT arma_pkey PRIMARY KEY (idarma);


--
-- TOC entry 3346 (class 2606 OID 16714)
-- Name: bestante bestante_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bestante
    ADD CONSTRAINT bestante_pkey PRIMARY KEY (idbestante);


--
-- TOC entry 3328 (class 2606 OID 16575)
-- Name: compartimento compartimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartimento
    ADD CONSTRAINT compartimento_pkey PRIMARY KEY (idcompartimento);


--
-- TOC entry 3332 (class 2606 OID 16605)
-- Name: construtor construtor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.construtor
    ADD CONSTRAINT construtor_pkey PRIMARY KEY (idconstrutor);


--
-- TOC entry 3324 (class 2606 OID 16548)
-- Name: consumivel consumivel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumivel
    ADD CONSTRAINT consumivel_pkey PRIMARY KEY (idconsumivel);


--
-- TOC entry 3338 (class 2606 OID 16658)
-- Name: distrito distrito_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distrito
    ADD CONSTRAINT distrito_pkey PRIMARY KEY (iddistrito);


--
-- TOC entry 3340 (class 2606 OID 16672)
-- Name: inventario inventario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_pkey PRIMARY KEY (idinventario);


--
-- TOC entry 3350 (class 2606 OID 16745)
-- Name: item_inventario item_inventario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_inventario
    ADD CONSTRAINT item_inventario_pkey PRIMARY KEY (iditeminventario);


--
-- TOC entry 3318 (class 2606 OID 16504)
-- Name: item item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pkey PRIMARY KEY (iditem);


--
-- TOC entry 3326 (class 2606 OID 16563)
-- Name: legivel legivel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legivel
    ADD CONSTRAINT legivel_pkey PRIMARY KEY (idlegivel);


--
-- TOC entry 3312 (class 2606 OID 16408)
-- Name: mapa mapa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mapa
    ADD CONSTRAINT mapa_pkey PRIMARY KEY (idmapa);


--
-- TOC entry 3342 (class 2606 OID 16682)
-- Name: personagem_jogavel personagem_jogavel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem_jogavel
    ADD CONSTRAINT personagem_jogavel_pkey PRIMARY KEY (idpersonagem);


--
-- TOC entry 3334 (class 2606 OID 16625)
-- Name: personagem personagem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem
    ADD CONSTRAINT personagem_pkey PRIMARY KEY (idpersonagem);


--
-- TOC entry 3314 (class 2606 OID 16418)
-- Name: regiao regiao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regiao
    ADD CONSTRAINT regiao_pkey PRIMARY KEY (idregiao);


--
-- TOC entry 3316 (class 2606 OID 16433)
-- Name: sala sala_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sala
    ADD CONSTRAINT sala_pkey PRIMARY KEY (idsala);


--
-- TOC entry 3348 (class 2606 OID 16727)
-- Name: tributo tributo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tributo
    ADD CONSTRAINT tributo_pkey PRIMARY KEY (idtributo);


--
-- TOC entry 3330 (class 2606 OID 16593)
-- Name: utilidade utilidade_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilidade
    ADD CONSTRAINT utilidade_pkey PRIMARY KEY (idutilidade);


--
-- TOC entry 3320 (class 2606 OID 16521)
-- Name: vestimenta vestimenta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vestimenta
    ADD CONSTRAINT vestimenta_pkey PRIMARY KEY (idvestimenta);


--
-- TOC entry 3336 (class 2606 OID 16642)
-- Name: vitalidade vitalidade_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitalidade
    ADD CONSTRAINT vitalidade_pkey PRIMARY KEY (idvitalidade);


--
-- TOC entry 3371 (class 2620 OID 16763)
-- Name: personagem_jogavel trigger_criar_inventario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_criar_inventario AFTER INSERT ON public.personagem_jogavel FOR EACH ROW EXECUTE FUNCTION public.criar_inventario();


--
-- TOC entry 3365 (class 2606 OID 16703)
-- Name: animal animal_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3354 (class 2606 OID 16537)
-- Name: arma arma_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma
    ADD CONSTRAINT arma_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3366 (class 2606 OID 16715)
-- Name: bestante bestante_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bestante
    ADD CONSTRAINT bestante_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3357 (class 2606 OID 16576)
-- Name: compartimento compartimento_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartimento
    ADD CONSTRAINT compartimento_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3359 (class 2606 OID 16606)
-- Name: construtor construtor_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.construtor
    ADD CONSTRAINT construtor_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3355 (class 2606 OID 16549)
-- Name: consumivel consumivel_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumivel
    ADD CONSTRAINT consumivel_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3362 (class 2606 OID 16659)
-- Name: distrito distrito_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distrito
    ADD CONSTRAINT distrito_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3363 (class 2606 OID 16673)
-- Name: inventario inventario_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3369 (class 2606 OID 16746)
-- Name: item_inventario item_inventario_idinventario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_inventario
    ADD CONSTRAINT item_inventario_idinventario_fkey FOREIGN KEY (idinventario) REFERENCES public.inventario(idinventario) ON DELETE CASCADE;


--
-- TOC entry 3370 (class 2606 OID 16751)
-- Name: item_inventario item_inventario_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_inventario
    ADD CONSTRAINT item_inventario_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3356 (class 2606 OID 16564)
-- Name: legivel legivel_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legivel
    ADD CONSTRAINT legivel_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3360 (class 2606 OID 16626)
-- Name: personagem personagem_idsala_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem
    ADD CONSTRAINT personagem_idsala_fkey FOREIGN KEY (idsala) REFERENCES public.sala(idsala);


--
-- TOC entry 3364 (class 2606 OID 16683)
-- Name: personagem_jogavel personagem_jogavel_iddistrito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem_jogavel
    ADD CONSTRAINT personagem_jogavel_iddistrito_fkey FOREIGN KEY (iddistrito) REFERENCES public.distrito(iddistrito);


--
-- TOC entry 3351 (class 2606 OID 16419)
-- Name: regiao regiao_idmapa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regiao
    ADD CONSTRAINT regiao_idmapa_fkey FOREIGN KEY (idmapa) REFERENCES public.mapa(idmapa);


--
-- TOC entry 3352 (class 2606 OID 16434)
-- Name: sala sala_idregiao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sala
    ADD CONSTRAINT sala_idregiao_fkey FOREIGN KEY (idregiao) REFERENCES public.regiao(idregiao);


--
-- TOC entry 3367 (class 2606 OID 16733)
-- Name: tributo tributo_iddistrito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tributo
    ADD CONSTRAINT tributo_iddistrito_fkey FOREIGN KEY (iddistrito) REFERENCES public.distrito(iddistrito) ON DELETE CASCADE;


--
-- TOC entry 3368 (class 2606 OID 16728)
-- Name: tributo tributo_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tributo
    ADD CONSTRAINT tributo_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3358 (class 2606 OID 16594)
-- Name: utilidade utilidade_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilidade
    ADD CONSTRAINT utilidade_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3353 (class 2606 OID 16522)
-- Name: vestimenta vestimenta_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vestimenta
    ADD CONSTRAINT vestimenta_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3361 (class 2606 OID 16643)
-- Name: vitalidade vitalidade_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitalidade
    ADD CONSTRAINT vitalidade_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


-- Completed on 2024-09-06 19:45:51

--
-- PostgreSQL database dump complete
--

