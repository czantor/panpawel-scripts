/*
  config.js – konfiguracja strony "Materiały do pobrania" (300PROCENT)

  1. apiKey  – klucz API Google (Drive API) z projektu w Google Cloud
               powiązanego z Waszym Workspace, ograniczony do domeny strony
               (HTTP referrer). Szczegóły: README.md
  2. clients – jeden wpis na zlecenie. Adres dla klienta:
               https://www.300procent.pl/materialy/?k=SLUG
*/
window.POBIERZ_CONFIG = {
  apiKey: "WSTAW_KLUCZ_API_GOOGLE",

  agency: {
    name: "300PROCENT",
    legalName: "300PROCENT sp. z o.o.",
    nip: "627 278 91 63",
    address: "Karłowicza 11, 41-506 Chorzów",
    site: "https://www.300procent.pl/",
    siteLabel: "300procent.pl",
    email: "info@300procent.pl",
    legalNote: "Materiały objęte licencją na stronę, social media i komunikację wewnętrzną. Kampanie płatne, pliki źródłowe i przeniesienie pełnych praw wyceniamy osobno.",
    // osoba prowadząca kontakt – pokazywana w sekcji "Pytania"; puste name = sekcja ukryta
    contact: { name: "Barbara Adamek", phone: "730 300 291", email: "barbara.adamek@gmail.com" }
  },

  // Domyślne teksty – można nadpisać per klient
  defaults: {
    chip: "Materiały do pobrania",
    title: "Zdjęcia i wideo z realizacji",   // gdy klient ma name, dokleja się " <em>Nazwa</em>."
    intro: "Wszystkie kadry przeszły selekcję i obróbkę. Możesz pobrać pojedyncze pliki albo cały komplet jako archiwum ZIP prosto z Dysku Google.",
    daysNotice: "Materiały są dostępne pod tym adresem przez 90 dni od publikacji. Po tym czasie folder zostaje zarchiwizowany, zapisz pliki u siebie.",
    licenseNote: ""   // np. dodatkowa uwaga o licencji; pusta = nic
  },

  clients: {
    // SLUG (w adresie ?k=przyklad) : dane zlecenia
    "przyklad": {
      name: "Nazwa Klienta",              // nazwa firmy / wydarzenia (amber kursywa w nagłówku)
      folderId: "ID_FOLDERU_Z_DYSKU",     // folder główny zlecenia na Dysku Google
      title: "",                          // opcjonalnie – własny nagłówek; <em>…</em> = amber kursywa
      date: "12 czerwca 2026",            // opcjonalnie – termin (trafia do chipa)
      place: "Jasienica",                 // opcjonalnie – miejsce (trafia do chipa)
      logoFileId: "",                     // opcjonalnie – ID pliku PNG/SVG z logo klienta na Dysku (udostępnionego)
      logoUrl: "",                        // …albo zwykły URL do logo
      intro: "",                          // opcjonalnie – nadpisuje defaults.intro
      expires: "2026-12-31",              // opcjonalnie – po tej dacie strona pokazuje "link wygasł"
      note: ""                            // opcjonalnie – dodatkowa uwaga dla klienta
    }
  }
};
