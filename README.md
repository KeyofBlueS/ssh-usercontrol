# ssh-usercontrol

# Version:    1.0.2
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-usercontrol
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette di controllare le attuali connessioni ssh remote su un server ssh. Se una o più connessioni ssh remote sono in esecuzione
sul server, comparirà nella system tray un'icona, cliccando su quest'ultima verranno visualizzate le connessioni ssh remote correnti.
Il controllo avviene ciclicamente con un intervallo di 10 secondi di default.

### INSTALLAZIONE
```sh
curl -o /tmp/ssh_usercontrol.sh 'https://raw.githubusercontent.com/KeyofBlueS/ssh-usercontrol/master/ssh_usercontrol.sh'
sudo mkdir -p /opt/ssh-usercontrol/
sudo mv /tmp/ssh_usercontrol.sh /opt/ssh-usercontrol/
sudo chown root:root /opt/ssh-usercontrol/ssh_usercontrol.sh
sudo chmod 755 /opt/ssh-usercontrol/ssh_usercontrol.sh
sudo chmod +x /opt/ssh-usercontrol/ssh_usercontrol.sh
sudo ln -s /opt/ssh-usercontrol/ssh_usercontrol.sh /usr/local/bin/ssh-usercontrol

### UTILIZZO
Per utilizzare manualmente lo script basta digitare su un terminale:
```sh
$ ssh-usercontrol
```

È possibile utilizzare le seguenti opzioni:
```
--secondi n   Imposta l'intervallo di tempo, in secondi, fra un controllo ed il seguente (default: 10 secondi)

--help        Visualizza una descrizione ed opzioni di ssh-usercontrol
```
