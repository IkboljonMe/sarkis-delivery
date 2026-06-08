#!/usr/bin/env python3
"""
Reset Sarkis Bread test customer data in Firestore.

Signs in as the admin account (admin rules allow full read/write) and deletes
test customers so you can re-test the registration flow.

It deletes, for each targeted customer:
  - users/{uid}
  - all orders where userId == uid
  - the chat topic messages/{uid} and its messages subcollection

It NEVER deletes admin users (isAdmin == true), categories, products, shifts,
or settings.

NOTE: This does not delete the Firebase Auth account. You don't need to — with
the profile doc gone, the app shows the registration screen again on next
launch. (To also remove the Auth login, delete the user in
Firebase Console -> Authentication -> Users.)

Usage:
  python3 reset_test_data.py --list                 # show test customers, delete nothing
  python3 reset_test_data.py --all                  # delete ALL non-admin customers
  python3 reset_test_data.py --uid <UID>            # delete one customer by uid
  python3 reset_test_data.py --phone +49000000000   # delete one customer by phone

Override credentials via env if needed:
  SB_API_KEY, SB_ADMIN_EMAIL, SB_ADMIN_PASSWORD, SB_PROJECT_ID
"""

import argparse
import json
import os
import sys
import urllib.error
import urllib.request

API_KEY = os.environ.get("SB_API_KEY", "AIzaSyBxRHDfeqfjKeE2982uS8sKp1_sLtHXlBE")
EMAIL = os.environ.get("SB_ADMIN_EMAIL", "admin@gmail.com")
PASSWORD = os.environ.get("SB_ADMIN_PASSWORD", "admin1221")
PROJECT = os.environ.get("SB_PROJECT_ID", "sarkisbread")

BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"


def _req(url, method="GET", token=None, payload=None):
    data = json.dumps(payload).encode() if payload is not None else None
    headers = {"Content-Type": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as r:
            body = r.read().decode()
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as e:
        msg = e.read().decode()
        raise RuntimeError(f"{method} {url} -> {e.code}: {msg[:400]}")


def sign_in():
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
    res = _req(url, "POST", payload={
        "email": EMAIL, "password": PASSWORD, "returnSecureToken": True})
    return res["idToken"]


def list_collection(path, token):
    """Yields (doc_id, fields) for every doc in a collection (paginated)."""
    page_token = None
    while True:
        url = f"{BASE}/{path}?pageSize=300"
        if page_token:
            url += f"&pageToken={page_token}"
        res = _req(url, token=token)
        for doc in res.get("documents", []):
            doc_id = doc["name"].split("/")[-1]
            yield doc_id, doc.get("fields", {})
        page_token = res.get("nextPageToken")
        if not page_token:
            break


def delete_doc(path, token):
    _req(f"{BASE}/{path}", "DELETE", token=token)


def s(fields, key):
    return fields.get(key, {}).get("stringValue", "")


def b(fields, key):
    return fields.get(key, {}).get("booleanValue", False)


def target_customers(token, args):
    customers = []
    for uid, fields in list_collection("users", token):
        if b(fields, "isAdmin"):
            continue
        if args.uid and uid != args.uid:
            continue
        if args.phone and s(fields, "phone") != args.phone:
            continue
        customers.append((uid, s(fields, "name"), s(fields, "phone")))
    return customers


def delete_customer(uid, token):
    # 1. orders for this user
    deleted_orders = 0
    for oid, fields in list_collection("orders", token):
        if s(fields, "userId") == uid:
            delete_doc(f"orders/{oid}", token)
            deleted_orders += 1

    # 2. chat topic messages/{uid}/messages/* then the topic doc
    deleted_msgs = 0
    try:
        for mid, _ in list_collection(f"messages/{uid}/messages", token):
            delete_doc(f"messages/{uid}/messages/{mid}", token)
            deleted_msgs += 1
    except RuntimeError:
        pass
    try:
        delete_doc(f"messages/{uid}", token)
    except RuntimeError:
        pass

    # 3. user doc
    delete_doc(f"users/{uid}", token)
    return deleted_orders, deleted_msgs


def main():
    ap = argparse.ArgumentParser(description="Delete Sarkis Bread test customer data")
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--list", action="store_true", help="list test customers, delete nothing")
    g.add_argument("--all", action="store_true", help="delete ALL non-admin customers")
    g.add_argument("--uid", help="delete one customer by Firebase uid")
    g.add_argument("--phone", help="delete one customer by phone (E.164, e.g. +49000000000)")
    args = ap.parse_args()

    print(f"Signing in as {EMAIL} ...")
    token = sign_in()
    print("OK.\n")

    customers = target_customers(token, args)
    if not customers:
        print("No matching test customers found.")
        return

    print(f"{'UID':<30} {'Name':<20} Phone")
    print("-" * 70)
    for uid, name, phone in customers:
        print(f"{uid:<30} {name:<20} {phone}")
    print()

    if args.list:
        print(f"{len(customers)} customer(s). (list mode — nothing deleted)")
        return

    confirm = input(f"Delete {len(customers)} customer(s) and their orders/chats? [y/N] ")
    if confirm.strip().lower() != "y":
        print("Aborted.")
        return

    for uid, name, _ in customers:
        orders, msgs = delete_customer(uid, token)
        print(f"  deleted {name} ({uid}): {orders} orders, {msgs} messages, 1 user doc")
    print("\nDone. Relaunch the customer app (or log out/in) to re-test registration.")


if __name__ == "__main__":
    main()
