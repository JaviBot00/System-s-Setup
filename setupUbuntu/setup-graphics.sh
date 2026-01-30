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

fInstalarDrivers() {
    echo "Detectando drivers..."
    sudo ubuntu-drivers devices
    read -p "¿Instalar drivers recomendados automáticamente? [y/N]: " instalarDrivers
    [[ "$instalarDrivers" =~ ^[YySs]$ ]] && sudo ubuntu-drivers autoinstall
}

fPaquetesBasicosEscritorio() {
    echo "Instalando paquetes útiles de escritorio..."
    sudo $cPaquete install -y \
        gnome-tweaks gnome-tweak-tool \
        ubuntu-restricted-extras \
        vlc \
        simplescreenrecorder \
        stacer \
        preload tlp tlp-rdw
}

fExtensionesGnomeRecomendadas() {
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
}

fHabilitarMinimizarAlHacerClic() {
    echo "Habilitando minimizar al hacer clic..."
    gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'
    echo "Hecho. Puedes revertir este cambio en GNOME Tweaks."
}

fInstalarQEMU_KVM() {
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
}

fInstalarAutoCPUFreq() {
    read -p "¿Instalar Auto CPUFreq? (Recomendado en portátiles) [y/N]: " instalarCPUFreq
    if [[ "$instalarCPUFreq" =~ ^[YySs]$ ]]; then
        sudo $cPaquete install -y git
        git clone https://github.com/AdnanHodzic/auto-cpufreq.git
        cd auto-cpufreq
        sudo ./auto-cpufreq-installer
        cd ..
    fi
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
    echo "----- CONFIGURACIÓN BÁSICA -----"
    echo "  01) Ver / Instalar Drivers \n"
    echo "  02) Paquetes básicos de escritorio \n"
    echo "  03) Extensiones GNOME recomendadas \n"
    echo "  04) Activar minimizar al hacer clic \n"
    echo "  05) Instalar QEMU / KVM (Máquinas virtuales Nativas) \n"
    echo "  06) Instalar Auto CPUFreq (Portátiles) \n"
    echo "  98) Volver \n"
    read -p "Elija: " opcionB

    case $opcionB in
        01 | 1) fInstalarDrivers ;;

        02 | 2) fPaquetesBasicosEscritorio ;;

        03 | 3) fExtensionesGnomeRecomendadas ;;

        04 | 4) fHabilitarMinimizarAlHacerClic ;;

        05 | 5) fInstalarQEMU_KVM ;;

        06 | 6) fInstalarAutoCPUFreq ;;

        98) break ;;

        99) fTerminar ;;

        *)
            echo "Opción inválida"
            sleep 2
            clear
        ;;
    esac

    clear
done
