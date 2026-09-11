# panpawel-scripts — skrypty do Adobe Illustrator

**Skrypty .jsx dla polskich grafików rozwiązujące realne problemy w Adobe Illustrator. Startujemy od najważniejszego dla polskiego składu: automatycznej walki z sierotkami (wiszącymi spójnikami).**

Repo zawiera skrypty rozwiązujące powtarzalne, codzienne problemy w pracy z Illustratorem — z naciskiem na typografię polskiego tekstu. Każdy skrypt jest opisany, gotowy do wgrania i nie wymaga programowania.

## Problem: sierotki w Adobe Illustrator

W polskiej typografii jednoliterowe spójniki i przyimki (**a, i, o, u, w, z**) nie powinny zostawać na końcu wiersza — nazywamy je **sierotkami** (albo wiszącymi spójnikami). Dotyczy to też części dwuliterowych (**we, ze, do, na, po, za, od**). To podstawowa zasada składu — i jednocześnie coś, co Adobe Illustrator olewa.

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

## Strona „Pobierz materiały” dla klientów foto/wideo

Folder [`foto-wideo-download-page/`](foto-wideo-download-page/) zawiera statyczną stronę w stylistyce aktualnych ofert www 300PROCENT (ciemny szablon, amber, Fraunces/Inter), z której klient pobiera zdjęcia i filmy trzymane na Dysku Google (Workspace). Instrukcja wdrożenia: [foto-wideo-download-page/README.md](foto-wideo-download-page/README.md). Demo: `index.html?demo=1`.

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

## Tematy / słowa kluczowe

Adobe Illustrator, illustrator scripts, jsx scripts, polska typografia, polish typography, sierotki, sierotki illustrator, wiszące spójniki, polskie sierotki, no-break, non-breaking space, polish orphans, typografia, skład tekstu, grafika dla grafików.

## Licencja

MIT — zobacz plik [LICENSE](LICENSE).
