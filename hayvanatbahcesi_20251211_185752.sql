--
-- PostgreSQL database dump
--

\restrict 8RNbaqHx4uMtifv9Xa7cFza8kmo2GvWEemOH5GGCa14HSk67keNBKwiJUT5HQpx

-- Dumped from database version 18.0
-- Dumped by pg_dump version 18.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: BeslenmeOzeti(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."BeslenmeOzeti"("hId" integer, ilk_tarih date, son_tarih date) RETURNS TABLE(toplam_miktar numeric, ortalama_miktar numeric, kayit_sayisi bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        SUM(miktar)::NUMERIC AS toplam_miktar,
        AVG(miktar)::NUMERIC AS ortalama_miktar,
        COUNT(*)::BIGINT AS kayit_sayisi
    FROM 
        "Beslenme"
    WHERE 
        "hayvanId" =  "hId"
       AND tarih >= ilk_tarih
        AND tarih <= son_tarih;
END;
$$;


ALTER FUNCTION public."BeslenmeOzeti"("hId" integer, ilk_tarih date, son_tarih date) OWNER TO postgres;

--
-- Name: KayitBeslenme(integer, integer, time without time zone, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public."KayitBeslenme"("hId" integer, m integer, s time without time zone, t date) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    gunluk_maks_miktar CONSTANT INTEGER := 500.0;  -- Varsayılan günlük limit
    toplam_miktar INTEGER;
BEGIN
    -- 1. ADIM: Kontrol – Bugün Beslenen Toplam Miktarı Hesapla
    SELECT COALESCE(SUM(miktar), 0)
    INTO toplam_miktar
    FROM "Beslenme"
    WHERE "hayvanId" = "hId"
      AND tarih = t; -- Sadece aynı güne ait kayıtları say

    -- Eğer yeni eklenecek miktar ile toplam miktar limiti aşıyorsa
    IF (toplam_miktar + m) > gunluk_maks_miktar THEN
        RAISE EXCEPTION 'HATA: % ID''li hayvan için günlük beslenme limiti (% birim) aşılacaktır.% tarihinde  zaten % birim beslendi.',
            "hId",
            t,
            gunluk_maks_miktar,
            toplam_miktar;
    END IF;

    -- 2. ADIM: Kayıt Ekleme
    INSERT INTO "Beslenme" ("hayvanId", miktar, saat,tarih)
    VALUES ("hId", m, s,t);

    -- 3. ADIM: Onay Mesajı
    RAISE NOTICE 'Hayvan ID % için % tarihinde %  miktarda beslenme kaydı başarıyla eklendi.', 
        "hId", t,m;

END;
$$;


ALTER FUNCTION public."KayitBeslenme"("hId" integer, m integer, s time without time zone, t date) OWNER TO postgres;

--
-- Name: alanraporu(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alanraporu(alan_id integer) RETURNS TABLE(tur_adi character varying, hayvan_sayisi bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.ad,
        COUNT(h."hayvanId") AS hayvan_sayisi
    FROM 
        "Hayvanlar" h
    JOIN 
        "Turler" t ON h."turId" = t."turId" -- Turler tablosunun kullanıldığı varsayılmıştır
    WHERE 
        h."alanId" = alan_id -- Hayvanlar tablosunda alan_id olduğu varsayılmıştır
    GROUP BY 
        t.ad
    ORDER BY
        hayvan_sayisi DESC;
END;
$$;


ALTER FUNCTION public.alanraporu(alan_id integer) OWNER TO postgres;

--
-- Name: calisankontrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.calisankontrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_TABLE_NAME = 'Bakıcı' THEN
        IF EXISTS (SELECT 1 FROM "Yonetici" WHERE "calisanId" = NEW.calisan_id) THEN
            RAISE EXCEPTION 'HATA: Calisan ID % zaten YONETICI olarak atanmistir.', NEW.calisan_id;
        END IF;
        IF EXISTS (SELECT 1 FROM "Personel" WHERE calisan_id = NEW.calisan_id) THEN
            RAISE EXCEPTION 'HATA: Calisan ID % zaten PERSONEL olarak atanmistir.', NEW.calisan_id;
        END IF;

    -- Eğer kayıt YÖNETİCİ tablosuna ekleniyorsa, BAKICI ve PERSONEL'i kontrol et
    ELSIF TG_TABLE_NAME = 'Yonetici' THEN
        IF EXISTS (SELECT 1 FROM "Bakıcı" WHERE "calisanId" = NEW.calisan_id) THEN
            RAISE EXCEPTION 'HATA: Calisan ID % zaten BAKICI olarak atanmistir.', NEW.calisan_id;
        END IF;
        IF EXISTS (SELECT 1 FROM "Personel" WHERE "calisanId"= NEW.calisan_id) THEN
            RAISE EXCEPTION 'HATA: Calisan ID % zaten PERSONEL olarak atanmistir.', NEW.calisan_id;
        END IF;

    -- Eğer kayıt PERSONEL tablosuna ekleniyorsa, BAKICI ve YÖNETİCİ'yi kontrol et
    ELSIF TG_TABLE_NAME = 'Personel' THEN
        IF EXISTS (SELECT 1 FROM "Bakıcı" WHERE "calisanId" = NEW.calisan_id) THEN
            RAISE EXCEPTION 'HATA: Calisan ID % zaten BAKICI olarak atanmistir.', NEW.calisan_id;
        END IF;
        IF EXISTS (SELECT 1 FROM "Yonetici" WHERE "calisanId" = NEW.calisan_id) THEN
            RAISE EXCEPTION 'HATA: Calisan ID % zaten YONETICI olarak atanmistir.', NEW.calisan_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.calisankontrol() OWNER TO postgres;

--
-- Name: eksikstokraporu(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.eksikstokraporu() RETURNS TABLE("yemTür" character varying, miktar integer, siparis_miktar integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_limit CONSTANT INTEGER := 1000;
BEGIN
  RETURN QUERY
    SELECT 
        d."yemTür",
        d.miktar,
        (v_limit - d.miktar) AS siparis_miktar -- 1000'e tamamlamak için gereken miktar
    FROM 
        "Depo" d
    WHERE 
        d.miktar < v_limit -- Sadece 1000'den az olanları filtreler
    ORDER BY 
        siparis_miktar DESC;
END;
$$;


ALTER FUNCTION public.eksikstokraporu() OWNER TO postgres;

--
-- Name: kontrolbakici(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kontrolbakici() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    sayi INT;
BEGIN
    -- Bu hayvan için kaç bakıcı var?
    SELECT COUNT(*) INTO sayi
    FROM "HayvanBak"
    WHERE "hayvanId" = NEW."hayvanId";

    -- Eğer zaten 2 bakıcı varsa, eklemeyi engelle
    IF sayi >= 2 THEN
        RAISE EXCEPTION 'Bir hayvana en fazla 2 bakıcı atanabilir (hayvan_id=%)', NEW."hayvanId";
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.kontrolbakici() OWNER TO postgres;

--
-- Name: kontrolvet(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.kontrolvet() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    sayi INT;
BEGIN
    -- Bu hayvan için kaç bakıcı var?
    SELECT COUNT(*) INTO sayi
    FROM "HayvanVet"
    WHERE "hayvanId" = NEW."hayvanId";

    -- Eğer zaten 2 bakıcı varsa, eklemeyi engelle
    IF sayi >= 2 THEN
        RAISE EXCEPTION 'Bir hayvana en fazla 2 bakıcı atanabilir (hayvan_id=%)', NEW."hayvanId";
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.kontrolvet() OWNER TO postgres;

--
-- Name: toplamgelir(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.toplamgelir(t date) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE
    toplam_gelir DECIMAL;
BEGIN
    -- Belirtilen tarihteki tüm bilet fiyatlarını toplar
    SELECT 
        COALESCE(SUM(fiyat), 0) -- Hiç satış yoksa 0 döndürür
    INTO 
        toplam_gelir
    FROM 
        "Biletler"
    WHERE 
        tarih = t;
        
    RETURN toplam_gelir;
END;
$$;


ALTER FUNCTION public.toplamgelir(t date) OWNER TO postgres;

--
-- Name: yasagoretarife(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.yasagoretarife() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Ziyaretçi tablosundan çekilecek yaşı tutacak değişken
    yas INTEGER;
BEGIN
IF NEW."ziyaretciId" IS NULL THEN
        -- Eğer ID girilmemişse, bir kısıtlama atıyoruz.
        RAISE EXCEPTION 'Bilet kaydı oluşturmak için ziyaretci_id alanı boş bırakılamaz.';
    END IF;

    -- 2. Ziyaretci tablosundan, verilen ID'ye karşılık gelen YAŞ bilgisini çekme
    SELECT z.yas INTO yas
    FROM "Ziyaretci" z
    WHERE z."ziyaretciId" = NEW."ziyaretciId";

    -- Eğer ID bulunamazsa hata fırlatılır
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ziyaretçi ID % numaralı ziyaretçi bulunamadı.', NEW."ziyaretciId";
    END IF;
    -- Yaş sütununu (ziyaretci tablosundan) NEW.yas olarak varsayıyoruz
    
    IF yas < 10 THEN
        new.tarife := 'Ücretsiz Çocuk';
        new.fiyat := 0.00;
    
    ELSIF yas BETWEEN 10 AND 20 THEN
        new.tarife := 'Genç Tarife';
        new.fiyat := 50.00; -- Genç fiyatı
        
    ELSE -- 21 yaş ve üzeri
        new.tarife := 'Tam Fiyat';
        new.fiyat := 100.00; -- Tam fiyat
        
    END IF;

    RETURN NEW; -- Değiştirilmiş yeni satırı döndür
END;$$;


ALTER FUNCTION public.yasagoretarife() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Alanlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Alanlar" (
    "alanId" integer NOT NULL,
    ad character varying(30) NOT NULL,
    konum text DEFAULT '60'::text NOT NULL,
    "metreKaresi" integer NOT NULL
);


ALTER TABLE public."Alanlar" OWNER TO postgres;

--
-- Name: Alanlar_alanId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Alanlar" ALTER COLUMN "alanId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Alanlar_alanId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Bakıcı; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Bakıcı" (
    "bakıcıId" integer NOT NULL,
    "yöneticiId" integer DEFAULT 2 NOT NULL,
    "calisanId" integer NOT NULL
);


ALTER TABLE public."Bakıcı" OWNER TO postgres;

--
-- Name: Bakıcı_bakıcıId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Bakıcı" ALTER COLUMN "bakıcıId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Bakıcı_bakıcıId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Beslenme; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Beslenme" (
    "beslenmeId" integer NOT NULL,
    miktar integer NOT NULL,
    saat time without time zone NOT NULL,
    "hayvanId" integer NOT NULL,
    tarih date NOT NULL
);


ALTER TABLE public."Beslenme" OWNER TO postgres;

--
-- Name: Beslenme_beslenmeId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Beslenme" ALTER COLUMN "beslenmeId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Beslenme_beslenmeId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Biletler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Biletler" (
    "biletKodu" integer NOT NULL,
    tarih date DEFAULT (CURRENT_DATE - ((((random() * (1825)::double precision))::integer)::double precision * '1 day'::interval)) NOT NULL,
    fiyat integer NOT NULL,
    tarife character varying NOT NULL,
    "ziyaretciId" integer NOT NULL
);


ALTER TABLE public."Biletler" OWNER TO postgres;

--
-- Name: Biletler_biletKodu_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Biletler" ALTER COLUMN "biletKodu" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Biletler_biletKodu_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Calisan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Calisan" (
    "calisanId" integer NOT NULL,
    ad character varying NOT NULL,
    tel text DEFAULT ('05'::text || lpad((floor((random() * (1000000000)::double precision)))::text, 9, '0'::text)) NOT NULL
);


ALTER TABLE public."Calisan" OWNER TO postgres;

--
-- Name: Calisan_calisanId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Calisan" ALTER COLUMN "calisanId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Calisan_calisanId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Depo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Depo" (
    "depoId" integer NOT NULL,
    "yemTür" character varying NOT NULL,
    miktar integer NOT NULL
);


ALTER TABLE public."Depo" OWNER TO postgres;

--
-- Name: Depo_depoId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Depo" ALTER COLUMN "depoId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Depo_depoId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: HayvanBak; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HayvanBak" (
    "hayvanId" integer NOT NULL,
    "bakıcıId" integer NOT NULL
);


ALTER TABLE public."HayvanBak" OWNER TO postgres;

--
-- Name: HayvanVet; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."HayvanVet" (
    "hayvanId" integer NOT NULL,
    "vetId" integer NOT NULL
);


ALTER TABLE public."HayvanVet" OWNER TO postgres;

--
-- Name: Hayvanlar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Hayvanlar" (
    "hayvanId" integer NOT NULL,
    ad character varying(40) DEFAULT (ARRAY['Aslan'::text, 'Fil'::text, 'Kaplan'::text, 'Zebra'::text, 'Ayı'::text, 'Kurt'::text, 'Leopar'::text, 'Gergedan'::text, 'Panda'::text, 'Maymun'::text, 'Zürafa'::text, 'Sırtlan'::text, 'Kanguru'::text, 'papağan'::text, 'Penguen'::text, 'Timsah'::text])[(floor((random() * (16)::double precision)) + (1)::double precision)] NOT NULL,
    cinsiyet character varying(10) DEFAULT (ARRAY['erkek'::text, 'dişi'::text])[(floor((random() * (2)::double precision)) + (1)::double precision)] NOT NULL,
    "turId" integer CONSTRAINT "Hayvanlar_türId_not_null" NOT NULL,
    "alanId" integer DEFAULT 1 NOT NULL,
    yas integer DEFAULT (floor((random() * (16)::double precision)))::integer NOT NULL
);


ALTER TABLE public."Hayvanlar" OWNER TO postgres;

--
-- Name: Hayvanlar_hayvanId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Hayvanlar" ALTER COLUMN "hayvanId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Hayvanlar_hayvanId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Kayit; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Kayit" (
    "kayitId" integer NOT NULL,
    tarih date DEFAULT CURRENT_DATE NOT NULL,
    "hayvanId" integer NOT NULL
);


ALTER TABLE public."Kayit" OWNER TO postgres;

--
-- Name: Kayit_kayitId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Kayit" ALTER COLUMN "kayitId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Kayit_kayitId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Personel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Personel" (
    "personelId" integer NOT NULL,
    "yoneticiId" integer DEFAULT 3 CONSTRAINT "Personel_yonetmenId_not_null" NOT NULL,
    gorev text DEFAULT '60'::text NOT NULL,
    "calisanId" integer NOT NULL
);


ALTER TABLE public."Personel" OWNER TO postgres;

--
-- Name: Personel_personelId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Personel" ALTER COLUMN "personelId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Personel_personelId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Sirket; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Sirket" (
    "sirketİd" integer NOT NULL,
    ad character varying(40) NOT NULL,
    adres text DEFAULT '60'::text NOT NULL,
    "depoId" integer NOT NULL
);


ALTER TABLE public."Sirket" OWNER TO postgres;

--
-- Name: Sirket_sirketİd_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Sirket" ALTER COLUMN "sirketİd" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Sirket_sirketİd_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Turler; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Turler" (
    "turId" integer NOT NULL,
    ad character varying(40) NOT NULL
);


ALTER TABLE public."Turler" OWNER TO postgres;

--
-- Name: Turler_turId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Turler" ALTER COLUMN "turId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Turler_turId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Veteriner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Veteriner" (
    "vetId" integer NOT NULL,
    "adSoyad" character varying(40) NOT NULL,
    tel text DEFAULT ('05'::text || lpad((floor((random() * (100000000)::double precision)))::text, 9, '0'::text)) NOT NULL
);


ALTER TABLE public."Veteriner" OWNER TO postgres;

--
-- Name: Veteriner_vetId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Veteriner" ALTER COLUMN "vetId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Veteriner_vetId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Yonetici; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Yonetici" (
    "yoneticiId" integer NOT NULL,
    "calisanId" integer NOT NULL
);


ALTER TABLE public."Yonetici" OWNER TO postgres;

--
-- Name: Yonetici_yoneticiId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Yonetici" ALTER COLUMN "yoneticiId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Yonetici_yoneticiId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: Ziyaretci; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."Ziyaretci" (
    "ziyaretciId" integer NOT NULL,
    "adSoyad" character varying NOT NULL,
    yas integer DEFAULT (floor((random() * (65)::double precision)))::integer NOT NULL
);


ALTER TABLE public."Ziyaretci" OWNER TO postgres;

--
-- Name: Ziyaretci_ziyaretciId_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public."Ziyaretci" ALTER COLUMN "ziyaretciId" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public."Ziyaretci_ziyaretciId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: Alanlar; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Alanlar" OVERRIDING SYSTEM VALUE VALUES
	(1, 'Hayvanlar', 'Kuzey', 50000),
	(2, 'Kafeler', 'güney', 20000),
	(3, 'Çalışan yeri', 'batı', 5000),
	(4, 'Bahçe', 'doğu', 10000);


--
-- Data for Name: Bakıcı; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Bakıcı" OVERRIDING SYSTEM VALUE VALUES
	(2, 2, 10),
	(3, 2, 13),
	(4, 2, 15),
	(5, 2, 20),
	(7, 2, 22);


--
-- Data for Name: Beslenme; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Beslenme" OVERRIDING SYSTEM VALUE VALUES
	(11, 200, '06:30:00', 15, '2025-05-05');


--
-- Data for Name: Biletler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Biletler" OVERRIDING SYSTEM VALUE VALUES
	(29, '2024-12-25', 100, 'Tam Fiyat', 8),
	(30, '2025-08-06', 50, 'Genç Tarife', 6),
	(32, '2024-06-25', 100, 'Tam Fiyat', 7),
	(35, '2025-08-06', 50, 'Genç Tarife', 13),
	(36, '2021-02-02', 100, 'Tam Fiyat', 14),
	(37, '2025-03-07', 100, 'Tam Fiyat', 15),
	(38, '2024-04-30', 100, 'Tam Fiyat', 16),
	(39, '2023-05-06', 0, 'Ücretsiz Çocuk', 17),
	(41, '2021-01-26', 0, 'Ücretsiz Çocuk', 18),
	(42, '2025-04-11', 100, 'Tam Fiyat', 19),
	(43, '2021-01-04', 100, 'Tam Fiyat', 21),
	(44, '2022-10-04', 0, 'Ücretsiz Çocuk', 22),
	(45, '2024-07-26', 100, 'Tam Fiyat', 23),
	(46, '2022-12-06', 100, 'Tam Fiyat', 24),
	(47, '2021-02-25', 0, 'Ücretsiz Çocuk', 25),
	(48, '2022-05-19', 100, 'Tam Fiyat', 26),
	(49, '2025-02-07', 100, 'Tam Fiyat', 27),
	(50, '2024-07-12', 50, 'Genç Tarife', 28),
	(51, '2025-07-30', 100, 'Tam Fiyat', 29),
	(52, '1970-01-01', 50, 'Genç Tarife', 30),
	(53, '2023-06-03', 100, 'Tam Fiyat', 31),
	(54, '2021-06-28', 100, 'Tam Fiyat', 32),
	(55, '2025-08-29', 100, 'Tam Fiyat', 33),
	(56, '2022-01-06', 100, 'Tam Fiyat', 34),
	(57, '2025-10-20', 50, 'Genç Tarife', 35),
	(58, '2024-07-09', 50, 'Genç Tarife', 36),
	(59, '2022-01-14', 100, 'Tam Fiyat', 37),
	(60, '2021-12-13', 100, 'Tam Fiyat', 38),
	(61, '2022-09-09', 100, 'Tam Fiyat', 39),
	(62, '2024-02-20', 50, 'Genç Tarife', 40),
	(63, '2022-06-18', 100, 'Tam Fiyat', 41),
	(64, '1970-01-01', 100, 'Tam Fiyat', 42),
	(65, '2025-08-12', 0, 'Ücretsiz Çocuk', 43),
	(66, '2024-03-19', 100, 'Tam Fiyat', 44);


--
-- Data for Name: Calisan; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Calisan" OVERRIDING SYSTEM VALUE VALUES
	(23, 'Emre  Türk', '05124016376'),
	(22, 'Burak Gül', '05952015995'),
	(21, 'Kaan Ersoy', '05260008093'),
	(20, 'Emir Bal', '05791749171'),
	(19, 'Kemal Uzun', '05564230466'),
	(18, 'Zehra Karataş', '05748399553'),
	(10, 'Ayşe Er', '05509936213'),
	(12, 'Betul Yılmaz', '05802016581'),
	(13, 'Ali Baş', '05288274819'),
	(14, 'Mehmet Kahraman', '05764940734'),
	(15, 'Mustafa Ata', '05151905766'),
	(16, 'Fatma Kara', '05929669991'),
	(17, 'Sultan Ak', '05902171630');


--
-- Data for Name: Depo; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Depo" OVERRIDING SYSTEM VALUE VALUES
	(1, 'A', 5000),
	(3, 'B', 7500),
	(4, 'c', 8000),
	(5, 'd', 15000),
	(6, 'f', 500);


--
-- Data for Name: HayvanBak; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."HayvanBak" VALUES
	(15, 7),
	(16, 7),
	(17, 7),
	(18, 7),
	(19, 7),
	(20, 7),
	(21, 7),
	(22, 7),
	(23, 7),
	(24, 7),
	(26, 7),
	(27, 7),
	(28, 7),
	(29, 7),
	(30, 7),
	(31, 7),
	(32, 7),
	(33, 7),
	(34, 7),
	(35, 7),
	(36, 7),
	(37, 7),
	(38, 7),
	(39, 7),
	(40, 7),
	(41, 7),
	(46, 7),
	(47, 7),
	(48, 7),
	(49, 7),
	(50, 7),
	(51, 7),
	(15, 5),
	(17, 3),
	(19, 3),
	(24, 4),
	(26, 3),
	(27, 2),
	(33, 5),
	(34, 5),
	(35, 5),
	(36, 4),
	(37, 5),
	(39, 2),
	(40, 4),
	(48, 2),
	(50, 3);


--
-- Data for Name: HayvanVet; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."HayvanVet" VALUES
	(37, 2),
	(38, 2),
	(39, 2),
	(40, 2),
	(41, 2),
	(46, 2),
	(47, 2),
	(48, 2),
	(49, 2),
	(50, 2),
	(51, 2),
	(36, 10),
	(38, 10),
	(39, 4),
	(40, 3),
	(41, 3),
	(46, 1),
	(48, 8),
	(50, 1);


--
-- Data for Name: Hayvanlar; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Hayvanlar" OVERRIDING SYSTEM VALUE VALUES
	(15, 'kaplan', 'erkek', 1, 1, 5),
	(35, 'pelikan', 'dişi', 2, 1, 5),
	(39, 'leopar', 'dişi', 1, 1, 5),
	(435, 'at', 'erkek', 1, 1, 3),
	(16, 'at', 'dişi', 1, 1, 5),
	(17, 'kurt', 'dişi', 1, 1, 5),
	(18, 'ayı', 'dişi', 1, 1, 5),
	(19, 'kanguru', 'dişi', 1, 1, 5),
	(20, 'panda', 'dişi', 1, 1, 5),
	(22, 'penguen', 'dişi', 2, 1, 5),
	(23, 'papagan', 'dişi', 2, 1, 5),
	(24, 'timsah', 'dişi', 3, 1, 5),
	(26, 'sırtlan', 'dişi', 1, 1, 5),
	(27, 'zebra', 'dişi', 1, 1, 5),
	(28, 'leopaar', 'dişi', 1, 1, 5),
	(29, 'gergedan', 'dişi', 1, 1, 5),
	(30, 'maymun', 'dişi', 1, 1, 5),
	(31, 'aslan', 'dişi', 1, 1, 5),
	(32, 'kaplan', 'dişi', 1, 1, 5),
	(33, 'panda', 'dişi', 1, 1, 5),
	(34, 'fil', 'dişi', 1, 1, 5),
	(21, 'zürafa', 'dişi', 1, 1, 5),
	(38, 'zürafa', 'dişi', 1, 1, 5),
	(36, 'penguen', 'dişi', 2, 1, 5),
	(37, 'timsah', 'dişi', 3, 1, 5),
	(40, 'aslan', 'dişi', 1, 1, 5),
	(41, 'zebra', 'dişi', 1, 1, 5),
	(46, 'at', 'dişi', 1, 1, 5),
	(47, 'eşşek', 'dişi', 1, 1, 5),
	(48, 'jaguar', 'dişi', 1, 1, 5),
	(49, 'jaguar', 'dişi', 1, 1, 5),
	(50, 'kanguru', 'dişi', 1, 1, 5),
	(51, 'panda', 'dişi', 1, 1, 5);


--
-- Data for Name: Kayit; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Kayit" OVERRIDING SYSTEM VALUE VALUES
	(3, '2023-08-13', 15),
	(4, '2024-06-26', 16),
	(5, '2024-09-18', 17),
	(6, '2021-09-10', 18),
	(7, '2023-08-01', 19),
	(8, '2025-07-15', 20),
	(9, '2022-08-20', 21),
	(10, '2025-08-24', 22),
	(11, '2024-04-15', 23),
	(12, '2024-11-07', 24),
	(13, '2023-07-07', 26),
	(14, '2022-04-06', 27),
	(15, '2023-12-19', 28),
	(16, '2021-09-07', 29),
	(17, '2025-10-19', 30),
	(18, '2023-06-17', 31),
	(19, '2021-06-06', 32),
	(20, '2023-04-11', 33),
	(21, '2021-01-17', 34),
	(22, '2023-06-30', 35),
	(23, '2021-06-23', 36),
	(24, '2024-11-22', 37),
	(25, '2023-05-16', 38),
	(26, '2022-11-04', 39),
	(27, '2021-07-14', 40),
	(28, '2023-06-02', 41),
	(29, '2021-03-26', 46),
	(30, '2022-06-19', 47),
	(31, '2023-04-14', 48),
	(32, '2023-07-26', 49),
	(33, '2023-04-03', 50),
	(34, '2021-05-31', 51);


--
-- Data for Name: Personel; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Personel" OVERRIDING SYSTEM VALUE VALUES
	(1, 3, 'güvenlik', 23),
	(2, 3, 'güvenlik', 19),
	(4, 3, 'kafe', 12),
	(5, 3, 'temizlik', 18),
	(6, 3, 'bahçe', 16);


--
-- Data for Name: Sirket; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Sirket" OVERRIDING SYSTEM VALUE VALUES
	(1, 'ard', 'istanbul', 1),
	(3, 'hyt', 'hatay', 3),
	(4, 'brs', 'Bursa', 4),
	(5, 'aft', 'afyon', 3),
	(6, 'kny', 'konya', 5),
	(7, 'sms', 'samsun', 1),
	(8, 'izm', 'izmir', 5);


--
-- Data for Name: Turler; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Turler" OVERRIDING SYSTEM VALUE VALUES
	(1, 'Memeli'),
	(2, 'Kuşlar'),
	(3, 'Sürüngenler'),
	(4, 'Balıklar');


--
-- Data for Name: Veteriner; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Veteriner" OVERRIDING SYSTEM VALUE VALUES
	(1, 'Özlem Karadeniz', '05046211988'),
	(2, 'Levent Gürbüz', '05027215014'),
	(3, 'Figen Başar', '05060841317'),
	(4, 'Cemal Tunahan', '05067613598'),
	(6, 'Nihan Özer

', '05095057346'),
	(7, 'Barış Güven', '05048954070'),
	(8, 'Şule Tamer', '05067713259'),
	(9, 'Volkan Ersoy', '05031117034'),
	(10, 'Ebru Çakır', '05045161854'),
	(11, 'Deniz Sarı', '05099132494');


--
-- Data for Name: Yonetici; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Yonetici" OVERRIDING SYSTEM VALUE VALUES
	(1, 21),
	(2, 14),
	(3, 17);


--
-- Data for Name: Ziyaretci; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."Ziyaretci" OVERRIDING SYSTEM VALUE VALUES
	(6, 'Nisa Aktaş', 15),
	(7, 'Ayşe Sarı', 40),
	(8, 'Gül Beyaz', 35),
	(13, 'kemal baş', 19),
	(14, 'Melis Aydın', 52),
	(15, 'Ramazan Tunç

', 50),
	(16, 'Esra Doğan', 47),
	(17, 'Gökhan Sezer', 0),
	(18, 'Burcu Tekin', 3),
	(19, 'Ömer Balcı', 54),
	(21, 'Cansu Yalçın', 60),
	(22, 'Kadir Erdem', 4),
	(23, 'Sibel Kurt', 63),
	(24, 'Okan Taş', 23),
	(25, 'Gamze Ergin', 4),
	(26, 'Serkan Uslu', 64),
	(27, 'Derya Korkmaz', 50),
	(28, 'Hakan Polat', 17),
	(29, 'Selin Öztürk', 59),
	(30, 'İsmail Karaca', 11),
	(31, 'Merve Aksoy', 24),
	(32, 'Hasan Çetin

', 39),
	(33, 'Emine Yıldırım', 33),
	(34, 'Yusuf Kaplan', 56),
	(35, 'Hatice Güneş', 20),
	(36, 'Murat Acar', 17),
	(37, 'Fatma Özkan', 32),
	(38, 'Ali Koç', 31),
	(39, 'Zeynep Arslan', 31),
	(40, 'Mustafa Şahin', 10),
	(41, 'Elif Çelik', 64),
	(42, 'Mehmet Kaya', 45),
	(43, 'Ayşe Demir', 5),
	(44, 'Ahmet Yılmaz', 32);


--
-- Name: Alanlar_alanId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Alanlar_alanId_seq"', 4, true);


--
-- Name: Bakıcı_bakıcıId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Bakıcı_bakıcıId_seq"', 7, true);


--
-- Name: Beslenme_beslenmeId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Beslenme_beslenmeId_seq"', 12, true);


--
-- Name: Biletler_biletKodu_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Biletler_biletKodu_seq"', 67, true);


--
-- Name: Calisan_calisanId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Calisan_calisanId_seq"', 23, true);


--
-- Name: Depo_depoId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Depo_depoId_seq"', 6, true);


--
-- Name: Hayvanlar_hayvanId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Hayvanlar_hayvanId_seq"', 435, true);


--
-- Name: Kayit_kayitId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Kayit_kayitId_seq"', 758, true);


--
-- Name: Personel_personelId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Personel_personelId_seq"', 6, true);


--
-- Name: Sirket_sirketİd_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Sirket_sirketİd_seq"', 8, true);


--
-- Name: Turler_turId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Turler_turId_seq"', 4, true);


--
-- Name: Veteriner_vetId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Veteriner_vetId_seq"', 11, true);


--
-- Name: Yonetici_yoneticiId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Yonetici_yoneticiId_seq"', 4, true);


--
-- Name: Ziyaretci_ziyaretciId_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."Ziyaretci_ziyaretciId_seq"', 44, true);


--
-- Name: Biletler Biletler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Biletler"
    ADD CONSTRAINT "Biletler_pkey" PRIMARY KEY ("biletKodu");


--
-- Name: Calisan Calisan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Calisan"
    ADD CONSTRAINT "Calisan_pkey" PRIMARY KEY ("calisanId");


--
-- Name: HayvanBak HayvanBak_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanBak"
    ADD CONSTRAINT "HayvanBak_pkey" PRIMARY KEY ("bakıcıId", "hayvanId");


--
-- Name: HayvanVet HayvanVet_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanVet"
    ADD CONSTRAINT "HayvanVet_pkey" PRIMARY KEY ("hayvanId", "vetId");


--
-- Name: Sirket Sirket_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sirket"
    ADD CONSTRAINT "Sirket_pkey" PRIMARY KEY ("sirketİd");


--
-- Name: Turler Turler_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Turler"
    ADD CONSTRAINT "Turler_pkey" PRIMARY KEY ("turId");


--
-- Name: Alanlar unique_Alanlar_alanId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Alanlar"
    ADD CONSTRAINT "unique_Alanlar_alanId" PRIMARY KEY ("alanId");


--
-- Name: Bakıcı unique_Bakıcı_bakıcıId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bakıcı"
    ADD CONSTRAINT "unique_Bakıcı_bakıcıId" PRIMARY KEY ("bakıcıId");


--
-- Name: Beslenme unique_Beslenme_beslenmeId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Beslenme"
    ADD CONSTRAINT "unique_Beslenme_beslenmeId" PRIMARY KEY ("beslenmeId");


--
-- Name: Biletler unique_Biletler_biletKodu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Biletler"
    ADD CONSTRAINT "unique_Biletler_biletKodu" UNIQUE ("biletKodu");


--
-- Name: Calisan unique_Calisan_calisanId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Calisan"
    ADD CONSTRAINT "unique_Calisan_calisanId" UNIQUE ("calisanId");


--
-- Name: Depo unique_Depo_depoId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Depo"
    ADD CONSTRAINT "unique_Depo_depoId" PRIMARY KEY ("depoId");


--
-- Name: Hayvanlar unique_Hayvanlar_hayvanId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hayvanlar"
    ADD CONSTRAINT "unique_Hayvanlar_hayvanId" PRIMARY KEY ("hayvanId");


--
-- Name: Kayit unique_Kayit_kayidId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kayit"
    ADD CONSTRAINT "unique_Kayit_kayidId" PRIMARY KEY ("kayitId");


--
-- Name: Personel unique_Personel_personelId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "unique_Personel_personelId" PRIMARY KEY ("personelId");


--
-- Name: Sirket unique_Sirket_sirketİd; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sirket"
    ADD CONSTRAINT "unique_Sirket_sirketİd" UNIQUE ("sirketİd");


--
-- Name: Turler unique_Turler_turId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Turler"
    ADD CONSTRAINT "unique_Turler_turId" UNIQUE ("turId");


--
-- Name: Veteriner unique_Veteriner_vetId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Veteriner"
    ADD CONSTRAINT "unique_Veteriner_vetId" PRIMARY KEY ("vetId");


--
-- Name: Yonetici unique_Yonetici_yoneticiId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetici"
    ADD CONSTRAINT "unique_Yonetici_yoneticiId" PRIMARY KEY ("yoneticiId");


--
-- Name: Ziyaretci unique_Ziyaretci_ziyaretciId; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Ziyaretci"
    ADD CONSTRAINT "unique_Ziyaretci_ziyaretciId" PRIMARY KEY ("ziyaretciId");


--
-- Name: HayvanBak unique_hayvan_bakici; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanBak"
    ADD CONSTRAINT unique_hayvan_bakici UNIQUE ("hayvanId", "bakıcıId");


--
-- Name: HayvanBak unique_hayvan_hayvanlar; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanBak"
    ADD CONSTRAINT unique_hayvan_hayvanlar UNIQUE ("hayvanId", "bakıcıId");


--
-- Name: HayvanVet unique_hayvan_hayvanvetler; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanVet"
    ADD CONSTRAINT unique_hayvan_hayvanvetler UNIQUE ("hayvanId", "vetId");


--
-- Name: HayvanVet unique_hayvan_veteriner; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanVet"
    ADD CONSTRAINT unique_hayvan_veteriner UNIQUE ("hayvanId", "vetId");


--
-- Name: index_bakıcıId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_bakıcıId" ON public."HayvanBak" USING btree ("bakıcıId");


--
-- Name: index_hayvanId; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "index_hayvanId" ON public."HayvanVet" USING btree ("hayvanId");


--
-- Name: HayvanBak bakicikontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bakicikontrol BEFORE INSERT ON public."HayvanBak" FOR EACH ROW EXECUTE FUNCTION public.kontrolbakici();


--
-- Name: Bakıcı bakıcıkontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "bakıcıkontrol" BEFORE INSERT ON public."Bakıcı" FOR EACH ROW EXECUTE FUNCTION public.calisankontrol();


--
-- Name: Biletler bilettarife; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER bilettarife BEFORE INSERT ON public."Biletler" FOR EACH ROW EXECUTE FUNCTION public.yasagoretarife();


--
-- Name: Personel personelkontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER personelkontrol BEFORE INSERT ON public."Personel" FOR EACH ROW EXECUTE FUNCTION public.calisankontrol();


--
-- Name: HayvanVet vetKontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "vetKontrol" BEFORE INSERT ON public."HayvanVet" FOR EACH ROW EXECUTE FUNCTION public.kontrolvet();


--
-- Name: Yonetici yoneticikontrol; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER yoneticikontrol BEFORE INSERT ON public."Yonetici" FOR EACH ROW EXECUTE FUNCTION public.calisankontrol();


--
-- Name: Hayvanlar link_Alanlar_Hayvanlar; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hayvanlar"
    ADD CONSTRAINT "link_Alanlar_Hayvanlar" FOREIGN KEY ("alanId") REFERENCES public."Alanlar"("alanId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HayvanBak link_Bakıcı_HayvanBak; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanBak"
    ADD CONSTRAINT "link_Bakıcı_HayvanBak" FOREIGN KEY ("bakıcıId") REFERENCES public."Bakıcı"("bakıcıId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Bakıcı link_Calisan_Bakıcı; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bakıcı"
    ADD CONSTRAINT "link_Calisan_Bakıcı" FOREIGN KEY ("calisanId") REFERENCES public."Calisan"("calisanId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Personel link_Calisan_Personel; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "link_Calisan_Personel" FOREIGN KEY ("calisanId") REFERENCES public."Calisan"("calisanId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Yonetici link_Calisan_Yonetici; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Yonetici"
    ADD CONSTRAINT "link_Calisan_Yonetici" FOREIGN KEY ("calisanId") REFERENCES public."Calisan"("calisanId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Sirket link_Depo_Sirket; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Sirket"
    ADD CONSTRAINT "link_Depo_Sirket" FOREIGN KEY ("depoId") REFERENCES public."Depo"("depoId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Beslenme link_Hayvanlar_Beslenme; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Beslenme"
    ADD CONSTRAINT "link_Hayvanlar_Beslenme" FOREIGN KEY ("hayvanId") REFERENCES public."Hayvanlar"("hayvanId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HayvanBak link_Hayvanlar_HayvanBak; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanBak"
    ADD CONSTRAINT "link_Hayvanlar_HayvanBak" FOREIGN KEY ("hayvanId") REFERENCES public."Hayvanlar"("hayvanId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HayvanVet link_Hayvanlar_HayvanVet; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanVet"
    ADD CONSTRAINT "link_Hayvanlar_HayvanVet" FOREIGN KEY ("hayvanId") REFERENCES public."Hayvanlar"("hayvanId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Kayit link_Hayvanlar_Kayit; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Kayit"
    ADD CONSTRAINT "link_Hayvanlar_Kayit" FOREIGN KEY ("hayvanId") REFERENCES public."Hayvanlar"("hayvanId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Hayvanlar link_Turler_Hayvanlar_2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Hayvanlar"
    ADD CONSTRAINT "link_Turler_Hayvanlar_2" FOREIGN KEY ("turId") REFERENCES public."Turler"("turId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: HayvanVet link_Veteriner_HayvanVet; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."HayvanVet"
    ADD CONSTRAINT "link_Veteriner_HayvanVet" FOREIGN KEY ("vetId") REFERENCES public."Veteriner"("vetId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Bakıcı link_Yonetici_Bakıcı; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Bakıcı"
    ADD CONSTRAINT "link_Yonetici_Bakıcı" FOREIGN KEY ("yöneticiId") REFERENCES public."Yonetici"("yoneticiId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Personel link_Yonetici_Personel; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Personel"
    ADD CONSTRAINT "link_Yonetici_Personel" FOREIGN KEY ("yoneticiId") REFERENCES public."Yonetici"("yoneticiId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: Biletler link_Ziyaretci_Biletler; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."Biletler"
    ADD CONSTRAINT "link_Ziyaretci_Biletler" FOREIGN KEY ("ziyaretciId") REFERENCES public."Ziyaretci"("ziyaretciId") MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 8RNbaqHx4uMtifv9Xa7cFza8kmo2GvWEemOH5GGCa14HSk67keNBKwiJUT5HQpx

