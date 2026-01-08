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

# https://kskroyal.com/23-things-to-do-after-installing-ubuntu/
fConfigBasica() {
    local opcionConf="S"
    while [ "$opcionConf" = "S" ]; do
        echo "----- CONFIGURACIÓN BÁSICA -----"
        echo "  01) Ver / Instalar Drivers"
        echo "  02) Paquetes básicos de escritorio"
        echo "  03) Extensiones GNOME recomendadas"
        echo "  04) Activar minimizar al hacer clic"
        echo "  05) Instalar QEMU / KVM (Máquinas virtuales)"
        echo "  06) Instalar Auto CPUFreq (Portátiles)"
        echo "  98) Volver"
        read -p "Elija: " opcionB

        case $opcionB in
            
            01 | 1)
                echo "Detectando drivers..."
                sudo ubuntu-drivers devices
                read -p "¿Instalar drivers recomendados automáticamente? [y/N]: " instalarDrivers
                [[ "$instalarDrivers" =~ ^[YySs]$ ]] && sudo ubuntu-drivers autoinstall
            ;;

            02 | 2)
                echo "Instalando paquetes útiles de escritorio..."
                sudo $cPaquete install -y \
                    gnome-tweaks \
                    ubuntu-restricted-extras \
                    vlc \
                    simplescreenrecorder \
                    stacer
            ;;

            03 | 3)
                echo "Instalando Extension Manager..."
                sudo $cPaquete install -y gnome-shell-extension-manager
                echo ""
                echo "Extensiones recomendadas:"
                echo "• Blur My Shell"
                echo "• Arc Menu"
                echo "• Just Perfection"
                echo "• Vitals"
                echo "• Caffeine"
                echo "• User Themes"
                echo ""
                echo "Puedes instalarlas desde: Extension Manager"
                read -p "Presione ENTER para continuar"
            ;;

            04 | 4)
                echo "Habilitando minimizar al hacer clic..."
                gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
                echo "Hecho."
            ;;

            05 | 5)
                read -p "¿Instalar QEMU / KVM? [y/N]: " instalarVMs
                if [[ "$instalarVMs" =~ ^[YySs]$ ]]; then
                    sudo $cPaquete install -y \
                        qemu-kvm qemu-utils libvirt-daemon-system \
                        libvirt-clients bridge-utils virt-manager ovmf
                    
                    sudo systemctl enable --now libvirtd
                    sudo usermod -aG libvirt $USER
                    sudo usermod -aG kvm $USER
                    echo "⚠ Debes cerrar sesión o reiniciar para aplicar permisos"
                fi
            ;;

            06 | 6)
                read -p "¿Instalar Auto CPUFreq? (Recomendado en portátiles) [y/N]: " instalarCPUFreq
                if [[ "$instalarCPUFreq" =~ ^[YySs]$ ]]; then
                    sudo $cPaquete install -y git
                    git clone https://github.com/AdnanHodzic/auto-cpufreq.git
                    cd auto-cpufreq
                    sudo ./auto-cpufreq-installer
                    cd ..
                fi
            ;;

            98)
                break
            ;;

            *)
                echo "Opción inválida"
                sleep 1
            ;;
        esac

        clear
    done
}

fTerminar() {
    read -p "¿Terminar el SetUp? [y/N]: " seguir
    [[ "$seguir" =~ ^[YySs]$ ]] && valor="N"
}

while [ "$valor" = "S" ]; do
    echo "Seleccione una opción:"
    echo "  01) Cambiar gestor de paquetes (actual: $cPaquete)"
    echo "  02) Configuracion basica"
    echo "  03) Discord"
    echo "  04) Spotify"
    echo "  05) Rhythmbox"
    echo "  98) Volver al MAIN"
    echo "  99) Salir"
    read -p "Elija: " opcion

    [[ ! $opcion =~ $validate_number ]] && echo "Opción inválida" && sleep 1 && continue

    case $opcion in
        01 | 1) fCambiarGestorPaquetes;;

        02 | 2) fConfigBasica;;

        03 | 3)
            echo "Instalando Discord..."
            wget -O discord-latest.deb "https://discord.com/api/download?platform=linux&format=deb"
            sudo $cPaquete install ./discord-latest.deb
            # sudo dpkg -i ./discord-latest.deb
            rm discord-latest.deb
            ;;

        04 | 4)
            echo "Instalando Spotify..."
            curl -fsSL https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor -o /usr/share/keyrings/spotify.gpg
            echo "deb [signed-by=/usr/share/keyrings/spotify.gpg] http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
            sudo $cPaquete update
            sudo $cPaquete install spotify-client
            ;;

        05 | 5)
            # echo  "Instalando Rhytmbox..."
        #     sudo $cPaquete install rhythmbox rhythmbox-plugin-alternative-toolbar
        #     cp /usr/share/applications/rhythmbox.desktop ~/.local/share/applications
        #     cp /usr/share/applications/org.gnome.Rhythmbox3.desktop ~/.local/share/applications
        #     nano /usr/share/applications/org.gnome.Rhythmbox3.desktop
        #     GTK_THEME=Yaru-dark rhythmbox
        #     nano .local/share/applications/org.gnome.Rhythmbox3.desktop
            ;;
        
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
