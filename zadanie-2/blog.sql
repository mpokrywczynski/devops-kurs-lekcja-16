-- ============================================================
-- Baza bloga – schemat w 3NF
-- Dlaczego 3NF:
--  1NF: każda komórka ma jedną wartość – tagi nie są listą w artykule,
--       tylko osobnymi wierszami w artykuly_tagi.
--  2NF: jedyny klucz złożony to (artykul_id, tag_id) w artykuly_tagi;
--       tabela nie ma innych kolumn, więc nic nie zależy od części klucza.
--  3NF: brak zależności przechodnich – dane autora (email, imię) są tylko
--       w autorzy, nazwa kategorii tylko w kategorie; artykuł trzyma same
--       klucze obce autor_id i kategoria_id.
--  artykuly_tagi realizuje relację M:N (artykuł ma wiele tagów, tag ma
--  wiele artykułów) – w modelu relacyjnym M:N wymaga tabeli łączącej.
-- ============================================================

CREATE TABLE autorzy (
    id        BIGSERIAL PRIMARY KEY,
    login     TEXT NOT NULL UNIQUE,
    email     TEXT NOT NULL UNIQUE,
    imie      TEXT NOT NULL,
    nazwisko  TEXT NOT NULL,
    utworzony TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE kategorie (
    id    BIGSERIAL PRIMARY KEY,
    nazwa TEXT NOT NULL UNIQUE
);

CREATE TABLE artykuly (
    id           BIGSERIAL PRIMARY KEY,
    autor_id     BIGINT NOT NULL REFERENCES autorzy(id)   ON DELETE RESTRICT,
    kategoria_id BIGINT NOT NULL REFERENCES kategorie(id) ON DELETE RESTRICT,
    tytul        TEXT NOT NULL,
    tresc        TEXT NOT NULL,
    opublikowany TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tagi (
    id    BIGSERIAL PRIMARY KEY,
    nazwa TEXT NOT NULL UNIQUE
);

-- tabela łącząca: relacja M:N artykuły <-> tagi
CREATE TABLE artykuly_tagi (
    artykul_id BIGINT NOT NULL REFERENCES artykuly(id) ON DELETE CASCADE,
    tag_id     BIGINT NOT NULL REFERENCES tagi(id)     ON DELETE CASCADE,
    PRIMARY KEY (artykul_id, tag_id)
);

CREATE TABLE komentarze (
    id         BIGSERIAL PRIMARY KEY,
    artykul_id BIGINT NOT NULL REFERENCES artykuly(id) ON DELETE CASCADE,
    autor_id   BIGINT NOT NULL REFERENCES autorzy(id)  ON DELETE RESTRICT,
    tresc      TEXT NOT NULL,
    dodany     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- Dane testowe: 20 autorów, 100 artykułów, 500 komentarzy
-- ============================================================

INSERT INTO autorzy (login, email, imie, nazwisko)
SELECT 'autor' || i, 'autor' || i || '@blog.test', 'Imię' || i, 'Nazwisko' || i
FROM generate_series(1, 20) AS i;

INSERT INTO kategorie (nazwa)
VALUES ('DevOps'), ('Linux'), ('Sieci'), ('Bazy danych'), ('Bezpieczeństwo');

INSERT INTO tagi (nazwa)
VALUES ('bash'), ('nginx'), ('git'), ('docker'), ('ssh'), ('tls'), ('dns'), ('postgresql'),
       ('mysql'), ('systemd'), ('kopie'), ('monitoring'), ('wydajność'), ('sql'), ('chmura');

INSERT INTO artykuly (autor_id, kategoria_id, tytul, tresc, opublikowany)
SELECT 1 + (i % 20),
       1 + (i % 5),
       'Artykuł ' || i,
       'Treść artykułu ' || i,
       now() - (random() * 365 || ' days')::interval
FROM generate_series(1, 100) AS i;

-- każdy artykuł dostaje 1–3 tagi
INSERT INTO artykuly_tagi (artykul_id, tag_id)
SELECT a.id, t.tag_id
FROM artykuly a
CROSS JOIN LATERAL (VALUES (1 + a.id % 15), (1 + (a.id * 7) % 15), (1 + (a.id * 11) % 15)) AS t(tag_id)
ON CONFLICT DO NOTHING;

INSERT INTO komentarze (artykul_id, autor_id, tresc, dodany)
SELECT 1 + (random() * 89)::int,      -- artykuły 1–90; 91–100 zostają bez komentarzy
       1 + (random() * 19)::int,
       'Komentarz ' || i,
       now() - (random() * 30 || ' days')::interval
FROM generate_series(1, 500) AS i;

ANALYZE;
