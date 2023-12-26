# Importer wifi-profil fra USB-drev.
netsh wlan add profile filename="{wifi xml filsti}" Interface="WI-FI" user=current
# Forbinde til KFS-INTERN wifi
netsh wlan connect ssid={Din SSID} name={Navn}

