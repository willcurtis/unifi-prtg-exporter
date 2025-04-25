#!/usr/bin/env python3
# UniFi to PRTG Metrics Exporter for UniFi OS Consoles
# Version: 2.0.0
# Maintainer: Will <will@willspace.co.uk>
#
# CHANGELOG:
# - 2.0.0: Rewrote to support UniFi OS API and login paths using requests.Session
# - 1.1.0: Added metrics for SSID clients, bandwidth usage, AP-level clients, and band-specific counts
# - 1.0.0: Initial version with channel utilization only

import os
import json
import requests
from datetime import datetime
from collections import defaultdict

UNIFI_USER = os.getenv("UNIFI_USER")
UNIFI_PASS = os.getenv("UNIFI_PASS")
UNIFI_HOST = os.getenv("UNIFI_HOST", "127.0.0.1")
UNIFI_PORT = int(os.getenv("UNIFI_PORT", 443))
SITE_ID = os.getenv("UNIFI_SITE", "default")
OUTDIR = "/var/www/html/unifi-prtg"

BASE_URL = f"https://{UNIFI_HOST}:{UNIFI_PORT}"
API_URL = f"{BASE_URL}/proxy/network/api/s/{SITE_ID}"

session = requests.Session()
session.verify = False
requests.packages.urllib3.disable_warnings()

def login():
    resp = session.post(f"{BASE_URL}/api/auth/login", json={
        "username": UNIFI_USER,
        "password": UNIFI_PASS
    })
    if resp.status_code != 200:
        raise Exception(f"Login failed: {resp.status_code} {resp.text}")

def write_json(name, data):
    with open(f"{OUTDIR}/{name}.json", "w") as f:
        json.dump(data, f)

def get(path):
    resp = session.get(f"{API_URL}{path}")
    resp.raise_for_status()
    return resp.json()["data"]

def get_channel_utilization():
    wlangs = get("/rest/wlanconf")
    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}
    for wlan in wlangs:
        radio = wlan.get("radio")
        util = wlan.get("channel_utilization", 0)
        if radio:
            result["prtg"]["result"].append({
                "channel": f"{radio} Channel Utilization",
                "value": util,
                "unit": "percent", "float": 1,
                "LimitMode": 1, "LimitMaxError": 90, "LimitMaxWarning": 70
            })
    write_json("channel_util", result)

def get_ssid_clients():
    clients = get("/stat/sta")
    ssid_count = defaultdict(int)
    for c in clients:
        ssid = c.get("essid")
        if ssid:
            ssid_count[ssid] += 1
    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}
    for ssid, count in ssid_count.items():
        result["prtg"]["result"].append({
            "channel": f"{ssid} Clients", "value": count, "unit": "count", "float": 0
        })
    write_json("ssid_clients", result)

def get_ssid_bandwidth():
    clients = get("/stat/sta")
    totals = defaultdict(lambda: {"rx": 0, "tx": 0})
    for c in clients:
        ssid = c.get("essid")
        if ssid:
            totals[ssid]["rx"] += c.get("rx_bytes", 0)
            totals[ssid]["tx"] += c.get("tx_bytes", 0)
    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}
    for ssid, stats in totals.items():
        result["prtg"]["result"].append({
            "channel": f"{ssid} RX MB", "value": round(stats["rx"] / 1048576, 2), "unit": "MB", "float": 1})
        result["prtg"]["result"].append({
            "channel": f"{ssid} TX MB", "value": round(stats["tx"] / 1048576, 2), "unit": "MB", "float": 1})
    write_json("ssid_bandwidth", result)

def get_ap_clients():
    clients = get("/stat/sta")
    ap_count = defaultdict(int)
    for c in clients:
        ap = c.get("ap_mac")
        if ap:
            ap_count[ap] += 1
    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}
    for ap_mac, count in ap_count.items():
        result["prtg"]["result"].append({
            "channel": f"AP {ap_mac} Clients", "value": count, "unit": "count", "float": 0
        })
    write_json("ap_clients", result)

def get_band_clients():
    clients = get("/stat/sta")
    band_count = defaultdict(int)
    for c in clients:
        radio = c.get("radio", "").lower()
        if "na" in radio:
            band_count["5GHz"] += 1
        elif "ng" in radio:
            band_count["2.4GHz"] += 1
    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}
    for band, count in band_count.items():
        result["prtg"]["result"].append({
            "channel": f"{band} Clients", "value": count, "unit": "count", "float": 0
        })
    write_json("band_clients", result)

def main():
    login()
    get_channel_utilization()
    get_ssid_clients()
    get_ssid_bandwidth()
    get_ap_clients()
    get_band_clients()

if __name__ == "__main__":
    main()
