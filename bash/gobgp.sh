#!/bin/bash

# Thanks Github Copilot
curl https://api.github.com/repos/osrg/gobgp/releases/latest | grep "browser_download_url.*linux_amd64.tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -qi -

tar -xzvf gobgp_*_linux_amd64.tar.gz
mv gobgp /usr/bin/
mv gobgpd /usr/bin/

groupadd --system gobgpd
useradd --system -d /var/lib/gobgpd -s /bin/bash -g gobgpd gobgpd
mkdir -p /var/{lib,run,log}/gobgpd
chown -R gobgpd:gobgpd /var/{lib,run,log}/gobgpd
mkdir -p /etc/gobgpd
chown -R gobgpd:gobgpd /etc/gobgpd

echo '
[Unit]
Description=GoBGP Routing Daemon
Wants=network.target
After=network.target

[Service]
Type=notify
ExecStartPre=/usr/bin/gobgpd -f /etc/gobgpd/gobgpd.conf -d
ExecStart=/usr/bin/gobgpd -f /etc/gobgpd/gobgpd.conf --sdnotify
ExecReload=/usr/bin/kill -HUP $MAINPID
StandardOutput=journal
StandardError=journal
User=gobgpd
Group=gobgpd
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
' > /usr/lib/systemd/system/gobgp.service 

echo '
[global.config]
  as = 65535
  router-id = "10.0.0.0"

' > /etc/gobgpd/gobgpd.conf

 systemctl enable gobgp.service
 systemctl start gobgp.service

 service gobgp status