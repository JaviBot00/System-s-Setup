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

fInstalarSublimeText() {
    echo  "Instalando Sublime Text..."
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
    # Stable Channel
    echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
    # Dev Channel
    # echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/dev/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
    # echo "deb [signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    
    sudo $cPaquete update
    sudo $cPaquete install sublime-text
}

fInstalarVSCode() {
    echo "Instalando VS CODE..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo $cPaquete update
    sudo $cPaquete install code
}

fInstalarAndroidStudio() {
    echo "Instalando Android studio..."
    sudo add-apt-repository ppa:maarten-fonville/android-studio
    sudo $cPaquete update
    sudo $cPaquete install android-studio
}

fInstalarIntelliJIdea() {
    echo "Instalando IntelliJ..."
    # Community on amd64 and arm64
    # sudo add-apt-repository ppa:xtradeb/apps
    # Community and Ultimate on amd64
    sudo add-apt-repository ppa:mmk2410/intellij-idea
    sudo $cPaquete update
    sudo $cPaquete install intellij-idea-community

    # curl -s https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg > /dev/null
    # echo "deb [signed-by=/usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg] http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com any main" | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list > /dev/null
}

fInstalarVMwareWorkstation() {
    echo "Instalando VMware Workstation Pro..."
    sudo $cPaquete install build-essential linux-headers-$(uname -r)
    sudo chmod +x ~/Downloads/VMware-Workstation-Full-17.6.2-24409262.x86_64.bundle
    sudo bash ~/Downloads/VMware-Workstation-Full-17.6.2-24409262.x86_64.bundle
    sudo vmware-modconfig --console --install-all

    # Otro procedimiento:
    # git clone https://github.com/bytium/vm-host-modules.git
    # cd vm-host-modules
    # git checkout 17.6.2
    #
    # make
    # sudo make install
    #
    # openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=VMware/"
    # sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv ./MOK.der $(modinfo -n vmmon)
    # sudo /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv ./MOK.der $(modinfo -n vmnet)
    # sudo mokutil --import MOK.der

    # Opcional
    # sudo /etc/init.d/vmware restart

    # Unistall
    # sudo vmware-installer -u vmware-workstation
}

fInstalarDocker() {
    echo  "Instalando Docker para Ubuntu..."
    sudo $cPaquete install lsb-release apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    # Run the following command to uninstall all conflicting packages
    # sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo $cPaquete update
    sudo apt-cache policy docker-ce
    sudo $cPaquete install -y docker-ce docker-ce-cli containerd.io docker-compose docker-buildx-plugin docker-compose-plugin
    sudo adduser ${USER} docker
    sudo usermod -aG docker ${USER}

    echo "Es recomendable reiniciar el sistema para aplicar los cambios de Docker."
    sleep 1

    read -p "¿Desea crear el Portainer?: " opcion
    if [[ "$opcion" =~ ^[YySs]$ ]]; then
        docker run -d -p 8000:8000 -p 9443:9443 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
        echo "Portainer creado y en ejecución en el puerto 9443."
    fi
}

fInstalarGitKraken() {
    echo "Instalando GitKraken..."
    # wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
    # sudo apt install ./gitkraken-amd64.deb

    wget -qO - https://release.gitkraken.com/linux/gitkraken.gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/gitkraken-archive-keyring.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/gitkraken-archive-keyring.gpg] https://release.gitkraken.com/linux/apt stable main" | sudo tee /etc/apt/sources.list.d/gitkraken.list > /dev/null
    sudo $cPaquete update
    sudo $cPaquete install gitkraken
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
    echo "  02) Sublime Text"
    echo "  03) VS Code"
    echo "  04) Android Studio"
    echo "  05) IntelliJ Idea (Community) UnOficial"
    # echo "  06) VMware Workstation Pro"
    # echo "  07) Docker"
    # echo "  08) GitKraken"
    echo "  98) Volver al MAIN"
    echo "  99) Salir"
    read -p "Elija: " opcion

    [[ ! $opcion =~ $validate_number ]] && echo "Opción inválida" && exit 1

    case $opcion in
        01 | 1) fCambiarGestorPaquetes ;;

        02 | 2) fInstalarSublimeText ;;

        03 | 3) fInstalarVSCode ;;

        04 | 4) fInstalarAndroidStudio ;;

        05 | 5) fInstalarIntelliJIdea ;;

        # 06 | 6) fInstalarVMwareWorkstation ;;

        # 07 | 7) fInstalarDocker ;;

        # 08 | 8) fInstalarGitKraken ;;

        98) break ;;

        99) fTerminar ;;

        *)
            echo "Operación no válida"
            sleep 2
            clear
            ;;
    esac

#    clear
done
