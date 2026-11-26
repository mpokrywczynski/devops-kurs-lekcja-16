-- 1. Dziesięć najpopularniejszych tagów
SELECT t.nazwa, count(*) AS liczba_artykulow
FROM tagi t
JOIN artykuly_tagi at ON at.tag_id = t.id
GROUP BY t.nazwa
ORDER BY liczba_artykulow DESC, t.nazwa
LIMIT 10;

-- 2. Kategorie: ile artykułów i ile komentarzy
SELECT k.nazwa,
       count(DISTINCT a.id) AS artykuly,
       count(c.id)          AS komentarze
FROM kategorie k
LEFT JOIN artykuly a   ON a.kategoria_id = k.id
LEFT JOIN komentarze c ON c.artykul_id = a.id
GROUP BY k.nazwa
ORDER BY artykuly DESC;

-- 3. Autorzy: liczba artykułów i średnia komentarzy na artykuł (CTE)
WITH na_artykul AS (
  SELECT a.id, a.autor_id, count(c.id) AS kom
  FROM artykuly a
  LEFT JOIN komentarze c ON c.artykul_id = a.id
  GROUP BY a.id, a.autor_id
)
SELECT au.login,
       count(n.id)                       AS artykuly,
       round(coalesce(avg(n.kom), 0), 1) AS sr_komentarzy
FROM autorzy au
LEFT JOIN na_artykul n ON n.autor_id = au.id
GROUP BY au.id, au.login
ORDER BY au.id;

-- 4. Artykuły bez ani jednego komentarza (antyzłączenie)
SELECT a.id, a.tytul
FROM artykuly a
LEFT JOIN komentarze c ON c.artykul_id = a.id
WHERE c.id IS NULL
ORDER BY a.id;

-- 5. Najnowszy artykuł w każdej kategorii (funkcja okna)
SELECT kategoria, tytul, opublikowany
FROM (
  SELECT k.nazwa AS kategoria, a.tytul, a.opublikowany,
         row_number() OVER (PARTITION BY k.id ORDER BY a.opublikowany DESC) AS nr
  FROM artykuly a
  JOIN kategorie k ON k.id = a.kategoria_id
) x
WHERE nr = 1
ORDER BY kategoria;
