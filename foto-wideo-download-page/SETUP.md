# Setup asystenta „Materiały do pobrania” na nowym komputerze (Claude Code)

Ten sam schemat co przy wycenach (`Oferta/SETUP_Claude-Code.md`): wszystko wspólne leży na Dysku, u siebie instalujesz tylko runtime.

## 1. Folder na Dysku
- Folder `foto-wideo-download-page/` z tego repo skopiuj na dysk współdzielony **`300PRO-Automatyzacje`** jako `300PRO/Materialy/`
  (albo pracuj bezpośrednio w klonie repo, jeśli wolisz git).
- Przez **Google Drive for Desktop** folder pojawi się lokalnie, np.
  `/Users/<ty>/Library/CloudStorage/GoogleDrive-<mail>/Shared drives/300PRO-Automatyzacje/300PRO/Materialy/`.

## 2. Claude Code
- Zainstaluj Claude Code i zaloguj się (własny dostęp, per osoba).

## 3. Python (jest w macOS; na Windows z python.org, „Add to PATH”)
- Skrypt `narzedzia/klient.py` nie potrzebuje żadnych bibliotek.
- Opcjonalnie `node` (do sprawdzania składni `config.js`), nie jest wymagany.

## 4. Jak opublikować materiały klientowi
1. Wgraj gotowe pliki do folderu na Dysku, np. `Klienci/PGB/2026-06-sesja/` (podfoldery `Zdjęcia`, `Wideo` = sekcje na stronie).
2. Udostępnij folder: **Udostępnij → Dostęp ogólny → „Każdy, kto ma link” → Przeglądający.**
3. Otwórz Claude Code **w folderze `Materialy/`** (Claude sam wczyta `CLAUDE.md`).
4. Napisz: *„Opublikuj materiały dla Polska PGB, folder: <link>, sesja 12 czerwca 2026 w Warszawie”*.
5. Claude sprawdzi folder, dopisze klienta do `config.js`, poda link `…/materialy/?k=pgb-2026-06` i przygotuje mail.
6. Wgraj `config.js` na serwer (sposób opisany w `CLAUDE.md`, sekcja *Wdrożenie*) i wyślij mail.

## 5. Zasady wspólnej pracy
- **Nie edytujcie `config.js` jednocześnie** na dwóch komputerach (Drive robi konflikty). Jedna publikacja na raz.
- Po terminie ważności: `python3 narzedzia/klient.py expired` i cofnięcie udostępnienia folderów z listy.
- Klucz API w `config.js` jest jawny z założenia (dane publiczne, klucz ograniczony do domeny). Nie wklejajcie go nigdzie indziej.
