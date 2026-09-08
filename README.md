# panpawel-scripts — skrypty do Adobe Illustrator

**Skrypty .jsx dla polskich grafików rozwiązujące realne problemy w Adobe Illustrator. Startujemy od najważniejszego dla polskiego składu: automatycznej walki z sierotkami (wiszącymi spójnikami).**

Repo zawiera skrypty rozwiązujące powtarzalne, codzienne problemy w pracy z Illustratorem — z naciskiem na typografię polskiego tekstu. Każdy skrypt jest opisany, gotowy do wgrania i nie wymaga programowania.

Dodatkowo jest tu mały pomocnik na macOS, który podpina **DaVinci Resolve Studio** pod **Claude Desktop** przez MCP - patrz sekcja [DaVinci Resolve + Claude (MCP)](#davinci-resolve--claude-mcp).

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

## Instalacja skryptów Illustrator

### Wariant A — na stałe (pojawi się w menu File → Scripts)

Wrzuć plik `.jsx` do folderu skryptów Illustratora:

- **Windows (64-bit):** `C:\Program Files\Adobe\Adobe Illustrator [wersja]\Presets\pl_PL\Scripts\` *(lub `en_GB`, zależnie od języka instalacji)*
- **Windows (32-bit):** `C:\Program Files (x86)\Adobe\Adobe Illustrator\Presets\pl_PL\Scripts\`
- **macOS:** `/Applications/Adobe Illustrator [wersja]/Presets/pl_PL/Scripts/`

Po wrzuceniu **uruchom Illustratora od nowa**. Skrypt pojawi się w `File → Scripts`.

### Wariant B — jednorazowo

`File → Scripts → Other Script…` *(skrót: `Ctrl+F12` / `Cmd+F12`)* i wskaż plik `.jsx` z dowolnej lokalizacji. Nic nie kopiujesz, nic nie restartujesz.

## DaVinci Resolve + Claude (MCP)

[resolve-claude-mcp](https://github.com/barckley75/resolve-claude-mcp) (autor: barckley75) to serwer MCP (Model Context Protocol), przez który Claude Desktop steruje DaVinci Resolve po jego API skryptowym - timeline, kolor, Fusion, render. Instalacja upstream wymaga ręcznej edycji `claude_desktop_config.json`, wpisania absolutnej ścieżki do sklonowanego repo i absolutnej ścieżki do `uv`. Łatwo to zepsuć, stąd skrypt w folderze `resolve-mcp/`, który robi to za ciebie.

Zanim zaczniesz:

- **Tylko macOS.** Na Windows ścieżki są inne (`fusionscript.dll`, `%APPDATA%\Claude\claude_desktop_config.json`) - ten skrypt tego nie obsługuje, zajrzyj do README upstream.
- **Wymagany DaVinci Resolve Studio** (18+). Darmowa wersja ma okrojony scripting i serwer MCP nie zadziała.
- Rzecz jest eksperymentalna. Claude może zmieniać twój projekt, więc pracuj na kopiach.

### Instalacja jedną komendą

```
git clone https://github.com/czantor/panpawel-scripts.git
cd panpawel-scripts
bash resolve-mcp/setup-resolve-mcp.sh
```

Domyślnie repo upstream ląduje w `~/resolve-claude-mcp`. Inny katalog:

```
bash resolve-mcp/setup-resolve-mcp.sh ~/inny/katalog
# albo
RESOLVE_MCP_DIR=~/inny/katalog bash resolve-mcp/setup-resolve-mcp.sh
```

Chcesz najpierw zobaczyć, co skrypt wpisze do configu, bez instalowania czegokolwiek:

```
bash resolve-mcp/setup-resolve-mcp.sh --dry-run
```

W trybie `--dry-run` na stdout leci wyłącznie gotowy JSON, więc `--dry-run | jq .` też działa.

### Co robi skrypt

1. Sprawdza, że to macOS, że są Xcode Command Line Tools (`xcode-select -p`) i że działa `git`.
2. Instaluje `uv`, jeśli go nie ma (Homebrew, a bez Homebrew oficjalny instalator `astral.sh`), i ustala jego **absolutną** ścieżkę. Claude Desktop startuje z launchd i nie widzi `PATH` z twojego `.zshrc`, więc samo `"command": "uv"` często nie działa.
3. Klonuje `resolve-claude-mcp` (albo robi `git pull`, jeśli już jest) i uruchamia `uv sync`.
4. Sprawdza, czy Resolve jest w `/Applications` i czy istnieje jego API skryptowe. Brak to tylko ostrzeżenie - config i tak się zapisze, Resolve Studio możesz doinstalować później.
5. Robi backup `claude_desktop_config.json` (`*.bak-<data>`), a potem dopisuje wpis `"resolve"` **nie ruszając innych serwerów MCP**. Jeśli plik nie istnieje, tworzy go. Jeśli jest zepsuty (niepoprawny JSON), odmawia zapisu i mówi ci o tym.
6. Przypomina, co zrobić dalej (patrz niżej).

### Ręcznie (bez skryptu)

Gotowy fragment jest w [`resolve-mcp/claude_desktop_config.example.json`](resolve-mcp/claude_desktop_config.example.json). Wklej go do `~/Library/Application Support/Claude/claude_desktop_config.json` i podmień dwie rzeczy:

- `/absolute/path/to/resolve-claude-mcp` - katalog, do którego sklonowałeś repo upstream (po `uv sync`).
- `/opt/homebrew/bin/uv` - wynik `which uv`. Na Apple Silicon z Homebrew to `/opt/homebrew/bin/uv`, na Intelu `/usr/local/bin/uv`, po instalatorze curl `/Users/<login>/.local/bin/uv` (pełna ścieżka, Claude Desktop nie rozwija `~` ani `$HOME`).

Jeśli plik ma już inne serwery w `"mcpServers"`, dopisz tylko blok `"resolve"` do środka. Nie twórz drugiego `"mcpServers"`.

### Po instalacji

1. **DaVinci Resolve:** Preferences → System → General → **External scripting using = Local**.
2. **Zamknij całkowicie Claude Desktop** (Cmd+Q, nie samo okno) i uruchom ponownie.
3. Resolve musi być uruchomiony **z otwartym projektem**.
4. Test w Claude: *"Jaki projekt mam otwarty w Resolve?"*

Opcjonalnie: `uv --directory ~/resolve-claude-mcp sync --extra transcription` włącza lokalną transkrypcję (tylko Apple Silicon). Narzędzie do zrzutów ekranu wymaga zgody na Screen Recording w ustawieniach macOS.

### Jeśli coś nie działa

| Objaw | Co sprawdzić |
|---|---|
| Claude nie widzi narzędzi Resolve | Czy Claude Desktop był zamknięty przez Cmd+Q, nie tylko okno. Czy `"command"` w configu to pełna ścieżka do `uv` (`which uv`). |
| `spawn uv ENOENT` w logach Claude | `uv` nie jest widoczne dla launchd - wpisz pełną ścieżkę zamiast `uv`. |
| Skrypt mówi, że config to niepoprawny JSON | Popraw plik ręcznie (np. `jq . claude_desktop_config.json` pokaże gdzie). Skrypt nic nie nadpisał, stare wersje są w `*.bak-<data>`. |
| Narzędzia są, ale każde zwraca błąd połączenia | Resolve nie jest uruchomiony, nie ma otwartego projektu, albo External scripting nie jest ustawione na Local. |
| Ostrzeżenie o braku `fusionscript.so` | Resolve Studio nie jest w `/Applications` albo to wersja darmowa. Ścieżki zmienisz w bloku KONFIGURACJA na górze skryptu. |
| Wyskakuje okienko "Install Command Line Tools" | Uruchom `xcode-select --install`, poczekaj, odpal skrypt jeszcze raz. |
| Windows | Nieobsługiwane tutaj. Ścieżki: `fusionscript.dll` w `C:\Program Files\Blackmagic Design\...`, config w `%APPDATA%\Claude\`. Patrz README upstream. |

## Atrybucja

- **Oryginalny skrypt:** [Nobr-auto.jsx](https://github.com/daani-rika/Illustrator-scripts#nobr-autojsx) — autor: [daani-rika](https://github.com/daani-rika)
- **Bazowy regex:** wątek na [Adobe Community](https://community.adobe.com/t5/illustrator/select-part-of-point-text-objects-matching-a-regex-expression/td-p/8919738)
- **Tip o adaptacji pod alfabet łaciński:** [Adobe Support Community](https://community.adobe.com/t5/illustrator-discussions/adobe-illustrator-does-not-use-standard-non-breaking-space-character-and-this-is-a-problem/m-p/13701954)
- **Modyfikacja PL (alfabet polski + diakrytyki, konfigurowalna długość słowa):** pan-pawel
- **resolve-claude-mcp (serwer MCP dla DaVinci Resolve):** [barckley75/resolve-claude-mcp](https://github.com/barckley75/resolve-claude-mcp) - autor: [barckley75](https://github.com/barckley75); skrypt instalacyjny `resolve-mcp/setup-resolve-mcp.sh` w tym repo: pan-pawel

## Tematy / słowa kluczowe

Adobe Illustrator, illustrator scripts, jsx scripts, polska typografia, polish typography, sierotki, sierotki illustrator, wiszące spójniki, polskie sierotki, no-break, non-breaking space, polish orphans, typografia, skład tekstu, grafika dla grafików, DaVinci Resolve, Resolve MCP, Claude Desktop MCP, model context protocol, claude_desktop_config.json, uv, macOS.

## Licencja

MIT — zobacz plik [LICENSE](LICENSE).
