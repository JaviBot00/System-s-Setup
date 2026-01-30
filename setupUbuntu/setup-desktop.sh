#!/bin/bash

valor="S"
validate_number='^[0-9]+$'
cPaquete="apt"

clear

fCambiarGestorPaquetes() {
    echo "Gestionar paquetes con actual: $cPaquete"
    read -p "¿Cambiar el gestor de paquetes a Nala? [y/N]: " instalarNala  # Install Nala? [yN]
    if [[ "$instalarNala" =~ ^[YySs]$ ]]; then
        cPaquete="nala"
        echo "Gestor de paquetes cambiado a Nala"
    fi
}

fInstalarMozillaFirefox() {
    echo "Instalando Mozilla Firefox..."
    # wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    # echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] http://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    sudo apt-mark hold firefox
    sudo add-apt-repository ppa:mozillateam/ppa
    sudo $cPaquete install firefox
}

fInstalarDiscord() {
    echo "Instalando Discord..."
    wget -O discord-latest.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo $cPaquete install ./discord-latest.deb
    # sudo dpkg -i ./discord-latest.deb
    rm discord-latest.deb
}

fInstalarSpotify() {
    echo "Instalando Spotify..."
    curl -fsSL https://download.spotify.com/debian/pubkey_5384CE82BA52C83A.asc | sudo gpg --dearmor -o /etc/apt/keyrings/spotify.gpg
    echo "deb [signed-by=/etc/apt/keyrings/spotify.gpg] https://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
    sudo $cPaquete update
    sudo $cPaquete install spotify-client
}

fInstalarRhythmbox() {
    echo  "Instalando Rhytmbox..."
    sudo $cPaquete install rhythmbox rhythmbox-plugin-alternative-toolbar
    cp /usr/share/applications/rhythmbox.desktop ~/.local/share/applications
    cp /usr/share/applications/org.gnome.Rhythmbox3.desktop ~/.local/share/applications
    nano /usr/share/applications/org.gnome.Rhythmbox3.desktop
    GTK_THEME=Yaru-dark rhythmbox
    nano .local/share/applications/org.gnome.Rhythmbox3.desktop
}

fTerminar() {
    read -p "¿Terminar el SetUp? [y/N]: " seguir
    [[ "$seguir" =~ ^[YySs]$ ]] && valor="N"
    echo "Bye!"
    echo "See you later"
    sleep 2
    clear
    exit 0
}

while [ "$valor" = "S" ]; do
    echo "Seleccione una opción:"
    echo "  01) Cambiar gestor de paquetes (actual: $cPaquete)"
    echo "  02) Mozilla Firefox"
    # echo "  03) Discord"
    echo "  04) Spotify"
    # echo "  05) Rhythmbox"
    echo "  98) Volver al MAIN"
    echo "  99) Salir"
    read -p "Elija: " opcion

    [[ ! $opcion =~ $validate_number ]] && echo "Opción inválida" && sleep 1 && continue

    case $opcion in
        01 | 1) fCambiarGestorPaquetes ;;

        02 | 2) fInstalarMozillaFirefox ;;

        # 03 | 3) fInstalarDiscord ;;

        04 | 4) fInstalarSpotify ;;

        # 05 | 5) fInstalarRhythmbox ;;

        98) break ;;

        99) fTerminar ;;

        *)
            echo "Operación no válida"
            sleep 2
            clear
            ;;
    esac

    # clear
done
