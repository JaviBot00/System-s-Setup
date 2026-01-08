#!/bin/bash

valor="S"
validate_number='^[0-9]+$'
cPaquete="apt"

fCambiarGestorPaquetes() {
    echo "Gestionar paquetes con actual: $cPaquete"
    read -p "¿Cambiar el gestor de paquetes a Nala? [y/N]: " instalarNala  # Install Nala? [yN]
    if [[ "$instalarNala" =~ ^[YySs]$ ]]; then
        cPaquete="nala"
        echo "Gestor de paquetes cambiado a Nala"
    fi
}

fInstalarNala() {
    echo "Gestionar paquetes con actual: $cPaquete"
    read -p "¿Instalar Nala como gestor de paquetes? [y/N]: " instalarNala  # Install Nala? [yN]
    if [[ "$instalarNala" =~ ^[YySs]$ ]]; then
        sudo apt install nala
        clear
        echo "Ahora se ejecutará 'sudo nala fetch' para"
        echo "seleccionar los repositorios más rápidos."
        echo "Se recomienda elegir los repositorios del 1 al 6"
        sleep 5
        sudo nala fetch
        cPaquete="nala"
    fi
}

fInstalarJava() {
    echo "  01) OpenJDK Default"
    echo "  02) OpenJDK 11"
    echo "  03) OpenJDK 17"
    echo "  04) OpenJDK 21"
    read -p "Elija: " opcionJava
    case $opcionJava in
        01 | 1) sudo $cPaquete install default-jdk ;;
        02 | 2) sudo $cPaquete install openjdk-11-jdk ;;
        03 | 3) sudo $cPaquete install openjdk-17-jdk ;;
        04 | 4) sudo $cPaquete install openjdk-21-jdk ;;
        *) echo "Opción inválida" ;;
    esac
}

fAjustarHora() {
    echo "Ajustando la hora..."
    # sudo timedatectl set-ntp off
    sudo timedatectl set-timezone Europe/Madrid
    # sudo timedatectl set-ntp on
    date
}

fInstalarPython() {
    sudo $cPaquete install python3 python3-pip python3-venv
}

fPaquetesUtiles() {
    # Falta agregar: tree, exa, bat, fd-find, ripgrep, fzf, entr, tldr, httpie, jq, yq, dust, procs
    # Falta agregar: visual-studio-code, code-oss, neovim
    # Falta agregar: docker, docker-compose, podman
    # Falta agregar: vcl
    echo "Instalando paquetes útiles..."
    sudo $cPaquete install ncdu curl wget htop git neofetch bpytop clang cargo unrar \
    gstreamer1.0-vaapi unzip ntfs-3g p7zip neofetch bpytop \
    libc6-i386 libc6-x32 libu2f-udev samba-common-bin exfat-fuse linux-headers-$(uname -r) \
    software-properties-common apt-transport-https
}

fPaquetesInnecesarios() {
    read -p "¿Eliminar snapd y servicios innecesarios? [y/N]: " confirmar
    [[ ! "$confirmar" =~ ^[YySs]$ ]] && return

    echo "Eliminando paquetes innecesarios..."
    sudo systemctl disable snapd apport || true
    sudo chmod -x /etc/update-motd.d/* || true

    # sudo $cPaquete purge snapd cups cups-browsed printer-driver-* bluez
    # avahi avahi-daemon modemmanager cloud-init multipath-tools lxd lxd-agent-loader
    
    sudo $cPaquete purge snapd cups cups-browsed avahi-daemon \
        modemmanager cloud-init multipath-tools lxd
    sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd

    sudo $cPaquete autoremove
    sudo $cPaquete autopurge
    sudo apt autoclean
}

fTerminar() {
    read -p "¿Terminar el SetUp? [y/N]: " seguir
    [[ "$seguir" =~ ^[YySs]$ ]] && valor="N"
}

while [ "$valor" = "S" ]; do
    echo "=== SetUp SERVER ==="
    echo "  01) Cambiar gestor de paquetes (actual: $cPaquete)"
    echo "  02) Instalar Nala (Recomendado)"
    echo "  03) Java (OpenJDK)"
    echo "  04) Python3"
    echo "  05) Paquetes utiles"
    echo "  06) Borrar paquetes innecesarios"
    echo "  07) Ajustar la hora"
    echo "  98) Volver al MAIN"
    echo "  99) Salir"
    read -p "Elija: " opcion

    [[ ! $opcion =~ $validate_number ]] && echo "Opción inválida" && sleep 1 && continue

    case $opcion in
        01 | 1) fCambiarGestorPaquetes;;

        02 | 2) fInstalarNala;;

        03 | 3) fInstalarJava;;

        04 | 4) fInstalarPython;;

        05 | 5) fPaquetesUtiles;;

        06 | 6) fPaquetesInnecesarios;;
        
        07 | 7) fAjustarHora;;
        
        98) break ;;

        99)
            fTerminar
            echo "Bye!"
            echo "See you later"
            sleep 2
            clear
            exit 0
            ;;

        *)
            clear
            echo "Operación no válida"
            sleep 2
            ;;
    esac

    clear
done
