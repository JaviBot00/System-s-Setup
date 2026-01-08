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

fTerminar() {
    read -p "¿Terminar el SetUp? [y/N]: " seguir
    [[ "$seguir" =~ ^[YySs]$ ]] && valor="N"
}

while [ "$valor" = "S" ]; do
    echo "Seleccione una opción:"
    echo "  01) Cambiar gestor de paquetes (actual: $cPaquete)"
    echo "  02) Sublime Text"
    echo "  03) VS Code"
    echo "  04) Android Studio"
    echo "  05) IntelliJ Idea (Community)"
    echo "  06) Docker"
    echo "  07) GitKraken"
    echo "  98) Volver al MAIN"
    echo "  99) Salir"
    read -p "Elija: " opcion

    [[ ! $opcion =~ $validate_number ]] && echo "Opción inválida" && exit 1

    case $opcion in
        01 | 1) fCambiarGestorPaquetes;;

        02 | 2)
            echo  "Instalando Sublime Text..."
            wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
            echo "deb [signed-by=/etc/apt/keyrings/sublimehq-pub.gpg] https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
            sudo $cPaquete update
            sudo $cPaquete install sublime-text
            ;;

        03 | 3)
            echo "Instalando VS CODE..."
            wget -qO - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
            echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
            sudo $cPaquete update
            sudo $cPaquete install code
            ;;

        04 | 4)
            echo "Instalando Android studio..."
            sudo add-apt-repository ppa:maarten-fonville/android-studio
            sudo $cPaquete update
            sudo $cPaquete install android-studio

            ;;

        05 | 5)
            echo "Instalando IntelliJ..."
            # Community on amd64 and arm64
            # sudo add-apt-repository ppa:xtradeb/apps
            # Community and Ultimate on amd64
            sudo add-apt-repository ppa:mmk2410/intellij-idea-community
            sudo $cPaquete update
            sudo $cPaquete install intellij-idea-community

            # curl -s https://s3.eu-central-1.amazonaws.com/jetbrains-ppa/0xA6E8698A.pub.asc | gpg --dearmor | sudo tee /usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg > /dev/null
            # echo "deb [signed-by=/usr/share/keyrings/jetbrains-ppa-archive-keyring.gpg] http://jetbrains-ppa.s3-website.eu-central-1.amazonaws.com any main" | sudo tee /etc/apt/sources.list.d/jetbrains-ppa.list > /dev/null
            ;;
        
        06 | 6)
            echo  "Instalando Docker..."
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
            
            ;;

        07 | 7)
            echo "Instalando GitKraken..."
            # wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
            # sudo apt install ./gitkraken-amd64.deb

            wget -qO - https://release.gitkraken.com/linux/gitkraken.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/gitkraken-archive-keyring.gpg > /dev/null
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/gitkraken-archive-keyring.gpg] https://release.gitkraken.com/linux/apt stable main" | sudo tee /etc/apt/sources.list.d/gitkraken.list > /dev/null
            sudo $cPaquete update
            sudo $cPaquete install gitkraken
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
