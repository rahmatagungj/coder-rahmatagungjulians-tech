# coder-rahmatagungjulians-tech
My Coder app

## Setup 

### Install Coder OSS
```
curl -fsSL https://coder.com/install.sh | sh
```

Update config `/etc/coder.d/coder.env` :
```
# Coder must be reachable from an external URL for users and workspaces to connect.
# e.g. https://coder.example.com
CODER_ACCESS_URL=https://coder.rahmatagungjulians.tech
CODER_WILDCARD_ACCESS_URL=*.coder.rahmatagungjulians.tech
CODER_ADDRESS=127.0.0.1:3000
CODER_PG_CONNECTION_URL=
CODER_TLS_CERT_FILE=
CODER_TLS_ENABLE=
CODER_TLS_KEY_FILE=

# Run "coder server --help" for flag information.                                                   
```

- Use systemd to start Coder now and on reboot
```
sudo systemctl enable --now coder
```

- View the logs to ensure a successful start
```
journalctl -u coder.service -b
```

- To restart Coder after applying system changes
```
sudo systemctl restart coder
```
