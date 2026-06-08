#!/usr/bin/env python3
"""
Seed test delivery orders (with coordinates) so the admin "Маршрут" multistop
route screen has stops to optimize.

Signs in as admin (admin rules allow writes), finds an open shift for the given
group, and creates several orders scattered across that city, each with
userLat/userLng so they appear on the route map.

Usage:
  python3 scripts/seed_orders.py                 # seed Berlin orders
  python3 scripts/seed_orders.py --group Hamburg  # other group
  python3 scripts/seed_orders.py --shift <id>     # attach to a specific shift
  python3 scripts/seed_orders.py --reset          # delete previously seeded orders

Override creds via env: SB_API_KEY, SB_ADMIN_EMAIL, SB_ADMIN_PASSWORD, SB_PROJECT_ID
"""
import argparse
import datetime
import json
import os
import random
import sys
import urllib.error
import urllib.request

API_KEY = os.environ.get("SB_API_KEY", "AIzaSyBxRHDfeqfjKeE2982uS8sKp1_sLtHXlBE")
EMAIL = os.environ.get("SB_ADMIN_EMAIL", "admin@gmail.com")
PASSWORD = os.environ.get("SB_ADMIN_PASSWORD", "admin1221")
PROJECT = os.environ.get("SB_PROJECT_ID", "sarkisbread")
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"

# ---- field encoders ----
def sv(v): return {"stringValue": v}
def dv(v): return {"doubleValue": v}
def iv(v): return {"integerValue": str(v)}
def bv(v): return {"booleanValue": v}
def tv(v): return {"timestampValue": v}
def mv(d): return {"mapValue": {"fields": d}}
def arr(values): return {"arrayValue": {"values": values}}

def req(url, method="GET", token=None, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    r = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(r) as resp:
            body = resp.read().decode()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        print("HTTP", e.code, e.read().decode()[:400], file=sys.stderr)
        raise

def sign_in():
    """Returns (idToken, uid). Orders must be created with userId == uid to
    satisfy the Firestore create rule."""
    res = req(
        f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}",
        "POST",
        payload={"email": EMAIL, "password": PASSWORD, "returnSecureToken": True},
    )
    return res["idToken"], res["localId"]

def run_query(token, structured):
    res = req(f"{BASE}:runQuery", "POST", token, {"structuredQuery": structured})
    return [row["document"] for row in res if "document" in row]

def doc_id(doc):
    return doc["name"].split("/")[-1]

def find_shift(token, group, shift_id):
    if shift_id:
        doc = req(f"{BASE}/shifts/{shift_id}", token=token)
        return shift_id, doc["fields"]
    docs = run_query(token, {
        "from": [{"collectionId": "shifts"}],
        "where": {"fieldFilter": {
            "field": {"fieldPath": "group"}, "op": "EQUAL",
            "value": sv(group)}},
        "limit": 20,
    })
    if not docs:
        sys.exit(f"No shifts found for group '{group}'. Create one in the admin app first.")
    # Prefer an open shift.
    docs.sort(key=lambda d: d["fields"].get("isOpen", {}).get("booleanValue", False),
              reverse=True)
    return doc_id(docs[0]), docs[0]["fields"]

# ---- Berlin / Hamburg sample stops (name, street, postal, lat, lng) ----
STOPS = {
    "Berlin": [
        ("Aram Petrosyan", "Alexanderplatz 1", "10178", 52.5219, 13.4132),
        ("Lena Müller", "Unter den Linden 77", "10117", 52.5163, 13.3777),
        ("Davit Sargsyan", "Kurfürstendamm 21", "10719", 52.5037, 13.3300),
        ("Sofia Klein", "Prenzlauer Allee 80", "10405", 52.5340, 13.4240),
        ("Narek Hakobyan", "Warschauer Str. 34", "10243", 52.5085, 13.4490),
        ("Mia Schäfer", "Kottbusser Damm 1", "10967", 52.4905, 13.4220),
        ("Gor Avetisyan", "Frankfurter Allee 110", "10247", 52.5150, 13.4760),
        ("Emma Fischer", "Schönhauser Allee 80", "10439", 52.5490, 13.4130),
        ("Tigran Grigoryan", "Hermannstr. 5", "12049", 52.4830, 13.4250),
        ("Lara Wagner", "Mehringdamm 33", "10961", 52.4930, 13.3870),
    ],
    "Hamburg": [
        ("Hayk Manukyan", "Mönckebergstr. 7", "20095", 53.5510, 10.0010),
        ("Jonas Braun", "Reeperbahn 1", "20359", 53.5497, 9.9630),
        ("Ani Khachatryan", "Osterstr. 100", "20255", 53.5740, 9.9530),
        ("Finn Hoffmann", "Mühlenkamp 40", "22303", 53.5800, 10.0150),
        ("Mariam Petrosyan", "Eppendorfer Baum 20", "20249", 53.5870, 9.9870),
        ("Leon Schmidt", "Steindamm 50", "20099", 53.5540, 10.0150),
        ("Vahe Sahakyan", "Eimsbütteler Chaussee 11", "20259", 53.5680, 9.9550),
        ("Clara Becker", "Winterhuder Weg 90", "22085", 53.5760, 10.0270),
    ],
}

CITY_CENTER = {"Berlin": (52.520, 13.405), "Hamburg": (53.551, 9.993)}
_STREETS = ["Hauptstr.", "Bergstr.", "Gartenweg", "Lindenallee", "Parkstr.",
            "Schulstr.", "Bahnhofstr.", "Kirchweg", "Ringstr.", "Seestr.",
            "Goethestr.", "Schillerstr.", "Waldweg", "Feldstr.", "Marktplatz"]
_FIRST = ["Anna", "Ben", "Carla", "David", "Elif", "Felix", "Greta", "Hans",
          "Ira", "Jan", "Karin", "Luca", "Maya", "Nico", "Olga", "Paul",
          "Rita", "Sami", "Tina", "Umut", "Aram", "Lena", "Davit", "Sofia"]
_LAST = ["Müller", "Schmidt", "Petrosyan", "Weber", "Wagner", "Becker",
         "Hoffmann", "Sahakyan", "Koch", "Klein", "Hakobyan", "Fischer"]

def gen_stops(group, n):
    """Returns n (name, street, postal, lat, lng) stops. Uses the hand-picked
    list first, then deterministically scatters the rest around the city."""
    base = STOPS.get(group, [])
    if n <= len(base):
        return base[:n]
    out = list(base)
    rnd = random.Random(1234)
    clat, clng = CITY_CENTER.get(group, (52.52, 13.405))
    pmin, pmax = (10115, 14199) if group == "Berlin" else (20095, 22769)
    for _ in range(n - len(base)):
        lat = clat + rnd.uniform(-0.06, 0.06)
        lng = clng + rnd.uniform(-0.09, 0.09)
        name = f"{rnd.choice(_FIRST)} {rnd.choice(_LAST)}"
        street = f"{rnd.choice(_STREETS)} {rnd.randint(1, 150)}"
        out.append((name, street, str(rnd.randint(pmin, pmax)),
                    round(lat, 5), round(lng, 5)))
    return out

def create_shift(token, group, now_iso):
    date = datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=14)
    iso = date.strftime("%Y-%m-%dT00:00:00Z")
    label = date.strftime("%d.%m")
    fields = {
        "group": sv(group), "date": tv(iso), "label": sv(label),
        "isOpen": bv(True), "seed": bv(True), "createdAt": tv(now_iso),
    }
    res = req(f"{BASE}/shifts", "POST", token, {"fields": fields})
    return doc_id(res), fields

def make_order(token, uid, group, shift_id, shift_fields, stop, now_iso):
    name, street, postal, lat, lng = stop
    city = "Berlin" if group == "Berlin" else "Hamburg"
    address = f"{street}, {postal} {city}"
    shift_date = shift_fields.get("date", {}).get("timestampValue", now_iso)
    shift_label = shift_fields.get("label", {}).get("stringValue", "")
    item = mv({
        "productId": sv("seed"),
        "categoryId": sv(""),
        "name": sv("Лаваш"),
        "qty": iv(2),
        "unitPrice": dv(3.5),
        "subtotal": dv(7.0),
    })
    fields = {
        # Must equal the signed-in admin uid to satisfy the create rule.
        "userId": sv(uid),
        "userName": sv(name),
        "userPhone": sv("+4915150000000"),
        "userAddress": sv(address),
        "userCity": sv(city),
        "userGroup": sv(group),
        "userLat": dv(lat),
        "userLng": dv(lng),
        "shiftId": sv(shift_id),
        "shiftDate": tv(shift_date),
        "shiftLabel": sv(shift_label),
        "items": arr([item]),
        "subtotal": dv(7.0),
        "discount": dv(0.0),
        "couponCode": sv(""),
        "totalPrice": dv(7.0),
        "status": sv("pending"),
        "adminNote": sv(""),
        "seed": bv(True),
        "createdAt": tv(now_iso),
        "updatedAt": tv(now_iso),
    }
    req(f"{BASE}/orders", "POST", token, {"fields": fields})
    print(f"  + {name} — {address}")

def reset(token):
    for coll in ("orders", "shifts"):
        docs = run_query(token, {
            "from": [{"collectionId": coll}],
            "where": {"fieldFilter": {
                "field": {"fieldPath": "seed"}, "op": "EQUAL", "value": bv(True)}},
            "limit": 1000,
        })
        for d in docs:
            req(f"{BASE}/{coll}/{doc_id(d)}", "DELETE", token)
        print(f"Deleted {len(docs)} seeded {coll[:-1]}(s).")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--group", default="Berlin")
    ap.add_argument("--shift", default=None)
    ap.add_argument("--count", type=int, default=10, help="number of orders")
    ap.add_argument("--new-shift", action="store_true",
                    help="create a fresh shift and seed into it")
    ap.add_argument("--reset", action="store_true")
    args = ap.parse_args()

    token, uid = sign_in()

    if args.reset:
        reset(token)
        return

    if args.group not in CITY_CENTER:
        sys.exit(f"No sample stops for group '{args.group}'. Use Berlin or Hamburg.")

    now_iso = datetime.datetime.now(datetime.timezone.utc).strftime(
        "%Y-%m-%dT%H:%M:%SZ")

    if args.new_shift:
        shift_id, shift_fields = create_shift(token, args.group, now_iso)
        print(f"Created new {args.group} shift {shift_id} "
              f"({shift_fields['label']['stringValue']}).")
    else:
        shift_id, shift_fields = find_shift(token, args.group, args.shift)

    label = shift_fields.get("label", {}).get("stringValue", "")
    stops = gen_stops(args.group, args.count)
    print(f"Seeding {len(stops)} orders into {args.group} shift "
          f"{shift_id} ({label})…")
    for stop in stops:
        make_order(token, uid, args.group, shift_id, shift_fields, stop, now_iso)
    print(f"Done. Open Маршрут, pick the '{label}' shift, and Optimize.")

if __name__ == "__main__":
    main()
