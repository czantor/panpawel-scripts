# Strona „Pobierz materiały” – zdjęcia i wideo dla klienta z Dysku Google

Jedna statyczna strona (HTML + JS, bez backendu), którą wysyłasz klientowi po realizacji foto/wideo.
Pliki leżą **na Dysku Google w Waszym Workspace** – strona tylko je wyświetla (miniatury, odtwarzacz wideo)
i daje przyciski do pobrania. Stylistyka: żółty pas z logo, żółte belki sekcji, Lato / Helvetica Neue – jak w ofertach 300PROCENT.

Demo bez Dysku (dane przykładowe): otwórz `index.html?demo=1`.

## Jak to działa

```
klient ──> https://twoja-domena.pl/pobierz/?k=nazwa-klienta
              │
              ├─ index.html + config.js   (hosting statyczny: GitHub Pages / Wasz serwer WWW)
              │
              └─ Google Drive API v3 (files.list, klucz API, tylko odczyt)
                    └─ folder zlecenia na Dysku ("Każdy, kto ma link")
                         ├─ Zdjęcia/      -> siatka miniatur + lightbox + "Pobierz oryginał"
                         ├─ Wideo/        -> odtwarzacz Dysku Google + "Pobierz"
                         └─ inne pliki    -> lista z przyciskiem "Pobierz"
```

- **Pobierz wszystko** otwiera folder na Dysku – Google pakuje go do ZIP (przy dużych zbiorach dzieli na kilka archiwów).
- Pojedyncze pliki pobierają się bezpośrednio z Dysku (`uc?export=download`).
- Wideo odtwarza się we wbudowanym odtwarzaczu Dysku (`/preview`), bez konwersji i bez YouTube.
- Podfoldery (1 poziom) stają się sekcjami strony i biorą nazwę z folderu. Bez podfolderów pliki grupują się same: Zdjęcia / Wideo / Pozostałe pliki.
- Brak backendu = nic nie trzeba utrzymywać. Cała „baza” to `config.js`.

## Wdrożenie – krok po kroku

### 1. Dysk Google (raz na zlecenie)

1. Załóż folder zlecenia, np. `Klienci/PGB/2026-06-sesja`. W środku opcjonalnie podfoldery `Zdjęcia`, `Wideo`.
   Dysk współdzielony (Shared Drive) też działa.
2. Udostępnij folder: **Udostępnij → Dostęp ogólny → „Każdy, kto ma link” → Przeglądający**.
   W ustawieniach udostępniania *nie* zaznaczaj „Przeglądający nie mogą pobierać”.
3. Skopiuj ID folderu z adresu: `https://drive.google.com/drive/folders/`**`1AbC…xyz`**.

Jeśli opcja „Każdy, kto ma link” jest wyszarzona, admin Workspace musi ją włączyć:
**Konsola administracyjna → Aplikacje → Google Workspace → Dysk i Dokumenty → Ustawienia udostępniania → Udostępnianie poza organizację: WŁ.**
(można ograniczyć do jednostki organizacyjnej, np. tylko konto `tool@` / produkcja).

### 2. Klucz API Google (raz)

1. Wejdź na https://console.cloud.google.com zalogowany na konto Workspace. Utwórz projekt, np. `300pro-pobierz`.
2. **APIs & Services → Library → Google Drive API → Enable.**
3. **APIs & Services → Credentials → Create credentials → API key.**
4. Kliknij klucz → **Application restrictions: Websites** → dodaj domenę strony, np. `https://pobierz.300pro.pl/*`
   (i `http://localhost/*` na czas testów). **API restrictions → Restrict key → Google Drive API.**
5. Wklej klucz do `config.js` → `apiKey`.

Klucz jest jawny w kodzie strony – to normalne dla kluczy API do publicznych danych. Ograniczenie do domeny sprawia,
że nikt inny go nie użyje, a i tak widzi nim tylko to, co jest publicznie udostępnione.

### 3. Hosting (raz)

Dowolny hosting statyczny. Najprościej:

- **GitHub Pages:** w repo *Settings → Pages → Deploy from branch*, folder `/ (root)`. Strona będzie pod
  `https://<konto>.github.io/<repo>/foto-wideo-download-page/?k=…`. Można podpiąć subdomenę (`pobierz.300pro.pl`, rekord CNAME).
- **Własny serwer WWW:** wgraj `index.html` + `config.js` do katalogu, np. `/pobierz/`.

Strona ma `noindex`, więc Google jej nie zaindeksuje.

### 4. Nowe zlecenie (za każdym razem, 2 minuty)

Dopisz wpis w `config.js`:

```js
"pgb-2026-06": {
  name: "Polska PGB",
  folderId: "1AbC…xyz",
  title: "Sesja foto i wideo",
  date: "12 czerwca 2026",
  place: "Warszawa",
  logoFileId: "",        // ID pliku z logo klienta na Dysku (udostępnionego) – opcjonalnie
  expires: "2026-09-30", // po tej dacie strona pokazuje "link wygasł"
  note: ""               // np. informacja o licencji / kredytach dla fotografa
}
```

Wyślij klientowi link: `https://twoja-domena.pl/pobierz/?k=pgb-2026-06`.

Wariant bez edycji configu: `?folder=1AbC…xyz&name=Polska%20PGB` – działa od razu, ale link jest brzydszy.

## Ograniczenia, o których trzeba wiedzieć

| Sprawa | Co się dzieje | Co robić |
|---|---|---|
| Pliki > 100 MB | Google pokazuje „nie można przeskanować antywirusem” i przycisk „Pobierz mimo to” | Strona informuje o tym klienta w ramce na dole |
| ZIP całego folderu | Google dzieli na paczki ok. 2 GB; bardzo duże foldery (dziesiątki GB) pobierają się niewygodnie | Do dużych realizacji wrzuć gotowy ZIP jako plik – pojawi się w „Pozostałe pliki” |
| Wideo 4K / duże pliki | Odtwarzacz Dysku pokazuje transkodowany podgląd (do 1080p); pobieranie daje oryginał | Bez zmian, tak działa Dysk |
| Limit zapytań API | 12 000 zapytań / min na projekt – dla kilkudziesięciu klientów bez znaczenia | – |
| Bezpieczeństwo | Folder jest dostępny dla każdego z linkiem (nie da się inaczej bez logowania klienta) | Nie używać do materiałów poufnych; po terminie cofnąć udostępnienie folderu i ustawić `expires` |
| Miniatury | Generuje je Dysk (`/thumbnail?id=`); dla świeżo wgranych plików mogą pojawić się po kilku minutach | – |

## Alternatywy, które odrzuciłem

- **Sam link do folderu Dysku** – zero pracy, ale wygląda jak „wrzuciłem Ci pliki”, brak brandingu, brak odtwarzacza wideo obok zdjęć, brak instrukcji i daty wygaśnięcia.
- **Google Apps Script jako backend** – pozwoliłby trzymać folder prywatny, ale pobieranie musiałoby iść przez skrypt (limit 50 MB na plik) – odpada dla wideo.
- **Pixieset / Pic-Time / WeTransfer** – ładne, ale płatne per GB i pliki leżą poza Waszym Workspace.
