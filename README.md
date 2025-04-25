# UniFi to PRTG Exporter

This project provides a Python-based exporter that pulls wireless metrics from UniFi OS controllers and serves them via a web interface in a format PRTG Network Monitor can read.

## 🌐 Overview

- ✅ Works with UniFi OS Consoles (UDM, Cloud Key Gen2+, etc.)
- 📊 Metrics: channel utilization, SSID client counts, per-AP clients, 2.4/5GHz band splits
- 📁 Outputs JSON to `/var/www/html/unifi-prtg/`
- 🌍 Served over HTTP via `lighttpd` on port `8111`
- 🕒 Runs every 5 minutes using `systemd` timer

## 🚀 Installation

Clone or download this repo, then:

```bash
chmod +x setup_unifi_prtg.sh
./setup_unifi_prtg.sh
```

The script will prompt for:
- UniFi Controller IP
- Username & Password
- Site ID (default: `default`)

Then it installs everything needed and starts the service.

## 📡 Access JSON Metrics

Visit:  
```
http://<your-server-ip>:8111/unifi-prtg/
```

Metrics files:
- `channel_util.json`
- `ssid_clients.json`
- `ssid_bandwidth.json`
- `ap_clients.json`
- `band_clients.json`

## 📦 Project Layout

```
unifi-prtg-exporter/
├── setup_unifi_prtg.sh      # Installation script
├── unifi_metrics_exporter.py # Exporter logic
└── README.md                # This file
```

## 📋 Requirements

- Ubuntu Server (20.04+ recommended)
- Python 3.6+
- `requests` Python module
- A UniFi OS–based controller

## 🛠 Use in PRTG

Configure an HTTP sensor to fetch the JSON file and parse the desired metrics.

## 🧑‍💻 Maintainer

Will – [will@willspace.co.uk](mailto:will@willspace.co.uk)

## 🪪 License

MIT – see [LICENSE](./LICENSE)
