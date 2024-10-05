$WEB_CMD="set wifi.handshakes.file /data/bettercap-wifi-handshakes.pcap; set api.rest.address 0.0.0.0; set http.server.port 1337; set http.server.address 0.0.0.0; set http.server.path /usr/local/share/bettercap/ui; api.rest on; http.server on;"
	
#$UPDATE_CMD="caplets.update; ui.update; q"


docker run --rm -it --name bettercap --privileged `
    --net=host `
    -v ./vol/bettercap:/usr/local/share/bettercap `
    -v "./vol/data":/data `
    bettercap/bettercap `
    -eval "$WEB_CMD"