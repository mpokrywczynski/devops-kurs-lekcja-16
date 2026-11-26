# Zadanie 2 – baza bloga (PostgreSQL 14)

Tabele: autorzy, kategorie, artykuly, tagi, artykuly_tagi, komentarze.
- artykuł ma jednego autora i jedną kategorię (klucze obce w artykuly)
- tagi: relacja wiele-do-wielu przez tabelę łączącą artykuly_tagi
- komentarz należy do artykułu i ma autora
- dane testowe: 20 autorów, 100 artykułów, 500 komentarzy (generate_series)

Uruchomienie:
  sudo -u postgres createdb blog

Dlaczego 3NF – komentarz na początku blog.sql.
Wyniki raportów: wyniki.txt, struktura tabel: struktura.txt.
