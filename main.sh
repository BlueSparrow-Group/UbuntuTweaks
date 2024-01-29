#!/bin/bash


# Change __DIR__ to script root
cd $(dirname $0)

# Declare variables
need_reboot=0
no_reboot=0
DEBIAN_FRONTEND=noninteractive

## Software manipulation functions

function install-general-software {
  echo -e "\n= Installing common general-use dependencies =\n"

  # Install software and libs from ubuntu repositories
  sudo apt-get install -qy make cmake dconf-cli gettext ca-certificates curl gnupg software-properties-common apt-transport-https unzip git snapd openjdk-17-jre openjdk-17-jre libfuse2 mc dconf-cli dconf-editor python3 pipx gnome-software gnome-software-plugin-snap flatpak gnome-software-plugin-flatpak libspeechd-dev libfuse2 golang gcc pkg-config libwebkit2gtk-4.0-dev libjson-glib-dev > /dev/null

  # Add flatpak repository
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

  # Install realpath if not found (bypass warning)
  sudo apt-get install -qy realpath &>/dev/null

  # Remove reduant snap-store
  sudo apt-get remove -qy snap-store &> /dev/null
}

function install-internet-software {
  echo -e "\n= Installing internet-software package =\n"

  # Add MS Edge repository
  sudo /bin/bash -c "echo 'deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list" &> /dev/null
  sudo /bin/bash -c "wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /usr/share/keyrings/microsoft-edge.gpg" &> /dev/null

  # Upate software list
  sudo apt-get update > /dev/null

  # Install software from added repositories
  sudo apt-get install -qy microsoft-edge-stable > /dev/null

  # Install OneDrive client
  sudo rm -R onedriver &> /dev/null;
  sudo mkdir onedriver;
  sudo /bin/bash -c "git clone https://github.com/jstaf/onedriver.git ./onedriver --depth=1 -q; cd onedriver; make; make install" > /dev/null

  # Downloads Zoom.us
  sudo rm /tmp/zoom.deb &> /dev/null
  sudo /bin/bash -c "wget -qO - https://zoom.us/client/5.17.1.1840/zoom_amd64.deb | tee /tmp/zoom.deb" &> /dev/null

  # Install Zoom.us
  sudo dpkg -i /tmp/zoom.deb &> /dev/null
  sudo apt-get --fix-broken install -qy > /dev/null

  # Install software from snap
  sudo snap install chromium > /dev/null
  sudo snap install spotify > /dev/null
  sudo snap install discord > /dev/null
}

function uninstall-internet-software {
  echo -e "\n= Uninstalling internet-software package =\n"

  # Remove MS Edge repository
  sudo rm /usr/share/keyrings/microsoft-edge.gpg &> /dev/null

  # Remove installed software
  sudo apt-get remove -qy microsoft-edge-stable > /dev/null

  # Remove OneDrive client
  sudo dpkg -r onedriver > /dev/null

  # Purge dependencies
  sudo apt-get autoremove -qy > /dev/null

  # Remove software from snap
  sudo snap remove chromium > /dev/null
  sudo snap remove spotify > /dev/null
}

function install-office-software {
  echo -e "\n= Installing office-software package =\n"

  # Install software and libs from ubuntu repositories
  sudo apt-get install -qy libreoffice cups cups-ipp-utils hplip printer-driver-gutenprint > /dev/null

  # Add TexStudio repository
  sudo add-apt-repository -y ppa:sunderme/texstudio > /dev/null

  # Upate software list
  sudo apt-get update > /dev/null

  # Install software from added repositories
  sudo apt-get install -qy texstudio > /dev/null

  # Install software from snap
  sudo snap install wps-office > /dev/null
  sudo snap install krita > /dev/null
  sudo snap install office365webdesktop --beta > /dev/null
}

function uninstall-office-software {
  echo -e "\n= Uninstalling office-software package =\n"

  # Remove TexStudio repository
  sudo add-apt-repository -y --remove ppa:sunderme/texstudio > /dev/null

  # Remove installed software
  sudo apt-get remove -qy libreoffice texstudio cups cups-ipp-utils hplip printer-driver-gutenprint > /dev/null

  # Purge dependencies
  sudo apt-get autoremove -qy > /dev/null

  # Remove software from snap
  sudo snap remove wps-office > /dev/null
  sudo snap remove krita > /dev/null
  sudo snap remove office365webdesktop > /dev/null
}

function install-edu-software {
  echo -e "\n= Installing edu-software package =\n"

  # Install software from snap
  sudo snap install teams-for-linux > /dev/null

  # Install OpenBoard software from flatpak
  flatpak install -y flathub ch.openboard.OpenBoard
}

function uninstall-edu-software {
  echo -e "\n= Uninstalling edu-software package =\n"

  # Remove software from snap
  sudo snap remove teams-for-linux > /dev/null

  # Remove OpenBoard software from flatpak
  flatpak uninstall -y ch.openboard.OpenBoard
}

function install-creative-software {
  echo -e "\n= Installing creative-software package =\n"

  # Install software and libs from ubuntu repositories
  sudo apt-get install -qy gimp gimp-data-extras gimp-help-common inkscape inkscape-open-symbols inkscape-tutorials kdenlive blender handbrake obs-studio > /dev/null

  # Downloads NDI with OBS NDI addon packages
  sudo rm /tmp/ndi.deb &> /dev/null
  sudo rm /tmp/obs-ndi.deb &> /dev/null
  sudo /bin/bash -c "wget -qO - https://github.com/obs-ndi/obs-ndi/releases/download/4.11.1/libndi5_5.5.3-1_amd64.deb | tee /tmp/ndi.deb" &>/dev/null
  sudo /bin/bash -c "wget -qO - https://github.com/obs-ndi/obs-ndi/releases/download/4.11.1/obs-ndi-4.11.1-linux-x86_64.deb | tee /tmp/obs-ndi.deb" &>/dev/null

  # Install NDI with OBS NDI addon from downloaded packages
  sudo dpkg -i /tmp/ndi.deb &> /dev/null
  sudo apt-get --fix-broken install -qy > /dev/null
  sudo dpkg -i /tmp/obs-ndi.deb &> /dev/null
  sudo apt-get --fix-broken install -qy > /dev/null

  # Downloads Lightworks
  sudo rm /tmp/lightworks.deb &> /dev/null
  sudo /bin/bash -c "wget -qO - https://app.lwks.com/api/auth/download/lightworks/linux_deb | tee /tmp/lightworks.deb" &>/dev/null

  # Install Lightworks from downloaded packages
  sudo dpkg -i /tmp/lightworks.deb &> /dev/null
  sudo apt-get --fix-broken install -qy > /dev/null
}

function uninstall-creative-software {
  echo -e "\n= Uninstalling creative-software package =\n"

  # Remove installed software
  sudo apt-get remove -qy gimp gimp-data-extras gimp-help-common inkscape inkscape-open-symbols inkscape-tutorials kdenlive blender handbrake obs-studio > /dev/null

  # Purge dependencies
  sudo apt-get autoremove -qy > /dev/null

  # Remove NDI with OBS NDI addon
  sudo dpkg -r libndi5 > /dev/null
  sudo dpkg -r obs-ndi > /dev/null

  # Remove Lightworks
  sudo dpkg -r lightworks > /dev/null
}

function install-programming-software {
  echo -e "\n= Installing programming-software package =\n"

  # Install software and libs from ubuntu repositories
  sudo apt-get install -qy filezilla codeblocks codeblocks-common codeblocks-contrib codeblocks-dev libcodeblocks0 thonny arduino > /dev/null

  # Add Docker repository
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --yes --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Julialang
  sudo /bin/bash -c "curl -fsSL https://install.julialang.org | sh -s -- -y" > /dev/null

  # Add Unity3D repository and download libssl1.1
  sudo /bin/bash -c "wget -qO - https://hub.unity3d.com/linux/keys/public | tee /etc/apt/trusted.gpg.d/unityhub.asc" &>/dev/null
  sudo /bin/bash -c 'echo "deb https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'
  rm /tmp/libssl11.deb &> /dev/null
  sudo /bin/bash -c "wget -qO - http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb | tee /tmp/libssl11.deb" &>/dev/null

  # Install libssl1.1 from downloaded packages
  sudo dpkg -i /tmp/libssl11.deb &> /dev/null
  sudo apt-get --fix-broken install -qy > /dev/null

  # Add C# IntelliSense
  sudo /bin/bash -c 'wget -O - "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xA6A19B38D3D831EF" | sudo gpg --yes --dearmor -o /etc/apt/trusted.gpg.d/mono-official-stable.gpg' &>/dev/null
  sudo /bin/bash -c 'echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list' &>/dev/null

  # Upate software list
  sudo apt-get update > /dev/null

  # Install software from added repositories
  sudo apt-get install -qy docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unityhub mono-complete dotnet6 > /dev/null

  # Install software from snap
  sudo snap install pycharm-community --classic > /dev/null
  sudo snap install intellij-idea-community --classic > /dev/null
  sudo snap install code --classic > /dev/null
  sudo snap install brackets --classic > /dev/null
  sudo snap install flutter --classic > /dev/null
  sudo snap install kate --classic > /dev/null
  sudo snap install go --classic > /dev/null
}

function uninstall-programming-software {
  echo -e "\n= Uninstalling programming-software package =\n"

  # Remove Docker repository
  sudo rm /etc/apt/keyrings/docker.gpg
  sudo rm /etc/apt/sources.list.d/docker.list

  # Remove julia
  sudo juliaup self uninstall > /dev/null

  # Remove Unity3D repository
  sudo rm /etc/apt/trusted.gpg.d/unityhub.asc
  sudo rm /etc/apt/sources.list.d/unityhub.list

  # Add C# IntelliSense
  sudo rm /etc/apt/trusted.gpg.d/mono-official-stable.gpg
  sudo rm /etc/apt/sources.list.d/mono-official-stable.list

  # Remove installed software
  sudo apt-get remove -qy filezilla codeblocks codeblocks-common codeblocks-contrib codeblocks-dev libcodeblocks0 thonny arduino docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unityhub mono-complete dotnet6 > /dev/null

  # Purge dependencies
  sudo apt-get autoremove -qy > /dev/null

  # Upate software list
  sudo apt-get update > /dev/null

  # Remove software from snap
  sudo snap remove pycharm-community --classic > /dev/null
  sudo snap remove intellij-idea-community --classic > /dev/null
  sudo snap remove code --classic > /dev/null
  sudo snap remove brackets --classic > /dev/null
  sudo snap remove flutter --classic > /dev/null
  sudo snap remove kate --classic > /dev/null
  sudo snap remove go --classic > /dev/null
}

# Install OSE ceryficate
function install-ose {
  echo -e "\n= Installing ose-certyficate package =\n"

  sudo rm /tmp/ose.zip &> /dev/null
  sudo rm /tmp/ose &> /dev/null
  sudo /bin/bash -c "wget -qO - https://ose.gov.pl/media/2022/09/pliki_linux.zip | sudo tee /tmp/ose.zip" &>/dev/null
  unzip /tmp/ose.zip -d /tmp/ose > /dev/null
  sudo /bin/bash -c "cd /tmp/ose/cert_install/; /bin/bash ./cert_install.sh" > /dev/null
}

# Uninstall OSE ceryficate
function uninstall-ose {
  echo -e "\n= Uninstalling ose-certyficate package =\n"

  # Remove certyficate from web browsers databases
  for cDB in $(sudo find /home/ -name "cert8.db")
  do
  	cert_dir=$(dirname ${cDB});
  	sudo certutil -D -n "NASK PIB" -t "C" -d dbm:${cert_dir}
  done
  for cDB in $(sudo find ~/ -name "cert8.db")
  do
  	cert_dir=$(dirname ${cDB});
  	sudo certutil -D -n "NASK PIB" -t "C" -d dbm:${cert_dir}
  done
  for cDB in $(sudo find /home/ -name "cert9.db")
  do
  	cert_dir=$(dirname ${cDB});
  	sudo certutil -D -n "NASK PIB" -t "C" -d sql:${cert_dir}
  done
  for cDB in $(sudo find ~/ -name "cert9.db")
  do
  	cert_dir=$(dirname ${cDB});
  	sudo certutil -D -n "NASK PIB" -t "C" -d sql:${cert_dir}
  done

  # Remove certyficate from system
  sudo rm /usr/local/share/ca-certificates/certyfikat.crt
  sudo update-ca-certificates > /dev/null

  # Remove installed software
  sudo apt-get remove -qy libnss3-tools > /dev/null

  # Purge dependencies
  sudo apt-get autoremove -qy > /dev/null
}

function install-remote-support {
  echo -e "\n= Installing remote-support package =\n"

  # Add Anydesk repository
  sudo /bin/bash -c "wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo tee /etc/apt/trusted.gpg.d/anydesk.asc" &>/dev/null
  echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list

  # Upate software list
  sudo apt-get update > /dev/null

  # Install software from added repositories
  sudo apt-get install -qy anydesk > /dev/null

  # Download TeamViewer
  rm -R /tmp/teamviewer.deb &> /dev/null
  sudo /bin/bash -c "wget -qO - https://download.teamviewer.com/download/linux/teamviewer_amd64.deb | sudo tee /tmp/teamviewer.deb" &>/dev/null

  # Install TeamViewer
  sudo dpkg -i /tmp/teamviewer.deb &> /dev/null
  sudo apt-get --fix-broken install -qy > /dev/null
}

function uninstall-remote-support {
  echo -e "\n= Uninstalling remote-support package =\n"

  # Remove Anydesk repository
  sudo rm /etc/apt/trusted.gpg.d/anydesk.asc &> /dev/null
  sudo rm /etc/apt/sources.list.d/anydesk-stable.list &> /dev/null

  # Remove installed software
  sudo apt-get remove -qy anydesk > /dev/null

  # Purge dependencies
  sudo apt-get autoremove > /dev/null

  # Upate software list
  sudo apt-get update > /dev/null

  # Remove TeamViewer
  sudo dpkg -r teamviewer > /dev/null
}

function install-aad {
  echo -e "\n= Installing aad-auth package =\n"

  # Install software and libs from ubuntu repositories
  sudo apt-get install -qy libpam-aad libnss-aad aad-cli > /dev/null

  # Enable automatic home creation for AAD users
  sudo pam-auth-update --enable mkhomedir > /dev/null
}

function uninstall-aad {
  echo -e "\n= Uninstalling aad-auth package =\n"

  # Remove installed software
  sudo apt-get remove libpam-aad libnss-aad > /dev/null

  # Purge dependencies
  sudo apt-get autoremove -qy > /dev/null

  # Remove AAD config
  sudo rm /etc/aad.conf &> /dev/null
}

# Prints auth background path (internal-use)
function get-custom-auth-background {
  if [ -f '/opt/bluesparrow/ubuntutweaks/bg-auth.jpg' ]
  then
    echo "/opt/bluesparrow/ubuntutweaks/bg-auth.jpg"
  else
    echo "$(realpath ./resources/bg-auth.jpg)"
  fi
}

# Prints auth background path (internal-use)
function get-custom-auth-blurry-background {
  if [ -f '/opt/bluesparrow/ubuntutweaks/bg-auth-blurry.jpg' ]
  then
    echo "/opt/bluesparrow/ubuntutweaks/bg-auth-blurry.jpg"
  else
    if [ -f '/opt/bluesparrow/ubuntutweaks/bg-auth.jpg' ]
    then
      echo "/opt/bluesparrow/ubuntutweaks/bg-auth.jpg"
    else
      echo "$(realpath ./resources/bg-auth-blurry.jpg)"
    fi
  fi
}

# Prints desktop background path (internal-use)
function get-custom-desktop-background {
  if [ -f '/opt/bluesparrow/ubuntutweaks/bg-desktop.jpg' ]
  then
    echo "/opt/bluesparrow/ubuntutweaks/bg-desktop.jpg"
  else
    echo "$(realpath ./resources/bg-desktop.jpg)"
  fi
}

function install-ui-mods {
  echo -e "\n= Installing ui-mods package =\n"

  # Install software and libs from ubuntu repositories
  sudo apt-get install -qy gnome-shell-extensions dbus-x11 plymouth-themes > /dev/null

  # Install gnome extensions cli from pipx
  sudo /bin/bash -c "PIPX_HOME=/var/pipx PIPX_BIN_DIR=/usr/local/bin pipx install gnome-extensions-cli --system-site-packages" > /dev/null

  # Install blur-my-shell gnome extension
  sudo /bin/bash -c "gnome-extensions-cli -F install blur-my-shell@aunetx" > /dev/null
  sudo /bin/bash -c "gnome-extensions-cli -F disable blur-my-shell@aunetx" > /dev/null
  sudo mv /root/.local/share/gnome-shell/extensions/blur-my-shell@aunetx /usr/share/gnome-shell/extensions/blur-my-shell@aunetx &> /dev/null

  # Install tactile gnome extension
  sudo /bin/bash -c "gnome-extensions-cli -F install tactile@lundal.io" > /dev/null
  sudo /bin/bash -c "gnome-extensions-cli -F disable tactile@lundal.io" > /dev/null
  sudo mv /root/.local/share/gnome-shell/extensions/tactile@lundal.io /usr/share/gnome-shell/extensions/tactile@lundal.io &> /dev/null

  # Install MacOS-like skin
  sudo rm -R whitesur &> /dev/null;
  sudo mkdir whitesur;
  sudo /bin/bash -c "git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git ./whitesur --depth=1 -q; cd whitesur; ./install.sh -i simple -N glassy -t all --silent-mode; ./tweaks.sh -f monterey; ./tweaks.sh -f -g -N -b '$(get-custom-auth-background)' --silent-mode" > /dev/null

  # Install MacOS-like icons
  sudo rm -R whitesur-icons &> /dev/null;
  sudo mkdir whitesur-icons;
  sudo /bin/bash -c "git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git ./whitesur-icons --depth=1 -q; cd whitesur-icons; sudo ./install.sh -a" > /dev/null
}

function uninstall-ui-mods {
  echo -e "\n= Uninstalling ui-mods package =\n"

  sudo rm -R /usr/share/gnome-shell/extensions/blur-my-shell@aunetx &> /dev/null
  sudo rm -R /usr/share/gnome-shell/extensions/tactile@lundal.io &> /dev/null

  # Remove MacOS-like skin
  sudo mkdir whitesur;
  sudo /bin/bash -c "git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git ./whitesur --depth=1 -q; cd whitesur; ./install.sh -r" > /dev/null

  # Remove MacOS-like icons
  sudo mkdir whitesur-icons;
  sudo /bin/bash -c "git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git ./whitesur-icons --depth=1 -q; cd whitesur-icons; ./install.sh -r" > /dev/null

  # Remove installed software
  sudo apt-get remove -qy gnome-shell-extensions > /dev/null

  # Purge dependencies
  sudo apt-get autoremove -qy > /dev/null
}

function update-software {
  echo -e "\n= Updates software =\n"

  # Update software list
  sudo apt-get update > /dev/null

  # Update software
  sudo apt-get upgrade -y > /dev/null

  # Update snap software
  sudo snap refresh > /dev/null
}

function schedule-update-software {
  echo -e "\n= Schedules weekly software update =\n"

  if [ -d "/var/bluesparrow/ubuntutweaks" ]
  then
    sudo touch /etc/cron.d/bs-ubuntutweaks-updatesoftware
    echo -e "0 0 * * 1 root bs-ubuntutweaks update" | sudo tee /etc/cron.d/bs-ubuntutweaks-updatesoftware

    # Remove ubuntu update notification
    sudo apt-get remove -qy update-notifier > /dev/null
    sudo pkill update-notifier

    # Purge dependencies
    sudo apt-get autoremove -qy > /dev/null
  else
    echo "Cannot schedule software weekly update due to lack of tweaks persistent installation." >&2
  fi
}

function unschedule-update-software {
  echo -e "\n= Unschedules weekly software update =\n"

  sudo rm /etc/cron.d/bs-ubuntutweaks-updatesoftware &> /dev/null
  # Remove ubuntu update notification
  sudo apt-get install -qy update-notifier > /dev/null
}

function set-general-ui-settings {
  echo -e "\n= Sets base configurations files =\n"

  # Create Gnome desktop profiles
  sudo mkdir -p /etc/dconf/profile
  if [ ! -f "/etc/dconf/profile/user" ]
  then
    sudo sh -c 'echo "user-db:user\nsystem-db:local\n">/etc/dconf/profile/user'
  fi
  if [ ! -f "/etc/dconf/profile/gdm" ]
  then
    sudo sh -c 'echo "user-db:user\nsystem-db:gdm\nfile-db:/usr/share/gdm/greeter-dconf-defaults\n">/etc/dconf/profile/gdm'
  fi
  if [ ! -f "/usr/local/share/fonts/Rubik.ttf" ]
  then
    sudo cp resources/Rubik.ttf /usr/local/share/fonts/Rubik.ttf
    fc-cache -f -v > /dev/null
  fi
  if [ ! -f "/usr/local/share/fonts/Rubik-Italic.ttf" ]
  then
    sudo cp resources/Rubik-Italic.ttf /usr/local/share/fonts/Rubik-Italic.ttf
    fc-cache -f -v > /dev/null
  fi
  if [ ! -f "/usr/local/share/fonts/RubikMonoOne.ttf" ]
  then
    sudo cp resources/RubikMonoOne.ttf /usr/local/share/fonts/RubikMonoOne.ttf
    fc-cache -f -v > /dev/null
  fi
  sudo mkdir -p /etc/dconf/db/local.d/locks
  sudo mkdir -p /etc/dconf/db/gdm.d/locks
}

function set-auth-ui-settings {
  echo -e "\n= Sets authorization screen ui mods settings =\n"

  # Change and lock Gnome authorization screen settings
  sudo sh -c $'echo "[org/gnome/desktop/background]\n\n# URI to use for the background image\npicture-uri=\'file://$1\'\n\n# Specify one of the rendering options for the background image:\npicture-options=\'zoom\'\n\n# Specify the left or top color when drawing gradients, or the solid color\nprimary-color=\'2E405D\'\n\n# Specify the right or bottom color when drawing gradients\nsecondary-color=\'DFEAF7\'\n\n[com/ubuntu/login-screen]\n\nbackground-picture-uri=\'file://$1\'\nbackground-size=\'cover\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth' -o "$(get-custom-auth-blurry-background)"
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\n/org/gnome/desktop/background/picture-uri\n/org/gnome/desktop/background/picture-options\n/org/gnome/desktop/background/primary-color\n/org/gnome/desktop/background/secondary-color\ncom/ubuntu/login-screen/background-picture-uri\ncom/ubuntu/login-screen/background-size\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth'
  # Change and lock Gnome screensaver settings
  sudo sh -c $'echo "[org/gnome/desktop/screensaver]\n\n# URI to use for the background image\npicture-uri=\'file://$1\'\n\n# Specify one of the rendering options for the background image:\npicture-options=\'zoom\'\n\n# Specify the left or top color when drawing gradients, or the solid color\nprimary-color=\'2E405D\'\n\n# Specify the right or bottom color when drawing gradients\nsecondary-color=\'DFEAF7\'\nlogout-enabled=true\nlock-delay=360\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-auth' -o "$(get-custom-auth-background)"
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\n/org/gnome/desktop/screensaver/picture-uri\n/org/gnome/desktop/screensaver/picture-options\n/org/gnome/desktop/screensaver/primary-color\n/org/gnome/desktop/screensaver/secondary-color\n/org/gnome/desktop/screensaver/logout-enabled\n/org/gnome/desktop/screensaver/lock-delay\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-auth'

  sudo dconf update > /dev/null
}

function unset-auth-ui-settings {
  echo -e "\n= Unsets authorization screen ui mods settings =\n"

  # Reverse changes and unlock Gnome authorization screen settings
  sudo rm /etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth &> /dev/null
  sudo rm /etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth &> /dev/null
  # Reverse changes and unlock Gnome screensaver settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-auth &> /dev/null
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-auth &> /dev/null

  sudo dconf update > /dev/null
}

function set-auth-nouserslist-settings {
  echo -e "\n= Disables authorization screen userslist =\n"

  # Change and lock Gnome authorization screen settings
  sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Do not show the user list\ndisable-user-list=true\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-nouserslist'
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/disable-user-list\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-nouserslist'
  sudo dconf update > /dev/null
}

function unset-auth-nouserslist-settings {
  echo -e "\n= Reenables authorization screen userslist =\n"

  # Reverse changes and unlock Gnome authorization screen settings
  sudo rm /etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-nouserslist &> /dev/null
  sudo rm /etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-nouserslist &> /dev/null
  sudo dconf update > /dev/null
}

function set-auth-notice-settings {
  echo -e "\n= Sets authorization screen notice banner settings =\n"

  if [[ $# -ge 1 ]]
  then
    # Change and lock Gnome authorization screen settings
    sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Display text message banner\nbanner-message-enable=true\nbanner-message-text=\'$*\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-notice' -o $*
    sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/banner-message-enable\norg/gnome/login-screen/banner-message-text\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-notice'
    sudo dconf update > /dev/null
  else
    if [ -f /opt/bluesparrow/ubuntutweaks/banner.txt ]
    then
      # Change and lock Gnome authorization screen settings
      sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Display text message banner\nbanner-message-enable=true\nbanner-message-text=\'$(cat /opt/bluesparrow/ubuntutweaks/banner.txt)\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-notice'
      sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/banner-message-enable\norg/gnome/login-screen/banner-message-text\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-notice'
      sudo dconf update > /dev/null
    else
      echo "No text provided!" >&2
    fi
  fi
}

function unset-auth-notice-settings {
  echo -e "\n= Unsets authorization screen notice banner settings =\n"

  # Reverse changes and unlock Gnome authorization screen settings
  sudo rm /etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-notice &> /dev/null
  sudo rm /etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-notice &> /dev/null
  sudo dconf update > /dev/null
}

function set-auth-logo-settings {
  echo -e "\n= Sets authorization screen logo settings =\n"

  if [ -f "/opt/bluesparrow/ubuntutweaks/logo.png" ]
  then
    # Change and lock Gnome authorization screen settings
    sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Display custom logo image\nlogo=\'/opt/bluesparrow/ubuntutweaks/logo.png\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-logo'
    sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/logo\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-logo'
    sudo dconf update > /dev/null

    # Change boot screen logo
    if [ ! -f /usr/share/plymouth/themes/spinner/watermark.png.bak ]
    then
      sudo mv /usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth/themes/spinner/watermark.png.bak
      sudo cp /opt/bluesparrow/ubuntutweaks/logo.png /usr/share/plymouth/themes/spinner/watermark.png
    fi
  else
    # Change and lock Gnome authorization screen settings
    sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Display custom logo image\nlogo=\'$(realpath ./resources/logo.png)\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-logo'
    sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/logo\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-logo'
    sudo dconf update > /dev/null

    # Change boot screen logo
    if [ ! -f /usr/share/plymouth/themes/spinner/watermark.png.bak ]
    then
      sudo mv /usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth/themes/spinner/watermark.png.bak
      sudo cp $(realpath ./resources/logo.png) /usr/share/plymouth/themes/spinner/watermark.png
    fi
  fi
}

function unset-auth-logo-settings {
  echo -e "\n= Unsets authorization screen logo settings =\n"

  # Reverse changes and unlock Gnome authorization screen settings
  sudo rm /etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-logo &> /dev/null
  sudo rm /etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-logo &> /dev/null
  sudo dconf update > /dev/null

  # Restore original boot screen logo
  if [ -f /usr/share/plymouth/themes/spinner/watermark.png.bak ]
  then
    sudo rm /usr/share/plymouth/themes/spinner/watermark.png &> /dev/null
    sudo mv /usr/share/plymouth/themes/spinner/watermark.png.bak /usr/share/plymouth/themes/spinner/watermark.png
  fi
}

function set-desktop-ui-settings {
  echo -e "\n= Sets desktop ui settings =\n"

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/online-accounts]\n\n# Disable gnome online accounts\nwhitelisted-providers=[\'\']\n\n[com/ubuntu/SoftwareProperties]\n\nubuntu-pro-banner-visible=false\n\n[org/gnome/shell/extensions/dash-to-dock]\n\nextend-height=false\ndock-position=\'BOTTOM\'\nshow-apps-at-top=true\nautohide-in-fullscreen=true\nmulti-monitor=true\nshow-mounts=false\n\n[org/gnome/desktop/interface]\n\ngtk-theme=\'WhiteSur-Light\'\nicon-theme=\'WhiteSur-light\'\nclock-show-weekday=true\nshow-battery-precentage=true\n\n[org/gnome/desktop/wm/preferences]\n\ntheme=\'WhiteSur-Light\'\n\n[org/gnome/nautilus/preferences]\n\nopen-folder-on-dnd-hover=true\n\n[org/gnome/mutter]\n\ncenter-new-windows=true\nworkspaces-only-on-primary=false\n\n[org/gnome/shell]\n\nenabled-extensions=[\'blur-my-shell@aunetx\', \'user-theme@gnome-shell-extensions.gcampax.github.com\', \'tactile@lundal.io\']\n\n[org/gnome/shell/extensions/user-theme]\n\nname=\'WhiteSur-Light\'\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop'
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/online-accounts/whitelisted-providers\ncom/ubuntu/SoftwareProperties/ubuntu-pro-banner-visible\norg/gnome/shell/extensions/dash-to-dock/extend-height\norg/gnome/shell/extensions/dash-to-dock/dock-position\norg/gnome/shell/extensions/dash-to-dock/show-apps-at-top\norg/gnome/shell/extensions/dash-to-dock/autohide-in-fullscreen\norg/gnome/shell/extensions/dash-to-dock/multi-monitor\norg/gnome/shell/extensions/dash-to-dock/show-mounts\norg/gnome/desktop/interface/gtk-theme\norg/gnome/desktop/interface/icon-theme\norg/gnome/desktop/interface/clock-show-weekday\norg/gnome/desktop/interface/show-battery-precentage\norg/gnome/desktop/wm/preferences/theme\norg/gnome/nautilus/preferences/open-folder-on-dnd-hover\norg/gnome/mutter/center-new-windows\norg/gnome/mutter/workspaces-only-on-primary\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop'
  sudo dconf update > /dev/null
}

function unset-desktop-ui-settings {
  echo -e "\n= Unsets desktop ui settings =\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop &> /dev/null
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop &> /dev/null
  sudo dconf update > /dev/null
}

function set-desktop-dark-ui-settings {
  echo -e "\n= Sets desktop ui dark theme settings =\n"

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/desktop/interface]\n\ngtk-theme=\'WhiteSur-Dark\'\nicon-theme=\'WhiteSur-dark\'\n\n[org/gnome/desktop/wm/preferences]\n\ntheme=\'WhiteSur-Dark\'\n\n[org/gnome/shell/extensions/user-theme]\n\nname=\'WhiteSur-Dark\'\n">/etc/dconf/db/local.d/01-bs-ubuntutweaks-desktop-dark'
  sudo dconf update > /dev/null
}

function unset-desktop-dark-ui-settings {
  echo -e "\n= Unsets desktop ui dark theme settings =\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/01-bs-ubuntutweaks-desktop-dark &> /dev/null
  sudo dconf update > /dev/null
}

function set-desktop-left-appnavigation-settings {
  echo -e "\n= Sets desktop applications windows navigation buttons location to left =\n"

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/desktop/wm/preferences]\n\nbutton-layout=\'close,minimize,maximize:\'\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop-left-appnavigation'
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/desktop/wm/preferences/button-layout\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-left-appnavigation'
  sudo dconf update > /dev/nulls
}

function unset-desktop-left-appnavigation-settings {
  echo -e "\n= Resets desktop applications windows navigation buttons location to right =\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop-left-appnavigation &> /dev/null
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-left-appnavigation &> /dev/null
  sudo dconf update > /dev/nulls
}

function set-desktop-background-settings {
  echo -e "\n= Sets desktop background settings =\n"

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/desktop/background]\n\n# URI to use for the background image\npicture-uri=\'file://$1\'\n\n# Specify one of the rendering options for the background image:\npicture-options=\'zoom\'\n\n# Specify the left or top color when drawing gradients, or the solid color\nprimary-color=\'2E405D\'\n\n# Specify the right or bottom color when drawing gradients\nsecondary-color=\'DFEAF7\'\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop-background' -o "$(get-custom-desktop-background)"
  if [[ $1 != "no-lock" ]]
  then
    sudo sh -c $'echo "# Prevent changes to the following keys:\n\n/org/gnome/desktop/background/picture-uri\n/org/gnome/desktop/background/picture-options\n/org/gnome/desktop/background/primary-color\n/org/gnome/desktop/background/secondary-color\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-background'
  else
    sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-background &> /dev/null
  fi
  sudo dconf update > /dev/null
}

function unset-desktop-background-settings {
  echo -e "\n= Unsets desktop background settings =\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop-background &> /dev/null
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-background &> /dev/null
  sudo dconf update > /dev/null
}

function set-rubik-as-defaultfont-settings {
  echo -e "\n= Sets Rubik as default desktop font =\n"

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/desktop/interface]\n\nfont-name=\'Rubik 11\'\n\n[org/gnome/desktop/wm/preferences]\n\ntitlebar-font=\'Rubik Bold 11\'\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-rubik-as-defaultfont'
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/desktop/interface/font-name\norg/gnome/desktop/wm/preferences/titlebar-font\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop'
  sudo dconf update > /dev/null
}

function unset-rubik-as-defaultfont-settings {
  echo -e "\n= Unsets Rubik as default desktop font =\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-rubik-as-defaultfont &> /dev/null
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-rubik-as-defaultfont &> /dev/null
  sudo dconf update > /dev/null
}

# Prints AAD configuration path (internal-use)
function get-custom-aad-config {
  if [ -f '/opt/bluesparrow/ubuntutweaks/aad.conf' ]
  then
    echo '/opt/bluesparrow/ubuntutweaks/aad.conf'
  else
    echo "$(realpath ./aad.conf)"
  fi
}

function set-aad-settings {
  echo -e "\n= Sets new Azure Active Directory settings =\n"

  # Change AAD settings via upload new file
  sudo rm /etc/aad.conf &> /dev/null
  sudo cp $(get-custom-aad-config) /etc/aad.conf &> /dev/null

  set-auth-nouserslist-settings

  need_reboot=1
}

function unset-aad-settings {
  echo -e "\n= Unsets Azure Active Directory settings =\n"

  # Remove AAD settings
  sudo rm /etc/aad.conf &> /dev/null

  unset-auth-nouserslist-settings

  need_reboot=1
}

function lock-all-settings-apps {
  echo -e "\n= Locks all settings-apps =\n"

  # Disable access to settings app for non-admin users
  sudo chown root:sudo /usr/bin/gnome-control-center
  sudo chmod 750 /usr/bin/gnome-control-center
  sudo chown root:sudo /usr/bin/dconf-editor
  sudo chmod 750 /usr/bin/dconf-editor
  if [ -f /usr/bin/gnome-tweaks ]
  then
    sudo chown root:sudo /usr/bin/gnome-tweaks
    sudo chmod 750 /usr/bin/gnome-tweaks
  fi
}

function unlock-all-settings-apps {
  echo -e "\n= Unlocks all settings-apps =\n"

  # Enable access to settings app for non-admin users
  sudo chown root:sudo /usr/bin/gnome-control-center
  sudo chmod 755 /usr/bin/gnome-control-center
  sudo chown root:sudo /usr/bin/dconf-editor
  sudo chmod 755 /usr/bin/dconf-editor
  if [ -f /usr/bin/gnome-tweaks ]
  then
    sudo chown root:sudo /usr/bin/gnome-tweaks
    sudo chmod 755 /usr/bin/gnome-tweaks
  fi
}

function lock-important-settings-apps {
  echo -e "\n= Locks important settings-apps =\n"

  # Disable access to some settings app for non-admin users
  sudo chown root:sudo /usr/bin/dconf-editor
  sudo chmod 750 /usr/bin/dconf-editor
  if [ -f /usr/bin/gnome-tweaks ]
  then
    sudo chown root:sudo /usr/bin/gnome-tweaks
    sudo chmod 750 /usr/bin/gnome-tweaks
  fi
}

function unlock-common-settings-apps {
  echo -e "\n= Unlocks common settings-apps =\n"

  # Enable access to some settings app for non-admin users
  sudo chown root:sudo /usr/bin/dconf-editor
  sudo chmod 755 /usr/bin/dconf-editor
  if [ -f /usr/bin/gnome-tweaks ]
  then
    sudo chown root:sudo /usr/bin/gnome-tweaks
    sudo chmod 755 /usr/bin/gnome-tweaks
  fi
}

function install-tweaks {
  echo -e "\n= Installing tweaks utility into system =\n"

  # Check of already installed tweaks utility
  if [ -d "/var/bluesparrow/ubuntutweaks" ]
  then
    read -p "Found the tweaks utility catalog. Procceed anyway (y/n)?: " choice
    case "$choice" in
      y | Y ) echo "Reinstalling tweaks utility!" ;;
      n | N ) echo "Skipping tweaks ulitity installation!";;
      * ) echo -e "Invalid option\n" >&2; install-tweaks; return 0 ;;
    esac
  fi

  # Install required git software
  sudo apt-get install -qy git > /dev/null

  # Create base and optional directories
  sudo mkdir -p /var/bluesparrow/ubuntutweaks
  sudo mkdir -p /opt/bluesparrow/ubuntutweaks

  # Clone tweaks into system
  sudo /bin/bash -c "git clone -b v1 https://gitlab.com/bluesparrow/ubuntutweaks.git /var/bluesparrow/ubuntutweaks -q" > /dev/null

  # Set right scripts permissions
  sudo chmod 755 /var/bluesparrow/ubuntutweaks/main.sh
  sudo chmod 755 /var/bluesparrow/ubuntutweaks/run.sh

  # Add tweaks into shell path
  sudo rm /usr/local/bin/bs-ubuntutweaks &> /dev/null
  sudo touch /usr/local/bin/bs-ubuntutweaks
  sudo /bin/bash -c $'echo "#!/bin/bash\n\n/bin/bash /var/bluesparrow/ubuntutweaks/run.sh \$*\n" > /usr/local/bin/bs-ubuntutweaks' > /dev/null
  sudo chmod 755 /usr/local/bin/bs-ubuntutweaks
}

function update-tweaks {
  echo -e "\n= Updating tweaks utility =\n"

  # Trigger download of tweaks utility updates
  sudo bash -c $'cd /var/bluesparrow/ubuntutweaks; git pull origin -q'

  if [ ! -z $1 ]
  then
    if [$(cd /var/bluesparrow/ubuntutweaks; git branch | grep -c "$1") -eq 1 ]
    then
      sudo bash -c "cd /var/bluesparrow/ubuntutweaks; git checkout $1 -q"
      echo "Switched to version \"$1\""
    else
      echo "Cannot find version \"$1\"!" >&2
    fi
  fi

  # Set right scripts permissions
  sudo chmod 755 /var/bluesparrow/ubuntutweaks/main.sh
}

function schedule-update-tweaks {
  echo -e "\n= Schedules tweaks utility weekly update =\n"

  if [ -d "/var/bluesparrow/ubuntutweaks" ]
  then
    sudo touch /etc/cron.d/bs-ubuntutweaks-updateself
    echo -e "0 0 * * 1 root bs-ubuntutweaks update-self" >> /etc/cron.d/bs-ubuntutweaks-updateself
  else
    echo "Cannot schedule tweaks weekly update due to lack of their persistent installation." >&2
  fi
}

function unschedule-update-tweaks {
  echo -e "\n= Unschedules tweaks utility weekly update =\n"

  sudo rm /etc/cron.d/bs-ubuntutweaks-updateself &> /dev/null
}

function uninstall-tweaks {
  echo -e "\n= Uninstalling tweaks utility from system =\n"

  sudo rm -R /var/bluesparrow/ubuntutweaks &> /dev/null
  sudo rm -R /opt/bluesparrow/ubuntutweaks &> /dev/null
  sudo rm /etc/cron.d/bs-ubuntutweaks-updateself &> /dev/null
  sudo rm /etc/cron.d/bs-ubuntutweaks-updatesoftware &> /dev/null
  sudo rm /usr/local/bin/bs-ubuntutweaks &> /dev/null
}

function purge-tweaks {
  unset-auth-ui-settings
  unset-auth-nouserslist-settings
  unset-auth-notice-settings
  unset-auth-logo-settings
  unset-desktop-ui-settings
  unset-desktop-dark-ui-settings
  unset-desktop-left-appnavigation-settings
  unset-desktop-background-settings
  unset-rubik-as-defaultfont-settings

  unset-aad-settings

  unlock-all-settings-apps

  uninstall-internet-software
  uninstall-office-software
  uninstall-edu-software
  uninstall-creative-software
  uninstall-programming-software
  uninstall-ose
  uninstall-remote-support
  uninstall-aad
  uninstall-ui-mods

  uninstall-tweaks
}

function reboot-system {
  read -p "Do you want to restart the computer to make changes effects (y/n)?: " choice
  case "$choice" in
    y | Y ) sudo reboot;;
    n | N ) echo "You would need to restart the machine manualy later";;
    * ) echo -e "Invalid option\n" >&2; reboot-system;;
  esac
}


## Prompt functions

# Handle main run functionality
function main-prompt {
  case "$1" in
    a | active | interactive ) interactive-prompt ;;
    i | install ) shift; install-prompt $* ;;
    c | config | configure ) shift; configure-prompt $* ;;
    u | update ) update-software ;;
    r | remove ) shift; remove-prompt $* ;;
    su | schedule-update ) schedule-update-software ;;
    usu | unschedule-update ) unschedule-update-software ;;
    is | install-self ) install-tweaks ;;
    us | update-self ) update-tweaks $2 ;;
    rs | remove-self ) uninstall-tweaks; need_reboot=1 ;;
    ps | purge-self ) purge-tweaks; need_reboot=1 ;;
    sus | schedule-update-self ) schedule-update-tweaks ;;
    usus | unschedule-update-self ) unchedule-update-tweaks ;;
    h | "-h" | help | "--help" | '' ) print-help ;;
    * ) echo -e "\nInvalid option!\n" >&2; print-help ;;
  esac
  if [[ need_reboot -eq 1 && no_reboot -eq 0 ]]
  then
    reboot-system
    need_reboot=0
  fi
}

function print-help {
  echo "
Usage:
    bs-ubuntutweaks [--no-reboot] [command [agrugemnts]]

Available commands:
- a, active, interactive - Runs utility in interactive(continous input) mode
- i, install [package] - Installs choosen software packs and kits (all usage of this command causes installation of some basic dependencies)
- c, config, configure [option] - Configures system by choosen option (all usage of this command causes creation of some gnome-desktop configuration files)
- u, update - Updates all software in system
- r, remove [package] - Removes choosen software packs and kits
- su, schedule-update - Schedules weekly software updates
- usu, unschedule-update - Unschedules weekly software updates
- is, install-self - Installs tweaks utility into system
- us, update-self [version] - Updates tweaks utility (fixes only unless provided new version)
- rs, remove-self - Removes tweaks utility from system
- ps, purge-self - Removes tweaks utility from system along with all its related software and settings
- sus, schedule-update-self - Schedules weekly tweaks utility updates
- usus, unschedule-update-self - Unschedules weekly tweaks utility updates
- h, -h, help, --help - Prints this help

When in use with --no-reboot flag it does not prompt for machine restart"
}

function print-packages {
  echo "
Available packages:
- is, internet-software - Software pack contains most popular internet-browsing software (ex. MS Edge, Chromium, Spotify, Zoom.us)
- os, office-software - Software pack contains popular office suites (LibreOffice, WPS Office and TexStudio) and printing drivers
- es, edu-software - Software pack with educational-use applications (like MS Teams)
- cs, creative-software - Software pack contains creative software (like Gimp, Inkscape, LightWorks, OBS and Blender)
- ps, programming-software - Software packs contains the most popular programming languages and IDE-tools (VS Code and Unity3d)
- ose, ose-certyficate - Certyficate for OSE network project
- rs, remote-support - Software pack with Anydesk and TeamViewer remote-support software
- aad[-wc], add-auth[-without-config] - Azure Active Directory support software (with configuration from /opt/bluesparrow/ubuntutweaks/aad.conf as default)
- ui[-wc], ui-mods[-without-config] - User interface modifications pack for gnome-desktop

Available kits (with remote-support + ui-mods + automatic updates):
- ok, office-kit - Software kit for home and office usage (internet-software + office-software + ui-mods)
- sk, student-kit - Software kit for student computers (internet-software + office-software + edu-software + creative-software + programming-software + ose-certyficate + remote-support + ui-mods + limitations)
- tk, teacher-kit - Software kit for teachers computers and students home computers (internet-software + office-software + edu-software + creative-software + programming-software + ose-certyficate + remote-support + ui-mods)
- pk, proffesional-kit - Software kit for proffesional users (internet-software + office-software + creative-software + programming-software + remote-support + ui-mods)
- okaadd[-wc], office-kit-aad[-without-config] - Package office-kit with Azure Active Directory installation
- skaadd[-wc], student-kit-aad[-without-config] - Package student-kit with Azure Active Directory installation
- tkaadd[-wc], teacher-kit-aad[-without-config] - Package teacher-kit with Azure Active Directory installation
- pkaadd[-wc], proffesional-kit-aad[-without-config] - Package proffesional-kit with Azure Active Directory installation

-wc, -without-config suffixes are available only in installation prompt (when removing it no matters)"
}

function print-config-options {
  echo "Important!
  Some modifications may not work if the ui-mods package is not installed.

Available configuration options:
- las, lock-all-settings-apps - Locks all settings applitactions
- ulas, unlock-all-settings-apps - Unlocks all settings applitactions
- lis, lock-important-settings-apps - Locks important settings applitactions (without main Settings app)
- ulcs, unlock-common-settings-apps - Unlocks main Settings application
- sau, set-auth-ui-mods - Applys authorization interface visual mods (background from /opt/bluesparrow/ubuntutweaks/bg-auth.jpg or default one)
- usau, unset-auth-ui-mods - Cancels authorization interface visual mods
- sanul, set-auth-nouserslist - Hides users list at authorization interface
- usanul, unset-auth-nouserslist - Shows again users list at authorization interface
- san, set-auth-notice [notice text] - Shows notice text banner at authorization interface (from /opt/bluesparrow/ubuntutweaks/banner.txt or provided one)
- usan, unset-auth-notice - Removes notice text banner from authorization interface
- sal, set-auth-logo - Replaces bottom logo at authorization interface (from /opt/bluesparrow/ubuntutweaks/logo.png or default one)
- usal, unset-auth-logo - Replaces bottom logo at authorization interface with default one again
- sdu, set-desktop-ui-mods - Applys desktop interface visual mods
- usdu, unset-desktop-ui-mods - Cancels desktop interface visual mods
- sddut, set-desktop-dark-ui-theme - Applys desktop interface dark theme (use after set-desktop-ui-mods)
- usddut, unset-desktop-dark-ui-theme - Cancels desktop interface dark theme
- sdlan, set-desktop-left-appnavigation - Moves navigation buttons to the left of the applications windows topbar (Macos style)
- usdlan, unset-desktop-left-appnavigation - Moves navigation buttons of applications windows topbar into default position (right)
- sdb, set-desktop-background - Applys desktop custom background (from /opt/bluesparrow/ubuntutweaks/bg-desktop.jpg or default one)
- sdbl, set-desktop-background-with-lock - Applys desktop custom background with change lock (from /opt/bluesparrow/ubuntutweaks/bg-desktop.jpg or default one)
- usdb, unset-desktop-background - Cancels desktop custom backgrounds (also with change lock one)
- srdf, set-rubik-as-defaultfont - Applys Rubik as system default font
- usrdf, unset-rubik-as-defaultfont - Cancels Rubik as system default font
- sa, set-add-settings - Applys Azure Active Directory (Entra ID) settings (from /opt/bluesparrow/ubuntutweaks/aad.conf or empty ones)
- usa, unset-add-settings - Cancels Azure Active Directory (Entra ID) settings
- l, list - Prints this help"
}

function interactive-prompt {
  if [[ $1 != "--no-introduce" ]]
  then
    echo -e "** Type commads of your choice (type exit/bye/quit/end to exit the program) **\n\n"
  fi

  read -p "> " choice
  if [[ choice != "bye" && choice != "exit" && choice != "quit" && choice != "end" ]]
  then
    main-prompt choice
    interactive-prompt --no-introduce
  fi
}

function install-prompt {
  if [[ $1 != "--no-init" ]]
  then
    # Upate software list
    sudo apt-get update > /dev/null

    install-general-software
  else
    shift
  fi

  for package
  do
    case "$package" in
      is | internet-software ) install-internet-software ;;
      os | office-software ) install-office-software ;;
      es | edu-software ) install-edu-software ;;
      cs | creative-software ) install-creative-software ;;
      ps | programming-software ) install-programming-software ;;
      ose | ose-certyficate ) install-ose; need_reboot=1 ;;
      rs | remote-support ) install-remote-support ;;
      aad | add-auth ) install-aad; configure-prompt set-aad-settings; need_reboot=1 ;;
      aad-wc | add-auth-without-config ) install-aad ;;
      ui | ui-mods ) install-ui-mods; configure-prompt set-auth-ui-mods; configure-prompt set-auth-logo; configure-prompt set-desktop-ui-mods; configure-prompt set-desktop-background; configure-prompt set-rubik-as-defaultfont; need_reboot=1 ;;
      ui-wc | ui-mods-without-config ) install-ui-mods ;;
      ok | office-kit ) install-internet-software; install-office-software; install-remote-support; install-prompt --no-init ui-mods; configure-prompt lock-important-settings-apps; schedule-update-software; schedule-update-tweaks; update-software; need_reboot=1 ;;
      sk | student-kit ) install-internet-software; install-office-software; install-edu-software; install-creative-software; install-programming-software; install-ose; install-remote-support; install-prompt --no-init ui-mods; configure-prompt set-desktop-background-with-lock; configure-prompt lock-all-settings-apps; schedule-update-software; schedule-update-tweaks; update-software; need_reboot=1 ;;
      tk | teacher-kit ) install-internet-software; install-office-software; install-edu-software; install-creative-software; install-programming-software; install-ose; install-remote-support; install-prompt --no-init ui-mods; configure-prompt lock-important-settings-apps; schedule-update-software; schedule-update-tweaks; update-software; need_reboot=1 ;;
      pk | proffesional-kit ) install-internet-software; install-office-software; install-creative-software; install-programming-software; install-remote-support; install-prompt --no-init ui-mods; schedule-update-software; schedule-update-tweaks; update-software; need_reboot=1 ;;
      okaad | office-kit-aad ) install-prompt --no-init office-kit; install-aad ;;
      skaad | student-kit-aad ) install-prompt --no-init student-kit; install-aad ;;
      tkaad | teacher-kit-aad ) install-prompt --no-init teacher-kit; install-aad ;;
      pkaad | proffesional-kit-aad ) install-prompt --no-init proffesional-kit; install-aad ;;
      okaad-wc | office-kit-aad-without-config ) install-internet-software; install-office-software; install-remote-support; install-ui-mods;;
      skaad-wc | student-kit-aad-without-config ) install-internet-software; install-office-software; install-edu-software; install-creative-software; install-programming-software; install-ose; install-remote-support; install-ui-mods ;;
      tkaad-wc | teacher-kit-aad-without-config ) install-internet-software; install-office-software; install-edu-software; install-creative-software; install-programming-software; install-ose; install-remote-support; install-ui-mods ;;
      pkaad-wc | proffesional-kit-aad-without-config ) install-internet-software; install-office-software; install-creative-software; install-programming-software; install-remote-support; install-ui-mods ;;
      l | list | '' ) print-packages ;;
      * ) echo -e "\nInvalid option!\n" >&2; print-packages ;;
    esac
  done
}

function configure-prompt {
  set-general-ui-settings

  case "$1" in
    las | lock-all-settings-apps ) lock-all-settings-apps ;;
    ulas | unlock-all-settings-apps ) unlock-all-settings-apps ;;
    lis | lock-important-settings-apps ) lock-important-settings-apps ;;
    ulcs | unlock-common-settings-apps ) unlock-common-settings-apps ;;
    sau | set-auth-ui-mods ) set-auth-ui-settings; need_reboot=1 ;;
    usau | unset-auth-ui-mods ) unset-auth-ui-settings; need_reboot=1 ;;
    sanul | set-auth-nouserslist ) set-auth-nouserslist-settings; need_reboot=1 ;;
    usanul | unset-auth-nouserslist ) unset-auth-nouserslist-settings; need_reboot=1 ;;
    san | set-auth-notice ) shift; set-auth-notice-settings $*; need_reboot=1 ;;
    usan | unset-auth-notice ) unset-auth-notice-settings; need_reboot=1 ;;
    sal | set-auth-logo ) set-auth-logo-settings; need_reboot=1 ;;
    usal | unset-auth-logo ) unset-auth-logo-settings; need_reboot=1 ;;
    sdu | set-desktop-ui-mods ) set-desktop-ui-settings; need_reboot=1 ;;
    usdu | unset-desktop-ui-mods ) unset-desktop-ui-settings; need_reboot=1 ;;
    sddut | set-desktop-dark-ui-theme ) set-desktop-dark-ui-settings; need_reboot=1 ;;
    usddut | unset-desktop-dark-ui-theme ) unset-desktop-dark-ui-settings; need_reboot=1 ;;
    sdlan | set-desktop-left-appnavigation ) set-desktop-left-appnavigation-settings; need_reboot=1 ;;
    usdlan | unset-desktop-left-appnavigation ) unset-desktop-left-appnavigation-settings; need_reboot=1 ;;
    sdb | set-desktop-background ) set-desktop-background-settings no-lock; need_reboot=1 ;;
    sdbl | set-desktop-background-with-lock ) set-desktop-background-settings; need_reboot=1 ;;
    usdb | unset-desktop-background ) unset-desktop-background-settings; need_reboot=1 ;;
    srdf | set-rubik-as-defaultfont ) set-rubik-as-defaultfont-settings; need_reboot=1 ;;
    usrdf | unset-rubik-as-defaultfont ) unset-rubik-as-defaultfont-settings; need_reboot=1 ;;
    sa | set-aad-settings ) set-aad-settings; need_reboot=1 ;;
    usa | unset-aad-settings ) unset-aad-settings; need_reboot=1 ;;
    l | list | '' ) print-config-options ;;
    * ) echo -e "\nInvalid option!\n" >&2; print-config-options ;;
  esac
}

function remove-prompt {
  for package
  do
    case "$package" in
      is | internet-software ) uninstall-internet-software ;;
      os | office-software ) uninstall-office-software ;;
      es | edu-software ) uninstall-edu-software ;;
      cs | creative-software ) uninstall-creative-software ;;
      ps | programming-software ) uninstall-programming-software ;;
      ose | ose-certyficate ) uninstall-ose; need_reboot=1 ;;
      rs | remote-support ) uninstall-remote-support ;;
      aad | add-auth ) uninstall-aad; configure-prompt unset-aad-settings; need_reboot=1 ;;
      ui | ui-mods ) uninstall-ui-mods; configure-prompt unset-auth-ui-mods; configure-prompt unset-auth-logo; configure-prompt unset-desktop-ui-mods; configure-prompt unset-desktop-background; configure-prompt unset-rubik-as-defaultfont; need_reboot=1 ;;
      ok | office-kit ) uninstall-internet-software; uninstall-office-software; uninstall-remote-support; uninstall-prompt ui-mods; configure-prompt unlock-all-settings-apps; need_reboot=1 ;;
      sk | student-kit ) uninstall-internet-software; uninstall-office-software; uninstall-edu-software; uninstall-creative-software; uninstall-programming-software; uninstall-ose; uninstall-remote-support; uninstall-prompt ui-mods; configure-prompt unlock-all-settings-apps; need_reboot=1 ;;
      tk | teacher-kit ) uninstall-internet-software; uninstall-office-software; uninstall-edu-software; uninstall-creative-software; uninstall-programming-software; uninstall-ose; uninstall-remote-support; uninstall-prompt ui-mods; configure-prompt unlock-all-settings-apps; need_reboot=1 ;;
      pk | proffesional-kit ) uninstall-internet-software; uninstall-office-software; uninstall-creative-software; uninstall-programming-software; uninstall-remote-support; uninstall-prompt ui-mods; need_reboot=1 ;;
      okaad | office-kit-aad ) uninstall-prompt office-kit; uninstall-prompt aad ;;
      skaad | student-kit-aad ) uninstall-prompt student-kit; uninstall-prompt aad ;;
      tkaad | teacher-kit-aad ) uninstall-prompt teacher-kit; uninstall-prompt aad ;;
      pkaad | proffesional-kit-aad ) uninstall-prompt proffesional-kit; uuninstall-prompt aad ;;
      l | list | '' ) print-packages ;;
      * ) echo -e "\nInvalid option!\n" >&2; print-packages ;;
    esac
  done
}

# Check no-restart flag
if [[ $1 == "--no-restart" ]]
then
  no_reboot=1
  shift
fi

echo -e "=== BlueSparrow UbuntuTweaks ===\n"
main-prompt $*
echo -e "\n= Bye! =\n"
