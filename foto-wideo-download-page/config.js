/*
  config.js – konfiguracja strony "Pobierz materiały" (300PROCENT)

  1. apiKey  – klucz API Google (Drive API) z projektu w Google Cloud
               powiązanego z Waszym Workspace. Ograniczony do domeny,
               na której stoi ta strona (HTTP referrer). Szczegóły: README.md
  2. clients – jeden wpis na zlecenie. Adres dla klienta:
               https://twoja-domena.pl/pobierz/?k=SLUG
*/
window.POBIERZ_CONFIG = {
  apiKey: "WSTAW_KLUCZ_API_GOOGLE",

  agency: {
    name: "300PROCENT",
    site: "https://300pro.pl",
    siteLabel: "300pro.pl",
    email: "",                       // np. "biuro@300pro.pl" – puste = nie pokazuj
    phone: "",                       // np. "+48 600 000 000" – puste = nie pokazuj
    tagline: "Tworzymy z pasją, wspieramy z zaangażowaniem!"
  },

  // Domyślne teksty – można nadpisać per klient
  defaults: {
    title: "Materiały z realizacji foto i wideo",
    intro: "Poniżej znajdziesz zdjęcia i filmy z Twojej realizacji. Możesz pobrać pojedyncze pliki albo cały komplet w jednym archiwum ZIP.",
    daysNotice: "Materiały są dostępne pod tym adresem przez 90 dni od publikacji. Po tym czasie folder zostanie zarchiwizowany – zapisz pliki u siebie."
  },

  clients: {
    // SLUG (w adresie ?k=pgb) : dane zlecenia
    "przyklad": {
      name: "Nazwa Klienta",              // nazwa firmy klienta
      folderId: "ID_FOLDERU_Z_DYSKU",     // folder główny zlecenia na Dysku Google
      title: "Sesja foto i wideo",        // opcjonalnie – nagłówek
      date: "12 czerwca 2026",            // opcjonalnie – data realizacji
      place: "Jasienica",                 // opcjonalnie – miejsce
      logoFileId: "",                     // opcjonalnie – ID pliku PNG/SVG z logo klienta na Dysku (udostępnionego)
      logoUrl: "",                        // …albo zwykły URL do logo
      intro: "",                          // opcjonalnie – nadpisuje defaults.intro
      expires: "2026-12-31",              // opcjonalnie – po tej dacie strona pokaże "link wygasł"
      note: ""                            // opcjonalnie – dodatkowa uwaga dla klienta (np. licencja)
    }
  }
};
