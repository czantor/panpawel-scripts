#!/usr/bin/env python3
"""
klient.py – narzędzie asystenta strony „Materiały do pobrania” (300PROCENT).

Edytuje config.js bez ręcznego grzebania w pliku i sprawdza folder na Dysku Google
przez publiczne Drive API (tym samym kluczem, którego używa strona).

Użycie (z folderu foto-wideo-download-page/):
  python3 narzedzia/klient.py list                         # wszystkie wpisy klientów
  python3 narzedzia/klient.py check  <ID_lub_link>         # czy folder jest publiczny + ile plików
  python3 narzedzia/klient.py add    <slug> --name "Polska PGB" --folder <ID_lub_link> \
                                     [--date "12 czerwca 2026"] [--place "Warszawa"] \
                                     [--expires 2026-09-30 | --days 90] [--title "…"] \
                                     [--logo-file-id ID] [--logo-url URL] [--intro "…"] [--note "…"]
  python3 narzedzia/klient.py link   <slug>                # gotowy adres dla klienta
  python3 narzedzia/klient.py expired                      # wpisy po terminie (do cofnięcia udostępnienia)
  python3 narzedzia/klient.py remove <slug>

Bez zależności poza biblioteką standardową. Działa na macOS/Linux/Windows.
"""
import argparse, json, os, re, sys, datetime, urllib.request, urllib.parse, urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
CONFIG = os.path.normpath(os.path.join(HERE, "..", "config.js"))
BASE_URL_DEFAULT = "https://www.300procent.pl/materialy/"

# ---------- config.js ----------

def read_config():
    with open(CONFIG, encoding="utf-8") as f:
        return f.read()

def write_config(text):
    with open(CONFIG, "w", encoding="utf-8") as f:
        f.write(text)

def api_key(text):
    m = re.search(r'apiKey:\s*"([^"]*)"', text)
    return m.group(1) if m else ""

def clients_span(text):
    """Zwraca (start, end) wnętrza obiektu clients: { … }."""
    m = re.search(r'clients:\s*\{', text)
    if not m:
        sys.exit("config.js: nie znaleziono sekcji clients: {")
    i = m.end(); depth = 1
    while i < len(text) and depth:
        c = text[i]
        if c == "{": depth += 1
        elif c == "}": depth -= 1
        i += 1
    return m.end(), i - 1

def parse_clients(text):
    """Prosty parser bloków  "slug": { klucz: "wartość", … } – wystarczający dla naszego config.js."""
    s, e = clients_span(text)
    body = text[s:e]
    out = {}
    for m in re.finditer(r'"([^"]+)"\s*:\s*\{(.*?)\n\s*\}', body, re.S):
        slug, inner = m.group(1), m.group(2)
        fields = {}
        for km in re.finditer(r'^\s*([A-Za-z_]\w*)\s*:\s*"((?:[^"\\]|\\.)*)"', inner, re.M):
            fields[km.group(1)] = km.group(2).replace('\\"', '"')
        out[slug] = fields
    return out

def js_str(v):
    return '"' + str(v).replace("\\", "\\\\").replace('"', '\\"') + '"'

def add_client(slug, fields):
    text = read_config()
    if slug in parse_clients(text):
        sys.exit(f"Wpis „{slug}” już istnieje. Użyj innego slugu albo najpierw: remove {slug}")
    if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", slug):
        sys.exit("Slug: tylko małe litery, cyfry i myślniki, np. pgb-2026-06")
    order = ["name","folderId","title","date","place","logoFileId","logoUrl","intro","expires","note"]
    lines = [f'      {k}: {js_str(fields[k])}' for k in order if fields.get(k)]
    block = f'    "{slug}": {{\n' + ",\n".join(lines) + "\n    }"
    s, e = clients_span(text)
    body = text[s:e].rstrip()
    sep = "," if body.strip() and not body.strip().endswith(",") else ""
    new_body = body + sep + "\n" + block + "\n  "
    write_config(text[:s] + new_body + text[e:])
    return block

def remove_client(slug):
    text = read_config()
    s, e = clients_span(text)
    body = text[s:e]
    m = re.search(r'\n\s*,?\s*"' + re.escape(slug) + r'"\s*:\s*\{.*?\n\s*\}\s*,?', body, re.S)
    if not m:
        sys.exit(f"Brak wpisu „{slug}”.")
    new_body = body[:m.start()] + "\n" + body[m.end():]
    # porządek przecinków między blokami
    new_body = re.sub(r'\}\s*\n\s*"', '},\n    "', new_body)
    new_body = re.sub(r',\s*$', '\n  ', new_body)
    write_config(text[:s] + new_body + text[e:])

# ---------- Drive ----------

def folder_id(s):
    s = s.strip()
    m = re.search(r'/folders/([A-Za-z0-9_-]+)', s) or re.search(r'[?&]id=([A-Za-z0-9_-]+)', s)
    return m.group(1) if m else s

def api_get(url):
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return json.load(r), None
    except urllib.error.HTTPError as ex:
        try: msg = json.load(ex).get("error", {}).get("message", "")
        except Exception: msg = ""
        return None, f"HTTP {ex.code} {msg}".strip()
    except Exception as ex:
        return None, str(ex)

def check_folder(fid, key):
    if not key or key.startswith("WSTAW"):
        return {"ok": False, "why": "W config.js nie ma klucza API (apiKey). Uzupełnij go, potem sprawdź ponownie."}
    q = urllib.parse.quote(f"'{fid}' in parents and trashed = false")
    url = (f"https://www.googleapis.com/drive/v3/files?q={q}&pageSize=1000&supportsAllDrives=true"
           f"&includeItemsFromAllDrives=true&fields=files(name,mimeType,size)&key={key}")
    data, err = api_get(url)
    if err:
        why = ("Folder nie jest udostępniony jako „Każdy, kto ma link” albo ID jest błędne."
               if err.startswith("HTTP 404") else
               "Klucz API odrzucony: sprawdź, czy Drive API jest włączone i czy klucz nie jest ograniczony do domeny "
               "(z terminala nie ma nagłówka Referer; do testu z komputera dodaj tymczasowo wyjątek albo użyj klucza bez ograniczeń)."
               if err.startswith("HTTP 403") else err)
        return {"ok": False, "why": f"{why} ({err})"}
    files = data.get("files", [])
    folders = [f for f in files if f["mimeType"] == "application/vnd.google-apps.folder"]
    imgs = [f for f in files if f["mimeType"].startswith("image/")]
    vids = [f for f in files if f["mimeType"].startswith("video/")]
    total_bytes = sum(int(f.get("size", 0) or 0) for f in files)
    return {"ok": True, "files": len(files), "folders": len(folders), "images": len(imgs), "videos": len(vids),
            "bytes": total_bytes, "big": [f["name"] for f in files if int(f.get("size", 0) or 0) > 100*1024*1024]}

def fmt_size(b):
    for u in ["B","KB","MB","GB","TB"]:
        if b < 1024: return f"{b:.1f} {u}" if u != "B" else f"{b} B"
        b /= 1024
    return f"{b:.1f} PB"

# ---------- main ----------

def main():
    ap = argparse.ArgumentParser(description="Asystent strony „Materiały do pobrania”")
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("list")
    c = sub.add_parser("check"); c.add_argument("folder")
    a = sub.add_parser("add"); a.add_argument("slug"); a.add_argument("--name", required=True); a.add_argument("--folder", required=True)
    for opt in ["--title","--date","--place","--logo-file-id","--logo-url","--intro","--note","--expires"]:
        a.add_argument(opt, default="")
    a.add_argument("--days", type=int, default=0, help="ważność w dniach od dziś (zamiast --expires)")
    a.add_argument("--no-check", action="store_true", help="nie sprawdzaj folderu przez API")
    l = sub.add_parser("link"); l.add_argument("slug"); l.add_argument("--base", default=os.environ.get("POBIERZ_BASE_URL", BASE_URL_DEFAULT))
    sub.add_parser("expired")
    r = sub.add_parser("remove"); r.add_argument("slug")
    args = ap.parse_args()

    if args.cmd == "list":
        for slug, f in parse_clients(read_config()).items():
            print(f"{slug:24} {f.get('name','')[:30]:30} folder={f.get('folderId','')} do={f.get('expires','–')}")
        return

    if args.cmd == "check":
        fid = folder_id(args.folder)
        res = check_folder(fid, api_key(read_config()))
        if not res["ok"]:
            print("NIE OK:", res["why"]); sys.exit(2)
        print(f"OK: folder {fid} jest publiczny. Plików: {res['files']} (zdjęć {res['images']}, wideo {res['videos']}, "
              f"podfolderów {res['folders']}), łącznie {fmt_size(res['bytes'])}.")
        if res["big"]: print("Pliki > 100 MB (klient zobaczy ostrzeżenie Google):", ", ".join(res["big"]))
        return

    if args.cmd == "add":
        fid = folder_id(args.folder)
        expires = args.expires
        if args.days and not expires:
            expires = (datetime.date.today() + datetime.timedelta(days=args.days)).isoformat()
        if expires and not re.fullmatch(r"\d{4}-\d{2}-\d{2}", expires):
            sys.exit("--expires w formacie RRRR-MM-DD")
        if not args.no_check:
            res = check_folder(fid, api_key(read_config()))
            print(("OK: " + f"{res['files']} plików w folderze.") if res["ok"] else "UWAGA: " + res["why"])
        block = add_client(args.slug, {"name": args.name, "folderId": fid, "title": args.title, "date": args.date,
                                       "place": args.place, "logoFileId": args.logo_file_id, "logoUrl": args.logo_url,
                                       "intro": args.intro, "expires": expires, "note": args.note})
        print("Dopisano do config.js:\n" + block)
        print("\nLink:", (os.environ.get("POBIERZ_BASE_URL", BASE_URL_DEFAULT)) + "?k=" + args.slug)
        return

    if args.cmd == "link":
        if args.slug not in parse_clients(read_config()): sys.exit(f"Brak wpisu „{args.slug}”.")
        print(args.base + "?k=" + args.slug); return

    if args.cmd == "expired":
        today = datetime.date.today().isoformat(); n = 0
        for slug, f in parse_clients(read_config()).items():
            if f.get("expires") and f["expires"] < today:
                n += 1; print(f"{slug:24} {f.get('name','')[:30]:30} wygasł {f['expires']}  → cofnij udostępnienie: https://drive.google.com/drive/folders/{f.get('folderId','')}")
        if not n: print("Brak wpisów po terminie.")
        return

    if args.cmd == "remove":
        remove_client(args.slug); print(f"Usunięto „{args.slug}”."); return

if __name__ == "__main__":
    main()
