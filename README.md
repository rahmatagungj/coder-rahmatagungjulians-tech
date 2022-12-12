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

### Install Caddy Server
```
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install caddy
```

Update config `vim /etc/caddy/Caddyfile` :
```
coder.rahmatagungjulians.tech, *.coder.rahmatagungjulians.tech {
        reverse_proxy localhost:3000
        tls {
            on_demand
            issuer acme {
              email rahmatagungj@gmail.com
            }
          }
}
```

- Use systemd to start Caddy now and on reboot
```
sudo systemctl enable --now caddy
```

- View the logs to ensure a successful start
```
journalctl -u caddy.service -b
```

- To restart Caddy after applying system changes
```
sudo systemctl restart caddy
```
