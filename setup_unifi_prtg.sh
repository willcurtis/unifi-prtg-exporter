    #!/bin/bash
    # UniFi to PRTG Exporter Setup Script (safe with sudo tee)
    # Version: 2.0.3
    # Maintainer: Will <will@willspace.co.uk>

    set -e

    echo "== UniFi PRTG Exporter Installation =="

    read -rp "Enter UniFi Controller IP: " UNIFI_HOST
    read -rp "Enter UniFi Username: " UNIFI_USER
    read -srp "Enter UniFi Password: " UNIFI_PASS
    echo
    read -rp "Enter UniFi Site ID [default]: " UNIFI_SITE
    UNIFI_SITE=${UNIFI_SITE:-default}

    echo "[1/6] Installing dependencies..."
    sudo apt update
    sudo apt install -y python3 python3-pip lighttpd curl
    sudo pip3 install requests

    echo "[2/6] Writing lighttpd config..."
    sudo mkdir -p /var/www/html/unifi-prtg
    sudo chown www-data:www-data /var/www/html/unifi-prtg

    sudo tee /etc/lighttpd/lighttpd.conf > /dev/null <<EOF
server.port = 8111
server.bind = "0.0.0.0"
server.document-root = "/var/www/html"
server.upload-dirs = ( "/var/cache/lighttpd/uploads" )
server.errorlog = "/var/log/lighttpd/error.log"
index-file.names = ( "index.html" )
include_shell "/usr/share/lighttpd/create-mime.conf.pl"
include "/etc/lighttpd/conf-enabled/*.conf"
EOF

    sudo systemctl restart lighttpd

    echo "[3/6] Creating /etc/unifi_prtg.env..."
    sudo tee /etc/unifi_prtg.env > /dev/null <<EOF
UNIFI_USER=${UNIFI_USER}
UNIFI_PASS=${UNIFI_PASS}
UNIFI_HOST=${UNIFI_HOST}
UNIFI_PORT=443
UNIFI_SITE=${UNIFI_SITE}
EOF
    sudo chmod 600 /etc/unifi_prtg.env

    echo "[4/6] Writing exporter script using sudo tee..."
    sudo mkdir -p /opt/unifi_prtg
    sudo rm -f /opt/unifi_prtg/unifi_metrics_exporter.py
echo '#!/usr/bin/env python3' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '# UniFi to PRTG Metrics Exporter for UniFi OS Consoles' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '# Version: 2.0.0' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '# Maintainer: Will <will@willspace.co.uk>' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '#' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '# CHANGELOG:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '# - 2.0.0: Rewrote to support UniFi OS API and login paths using requests.Session' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '# - 1.1.0: Added metrics for SSID clients, bandwidth usage, AP-level clients, and band-specific counts' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '# - 1.0.0: Initial version with channel utilization only' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'import os' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'import json' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'import requests' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'from datetime import datetime' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'from collections import defaultdict' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'UNIFI_USER = os.getenv("UNIFI_USER")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'UNIFI_PASS = os.getenv("UNIFI_PASS")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'UNIFI_HOST = os.getenv("UNIFI_HOST", "127.0.0.1")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'UNIFI_PORT = int(os.getenv("UNIFI_PORT", 443))' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'SITE_ID = os.getenv("UNIFI_SITE", "default")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'OUTDIR = "/var/www/html/unifi-prtg"' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'BASE_URL = f"https://{UNIFI_HOST}:{UNIFI_PORT}"' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'API_URL = f"{BASE_URL}/proxy/network/api/s/{SITE_ID}"' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'session = requests.Session()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'session.verify = False' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'requests.packages.urllib3.disable_warnings()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def login():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    resp = session.post(f"{BASE_URL}/api/auth/login", json={' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        "username": UNIFI_USER,' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        "password": UNIFI_PASS' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    })' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    if resp.status_code != 200:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        raise Exception(f"Login failed: {resp.status_code} {resp.text}")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def write_json(name, data):' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    with open(f"{OUTDIR}/{name}.json", "w") as f:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        json.dump(data, f)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def get(path):' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    resp = session.get(f"{API_URL}{path}")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    resp.raise_for_status()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    return resp.json()["data"]' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def get_channel_utilization():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    wlangs = get("/rest/wlanconf")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for wlan in wlangs:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        radio = wlan.get("radio")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        util = wlan.get("channel_utilization", 0)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        if radio:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            result["prtg"]["result"].append({' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '                "channel": f"{radio} Channel Utilization",' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '                "value": util,' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '                "unit": "percent", "float": 1,' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '                "LimitMode": 1, "LimitMaxError": 90, "LimitMaxWarning": 70' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            })' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    write_json("channel_util", result)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def get_ssid_clients():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    clients = get("/stat/sta")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    ssid_count = defaultdict(int)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for c in clients:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        ssid = c.get("essid")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        if ssid:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            ssid_count[ssid] += 1' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for ssid, count in ssid_count.items():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        result["prtg"]["result"].append({' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            "channel": f"{ssid} Clients", "value": count, "unit": "count", "float": 0' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        })' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    write_json("ssid_clients", result)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def get_ssid_bandwidth():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    clients = get("/stat/sta")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    totals = defaultdict(lambda: {"rx": 0, "tx": 0})' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for c in clients:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        ssid = c.get("essid")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        if ssid:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            totals[ssid]["rx"] += c.get("rx_bytes", 0)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            totals[ssid]["tx"] += c.get("tx_bytes", 0)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for ssid, stats in totals.items():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        result["prtg"]["result"].append({' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            "channel": f"{ssid} RX MB", "value": round(stats["rx"] / 1048576, 2), "unit": "MB", "float": 1})' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        result["prtg"]["result"].append({' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            "channel": f"{ssid} TX MB", "value": round(stats["tx"] / 1048576, 2), "unit": "MB", "float": 1})' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    write_json("ssid_bandwidth", result)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def get_ap_clients():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    clients = get("/stat/sta")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    ap_count = defaultdict(int)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for c in clients:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        ap = c.get("ap_mac")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        if ap:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            ap_count[ap] += 1' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for ap_mac, count in ap_count.items():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        result["prtg"]["result"].append({' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            "channel": f"AP {ap_mac} Clients", "value": count, "unit": "count", "float": 0' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        })' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    write_json("ap_clients", result)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def get_band_clients():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    clients = get("/stat/sta")' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    band_count = defaultdict(int)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for c in clients:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        radio = c.get("radio", "").lower()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        if "na" in radio:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            band_count["5GHz"] += 1' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        elif "ng" in radio:' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            band_count["2.4GHz"] += 1' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    result = {"prtg": {"result": [], "text": f"Updated {datetime.utcnow().isoformat()} UTC"}}' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    for band, count in band_count.items():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        result["prtg"]["result"].append({' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '            "channel": f"{band} Clients", "value": count, "unit": "count", "float": 0' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '        })' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    write_json("band_clients", result)' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'def main():' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    login()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    get_channel_utilization()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    get_ssid_clients()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    get_ssid_bandwidth()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    get_ap_clients()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    get_band_clients()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo 'if __name__ == "__main__":' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null
echo '    main()' | sudo tee -a /opt/unifi_prtg/unifi_metrics_exporter.py > /dev/null

    sudo chmod +x /opt/unifi_prtg/unifi_metrics_exporter.py

    echo "[5/6] Writing systemd unit files..."
    sudo tee /etc/systemd/system/unifi_prtg.service > /dev/null <<EOF
[Unit]
Description=Run UniFi OS Metrics Export Script

[Service]
EnvironmentFile=/etc/unifi_prtg.env
ExecStart=/opt/unifi_prtg/unifi_metrics_exporter.py
EOF

    sudo tee /etc/systemd/system/unifi_prtg.timer > /dev/null <<EOF
[Unit]
Description=Run UniFi exporter every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Unit=unifi_prtg.service

[Install]
WantedBy=timers.target
EOF

    echo "[6/6] Starting exporter..."
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
    sudo systemctl enable --now unifi_prtg.timer

    IP=$(hostname -I | awk '{print $1}')
    echo "✅ Exporter setup complete. Access your JSON at:"
    echo "  http://$IP:8111/unifi-prtg/"
