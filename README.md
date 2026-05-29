# pan-pawel — scripts

Zbiór skryptów dla grafików rozwiązujących realne, powtarzalne problemy w pracy z Adobe Illustrator. Repo startuje od jednego, ale najważniejszego dla polskiego składu: walki z **wiszącymi spójnikami**.

## Problem

W polskiej typografii jednoliterowe spójniki i przyimki (**a, i, o, u, w, z**) nie powinny zostawać na końcu wiersza. Dotyczy to też części dwuliterowych (**we, ze, do, na, po, za, od**). To podstawowa zasada składu — i jednocześnie coś, co Illustrator olewa.

Gorzej: **Illustrator nie rozpoznaje standardowego znaku non-breaking space** (U+00A0). Jeśli wklejasz tekst z InDesigna albo z Worda z poprawnie wstawionymi twardymi spacjami — Illustrator potraktuje je jak zwykłe spacje i wszystko ci się rozjedzie.

Jedyna metoda, którą Illustrator naprawdę respektuje, to atrybut **No Break** ustawiony na znakach. Ręczne klikanie tego po każdym spójniku to katorga. Stąd ten skrypt.

## Skrypty

### Sierotki-PanPawel.jsx

Automatycznie znajduje wszystkie 1- i 2-literowe słowa w ramce tekstowej i nadaje im atrybut **No Break**. Po polsku łapie to głównie:

- **1 litera:** a, i, o, u, w, z
- **2 litery:** we, ze, do, na, po, za, od, ku, by, że, to…

**Dwa tryby:**

| Co masz zaznaczone | Co robi skrypt |
|---|---|
| Ramkę tekstową | Skanuje cały tekst regexem i no-breakuje wszystkie krótkie słowa |
| Fragment tekstu | Stosuje No Break tylko do zaznaczenia |

#### Co dodałem względem oryginału

Oryginalny skrypt [daani-rika](https://github.com/daani-rika/Illustrator-scripts#nobr-autojsx) obsługiwał tylko cyrylicę. Moje zmiany:

- **Polski alfabet w regexie.** Klasa znaków przerobiona z cyrylicy na `a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ` — działa na polskich diakrytykach (ąćęłńóśźż) i podstawowym łacińskim.
- **Wyciągnięta konfiguracja na górę pliku.** Zmienne `maxWordLength` (domyślnie 2) i `letters` są w pierwszych liniach funkcji — łatwo zmienisz długość łapanego słowa albo dodasz inny alfabet bez grzebania w samym regexie.
- **Polski komentarz nagłówkowy** z opisem działania, trybów pracy, konfiguracji i ograniczeń Illustratora (NBSP).
- **Pełna polska dokumentacja** (ten README) — z instrukcją instalacji pod Windows/macOS i wyjaśnieniem dlaczego ten skrypt w ogóle musi istnieć.

Logika skryptu (dwa tryby pracy, pętla po TextFrame, mechanizm aplikowania No Break) pochodzi od daani-rika i nie była ruszana.

#### Użycie

1. **Otwórz dokument w Illustratorze.**
2. **Zaznacz ramkę tekstową** (lub fragment tekstu w trybie edycji).
3. **File → Scripts → Sierotki-PanPawel** *(albo Other Script → wskaż plik)*.
4. Gotowe — spójniki są no-breakowane.

Możesz to sobie podpiąć pod skrót klawiszowy przez **Edit → Keyboard Shortcuts → Menu Commands → File → Scripts → Sierotki-PanPawel**.

## Instalacja skryptów Illustrator

### Wariant A — na stałe (pojawi się w menu File → Scripts)

Wrzuć plik `.jsx` do folderu skryptów Illustratora:

- **Windows (64-bit):** `C:\Program Files\Adobe\Adobe Illustrator [wersja]\Presets\pl_PL\Scripts\` *(lub `en_GB`, zależnie od języka instalacji)*
- **Windows (32-bit):** `C:\Program Files (x86)\Adobe\Adobe Illustrator\Presets\pl_PL\Scripts\`
- **macOS:** `/Applications/Adobe Illustrator [wersja]/Presets/pl_PL/Scripts/`

Po wrzuceniu **uruchom Illustratora od nowa**. Skrypt pojawi się w `File → Scripts`.

### Wariant B — jednorazowo

`File → Scripts → Other Script…` *(skrót: `Ctrl+F12` / `Cmd+F12`)* i wskaż plik `.jsx` z dowolnej lokalizacji. Nic nie kopiujesz, nic nie restartujesz.

## Atrybucja

- **Oryginalny skrypt:** [Nobr-auto.jsx](https://github.com/daani-rika/Illustrator-scripts#nobr-autojsx) — autor: [daani-rika](https://github.com/daani-rika)
- **Bazowy regex:** wątek na [Adobe Community](https://community.adobe.com/t5/illustrator/select-part-of-point-text-objects-matching-a-regex-expression/td-p/8919738)
- **Tip o adaptacji pod alfabet łaciński:** [Adobe Support Community](https://community.adobe.com/t5/illustrator-discussions/adobe-illustrator-does-not-use-standard-non-breaking-space-character-and-this-is-a-problem/m-p/13701954)
- **Modyfikacja PL (alfabet polski + diakrytyki, konfigurowalna długość słowa):** pan-pawel

## Licencja

MIT — zobacz plik [LICENSE](LICENSE).
