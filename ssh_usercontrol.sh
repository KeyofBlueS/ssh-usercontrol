#!/bin/bash

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-usercontrol
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

for name in yad
do
  [[ $(which $name 2>/dev/null) ]] || { echo -en "\n$name è richiesto da questo script. Utilizza 'sudo apt-get install $name'";deps=1; }
done
[[ $deps -ne 1 ]] && echo "" || { echo -en "\nInstalla le dipendenze necessarie e riavvia questo script\n";exit 1; }

STOREDPTS="$(who | grep "pts")"

for pid in $(pgrep "ssh-usercontrol"); do
    if [ $pid != $$ ]; then
        kill -9 $pid
    fi 
done

pkill -15 -f "yad --notification --text=Utenti remoti connessi via ssh"
pkill -15 -f "yad --title=Utenti ssh connessi"

echo $@ | grep -Poq '\d+'
if [ $? = 0 ]; then
TIME="$(echo $@ | grep -Po '\d+')"
else
TIME=10
fi

ssh_userconnection(){
echo -e "\e[1;34m
## CONTROLLO UTENTI REMOTI CONNESSI ##
\e[0m"
while true
do
CURRENTPTS="$(who | grep "pts")"
echo $CURRENTPTS | grep -q "pts"
if [ $? = 0 ]; then
		echo -e "\e[1;31m
## UTENTE REMOTO CONNESSO ##
	\e[0m"
	date
	echo $CURRENTPTS
	if [ "$CURRENTPTS" == "$STOREDPTS" ]; then
		pgrep -f "yad --notification --text=Utenti remoti connessi via ssh"
		if [ $? = 0 ]; then
			echo -e "\e[1;32m
Icona di notifica già presente
			\e[0m"
		else
			echo -e "\e[1;34m
Imposto lista utenti
			\e[0m"
			yad --notification --text="Utenti remoti connessi via ssh" --command="yad --title='Utenti ssh connessi' --center --text='`who | grep pts`' --button=gtk-ok:0" &
		fi
	else
			echo -e "\e[1;31m
Aggiorno lista utenti
			\e[0m"
			pkill -15 -f "yad --notification --text=Utenti remoti connessi via ssh"
			pkill -15 -f "yad --title=Utenti ssh connessi"
			yad --notification --text="Utenti remoti connessi via ssh" --command="yad --title='Utenti ssh connessi' --center --text='`who | grep pts`' --button=gtk-ok:0" &
	fi
	STOREDPTS="$(who | grep "pts")"
	echo -e "\e[1;31m
Premi INVIO per uscire, o attendi $TIME secondi per proseguire il controllo\e[0m"
	if read -t "$TIME" _e; then
		pkill -15 -f "yad --notification --text=Utenti remoti connessi via ssh"
		pkill -15 -f "yad --title=Utenti ssh connessi"
		exit 0
	fi
else
	date
	echo -e "\e[1;34m
## NESSUN UTENTE REMOTO CONNESSO ##\e[0m"
	pkill -15 -f "yad --notification --text=Utenti remoti connessi via ssh"
	pkill -15 -f "yad --title=Utenti ssh connessi"
	echo -e "\e[1;31m
Premi INVIO per uscire, o attendi $TIME secondi per proseguire il controllo\e[0m"
	if read -t "$TIME" _e; then
		exit 0
	fi
fi
done
}

givemehelp(){
echo "
# ssh-usercontrol

# Version:    1.0.0
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-usercontrol
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

### DESCRIZIONE
Questo script permette di controllare le attuali connessioni ssh remote su un server ssh. Se una o più connessioni ssh remote sono in esecuzione
sul server, comparirà nella system tray un'icona, cliccando su quest'ultima verranno visualizzate le connessioni ssh remote correnti.
Il controllo avviene ciclicamente con un intervallo di 10 secondi di default.

### UTILIZZO
Per utilizzare manualmente lo script basta digitare su un terminale:

$ ssh-usercontrol


È possibile utilizzare le seguenti opzioni:

--secondi n   Imposta l'intervallo di tempo, in secondi, fra un controllo ed il seguente (default: 10 secondi)

--help        Visualizza una descrizione ed opzioni di ssh-usercontrol
"
exit 0
}

if [ "$1" = "" ]
then
   ssh_userconnection
elif [ "$1" = "--help" ]
then
   givemehelp
else
   ssh_userconnection
fi
