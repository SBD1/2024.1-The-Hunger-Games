--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 16.4

-- Started on 2024-09-08 16:08:26

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
-- TOC entry 286 (class 1255 OID 16612)
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
-- TOC entry 287 (class 1255 OID 17033)
-- Name: atualizar_capitulo_usuario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atualizar_capitulo_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Atualiza o idcapitulo na tabela usuario
    UPDATE usuario
    SET idcapitulo = NEW.idcapitulo
    WHERE id = NEW.idusuario;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.atualizar_capitulo_usuario() OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 16998)
-- Name: atualizar_idcapitulo(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atualizar_idcapitulo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Atualizar o idcapitulo do usu rio com base no idpersonagem
    UPDATE usuario
    SET idcapitulo = (
        SELECT idcapitulo_inicial
        FROM historia
        WHERE idpersonagem = NEW.idpersonagem
    )
    WHERE id = NEW.id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.atualizar_idcapitulo() OWNER TO postgres;

--
-- TOC entry 288 (class 1255 OID 17055)
-- Name: atualizar_vitalidade(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.atualizar_vitalidade() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Atualiza a tabela vitalidade com os valores da tabela distrito para o idusuario correspondente
    UPDATE vitalidade
    SET popularidade = d.popularidade,
        agilidade = d.agilidade,
        forca = d.forca,
        nado = d.nado,
        carisma = d.carisma,
        combate = d.combate,
        perspicacia = d.perspicacia,
        furtividade = d.furtividade,
        sobrevivencia = d.sobrevivencia,
        precisao = d.precisao
    FROM distrito d
    WHERE d.idpersonagem = NEW.idpersonagem
      AND vitalidade.idusuario = NEW.id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.atualizar_vitalidade() OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 16611)
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

--
-- TOC entry 284 (class 1255 OID 17053)
-- Name: criar_vitalidade(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.criar_vitalidade() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Insere uma nova linha em vitalidade usando o idusuario do registro rec‚m-inserido
    INSERT INTO vitalidade (idusuario, nutricao, hidratacao, stamina, calor, dano)
    VALUES (NEW.id, 100, 100, 100, 50, 0); 

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.criar_vitalidade() OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 17025)
-- Name: excluir_localizacao_anterior(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.excluir_localizacao_anterior() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Exclui a linha da tabela localizacao para o mesmo idusuario, mas com idcapitulo diferente do novo
    DELETE FROM localizacao
    WHERE idusuario = NEW.idusuario
      AND idcapitulo <> NEW.idcapitulo;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.excluir_localizacao_anterior() OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 17043)
-- Name: inserir_localizacao(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inserir_localizacao() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica se os valores necess rios estÆo presentes
    IF NEW.idcapitulo IS NOT NULL AND NEW.idpersonagem IS NOT NULL THEN
        -- Insere uma nova linha na tabela localizacao com a sala 1
        INSERT INTO localizacao (idcapitulo, idpersonagem, idsala, idusuario)
        VALUES (NEW.idcapitulo, NEW.idpersonagem, 1, NEW.id);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.inserir_localizacao() OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 17045)
-- Name: inserir_localizacao_sala_1(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.inserir_localizacao_sala_1() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Verifica se o idpersonagem foi alterado (isto ‚, nÆo ‚ NULL)
    IF NEW.idpersonagem IS NOT NULL AND OLD.idpersonagem IS DISTINCT FROM NEW.idpersonagem THEN
        -- Insere uma nova linha na tabela localizacao
        INSERT INTO localizacao (idcapitulo, idpersonagem, idsala, idusuario)
        VALUES (NEW.idcapitulo, NEW.idpersonagem, 1, NEW.id);
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.inserir_localizacao_sala_1() OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 16895)
-- Name: verificar_nome_unico(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.verificar_nome_unico() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM usuario WHERE nome = NEW.nome) THEN
        RAISE EXCEPTION 'O nome de usu rio "%" j  existe no sistema. Escolha outro nome.', NEW.nome;
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.verificar_nome_unico() OWNER TO postgres;

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
-- TOC entry 3654 (class 0 OID 0)
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
-- TOC entry 3655 (class 0 OID 0)
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
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 247
-- Name: bestante_idbestante_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bestante_idbestante_seq OWNED BY public.bestante.idbestante;


--
-- TOC entry 256 (class 1259 OID 16910)
-- Name: capitulo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.capitulo (
    idcapitulo integer NOT NULL,
    texto text NOT NULL,
    objetivo text
);


ALTER TABLE public.capitulo OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 16909)
-- Name: capitulo_idcapitulo_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.capitulo_idcapitulo_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.capitulo_idcapitulo_seq OWNER TO postgres;

--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 255
-- Name: capitulo_idcapitulo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.capitulo_idcapitulo_seq OWNED BY public.capitulo.idcapitulo;


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
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 230
-- Name: compartimento_idcompartimento_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compartimento_idcompartimento_seq OWNED BY public.compartimento.idcompartimento;


--
-- TOC entry 267 (class 1259 OID 17058)
-- Name: consequencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.consequencia (
    idconsequencia integer NOT NULL,
    idopcao integer,
    idpersonagem integer,
    texto text,
    atributo text,
    recompensa integer
);


ALTER TABLE public.consequencia OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 17057)
-- Name: consequencia_idconsequencia_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.consequencia_idconsequencia_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.consequencia_idconsequencia_seq OWNER TO postgres;

--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 266
-- Name: consequencia_idconsequencia_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.consequencia_idconsequencia_seq OWNED BY public.consequencia.idconsequencia;


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
-- TOC entry 3660 (class 0 OID 0)
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
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 226
-- Name: consumivel_idconsumivel_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.consumivel_idconsumivel_seq OWNED BY public.consumivel.idconsumivel;


--
-- TOC entry 260 (class 1259 OID 16941)
-- Name: decisao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.decisao (
    iddecisao integer NOT NULL,
    descricao text NOT NULL
);


ALTER TABLE public.decisao OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 16940)
-- Name: decisao_iddecisao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.decisao_iddecisao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.decisao_iddecisao_seq OWNER TO postgres;

--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 259
-- Name: decisao_iddecisao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.decisao_iddecisao_seq OWNED BY public.decisao.iddecisao;


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
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 240
-- Name: distrito_iddistrito_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.distrito_iddistrito_seq OWNED BY public.distrito.iddistrito;


--
-- TOC entry 258 (class 1259 OID 16919)
-- Name: historia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.historia (
    idhistoria integer NOT NULL,
    idpersonagem integer,
    idcapitulo_inicial integer
);


ALTER TABLE public.historia OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 16918)
-- Name: historia_idhistoria_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.historia_idhistoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.historia_idhistoria_seq OWNER TO postgres;

--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 257
-- Name: historia_idhistoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.historia_idhistoria_seq OWNED BY public.historia.idhistoria;


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
-- TOC entry 3665 (class 0 OID 0)
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
-- TOC entry 3666 (class 0 OID 0)
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
-- TOC entry 3667 (class 0 OID 0)
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
-- TOC entry 3668 (class 0 OID 0)
-- Dependencies: 228
-- Name: legivel_idlegivel_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.legivel_idlegivel_seq OWNED BY public.legivel.idlegivel;


--
-- TOC entry 265 (class 1259 OID 17000)
-- Name: localizacao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.localizacao (
    idcapitulo integer NOT NULL,
    idpersonagem integer NOT NULL,
    idsala integer,
    idusuario integer
);


ALTER TABLE public.localizacao OWNER TO postgres;

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
-- TOC entry 3669 (class 0 OID 0)
-- Dependencies: 214
-- Name: mapa_idmapa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mapa_idmapa_seq OWNED BY public.mapa.idmapa;


--
-- TOC entry 262 (class 1259 OID 16955)
-- Name: opcao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opcao (
    idopcao integer NOT NULL,
    iddecisao integer,
    descricao text NOT NULL,
    efeito_atributo integer,
    proximo_capitulo integer,
    peso integer,
    atributo text
);


ALTER TABLE public.opcao OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 16954)
-- Name: opcao_idopcao_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.opcao_idopcao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opcao_idopcao_seq OWNER TO postgres;

--
-- TOC entry 3670 (class 0 OID 0)
-- Dependencies: 261
-- Name: opcao_idopcao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.opcao_idopcao_seq OWNED BY public.opcao.idopcao;


--
-- TOC entry 237 (class 1259 OID 16617)
-- Name: personagem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personagem (
    idpersonagem integer NOT NULL,
    tipop character varying(25),
    nomep character varying(50) NOT NULL,
    hpmax integer DEFAULT 100,
    hpatual integer DEFAULT 100
);


ALTER TABLE public.personagem OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 16974)
-- Name: personagem_capitulo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personagem_capitulo (
    id integer NOT NULL,
    idpersonagem integer,
    idcapitulo integer,
    acao text
);


ALTER TABLE public.personagem_capitulo OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 16973)
-- Name: personagem_capitulo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personagem_capitulo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personagem_capitulo_id_seq OWNER TO postgres;

--
-- TOC entry 3671 (class 0 OID 0)
-- Dependencies: 263
-- Name: personagem_capitulo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personagem_capitulo_id_seq OWNED BY public.personagem_capitulo.id;


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
-- TOC entry 3672 (class 0 OID 0)
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
-- TOC entry 3673 (class 0 OID 0)
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
-- TOC entry 3674 (class 0 OID 0)
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
-- TOC entry 3675 (class 0 OID 0)
-- Dependencies: 249
-- Name: tributo_idtributo_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tributo_idtributo_seq OWNED BY public.tributo.idtributo;


--
-- TOC entry 254 (class 1259 OID 16884)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id integer NOT NULL,
    nome character varying(50) NOT NULL,
    senha character varying(255) NOT NULL,
    idpersonagem integer,
    idcapitulo integer
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 16883)
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.usuario_id_seq OWNER TO postgres;

--
-- TOC entry 3676 (class 0 OID 0)
-- Dependencies: 253
-- Name: usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_seq OWNED BY public.usuario.id;


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
-- TOC entry 3677 (class 0 OID 0)
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
-- TOC entry 3678 (class 0 OID 0)
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
    idusuario integer NOT NULL,
    nutricao integer DEFAULT 100,
    hidratacao integer DEFAULT 100,
    stamina integer DEFAULT 100,
    calor integer DEFAULT 50,
    dano integer DEFAULT 0,
    popularidade integer,
    agilidade integer,
    forca integer,
    nado integer,
    carisma integer,
    combate integer,
    perspicacia integer,
    furtividade integer,
    sobrevivencia integer,
    precisao integer,
    amigo integer
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
-- TOC entry 3679 (class 0 OID 0)
-- Dependencies: 238
-- Name: vitalidade_idvitalidade_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vitalidade_idvitalidade_seq OWNED BY public.vitalidade.idvitalidade;


--
-- TOC entry 3351 (class 2604 OID 16700)
-- Name: animal idanimal; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal ALTER COLUMN idanimal SET DEFAULT nextval('public.animal_idanimal_seq'::regclass);


--
-- TOC entry 3325 (class 2604 OID 16531)
-- Name: arma idarma; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma ALTER COLUMN idarma SET DEFAULT nextval('public.arma_idarma_seq'::regclass);


--
-- TOC entry 3352 (class 2604 OID 16712)
-- Name: bestante idbestante; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bestante ALTER COLUMN idbestante SET DEFAULT nextval('public.bestante_idbestante_seq'::regclass);


--
-- TOC entry 3357 (class 2604 OID 16913)
-- Name: capitulo idcapitulo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capitulo ALTER COLUMN idcapitulo SET DEFAULT nextval('public.capitulo_idcapitulo_seq'::regclass);


--
-- TOC entry 3330 (class 2604 OID 16573)
-- Name: compartimento idcompartimento; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartimento ALTER COLUMN idcompartimento SET DEFAULT nextval('public.compartimento_idcompartimento_seq'::regclass);


--
-- TOC entry 3362 (class 2604 OID 17061)
-- Name: consequencia idconsequencia; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consequencia ALTER COLUMN idconsequencia SET DEFAULT nextval('public.consequencia_idconsequencia_seq'::regclass);


--
-- TOC entry 3336 (class 2604 OID 16603)
-- Name: construtor idconstrutor; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.construtor ALTER COLUMN idconstrutor SET DEFAULT nextval('public.construtor_idconstrutor_seq'::regclass);


--
-- TOC entry 3327 (class 2604 OID 16546)
-- Name: consumivel idconsumivel; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumivel ALTER COLUMN idconsumivel SET DEFAULT nextval('public.consumivel_idconsumivel_seq'::regclass);


--
-- TOC entry 3359 (class 2604 OID 16944)
-- Name: decisao iddecisao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.decisao ALTER COLUMN iddecisao SET DEFAULT nextval('public.decisao_iddecisao_seq'::regclass);


--
-- TOC entry 3358 (class 2604 OID 16922)
-- Name: historia idhistoria; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historia ALTER COLUMN idhistoria SET DEFAULT nextval('public.historia_idhistoria_seq'::regclass);


--
-- TOC entry 3348 (class 2604 OID 16668)
-- Name: inventario idinventario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario ALTER COLUMN idinventario SET DEFAULT nextval('public.inventario_idinventario_seq'::regclass);


--
-- TOC entry 3322 (class 2604 OID 16502)
-- Name: item iditem; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item ALTER COLUMN iditem SET DEFAULT nextval('public.item_iditem_seq'::regclass);


--
-- TOC entry 3355 (class 2604 OID 16743)
-- Name: item_inventario iditeminventario; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_inventario ALTER COLUMN iditeminventario SET DEFAULT nextval('public.item_inventario_iditeminventario_seq'::regclass);


--
-- TOC entry 3328 (class 2604 OID 16558)
-- Name: legivel idlegivel; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legivel ALTER COLUMN idlegivel SET DEFAULT nextval('public.legivel_idlegivel_seq'::regclass);


--
-- TOC entry 3316 (class 2604 OID 16403)
-- Name: mapa idmapa; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mapa ALTER COLUMN idmapa SET DEFAULT nextval('public.mapa_idmapa_seq'::regclass);


--
-- TOC entry 3360 (class 2604 OID 16958)
-- Name: opcao idopcao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opcao ALTER COLUMN idopcao SET DEFAULT nextval('public.opcao_idopcao_seq'::regclass);


--
-- TOC entry 3337 (class 2604 OID 16620)
-- Name: personagem idpersonagem; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem ALTER COLUMN idpersonagem SET DEFAULT nextval('public.personagem_idpersonagem_seq'::regclass);


--
-- TOC entry 3361 (class 2604 OID 16977)
-- Name: personagem_capitulo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem_capitulo ALTER COLUMN id SET DEFAULT nextval('public.personagem_capitulo_id_seq'::regclass);


--
-- TOC entry 3318 (class 2604 OID 16413)
-- Name: regiao idregiao; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regiao ALTER COLUMN idregiao SET DEFAULT nextval('public.regiao_idregiao_seq'::regclass);


--
-- TOC entry 3320 (class 2604 OID 16428)
-- Name: sala idsala; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sala ALTER COLUMN idsala SET DEFAULT nextval('public.sala_idsala_seq'::regclass);


--
-- TOC entry 3353 (class 2604 OID 16724)
-- Name: tributo idtributo; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tributo ALTER COLUMN idtributo SET DEFAULT nextval('public.tributo_idtributo_seq'::regclass);


--
-- TOC entry 3356 (class 2604 OID 16887)
-- Name: usuario id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq'::regclass);


--
-- TOC entry 3331 (class 2604 OID 16585)
-- Name: utilidade idutilidade; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilidade ALTER COLUMN idutilidade SET DEFAULT nextval('public.utilidade_idutilidade_seq'::regclass);


--
-- TOC entry 3323 (class 2604 OID 16516)
-- Name: vestimenta idvestimenta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vestimenta ALTER COLUMN idvestimenta SET DEFAULT nextval('public.vestimenta_idvestimenta_seq'::regclass);


--
-- TOC entry 3340 (class 2604 OID 16635)
-- Name: vitalidade idvitalidade; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitalidade ALTER COLUMN idvitalidade SET DEFAULT nextval('public.vitalidade_idvitalidade_seq'::regclass);


--
-- TOC entry 3627 (class 0 OID 16697)
-- Dependencies: 246
-- Data for Name: animal; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.animal (idanimal, idpersonagem) FROM stdin;
\.


--
-- TOC entry 3606 (class 0 OID 16528)
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
-- TOC entry 3629 (class 0 OID 16709)
-- Dependencies: 248
-- Data for Name: bestante; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bestante (idbestante, idpersonagem, agilidade, nado, voo) FROM stdin;
\.


--
-- TOC entry 3637 (class 0 OID 16910)
-- Dependencies: 256
-- Data for Name: capitulo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.capitulo (idcapitulo, texto, objetivo) FROM stdin;
1	Depois de um longo dia de viagem de trem, vocˆ finalmente chegou … Capital. Agora, vocˆ se encontra no Centro de Treinamento, onde passar  os pr¢ximos dois dias com os outros tributos.	Faca duas aulas
2	Depois de uma longa aula cansativa, vocˆ ainda tem energia pra mais uma aula	Objetivo do segundo cap¡tulo
3	Uma farta ceia ‚ servida na mesa de jantar. Sua colega de distrito, Pandora, est  sentada ao lado da mentora do distrito 1, vencedora da 64ø edi‡Æo dos Jogos Vorazes, Cashmere.	Aproveite o jantar da sua melhor forma
4	Depois de um longo dia vocˆ est  sem energia!	V  descan‡ar!
\.


--
-- TOC entry 3612 (class 0 OID 16570)
-- Dependencies: 231
-- Data for Name: compartimento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compartimento (idcompartimento, iditem, adcapmax) FROM stdin;
1	30	10
2	31	20
\.


--
-- TOC entry 3648 (class 0 OID 17058)
-- Dependencies: 267
-- Data for Name: consequencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.consequencia (idconsequencia, idopcao, idpersonagem, texto, atributo, recompensa) FROM stdin;
1	2	39	Os tributos treinaram t‚cnicas de luta, come‡ando com uma introdu‡Æo te¢rica antes de enfrentar desafios realistas. Ao final da aula, a instrutora Jennifer liberou todos.	combate	1
2	3	40	Os tributos praticaram t‚cnicas de sobrevivˆncia com o instrutor Josh, que mostrou como lidar com situa‡äes de escassez de recursos e perigos naturais. Ao final, todos estavam mais preparados para enfrentar desafios de sobrevivˆncia.	sobrevivencia	1
3	4	41	Durante a aula de mira com Liam, os tributos aperfei‡oaram suas habilidades de precisÆo e tiro. Cada um teve a oportunidade de praticar com diferentes armas e t‚cnicas.	mira	1
4	5	42	Na aula de nata‡Æo com Sam, os tributos treinaram suas habilidades na  gua, aprendendo t‚cnicas de nata‡Æo e estrat‚gias de sobrevivˆncia aqu tica.	nata‡Æo	1
5	6	43	Willow conduziu uma aula de camuflagem, ensinando os tributos a se esconder e se misturar com o ambiente. A pr tica envolveu t‚cnicas de camuflagem em diferentes cen rios.	camuflagem	1
6	7	39	Os tributos participaram de uma aula de combate intensiva com Jennifer, melhorando suas habilidades em luta corpo a corpo e estrat‚gias de combate.	combate	1
7	8	40	Josh fez uma revisÆo dos conceitos de sobrevivˆncia com os tributos, enfatizando a importƒncia de estrat‚gias adaptativas e o uso eficiente dos recursos dispon¡veis.	sobrevivencia	1
8	9	41	Liam organizou uma s‚rie de exerc¡cios de precisÆo, onde os tributos puderam testar suas habilidades em diferentes alvos e distƒncias.	mira	1
9	10	42	Sam supervisionou uma pr tica de nata‡Æo em ambientes simulados, desafiando os tributos a manter a calma e a eficiˆncia sob pressÆo.	nata‡Æo	1
10	11	43	Na aula de camuflagem final com Willow, os tributos aplicaram todas as t‚cnicas aprendidas em um exerc¡cio de campo, testando suas habilidades de camuflagem em cen rios variados.	camuflagem	1
11	12	1	Os tributos realizaram a refei‡Æo em silˆncio, sem interagir com os outros. Este momento de quietude ajudou a focar e refletir sobre as experiˆncias do dia.	carisma	0
12	13	27	Cashmere: "Nosso distrito ‚ o mais preparado para os Jogos, tente ser o mais agressivo que puder	perspicacia	0
13	14	2	Depois de uma breve conversa, Pandora aceitou ser sua aliada durante os Jogos	amigo	1
\.


--
-- TOC entry 3616 (class 0 OID 16600)
-- Dependencies: 235
-- Data for Name: construtor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.construtor (idconstrutor, iditem) FROM stdin;
\.


--
-- TOC entry 3608 (class 0 OID 16543)
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
-- TOC entry 3641 (class 0 OID 16941)
-- Dependencies: 260
-- Data for Name: decisao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.decisao (iddecisao, descricao) FROM stdin;
1	Escolha uma aula para fazer hoje e evoluir suas habilidades
2	Escolha a sua £ltima aula do dia
3	Fa‡a a sua escolha:
4	S¢ h  uma escolha:
\.


--
-- TOC entry 3622 (class 0 OID 16649)
-- Dependencies: 241
-- Data for Name: distrito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.distrito (iddistrito, idpersonagem, popularidade, agilidade, forca, nado, carisma, combate, perspicacia, furtividade, sobrevivencia, precisao, descricao) FROM stdin;
1	1	6	4	5	4	4	8	5	3	4	7	Dominic ‚ o tributo masculino do Distrito 1, um Carreirista que treinou anos em uma academia especial apenas para se voluntariar aos Jogos quando completasse 18 anos. Ele ‚ conhecido por sua habilidade em combate e precisÆo
4	7	4	8	4	9	5	5	3	4	5	6	Icaro ‚ o tributo masculino do Distrito 4, o Distrito da Pesca. Cresceu nadando e pescando de diversas formas, e ‚ conhecido por sua habilidade em nado e agilidade.
12	24	4	6	4	6	8	4	5	5	8	5	Leslie ‚ a tributo feminina do Distrito 12, conhecido pela minera‡Æo e por ser o Distrito mais pobre de Panem. A falta de recursos nas cidades fez com que a sobrevivˆncia no ambiente natural se tornasse essencial. Ela ‚ conhecida pelo seu carisma e pelo seu conhecimento da natureza
3	6	3	4	4	5	4	4	10	8	6	4	Gabrielle ‚ a tributo feminina do Distrito 3, conhecido pelo desenvolvimento tecnol¢gico de toda a Panem. Gabrielle ‚ famosa pela sua inteligˆncia e pela facilidade de se esconder.
\.


--
-- TOC entry 3639 (class 0 OID 16919)
-- Dependencies: 258
-- Data for Name: historia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.historia (idhistoria, idpersonagem, idcapitulo_inicial) FROM stdin;
1	1	1
\.


--
-- TOC entry 3624 (class 0 OID 16665)
-- Dependencies: 243
-- Data for Name: inventario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventario (idinventario, idpersonagem, capmax, capatual) FROM stdin;
\.


--
-- TOC entry 3602 (class 0 OID 16499)
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
-- TOC entry 3633 (class 0 OID 16740)
-- Dependencies: 252
-- Data for Name: item_inventario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item_inventario (iditeminventario, idinventario, iditem) FROM stdin;
\.


--
-- TOC entry 3610 (class 0 OID 16555)
-- Dependencies: 229
-- Data for Name: legivel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.legivel (idlegivel, iditem, conteudo) FROM stdin;
1	29	Bilhete informativo que pode conter informações úteis para o jogador
\.


--
-- TOC entry 3646 (class 0 OID 17000)
-- Dependencies: 265
-- Data for Name: localizacao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.localizacao (idcapitulo, idpersonagem, idsala, idusuario) FROM stdin;
2	1	2	85
2	1	5	88
3	1	5	89
3	1	2	91
3	1	3	95
2	1	3	96
2	1	2	97
2	1	2	98
3	1	3	100
2	1	2	101
3	1	4	102
\.


--
-- TOC entry 3596 (class 0 OID 16400)
-- Dependencies: 215
-- Data for Name: mapa; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mapa (idmapa, nomem, descricao) FROM stdin;
1	Centro de Treinamento	O Centro de Treinamento é um arranha-céu onde os tributos moram, treinam e se preparam para os Jogos Vorazes
2	Arena	Aqui é onde os 24 tributos se enfrentarão até que reste apenas um vencedor
\.


--
-- TOC entry 3643 (class 0 OID 16955)
-- Dependencies: 262
-- Data for Name: opcao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opcao (idopcao, iddecisao, descricao, efeito_atributo, proximo_capitulo, peso, atributo) FROM stdin;
2	1	Aula de Combate	2	2	0	idsala
3	1	Aula de T‚cnicas de Sobrevivˆncia	3	2	0	idsala
4	1	Aula de Mira	4	2	0	idsala
5	1	Aula de Nata‡Æo	5	2	0	idsala
6	1	Aula de Camuflagem	6	2	0	idsala
7	2	Aula de Combate	2	3	0	idsala
8	2	Aula de T‚cnicas de Sobrevivˆncia	3	3	0	idsala
9	2	Aula de Mira	4	3	0	idsala
10	2	Aula de Nata‡Æo	5	3	0	idsala
11	2	Aula de Camuflagem	6	3	0	idsala
12	3	Fazer a refei‡Æo em silˆncio	-1	4	0	carisma
13	3	Fazer uma pergunta para Cashmere	1	4	5	perspicacia
14	3	Sugerir parceria para Pandora	0	4	6	popularidade
\.


--
-- TOC entry 3618 (class 0 OID 16617)
-- Dependencies: 237
-- Data for Name: personagem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personagem (idpersonagem, tipop, nomep, hpmax, hpatual) FROM stdin;
2	nj	Pandora	100	100
3	nj	Octavio	100	100
4	nj	June	100	100
5	nj	Pierre	100	100
8	nj	Zoe	100	100
10	nj	Marta	100	100
11	nj	Daniel	100	100
12	nj	Lucian	100	100
13	nj	Charlotte	100	100
14	nj	Benedict	100	100
15	nj	Daphine	100	100
16	nj	Maximilian	100	100
17	nj	Stefani	100	100
18	nj	Damon	100	100
19	nj	Selene	100	100
20	nj	Walter	100	100
21	nj	Skyler	100	100
22	nj	Nico	100	100
23	nj	Agnes	100	100
25	nj	Jesse	100	100
26	nj	Ceasar Flickerman	100	100
27	nj	Cashmere	100	100
28	nj	Brutus	100	100
29	nj	Beetee	100	100
30	nj	Finnick	100	100
31	nj	Columbae	100	100
32	nj	Hardie	100	100
33	nj	Johanna	100	100
34	nj	Woof	100	100
35	nj	Driff	100	100
36	nj	Magnus	100	100
37	nj	Seeder	100	100
38	nj	Haymitch	100	100
39	nj	Jennifer	100	100
40	nj	Josh	100	100
41	nj	Liam	100	100
42	nj	Sam	100	100
43	nj	Willow	100	100
1	pj	Dominic	100	100
7	pj	Icaro	100	100
6	pj	Gabrielle	100	100
24	pj	Leslie	100	100
\.


--
-- TOC entry 3645 (class 0 OID 16974)
-- Dependencies: 264
-- Data for Name: personagem_capitulo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personagem_capitulo (id, idpersonagem, idcapitulo, acao) FROM stdin;
\.


--
-- TOC entry 3625 (class 0 OID 16678)
-- Dependencies: 244
-- Data for Name: personagem_jogavel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personagem_jogavel (idpersonagem, iddistrito) FROM stdin;
\.


--
-- TOC entry 3598 (class 0 OID 16410)
-- Dependencies: 217
-- Data for Name: regiao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.regiao (idregiao, idmapa, nomer, tempr, descricao) FROM stdin;
1	1	Andar de Capacitação	24	O Andar de Capacitação é o lugar onde os tributos podem treinar e ter aulas
2	1	Andar Moradia	24	O Andar Moradia é onde os tributos e seus tutores comem e dormem
3	1	Andar Mídia	24	O Andar Mídia é onde os tributos fazem as suas entrevistas para a TV
\.


--
-- TOC entry 3600 (class 0 OID 16425)
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
-- TOC entry 3631 (class 0 OID 16721)
-- Dependencies: 250
-- Data for Name: tributo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tributo (idtributo, idpersonagem, iddistrito, statust) FROM stdin;
\.


--
-- TOC entry 3635 (class 0 OID 16884)
-- Dependencies: 254
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id, nome, senha, idpersonagem, idcapitulo) FROM stdin;
80	xuxu	123	1	1
94	wewe	123	1	1
83	tata	123	1	1
86	frfr	123	1	1
97	gigi	123	1	2
89	popo	123	1	3
101	mama	123	1	2
81	bubu	123	1	1
84	jesus	123	1	1
87	susu	123	1	1
90	fifi	123	1	1
95	nana	123	1	4
93	xuxa	123	1	1
98	nunu	123	1	2
102	mm	123	1	3
82	mimi	123	1	1
96	kaka	123	1	2
85	mds	123	1	2
88	vruv	123	1	2
100	na	123	1	3
91	vivi	123	1	3
79	cra	123	24	\N
\.


--
-- TOC entry 3614 (class 0 OID 16582)
-- Dependencies: 233
-- Data for Name: utilidade; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.utilidade (idutilidade, iditem, nome, descricao, geraitem, capturainimigo, geracalor) FROM stdin;
\.


--
-- TOC entry 3604 (class 0 OID 16513)
-- Dependencies: 223
-- Data for Name: vestimenta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vestimenta (idvestimenta, iditem, descricao, adcalor) FROM stdin;
1	1	Vestimenta padrão de todos os tributos na Arena	5
2	2	Um casaco resistente que te protegerá contra o frio	20
\.


--
-- TOC entry 3620 (class 0 OID 16632)
-- Dependencies: 239
-- Data for Name: vitalidade; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vitalidade (idvitalidade, idusuario, nutricao, hidratacao, stamina, calor, dano, popularidade, agilidade, forca, nado, carisma, combate, perspicacia, furtividade, sobrevivencia, precisao, amigo) FROM stdin;
1	93	100	100	100	50	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2	94	100	100	100	50	0	6	4	5	4	4	8	5	3	4	7	\N
3	95	100	100	100	50	0	6	4	5	4	5	8	5	3	4	7	\N
4	96	100	100	100	50	0	6	4	5	4	4	8	5	3	4	7	\N
5	97	100	100	100	50	0	6	4	5	4	4	8	5	3	4	7	\N
6	98	100	100	100	50	0	6	4	5	4	4	8	5	3	4	7	\N
7	100	100	100	100	50	0	6	4	5	4	4	8	5	3	4	7	\N
8	101	100	100	100	50	0	6	4	5	4	4	8	5	3	4	7	\N
9	102	100	100	100	50	0	6	4	5	4	4	8	5	3	4	7	\N
\.


--
-- TOC entry 3680 (class 0 OID 0)
-- Dependencies: 245
-- Name: animal_idanimal_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.animal_idanimal_seq', 1, false);


--
-- TOC entry 3681 (class 0 OID 0)
-- Dependencies: 224
-- Name: arma_idarma_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.arma_idarma_seq', 9, true);


--
-- TOC entry 3682 (class 0 OID 0)
-- Dependencies: 247
-- Name: bestante_idbestante_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bestante_idbestante_seq', 1, false);


--
-- TOC entry 3683 (class 0 OID 0)
-- Dependencies: 255
-- Name: capitulo_idcapitulo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.capitulo_idcapitulo_seq', 2, true);


--
-- TOC entry 3684 (class 0 OID 0)
-- Dependencies: 230
-- Name: compartimento_idcompartimento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compartimento_idcompartimento_seq', 2, true);


--
-- TOC entry 3685 (class 0 OID 0)
-- Dependencies: 266
-- Name: consequencia_idconsequencia_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.consequencia_idconsequencia_seq', 13, true);


--
-- TOC entry 3686 (class 0 OID 0)
-- Dependencies: 234
-- Name: construtor_idconstrutor_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.construtor_idconstrutor_seq', 1, false);


--
-- TOC entry 3687 (class 0 OID 0)
-- Dependencies: 226
-- Name: consumivel_idconsumivel_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.consumivel_idconsumivel_seq', 8, true);


--
-- TOC entry 3688 (class 0 OID 0)
-- Dependencies: 259
-- Name: decisao_iddecisao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.decisao_iddecisao_seq', 2, true);


--
-- TOC entry 3689 (class 0 OID 0)
-- Dependencies: 240
-- Name: distrito_iddistrito_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.distrito_iddistrito_seq', 1, true);


--
-- TOC entry 3690 (class 0 OID 0)
-- Dependencies: 257
-- Name: historia_idhistoria_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.historia_idhistoria_seq', 1, true);


--
-- TOC entry 3691 (class 0 OID 0)
-- Dependencies: 242
-- Name: inventario_idinventario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventario_idinventario_seq', 1, false);


--
-- TOC entry 3692 (class 0 OID 0)
-- Dependencies: 220
-- Name: item_iditem_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_iditem_seq', 31, true);


--
-- TOC entry 3693 (class 0 OID 0)
-- Dependencies: 251
-- Name: item_inventario_iditeminventario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_inventario_iditeminventario_seq', 1, false);


--
-- TOC entry 3694 (class 0 OID 0)
-- Dependencies: 228
-- Name: legivel_idlegivel_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.legivel_idlegivel_seq', 1, true);


--
-- TOC entry 3695 (class 0 OID 0)
-- Dependencies: 214
-- Name: mapa_idmapa_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mapa_idmapa_seq', 2, true);


--
-- TOC entry 3696 (class 0 OID 0)
-- Dependencies: 261
-- Name: opcao_idopcao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.opcao_idopcao_seq', 6, true);


--
-- TOC entry 3697 (class 0 OID 0)
-- Dependencies: 263
-- Name: personagem_capitulo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personagem_capitulo_id_seq', 1, false);


--
-- TOC entry 3698 (class 0 OID 0)
-- Dependencies: 236
-- Name: personagem_idpersonagem_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personagem_idpersonagem_seq', 43, true);


--
-- TOC entry 3699 (class 0 OID 0)
-- Dependencies: 216
-- Name: regiao_idregiao_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.regiao_idregiao_seq', 3, true);


--
-- TOC entry 3700 (class 0 OID 0)
-- Dependencies: 218
-- Name: sala_idsala_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sala_idsala_seq', 10, true);


--
-- TOC entry 3701 (class 0 OID 0)
-- Dependencies: 249
-- Name: tributo_idtributo_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tributo_idtributo_seq', 1, false);


--
-- TOC entry 3702 (class 0 OID 0)
-- Dependencies: 253
-- Name: usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_seq', 102, true);


--
-- TOC entry 3703 (class 0 OID 0)
-- Dependencies: 232
-- Name: utilidade_idutilidade_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.utilidade_idutilidade_seq', 1, false);


--
-- TOC entry 3704 (class 0 OID 0)
-- Dependencies: 222
-- Name: vestimenta_idvestimenta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vestimenta_idvestimenta_seq', 2, true);


--
-- TOC entry 3705 (class 0 OID 0)
-- Dependencies: 238
-- Name: vitalidade_idvitalidade_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vitalidade_idvitalidade_seq', 9, true);


--
-- TOC entry 3396 (class 2606 OID 16702)
-- Name: animal animal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_pkey PRIMARY KEY (idanimal);


--
-- TOC entry 3374 (class 2606 OID 16536)
-- Name: arma arma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma
    ADD CONSTRAINT arma_pkey PRIMARY KEY (idarma);


--
-- TOC entry 3398 (class 2606 OID 16714)
-- Name: bestante bestante_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bestante
    ADD CONSTRAINT bestante_pkey PRIMARY KEY (idbestante);


--
-- TOC entry 3406 (class 2606 OID 16917)
-- Name: capitulo capitulo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capitulo
    ADD CONSTRAINT capitulo_pkey PRIMARY KEY (idcapitulo);


--
-- TOC entry 3380 (class 2606 OID 16575)
-- Name: compartimento compartimento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartimento
    ADD CONSTRAINT compartimento_pkey PRIMARY KEY (idcompartimento);


--
-- TOC entry 3416 (class 2606 OID 17065)
-- Name: consequencia consequencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consequencia
    ADD CONSTRAINT consequencia_pkey PRIMARY KEY (idconsequencia);


--
-- TOC entry 3384 (class 2606 OID 16605)
-- Name: construtor construtor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.construtor
    ADD CONSTRAINT construtor_pkey PRIMARY KEY (idconstrutor);


--
-- TOC entry 3376 (class 2606 OID 16548)
-- Name: consumivel consumivel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumivel
    ADD CONSTRAINT consumivel_pkey PRIMARY KEY (idconsumivel);


--
-- TOC entry 3410 (class 2606 OID 16948)
-- Name: decisao decisao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.decisao
    ADD CONSTRAINT decisao_pkey PRIMARY KEY (iddecisao);


--
-- TOC entry 3390 (class 2606 OID 16658)
-- Name: distrito distrito_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distrito
    ADD CONSTRAINT distrito_pkey PRIMARY KEY (iddistrito);


--
-- TOC entry 3408 (class 2606 OID 16924)
-- Name: historia historia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historia
    ADD CONSTRAINT historia_pkey PRIMARY KEY (idhistoria);


--
-- TOC entry 3392 (class 2606 OID 16672)
-- Name: inventario inventario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_pkey PRIMARY KEY (idinventario);


--
-- TOC entry 3402 (class 2606 OID 16745)
-- Name: item_inventario item_inventario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_inventario
    ADD CONSTRAINT item_inventario_pkey PRIMARY KEY (iditeminventario);


--
-- TOC entry 3370 (class 2606 OID 16504)
-- Name: item item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item
    ADD CONSTRAINT item_pkey PRIMARY KEY (iditem);


--
-- TOC entry 3378 (class 2606 OID 16563)
-- Name: legivel legivel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legivel
    ADD CONSTRAINT legivel_pkey PRIMARY KEY (idlegivel);


--
-- TOC entry 3364 (class 2606 OID 16408)
-- Name: mapa mapa_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mapa
    ADD CONSTRAINT mapa_pkey PRIMARY KEY (idmapa);


--
-- TOC entry 3412 (class 2606 OID 16962)
-- Name: opcao opcao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opcao
    ADD CONSTRAINT opcao_pkey PRIMARY KEY (idopcao);


--
-- TOC entry 3414 (class 2606 OID 16981)
-- Name: personagem_capitulo personagem_capitulo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem_capitulo
    ADD CONSTRAINT personagem_capitulo_pkey PRIMARY KEY (id);


--
-- TOC entry 3394 (class 2606 OID 16682)
-- Name: personagem_jogavel personagem_jogavel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem_jogavel
    ADD CONSTRAINT personagem_jogavel_pkey PRIMARY KEY (idpersonagem);


--
-- TOC entry 3386 (class 2606 OID 16625)
-- Name: personagem personagem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem
    ADD CONSTRAINT personagem_pkey PRIMARY KEY (idpersonagem);


--
-- TOC entry 3366 (class 2606 OID 16418)
-- Name: regiao regiao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regiao
    ADD CONSTRAINT regiao_pkey PRIMARY KEY (idregiao);


--
-- TOC entry 3368 (class 2606 OID 16433)
-- Name: sala sala_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sala
    ADD CONSTRAINT sala_pkey PRIMARY KEY (idsala);


--
-- TOC entry 3400 (class 2606 OID 16727)
-- Name: tributo tributo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tributo
    ADD CONSTRAINT tributo_pkey PRIMARY KEY (idtributo);


--
-- TOC entry 3404 (class 2606 OID 16889)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- TOC entry 3382 (class 2606 OID 16593)
-- Name: utilidade utilidade_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilidade
    ADD CONSTRAINT utilidade_pkey PRIMARY KEY (idutilidade);


--
-- TOC entry 3372 (class 2606 OID 16521)
-- Name: vestimenta vestimenta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vestimenta
    ADD CONSTRAINT vestimenta_pkey PRIMARY KEY (idvestimenta);


--
-- TOC entry 3388 (class 2606 OID 16642)
-- Name: vitalidade vitalidade_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitalidade
    ADD CONSTRAINT vitalidade_pkey PRIMARY KEY (idvitalidade);


--
-- TOC entry 3451 (class 2620 OID 17034)
-- Name: localizacao trigger_atualizar_capitulo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_atualizar_capitulo AFTER INSERT ON public.localizacao FOR EACH ROW EXECUTE FUNCTION public.atualizar_capitulo_usuario();


--
-- TOC entry 3447 (class 2620 OID 17037)
-- Name: usuario trigger_atualizar_idcapitulo; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_atualizar_idcapitulo AFTER INSERT OR UPDATE OF idpersonagem ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.atualizar_idcapitulo();


--
-- TOC entry 3448 (class 2620 OID 17056)
-- Name: usuario trigger_atualizar_vitalidade; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_atualizar_vitalidade AFTER UPDATE OF idpersonagem ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.atualizar_vitalidade();


--
-- TOC entry 3446 (class 2620 OID 16763)
-- Name: personagem_jogavel trigger_criar_inventario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_criar_inventario AFTER INSERT ON public.personagem_jogavel FOR EACH ROW EXECUTE FUNCTION public.criar_inventario();


--
-- TOC entry 3449 (class 2620 OID 17054)
-- Name: usuario trigger_criar_vitalidade; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_criar_vitalidade AFTER INSERT ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.criar_vitalidade();


--
-- TOC entry 3452 (class 2620 OID 17026)
-- Name: localizacao trigger_excluir_localizacao_anterior; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_excluir_localizacao_anterior AFTER INSERT ON public.localizacao FOR EACH ROW EXECUTE FUNCTION public.excluir_localizacao_anterior();


--
-- TOC entry 3450 (class 2620 OID 16896)
-- Name: usuario trigger_verificar_nome_unico; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_verificar_nome_unico BEFORE INSERT ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.verificar_nome_unico();


--
-- TOC entry 3430 (class 2606 OID 16703)
-- Name: animal animal_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3420 (class 2606 OID 16537)
-- Name: arma arma_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.arma
    ADD CONSTRAINT arma_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3431 (class 2606 OID 16715)
-- Name: bestante bestante_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bestante
    ADD CONSTRAINT bestante_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3423 (class 2606 OID 16576)
-- Name: compartimento compartimento_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compartimento
    ADD CONSTRAINT compartimento_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3444 (class 2606 OID 17066)
-- Name: consequencia consequencia_idopcao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consequencia
    ADD CONSTRAINT consequencia_idopcao_fkey FOREIGN KEY (idopcao) REFERENCES public.opcao(idopcao);


--
-- TOC entry 3445 (class 2606 OID 17071)
-- Name: consequencia consequencia_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consequencia
    ADD CONSTRAINT consequencia_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem);


--
-- TOC entry 3425 (class 2606 OID 16606)
-- Name: construtor construtor_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.construtor
    ADD CONSTRAINT construtor_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3421 (class 2606 OID 16549)
-- Name: consumivel consumivel_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.consumivel
    ADD CONSTRAINT consumivel_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3427 (class 2606 OID 16659)
-- Name: distrito distrito_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.distrito
    ADD CONSTRAINT distrito_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3436 (class 2606 OID 16890)
-- Name: usuario fk_personagem; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT fk_personagem FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem);


--
-- TOC entry 3443 (class 2606 OID 17020)
-- Name: localizacao fk_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.localizacao
    ADD CONSTRAINT fk_usuario FOREIGN KEY (idusuario) REFERENCES public.usuario(id);


--
-- TOC entry 3437 (class 2606 OID 16930)
-- Name: historia historia_idcapitulo_inicial_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historia
    ADD CONSTRAINT historia_idcapitulo_inicial_fkey FOREIGN KEY (idcapitulo_inicial) REFERENCES public.capitulo(idcapitulo);


--
-- TOC entry 3438 (class 2606 OID 16925)
-- Name: historia historia_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.historia
    ADD CONSTRAINT historia_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem);


--
-- TOC entry 3428 (class 2606 OID 16673)
-- Name: inventario inventario_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventario
    ADD CONSTRAINT inventario_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3434 (class 2606 OID 16746)
-- Name: item_inventario item_inventario_idinventario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_inventario
    ADD CONSTRAINT item_inventario_idinventario_fkey FOREIGN KEY (idinventario) REFERENCES public.inventario(idinventario) ON DELETE CASCADE;


--
-- TOC entry 3435 (class 2606 OID 16751)
-- Name: item_inventario item_inventario_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_inventario
    ADD CONSTRAINT item_inventario_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3422 (class 2606 OID 16564)
-- Name: legivel legivel_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.legivel
    ADD CONSTRAINT legivel_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3439 (class 2606 OID 16963)
-- Name: opcao opcao_iddecisao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opcao
    ADD CONSTRAINT opcao_iddecisao_fkey FOREIGN KEY (iddecisao) REFERENCES public.decisao(iddecisao);


--
-- TOC entry 3440 (class 2606 OID 16968)
-- Name: opcao opcao_proximo_capitulo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opcao
    ADD CONSTRAINT opcao_proximo_capitulo_fkey FOREIGN KEY (proximo_capitulo) REFERENCES public.capitulo(idcapitulo);


--
-- TOC entry 3441 (class 2606 OID 16987)
-- Name: personagem_capitulo personagem_capitulo_idcapitulo_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem_capitulo
    ADD CONSTRAINT personagem_capitulo_idcapitulo_fkey FOREIGN KEY (idcapitulo) REFERENCES public.capitulo(idcapitulo);


--
-- TOC entry 3442 (class 2606 OID 16982)
-- Name: personagem_capitulo personagem_capitulo_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem_capitulo
    ADD CONSTRAINT personagem_capitulo_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem);


--
-- TOC entry 3429 (class 2606 OID 16683)
-- Name: personagem_jogavel personagem_jogavel_iddistrito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personagem_jogavel
    ADD CONSTRAINT personagem_jogavel_iddistrito_fkey FOREIGN KEY (iddistrito) REFERENCES public.distrito(iddistrito);


--
-- TOC entry 3417 (class 2606 OID 16419)
-- Name: regiao regiao_idmapa_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.regiao
    ADD CONSTRAINT regiao_idmapa_fkey FOREIGN KEY (idmapa) REFERENCES public.mapa(idmapa);


--
-- TOC entry 3418 (class 2606 OID 16434)
-- Name: sala sala_idregiao_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sala
    ADD CONSTRAINT sala_idregiao_fkey FOREIGN KEY (idregiao) REFERENCES public.regiao(idregiao);


--
-- TOC entry 3432 (class 2606 OID 16733)
-- Name: tributo tributo_iddistrito_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tributo
    ADD CONSTRAINT tributo_iddistrito_fkey FOREIGN KEY (iddistrito) REFERENCES public.distrito(iddistrito) ON DELETE CASCADE;


--
-- TOC entry 3433 (class 2606 OID 16728)
-- Name: tributo tributo_idpersonagem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tributo
    ADD CONSTRAINT tributo_idpersonagem_fkey FOREIGN KEY (idpersonagem) REFERENCES public.personagem(idpersonagem) ON DELETE CASCADE;


--
-- TOC entry 3424 (class 2606 OID 16594)
-- Name: utilidade utilidade_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.utilidade
    ADD CONSTRAINT utilidade_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3419 (class 2606 OID 16522)
-- Name: vestimenta vestimenta_iditem_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vestimenta
    ADD CONSTRAINT vestimenta_iditem_fkey FOREIGN KEY (iditem) REFERENCES public.item(iditem) ON DELETE CASCADE;


--
-- TOC entry 3426 (class 2606 OID 17048)
-- Name: vitalidade vitalidade_idusuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vitalidade
    ADD CONSTRAINT vitalidade_idusuario_fkey FOREIGN KEY (idusuario) REFERENCES public.usuario(id) ON DELETE CASCADE;


-- Completed on 2024-09-08 16:08:26

--
-- PostgreSQL database dump complete
--

