#!/bin/bash
clear

validate_number='^[0-9]+$'

echo "By
  ___ ___         __     ________              
 /   |   \  _____/  |_  /  _____/ __ __ ___.__.
/    ~    \/  _ \   __\/   \  ___|  |  <   |  |
\    Y    (  <_> )  |  \    \_\  \  |  /\___  |
 \___|_  / \____/|__|   \______  /____/ / ____|
       \/                      \/       \/  
"
echo "==============================="
echo "  SetUp Ubuntu 24 | 25 - MAIN"
echo "==============================="

es_desktop() {
    if [[ -n "$(command -v gdm3)" || -n "$(command -v lightdm)" || -n "$(command -v sddm)" ]]; then
        return 0
    else
        return 1
    fi
}

if es_desktop; then
    echo "Sistema detectado: UBUNTU DESKTOP"
else
    echo "Sistema detectado: UBUNTU SERVER"
fi

echo "-------------------------------"
echo "  01) SetUp Ubuntu Server"
echo "  02) SetUp Ubuntu Desktop"
echo "  03) SetUp Ubuntu Developer"
echo "  04) Server ➜ Desktop (instalar GUI)"
echo "  05) Desktop ➜ Server (eliminar GUI)"
echo "  06) (Des)Habilitar GUI"
echo "  99) Salir"
echo "-------------------------------"

read -p "Elija una opción: " opcion

[[ ! $opcion =~ $validate_number ]] && echo "Opción inválida" && exit 1

case $opcion in
    01 | 1)
        if [[ -f "./setup-server.sh" ]]; then
            chmod +x ./setup-server.sh
            ./setup-server.sh
        else
            echo "Error: setup-server.sh no encontrado"
        fi
        ;;

    02 | 2)
        if [[ -f "./setup-desktop.sh" ]]; then
            chmod +x ./setup-desktop.sh
            ./setup-desktop.sh
        else
            echo "Error: setup-desktop.sh no encontrado"
        fi
        ;;

    03 | 3)
        if [[ -f "./setup-dev.sh" ]]; then
            chmod +x ./setup-dev.sh
            ./setup-desktop.sh
        else
            echo "Error: setup-dev.sh no encontrado"
        fi
        ;;

    04 | 4)
        echo "Instalando Ubuntu Desktop..."
        sudo apt update
        # sudo apt install -y ubuntu-desktop
        sudo apt install ubuntu-desktop-minimal
        echo "Instalación completada. Reinicie el sistema."
        ;;

    05 | 5)
        echo "⚠ ADVERTENCIA"
        echo "Esto eliminará el entorno gráfico."
        read -p "¿Seguro? [y/N]: " confirmar
        [[ ! "$confirmar" =~ ^[YySs]$ ]] && exit 0

        sudo apt purge ubuntu-desktop ubuntu-desktop-minimal gdm3
        sudo apt autoremove --purge
        sudo apt autoclean
        echo "Desktop eliminado. Reinicie el sistema."
        ;;

    06 | 6)
        read -p "¿Habilitar GUI al iniciar? [y/N]: " habilitarGUI
        if [[ "$habilitarGUI" =~ ^[YySs]$ ]]; then
            # Desktop (con GUI)
            echo "Habilitando GUI..."
            sudo systemctl set-default graphical.target
        else
            # Server (sin GUI)
            echo "Deshabilitando GUI..."
            sudo systemctl set-default multi-user.target
        fi

        ;;

    99)
        echo "Bye!"; exit 0 ;;

    *)
        echo "Opción no válida"; sleep 1;;
esac
