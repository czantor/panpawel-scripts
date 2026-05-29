/*
  Sierotki-PanPawel.jsx
  Wersja: 1.0

  Skrypt do walki z sierotkami (wiszącymi spójnikami) w Adobe Illustrator.

  Autor adaptacji:  pan-pawel
  Bazuje na:        Nobr-auto.jsx by daani-rika
                    https://github.com/daani-rika/Illustrator-scripts

  ─────────────────────────────────────────────────────────────────────────
  MOJE ZMIANY WZGLĘDEM ORYGINAŁU
  ─────────────────────────────────────────────────────────────────────────
  >> Polski alfabet w regexie: a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ
     (oryginał obsługiwał tylko cyrylicę).
  >> Konfiguracja na górze funkcji: zmienne maxWordLength i letters
     wyciągnięte z regexu — łatwo zmienisz długość słowa lub alfabet.
  >> Polski komentarz nagłówkowy z opisem działania i ograniczeń.

  Logika (dwa tryby, pętla po TextFrame, aplikowanie No Break) — daani-rika.
  Bazuje na: https://community.adobe.com/t5/illustrator/select-part-of-point-text-objects-matching-a-regex-expression/td-p/8919738

  ─────────────────────────────────────────────────────────────────────────
  CO ROBI
  ─────────────────────────────────────────────────────────────────────────
  Tryb 1 — zaznaczona ramka tekstowa (TextFrame):
      Skrypt wyszukuje 1- i 2-literowe słowa (głównie polskie spójniki
      i przyimki: a, i, o, u, w, z, we, ze, do, na, po, za, od, …)
      i nadaje im atrybut "No Break", który zapobiega zostawianiu ich
      na końcu wiersza (czyli klasyczne "wiszące spójniki").

  Tryb 2 — zaznaczony fragment tekstu (TextRange):
      Skrypt po prostu stosuje "No Break" do zaznaczenia.

  ─────────────────────────────────────────────────────────────────────────
  KONFIGURACJA
  ─────────────────────────────────────────────────────────────────────────
  maxWordLength — maks. długość słowa łączonego z następnym (domyślnie 2).
      Ustaw 3, żeby łapać też 3-literowe (lub, ale, czy, dla, oraz…),
      ale uwaga: złapie wtedy też zwykłe 3-literowe słowa typu "kot", "dom",
      co może być niepożądane.

  letters — klasa znaków traktowanych jako "litera". Można dopisać
      np. cyrylicę: А-Яа-яёЁ — jeśli składasz teksty wielojęzyczne.

  ─────────────────────────────────────────────────────────────────────────
  WAŻNE OGRANICZENIE ILLUSTRATORA
  ─────────────────────────────────────────────────────────────────────────
  Illustrator NIE rozpoznaje znaku NBSP (U+00A0, twarda spacja z InDesigna
  czy z Worda). Atrybut "No Break" to JEDYNA metoda zapobiegania złym
  łamaniom, którą Illustrator faktycznie respektuje — i właśnie ją stosuje
  ten skrypt.
*/

function NoBreak() {
    var doc = app.activeDocument;
    var sel = doc.selection;

    // Maks. długość słowa łączonego z następnym
    var maxWordLength = 2;

    // Polski alfabet (z diakrytykami) + podstawowy łaciński
    var letters = "a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ";

    var pattern = "\\s(((([" + letters + "]){1," + maxWordLength + "})(\\s[" + letters + "])+)+)";
    var grep = new RegExp(pattern, "ig");

    var result = [];

    if (sel.typename == "TextRange") {
        sel.characterAttributes.noBreak = true;
    } else {
        for (var i = 0; i < sel.length; i++) {
            if (sel[i].typename == "TextFrame") {
                var txtFr = sel[i];
                grep.lastIndex = 0;
                while (result = grep.exec(txtFr.contents)) {
                    try {
                        var aCon = txtFr.characters[result.index + 1];
                        aCon.length = result[1].length;
                        aCon.characterAttributes.noBreak = true;
                    } catch (e) {};
                }
            }
        }
    }
}

NoBreak();
