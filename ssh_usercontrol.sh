#!/bin/bash

# Version:    1.0.4
# Author:     KeyofBlueS
# Repository: https://github.com/KeyofBlueS/ssh-usercontrol
# License:    GNU General Public License v3.0, https://opensource.org/licenses/GPL-3.0

if curl -s github.com > /dev/null; then
	SCRIPT_LINK="https://raw.githubusercontent.com/KeyofBlueS/ssh-usercontrol/master/ssh_usercontrol.sh"
	UPSTREAM_VERSION="$(timeout -s SIGTERM 15 curl -L "$SCRIPT_LINK" 2> /dev/null | grep "# Version:" | head -n 1)"
	LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
	REPOSITORY_LINK="$(cat "${0}" | grep "# Repository:" | head -n 1)"
	if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
		echo -n
	else
		echo -e "\e[1;33m-----------------------------------------------------------------------------------	
## ATTENZIONE: questo script non risulta aggiornato alla versione upstream, visita:
\e[1;32m$REPOSITORY_LINK

\e[1;33m$LOCAL_VERSION (locale)
\e[1;32m$UPSTREAM_VERSION (upstream)
\e[1;33m-----------------------------------------------------------------------------------

\e[1;35mPremi invio per aggiornare questo script o attendi 10 secondi per andare avanti normalmente
\e[1;31m## ATTENZIONE: eventuali modifiche effettuate a questo script verranno perse!!!
\e[0m
"
		if read -t 10 _e; then
			echo -e "\e[1;34m	Aggiorno questo script...\e[0m"
			if [[ -L "${0}" ]]; then
				scriptpath="$(readlink -f "${0}")"
			else
				scriptpath="${0}"
			fi
			if [ -z "${scriptfolder}" ]; then
				scriptfolder="${scriptpath}"
				if ! [[ "${scriptpath}" =~ ^/.*$ ]]; then
					if ! [[ "${scriptpath}" =~ ^.*/.*$ ]]; then
					scriptfolder="./"
					fi
				fi
				scriptfolder="${scriptfolder%/*}/"
				scriptname="${scriptpath##*/}"
			fi
			if timeout -s SIGTERM 15 curl -s -o /tmp/"${scriptname}" "$SCRIPT_LINK"; then
				if [[ -w "${scriptfolder}${scriptname}" ]] && [[ -w "${scriptfolder}" ]]; then
					mv /tmp/"${scriptname}" "${scriptfolder}"
					chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				elif which sudo > /dev/null 2>&1; then
					echo -e "\e[1;33mPer proseguire con l'aggiornamento occorre concedere i permessi di amministratore\e[0m"
					sudo mv /tmp/"${scriptname}" "${scriptfolder}"
					sudo chown root:root "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod 755 "${scriptfolder}${scriptname}" > /dev/null 2>&1
					sudo chmod +x "${scriptfolder}${scriptname}" > /dev/null 2>&1
				else
					echo -e "\e[1;31m	Errore durante l'aggiornamento di questo script!
Permesso negato!
\e[0m"
				fi
			else
				echo -e "\e[1;31m	Errore durante il download!
\e[0m"
			fi
			LOCAL_VERSION="$(cat "${0}" | grep "# Version:" | head -n 1)"
			if echo "$LOCAL_VERSION" | grep -q "$UPSTREAM_VERSION"; then
				echo -e "\e[1;34m	Fatto!
\e[0m"
				exec "${scriptfolder}${scriptname}"
			else
				echo -e "\e[1;31m	Errore durante l'aggiornamento di questo script!
\e[0m"
			fi
		fi
	fi
fi

ssh_userconnection(){
echo -e "\e[1;34m
## CONTROLLO UTENTI REMOTI CONNESSI ##
\e[0m"
while true
do
CURRENTPTS="$(who | grep "pts")"
if echo $CURRENTPTS | grep -q "pts"; then
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

# Version:    1.0.4
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

if [ "$1" = "" ]; then
	ssh_userconnection
elif [ "$1" = "--help" ]; then
	givemehelp
else
	ssh_userconnection
fi
