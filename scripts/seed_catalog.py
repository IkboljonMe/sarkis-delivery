#!/usr/bin/env python3
"""
Seed the Sarkis Bread catalog: categories (Armenian Bread, Turkish Lavash,
Cheese) and products with 5-language names/descriptions and web images.

Idempotent-ish: pass --reset to delete existing categories & products first.
Signs in as admin (admin rules allow writes). Images are public Wikimedia
Commons URLs (stable, hotlinkable).

Usage:
  python3 scripts/seed_catalog.py            # add catalog (keeps existing)
  python3 scripts/seed_catalog.py --reset    # wipe categories+products, then seed
"""
import json, os, sys, urllib.request, urllib.error

API_KEY = os.environ.get("SB_API_KEY", "AIzaSyBxRHDfeqfjKeE2982uS8sKp1_sLtHXlBE")
EMAIL = os.environ.get("SB_ADMIN_EMAIL", "admin@gmail.com")
PASSWORD = os.environ.get("SB_ADMIN_PASSWORD", "admin1221")
PROJECT = os.environ.get("SB_PROJECT_ID", "sarkisbread")
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"

IMG = "https://commons.wikimedia.org/wiki/Special:FilePath/"
def img(name, w=700):
    import urllib.parse
    return IMG + urllib.parse.quote(name) + f"?width={w}"

# ---- field encoders ----
def sv(v): return {"stringValue": v}
def dv(v): return {"doubleValue": v}
def iv(v): return {"integerValue": str(v)}
def bv(v): return {"booleanValue": v}
def mv(d): return {"mapValue": {"fields": d}}
def av(lst): return {"arrayValue": {"values": [sv(x) for x in lst]}}
def nm(en, hy, ru, tr, de): return mv({"en": sv(en), "hy": sv(hy), "ru": sv(ru), "tr": sv(tr), "de": sv(de)})

def req(url, method="GET", token=None, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    headers = {"Content-Type": "application/json"}
    if token: headers["Authorization"] = f"Bearer {token}"
    r = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(r) as resp:
        body = resp.read().decode()
        return json.loads(body) if body else {}

def sign_in():
    return req(f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}",
               "POST", payload={"email": EMAIL, "password": PASSWORD, "returnSecureToken": True})["idToken"]

def add(coll, fields, token):
    r = req(f"{BASE}/{coll}", "POST", token, {"fields": fields})
    return r["name"].split("/")[-1]

def wipe(coll, token):
    n = 0
    while True:
        res = req(f"{BASE}/{coll}?pageSize=300", token=token)
        docs = res.get("documents", [])
        if not docs: break
        for d in docs:
            short = d["name"].split("/documents/")[1]
            try: req(f"{BASE}/{short}", "DELETE", token); n += 1
            except urllib.error.HTTPError: pass
        if not res.get("nextPageToken"): break
    print(f"  wiped {n} from {coll}")

CATEGORIES = [
    {"key": "bread", "sort": 0, "img": img("Matnakash bread Mos06-13.jpg", 400),
     "name": nm("Armenian Bread", "Հայկական հաց", "Армянский хлеб", "Ermeni Ekmeği", "Armenisches Brot")},
    {"key": "tlavash", "sort": 1, "img": img("Iğdır Lavaş.jpg", 400),
     "name": nm("Turkish Lavash", "Թուրքական լավաշ", "Турецкий лаваш", "Türk Lavaşı", "Türkisches Lavash")},
    {"key": "cheese", "sort": 2, "img": img("Armenian cheeses.jpg", 400),
     "name": nm("Cheese", "Պանիր", "Сыр", "Peynir", "Käse")},
]

PRODUCTS = [
    # ---- Armenian Bread ----
    {"cat": "bread", "price": 2.50, "unit": "pack", "sort": 0,
     "name": nm("Lavash", "Լավաշ", "Лаваш", "Lavaş", "Lavash"),
     "desc": nm("Traditional thin Armenian flatbread, soft and fresh.",
                "Ավանդական բարակ հայկական լավաշ՝ փափուկ և թարմ։",
                "Традиционный тонкий армянский лаваш, мягкий и свежий.",
                "Geleneksel ince Ermeni yufka ekmeği, yumuşak ve taze.",
                "Traditionelles dünnes armenisches Fladenbrot, weich und frisch."),
     "imgs": ["Lavash.jpg", "Lavash preparation.jpg", "Lavash cooking.jpg"]},
    {"cat": "bread", "price": 3.00, "unit": "piece", "sort": 1,
     "name": nm("Matnakash", "Մատնաքաշ", "Матнакаш", "Matnakaş", "Matnakasch"),
     "desc": nm("Soft oval leavened bread with a golden crust.",
                "Փափուկ օվալաձև խմորով հաց՝ ոսկեգույն կեղևով։",
                "Мягкий овальный дрожжевой хлеб с золотистой корочкой.",
                "Altın kabuklu yumuşak oval mayalı ekmek.",
                "Weiches ovales Hefebrot mit goldener Kruste."),
     "imgs": ["Matnakash bread Mos06-13.jpg", "Armenian Matnakash Bread.jpg"]},
    {"cat": "bread", "price": 4.50, "unit": "piece", "sort": 2,
     "name": nm("Gata", "Գաթա", "Гата", "Gata", "Gata"),
     "desc": nm("Sweet Armenian pastry, buttery and flaky.",
                "Քաղցր հայկական գաթա՝ յուղալի և շերտավոր։",
                "Сладкая армянская гата, маслянистая и слоёная.",
                "Tatlı Ermeni böreği, tereyağlı ve katmer.",
                "Süßes armenisches Gebäck, butterig und blättrig."),
     "imgs": ["Gata (pâtisserie).jpg", "Parts de Gata.jpg"]},
    # ---- Turkish Lavash ----
    {"cat": "tlavash", "price": 2.20, "unit": "pack", "sort": 0,
     "name": nm("Turkish Lavash", "Թուրքական լավաշ", "Турецкий лаваш", "Türk Lavaşı", "Türkisches Lavash"),
     "desc": nm("Thin Turkish-style lavash, perfect for wraps.",
                "Բարակ թուրքական լավաշ՝ իդեալական փաթաթելու համար։",
                "Тонкий лаваш в турецком стиле, идеален для роллов.",
                "İnce Türk usulü lavaş, dürüm için ideal.",
                "Dünnes Lavash nach türkischer Art, ideal für Wraps."),
     "imgs": ["Iğdır Lavaş.jpg", "Lavash.jpg"]},
    {"cat": "tlavash", "price": 2.80, "unit": "pack", "sort": 1,
     "name": nm("Lavash XL", "Լավաշ XL", "Лаваш XL", "Lavaş XL", "Lavash XL"),
     "desc": nm("Extra-large lavash sheets for family meals.",
                "Շատ մեծ լավաշի թերթիկներ ընտանեկան ճաշի համար։",
                "Очень большие листы лаваша для всей семьи.",
                "Aile yemekleri için ekstra büyük lavaş.",
                "Extra große Lavash-Blätter für die Familie."),
     "imgs": ["Lavash preparation.jpg", "Iğdır Lavaş.jpg"]},
    # ---- Cheese ----
    {"cat": "cheese", "price": 6.50, "unit": "pack", "sort": 0,
     "name": nm("Lori Cheese", "Լոռի պանիր", "Сыр Лори", "Lori Peyniri", "Lori-Käse"),
     "desc": nm("Semi-hard Armenian Lori cheese, rich and savory.",
                "Կիսակարծր հայկական Լոռի պանիր՝ հարուստ համով։",
                "Полутвёрдый армянский сыр Лори, насыщенный вкус.",
                "Yarı sert Ermeni Lori peyniri, zengin ve lezzetli.",
                "Halbharter armenischer Lori-Käse, würzig."),
     "imgs": ["1070282 Lori Cheese (Լոռի պանիր) Armenia 260408.jpg", "Lori Cheese Production (3).jpg"]},
    {"cat": "cheese", "price": 7.20, "unit": "pack", "sort": 1,
     "name": nm("Chechil (String Cheese)", "Չեչիլ", "Чечил", "Çeçil", "Tschetschil"),
     "desc": nm("Braided string cheese, lightly smoked and salty.",
                "Հյուսված թելանման պանիր՝ թեթևակի ապխտած։",
                "Плетёный сыр-косичка, слегка копчёный и солёный.",
                "Örgü tel peyniri, hafif tütsülenmiş ve tuzlu.",
                "Geflochtener Zupfkäse, leicht geräuchert und salzig."),
     "imgs": ["Queso çeçil turco.jpg", "Turkish cheeses Dil and Civil.jpg"]},
    {"cat": "cheese", "price": 5.90, "unit": "pack", "sort": 2,
     "name": nm("Cheese with Herbs", "Պանիր խոտաբույսերով", "Сыр с зеленью", "Otlu Peynir", "Käse mit Kräutern"),
     "desc": nm("Fresh cheese mixed with mountain herbs.",
                "Թարմ պանիր՝ լեռնային խոտաբույսերով։",
                "Свежий сыр с горными травами.",
                "Dağ otları ile karışık taze peynir.",
                "Frischer Käse mit Bergkräutern."),
     "imgs": ["Armenian cheese and herbs.jpg", "Armenian cheeses.jpg"]},
]

def main():
    reset = "--reset" in sys.argv
    print(f"Signing in as {EMAIL} ...")
    token = sign_in()
    print("OK.")

    if reset:
        print("Resetting catalog ...")
        wipe("products", token)
        wipe("categories", token)

    print("Seeding categories ...")
    cat_ids = {}
    for c in CATEGORIES:
        cid = add("categories", {
            "name": c["name"], "imageUrl": sv(c["img"]),
            "sortOrder": iv(c["sort"]), "isActive": bv(True),
        }, token)
        cat_ids[c["key"]] = cid
        print(f"  + category {c['key']} -> {cid}")

    print("Seeding products ...")
    for p in PRODUCTS:
        gallery = [img(n) for n in p["imgs"]]
        add("products", {
            "categoryId": sv(cat_ids[p["cat"]]),
            "name": p["name"], "description": p["desc"],
            "price": dv(p["price"]), "unit": sv(p["unit"]),
            "maxQty": iv(10), "imageUrl": sv(gallery[0]),
            "images": av(gallery), "isActive": bv(True), "sortOrder": iv(p["sort"]),
        }, token)
        print(f"  + product {p['name']['mapValue']['fields']['en']['stringValue']}")

    print("\nDone. Catalog seeded.")

if __name__ == "__main__":
    main()
