#!/bin/bash


# Change __DIR__ to script root
cd $(dirname $0)

# Upate software list
sudo apt update

# Declare variables
need_reboot=0

## Software manipulation functions

function install-general-software {
  echo -e "= Installing common general-use dependencies =\n\n"

  # Install software and libs from ubuntu repositories
  sudo apt install -y gettext ca-certificates curl gnupg software-properties-common apt-transport-https realpath unzip git snapd openjdk-17-jre openjdk-17-jre libfuse2 mc dconf-cli dconf-editor python3 pipx
}

function install-internet-software {
  echo -e "= Installing internet-software package =\n\n"

  # Disable echo
  stty -echo

  # Add MS Edge repository
  echo 'deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
  sudo wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg

  # Re-enable echo
  stty echo

  # Upate software list
  sudo apt update

  # Install software from added repositories
  sudo apt install -y microsoft-edge-stable

  # Disable echo
  stty -echo

  # Downloads Zoom.us
  sudo rm -R /tmp/zoom.deb
  wget -qO - https://zoom.us/client/5.17.1.1840/zoom_amd64.deb | sudo tee /tmp/zoom.deb

  # Re-enable echo
  stty echo

  # Install Zoom.us
  sudo dpkg -i /tmp/zoom.deb
  sudo apt --fix-broken install -y

  # Disable echo
  stty -echo

  # Install software from snap
  sudo snap install chromium
  sudo snap install spotify
  sudo snap install discord
}

function uninstall-internet-software {
  echo -e "= Uninstalling internet-software package =\n\n"

  # Remove MS Edge repository
  sudo rm /usr/share/keyrings/microsoft-edge.gpg

  # Remove installed software
  sudo apt remove -y microsoft-edge-stable

  # Purge dependencies
  sudo apt autoremove

  # Remove software from snap
  sudo snap remove chromium
  sudo snap remove spotify
}

function install-office-software {
  echo -e "= Installing office-software package =\n\n"

  # Install software and libs from ubuntu repositories
  sudo apt install -y libreoffice cups cups-ipp-utils hplip printer-driver-gutenprint

  # Add TexStudio repository
  sudo add-apt-repository -y ppa:sunderme/texstudio

  # Upate software list
  sudo apt update

  # Install software from added repositories
  sudo apt install -y texstudio

  # Install software from snap
  sudo snap install wps-office
  sudo snap install krita
}

function uninstall-office-software {
  echo -e "= Uninstalling office-software package =\n\n"

  # Remove TexStudio repository
  sudo remove-apt-repository -y ppa:sunderme/texstudio

  # Remove installed software
  sudo apt remove -y libreoffice texstudio cups cups-ipp-utils hplip printer-driver-gutenprint

  # Purge dependencies
  sudo apt autoremove

  # Remove software from snap
  sudo snap remove wps-office
  sudo snap remove krita
}

function install-edu-software {
  echo -e "= Installing edu-software package =\n\n"

  # Install software from snap
  sudo snap install teams-for-linux
}

function uninstall-edu-software {
  echo -e "= Uninstalling edu-software package =\n\n"

  # Remove software from snap
  sudo snap remove teams-for-linux
}

function install-creative-software {
  echo -e "= Installing creative-software package =\n\n"

  # Install software and libs from ubuntu repositories
  sudo apt install -y gimp gimp-data-extras gimp-help-common inkscape inkscape-open-symbols inkscape-tutorials kdenlive blender handbrake obs-studio

  # Disable echo
  stty -echo

  # Downloads NDI with OBS NDI addon packages
  sudo rm -R /tmp/ndi.deb
  sudo rm -R /tmp/obs-ndi.deb
  wget -qO - https://github.com/obs-ndi/obs-ndi/releases/download/4.11.1/libndi5_5.5.3-1_amd64.deb | sudo tee /tmp/ndi.deb
  wget -qO - https://github.com/obs-ndi/obs-ndi/releases/download/4.11.1/obs-ndi-4.11.1-linux-x86_64.deb | sudo tee /tmp/obs-ndi.deb

  # Re-enable echo
  stty echo

  # Install NDI with OBS NDI addon from downloaded packages
  sudo dpkg -i /tmp/ndi.deb
  sudo apt --fix-broken install -y
  sudo dpkg -i /tmp/obs-ndi.deb
  sudo apt --fix-broken install -y

  # Disable echo
  stty -echo

  # Downloads Lightworks
  sudo rm -R /tmp/lightworks.deb
  wget -qO - https://app.lwks.com/api/auth/download/lightworks/linux_deb | sudo tee /tmp/lightworks.deb

  # Re-enable echo
  stty echo

  # Install Lightworks from downloaded packages
  sudo dpkg -i /tmp/lightworks.deb
  sudo apt --fix-broken install -y
}

function uninstall-creative-software {
  echo -e "= Uninstalling creative-software package =\n\n"

  # Remove installed software
  sudo apt remove -y gimp gimp-data-extras gimp-help-common inkscape inkscape-open-symbols inkscape-tutorials kdenlive blender handbrake obs-studio

  # Purge dependencies
  sudo apt autoremove

  # Remove NDI with OBS NDI addon
  sudo dpkg -r ndi
  sudo dpkg -r obs-ndi

  # Remove Lightworks
  sudo dpkg -r lightworks
}

function install-programming-software {
  echo -e "= Installing programming-software package =\n\n"

  # Install software and libs from ubuntu repositories
  sudo apt install -y filezilla codeblocks codeblocks-common codeblocks-contrib codeblocks-dev libcodeblocks0 thonny arduino

  # Add Docker repository
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Julialang
  curl -fsSL https://install.julialang.org | sh -s -- -y

  # Disable echo
  stty -echo

  # Add Unity3D repository and download libssl1.1
  wget -qO - https://hub.unity3d.com/linux/keys/public | sudo tee /etc/apt/trusted.gpg.d/unityhub.asc
  sudo sh -c 'echo "deb https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'
  rm -R /tmp/libssl11.deb
  wget -qO - http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb | sudo tee /tmp/libssl11.deb

  # Re-enable echo
  stty echo

  # Install libssl1.1 from downloaded packages
  sudo dpkg -i /tmp/libssl11.deb

  # Disable echo
  stty -echo

  # Add C# IntelliSense
  wget -O - "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xA6A19B38D3D831EF" | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/mono-official-stable.gpg
  echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list

  # Re-enable echo
  stty echo

  # Upate software list
  sudo apt update

  # Install software from added repositories
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unityhub mono-complete dotnet6

  # Install software from snap
  sudo snap install pycharm-community --classic
  sudo snap install intellij-idea-community --classic
  sudo snap install code --classic
  sudo snap install brackets --classic
  sudo snap install flutter --classic
  sudo snap install kate --classic
  sudo snap install go --classic
}

function uninstall-programming-software {
  echo -e "= Uninstalling programming-software package =\n\n"

  # Remove Docker repository
  sudo rm /etc/apt/keyrings/docker.gpg
  sudo rm /etc/apt/sources.list.d/docker.list

  # Remove julia
  sudo juliaup self uninstall

  # Remove Unity3D repository
  sudo rm /etc/apt/trusted.gpg.d/unityhub.asc
  sudo rm /etc/apt/sources.list.d/unityhub.list

  # Add C# IntelliSense
  sudo rm /etc/apt/trusted.gpg.d/mono-official-stable.gpg
  sudo rm /etc/apt/sources.list.d/mono-official-stable.list

  # Remove installed software
  sudo apt remove -y filezilla codeblocks codeblocks-common codeblocks-contrib codeblocks-dev libcodeblocks0 thonny arduino docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unityhub mono-complete dotnet6

  # Purge dependencies
  sudo apt autoremove

  # Upate software list
  sudo apt update

  # Remove software from snap
  sudo snap remove pycharm-community --classic
  sudo snap remove intellij-idea-community --classic
  sudo snap remove code --classic
  sudo snap remove brackets --classic
  sudo snap remove flutter --classic
  sudo snap remove kate --classic
  sudo snap remove go --classic
}

# Install OSE ceryficate
function install-ose {
  echo -e "= Installing ose-certyficate package =\n\n"

  sudo rm -R /tmp/ose.zip
  sudo rm -R /tmp/ose
  wget -qO - https://ose.gov.pl/media/2022/09/pliki_linux.zip | sudo tee /tmp/ose.zip
  unzip /tmp/ose.zip -d /tmp/ose
  sudo /tmp/ose/cert_install/cert_install.sh
}

# Uninstall OSE ceryficate
function uninstall-ose {
  echo -e "= Uninstalling ose-certyficate package =\n\n"

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
  sudo update-ca-certificates

  # Remove installed software
  sudo apt remove -y libnss3-tools

  # Purge dependencies
  sudo apt autoremove
}

function install-remote-support {
  echo -e "= Installing remote-support package =\n\n"

  # Disable echo
  stty -echo

  # Add Anydesk repository
  wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo tee /etc/apt/trusted.gpg.d/anydesk.asc
  echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list

  # Reenable echo
  stty -echo

  # Upate software list
  sudo apt update

  # Install software from added repositories
  sudo apt install -y anydesk

  # Install TeamViewer
  rm -R /tmp/teamviewer.deb
  wget -qO - https://download.teamviewer.com/download/linux/teamviewer_amd64.deb | sudo tee /tmp/teamviewer.deb
  sudo dpkg -i /tmp/teamviewer.deb
}

function uninstall-remote-support {
  echo -e "= Uninstalling remote-support package =\n\n"

  # Remove Anydesk repository
  sudo rm /etc/apt/trusted.gpg.d/anydesk.asc
  sudo rm /etc/apt/sources.list.d/anydesk-stable.list

  # Remove installed software
  sudo apt remove -y anydesk

  # Purge dependencies
  sudo apt autoremove

  # Upate software list
  sudo apt update

  # Remove TeamViewer
  sudo dpkg -r teamviewer
}

function install-aad {
  echo -e "= Installing aad-auth package =\n\n"

  # Install software and libs from ubuntu repositories
  sudo apt install libpam-aad libnss-aad

  # Enable automatic home creation for AAD users
  sudo pam-auth-update --enable mkhomedir
}

function uninstall-aad {
  echo -e "= Uninstalling aad-auth package =\n\n"

  # Remove installed software
  sudo apt remove libpam-aad libnss-aad

  # Purge dependencies
  sudo apt autoremove

  # Remove AAD config
  sudo rm /etc/aad.conf
}

# Prints auth background path (internal-use)
function get-custom-auth-background {
  if [ -f '/opt/bluesparrow/ubuntutweaks/bg-auth.jpg']
  then
    echo "/opt/bluesparrow/ubuntutweaks/bg-auth.jpg"
  else
    echo "$(realpath ./resources/bg-auth.jpg)"
  fi
}

# Prints desktop background path (internal-use)
function get-custom-desktop-background {
  if [ -f '/opt/bluesparrow/ubuntutweaks/bg-desktop.jpg']
  then
    echo "/opt/bluesparrow/ubuntutweaks/bg-desktop.jpg"
  else
    echo "$(realpath ./resources/bg-desktop.jpg)"
  fi
}

function install-ui-mods {
  echo -e "= Installing ui-mods package =\n\n"

  # Install software and libs from ubuntu repositories
  sudo apt install -y gnome-shell-extensions dbus-x11

  # Fix gnome-shell-extensions
  sudo apt install -y gnome-shell-extension-prefs
  sudo apt remove -y gnome-shell-extension-prefs
  sudo apt install -y gnome-shell-extension-prefs

  # Install gnome extensions cli from pipx
  pipx install gnome-extensions-cli --system-site-packages

  # Enable user-theme gnome extensions
  gnome-extensions-cli enable user-theme@gnome-shell-extensions.gcampax.github.com

  # Install blur-my-shell gnome extension
  gnome-extensions-cli install blur-my-shell@aunetx
  gnome-extensions-cli disable blur-my-shell@aunetx

  # Install MacOS-like skin
  sudo mkdir whitesur;
  sudo git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git ./whitesur --depth=1
  (cd whitesur; sudo ./install.sh -i ubuntu; sudo ./tweaks.sh -f monterey; sudo ./tweaks.sh -g -N -b "$(get-custom-auth-background)";)

  # Install MacOS-like icons
  sudo mkdir whitesur-icons;
  sudo git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git ./whitesur-icons --depth=1
  (cd whitesur-icons; sudo ./install.sh -a;)
}

function uninstall-ui-mods {
  echo -e "= Uninstalling ui-mods package =\n\n"

  sudo rm -r ~/.local/share/gnome-shell/extensions/blur-my-shell@aunetx

  # Remove MacOS-like skin
  sudo mkdir whitesur;
  sudo git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git ./whitesur --depth=1
  (cd whitesur; sudo ./install.sh -r)

  # Remove MacOS-like icons
  sudo mkdir whitesur-icons;
  sudo git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git ./whitesur-icons --depth=1
  (cd whitesur-icons; sudo ./install.sh -r)

  # Remove installed software
  sudo apt remove -y gnome-shell-extensions

  # Purge dependencies
  sudo apt autoremove
}

function update-software {
  echo -e "= Updates software =\n\n"

  # Update software list
  sudo apt update

  # Update software
  sudo apt upgrade -y

  # Update snap software
  sudo snap refresh
}

function schedule-update-software {
  echo -e "= Schedules weekly software update =\n\n"

  if [ -d "/var/bluesparrow/ubuntutweaks" ]
  then
    sudo touch /etc/cron.d/bs-ubuntutweaks-updatesoftware
    echo -e "0 0 * * 1 root bash /var/bluesparrow/ubuntutweaks/run.sh update" >> /etc/cron.d/bs-ubuntutweaks-updatesoftware
  else
    echo "Cannot schedule software weekly update due to lack of tweaks persistent installation."
  fi
}

function unschedule-update-software {
  echo -e "= Unschedules weekly software update =\n\n"

  sudo rm /etc/cron.d/bs-ubuntutweaks-updatesoftware
}

function set-general-ui-settings {
  echo -e "= Sets base configurations files =\n\n"

  # Create Gnome desktop profiles
  sudo mkdir -p /etc/dconf/profile
  if [ ! -f "/etc/dconf/profile/user" ]
  then
    sudo sh -c 'echo -e "user-db:user\nsystem-db:local\n">/etc/dconf/profile/user'
  fi
  if [ ! -f "/etc/dconf/profile/gdm" ]
  then
    sudo sh -c 'echo -e "user-db:user\nsystem-db:gdm\nfile-db:/usr/share/gdm/greeter-dconf-defaults\n">/etc/dconf/profile/gdm'
  fi
  if [ ! -f "/usr/local/share/fonts/Rubik.ttf" ]
  then
    sudo cp resources/Rubik.ttf /usr/local/share/fonts/Rubik.ttf
    fc-cache -f -v
  fi
  if [ ! -f "/usr/local/share/fonts/Rubik-Italic.ttf" ]
  then
    sudo cp resources/Rubik-Italic.ttf /usr/local/share/fonts/Rubik-Italic.ttf
    fc-cache -f -v
  fi
  if [ ! -f "/usr/local/share/fonts/RubikMonoOne.ttf" ]
  then
    sudo cp resources/RubikMonoOne.ttf /usr/local/share/fonts/RubikMonoOne.ttf
    fc-cache -f -v
  fi
  sudo mkdir -p /etc/dconf/db/local.d/locks
}

function set-auth-ui-settings {
  echo -e "= Sets authorization screen ui mods settings =\n\n"

  # Change and lock Gnome authorization screen settings
  sudo sh -c $'echo "[org/gnome/desktop/screensaver]\n\n# URI to use for the background image\npicture-uri=\'file://$1\'\n\n# Specify one of the rendering options for the background image:\npicture-options=\'zoom\'\n\n# Specify the left or top color when drawing gradients, or the solid color\nprimary-color=\'2E405D\'\n\n# Specify the right or bottom color when drawing gradients\nsecondary-color=\'DFEAF7\'\nlogout-enabled=true\nlock-delay=360\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-auth' -o "$(get-custom-auth-background)"
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\n/org/gnome/desktop/screensaver/picture-uri\n/org/gnome/desktop/screensaver/picture-options\n/org/gnome/desktop/screensaver/primary-color\n/org/gnome/desktop/screensaver/secondary-color\n/org/gnome/desktop/screensaver/logout-enabled\n/org/gnome/desktop/screensaver/lock-delay\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-auth'
  sudo dconf update
}

function unset-auth-ui-settings {
  echo -e "= Unsets authorization screen ui mods settings =\n\n"

  # Reverse changes and unlock Gnome authorization screen settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-auth
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-auth
  sudo dconf update
}

function set-auth-nouserslist-settings {
  echo -e "= Disables authorization screen userslist =\n\n"

  # Change and lock Gnome authorization screen settings
  sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Do not show the user list\ndisable-user-list=true\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-nouserslist'
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/disable-user-list\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-nouserslist'
  sudo dconf update
}

function unset-auth-nouserslist-settings {
  echo -e "= Reenables authorization screen userslist =\n\n"

  # Reverse changes and unlock Gnome authorization screen settings
  sudo rm /etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-nouserslist
  sudo rm /etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-nouserslist
  sudo dconf update
}

function set-auth-notice-settings {
  echo -e "= Sets authorization screen notice banner settings =\n\n"

  if [[ $# -eq 1 ]]
  then
    # Change and lock Gnome authorization screen settings
    sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Display text message banner\nbanner-message-enable=true\nbanner-message-text=\'$1\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-notice' -o $1
    sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/banner-message-enable\norg/gnome/login-screen/banner-message-text\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-notice'
    sudo dconf update
  else
    if [ -f /opt/bluesparrow/ubuntutweaks/banner.txt ]
    then
      # Change and lock Gnome authorization screen settings
      sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Display text message banner\nbanner-message-enable=true\nbanner-message-text=\'$(cat /opt/bluesparrow/ubuntutweaks/banner.txt)\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-notice'
      sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/banner-message-enable\norg/gnome/login-screen/banner-message-text\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-notice'
      sudo dconf update
    else
      echo "No text provided!!!"
    fi
  fi
}

function unset-auth-notice-settings {
  echo -e "= Unsets authorization screen notice banner settings =\n\n"

  # Reverse changes and unlock Gnome authorization screen settings
  sudo rm /etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-notice
  sudo rm /etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-notice
  sudo dconf update
}

function set-auth-logo-settings {
  echo -e "= Sets authorization screen logo settings =\n\n"

  if [ -f "/opt/bluesparrow/ubuntutweaks/logo.png" ]
  then
    # Change and lock Gnome authorization screen settings
    sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Display custom logo image\nblogo=\'/opt/bluesparrow/ubuntutweaks/logo.png\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-logo'
    sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/banner-message-text\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-logo'
    sudo dconf update
  else
    # Change and lock Gnome authorization screen settings
    sudo sh -c $'echo "[org/gnome/login-screen]\n\n# Display custom logo image\nblogo=\'$(realpath ./resources/logo.png)\'\n">/etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-logo'
    sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/login-screen/banner-message-text\n">/etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-logo'
    sudo dconf update
  fi
}

function unset-auth-logo-settings {
  echo -e "= Unsets authorization screen logo settings =\n\n"

  # Reverse changes and unlock Gnome authorization screen settings
  sudo rm /etc/dconf/db/gdm.d/00-bs-ubuntutweaks-auth-logo
  sudo rm /etc/dconf/db/gdm.d/locks/00-bs-ubuntutweaks-auth-logo
  sudo dconf update
}

function set-desktop-ui-settings {
  echo -e "= Sets desktop ui settings =\n\n"

  # Enable blur-my-shell gnome extension
  gnome-extensions-cli enable blur-my-shell@aunetx

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/online-accounts]\n\n# Disable gnome online accounts\nwhitelisted-providers=[\'\']\n\n[com/ubuntu/SoftwareProperties]\n\nubuntu-pro-banner-visible=false\n\n[org/gnome/shell/extensions/dash-to-dock]\n\nextend-height=false\ndock-position=\'BOTTOM\'\nshow-apps-at-top=true\nautohide-in-fullscreen=true\nmulti-monitor=true\nshow-mounts=false\n\n[org/gnome/desktop/interface]\n\ngtk-theme=\'WhiteSur-Light\'\nicon-theme=\'WhiteSur-light\'\nclock-show-weekday=true\n\n[org/gnome/desktop/wm/preferences]\n\ntheme=\'WhiteSur-Light\'\n\n[org/gnome/nautilus/preferences]\n\nopen-folder-on-dnd-hover=true\n\n[org/gnome/mutter]\n\ncenter-new-windows=true\nworkspaces-only-on-primary=false\n\n[org/gnome/shell/extensions/user-theme]\n\nname=\'WhiteSur-Light\'\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop'
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/online-accounts/whitelisted-providers\ncom/ubuntu/SoftwareProperties/ubuntu-pro-banner-visible\norg/gnome/shell/extensions/dash-to-dock/extend-height\norg/gnome/shell/extensions/dash-to-dock/dock-position\norg/gnome/shell/extensions/dash-to-dock/show-apps-at-top\norg/gnome/shell/extensions/dash-to-dock/autohide-in-fullscreen\norg/gnome/shell/extensions/dash-to-dock/multi-monitor\norg/gnome/shell/extensions/dash-to-dock/show-mounts\norg/gnome/desktop/interface/gtk-theme\norg/gnome/desktop/interface/icon-theme\norg/gnome/desktop/interface/clock-show-weekday\norg/gnome/desktop/wm/preferences/theme\norg/gnome/nautilus/preferences/open-folder-on-dnd-hover\norg/gnome/mutter/center-new-windows\norg/gnome/mutter/workspaces-only-on-primary\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop'
  sudo dconf update
}

function unset-desktop-ui-settings {
  echo -e "= Unsets desktop ui settings =\n\n"

  # Disable blur my shell
  sudo gnome-extensions disable blur-my-shell@aunetx

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop
  sudo dconf update
}

function set-desktop-dark-ui-settings {
  echo -e "= Sets desktop ui dark theme settings =\n\n"

  # Enable blur my shell
  sudo gnome-extensions enable blur-my-shell@aunetx

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/desktop/interface]\n\ngtk-theme=\'WhiteSur-Dark\'\nicon-theme=\'WhiteSur-dark\'\n\n[org/gnome/desktop/wm/preferences]\n\ntheme=\'WhiteSur-Dark\'\n\n[org/gnome/shell/extensions/user-theme]\n\nname=\'WhiteSur-Dark\'\n">/etc/dconf/db/local.d/01-bs-ubuntutweaks-desktop-dark'
  sudo dconf update
}

function unset-desktop-dark-ui-settings {
  echo -e "= Unsets desktop ui dark theme settings =\n\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/01-bs-ubuntutweaks-desktop-dark
  sudo dconf update
}

function set-desktop-left-appnavigation-settings {
  echo -e "= Sets desktop applications windows navigation buttons location to left =\n\n"

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/desktop/wm/preferences]\n\nbutton-layout=\'close,minimize,maximize:\'\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop-left-appnavigation'
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/desktop/wm/preferences/button-layout\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-left-appnavigation'
  sudo dconf update
}

function unset-desktop-left-appnavigation-settings {
  echo -e "= Resets desktop applications windows navigation buttons location to right =\n\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop-left-appnavigation
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-left-appnavigation
  sudo dconf update
}

function set-desktop-background-settings {
  echo -e "= Sets desktop background settings =\n\n"

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/desktop/background]\n\n# URI to use for the background image\npicture-uri=\'file://$1\'\n\n# Specify one of the rendering options for the background image:\npicture-options=\'zoom\'\n\n# Specify the left or top color when drawing gradients, or the solid color\nprimary-color=\'2E405D\'\n\n# Specify the right or bottom color when drawing gradients\nsecondary-color=\'DFEAF7\'\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop-background' -o "$(get-custom-desktop-background)"
  if [[ $1 != "no-lock" ]]
  then
    sudo sh -c $'echo "# Prevent changes to the following keys:\n\n/org/gnome/desktop/background/picture-uri\n/org/gnome/desktop/background/picture-options\n/org/gnome/desktop/background/primary-color\n/org/gnome/desktop/background/secondary-color\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-background'
  else
    sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-background
  fi
  sudo dconf update
}

function unset-desktop-background-settings {
  echo -e "= Unsets desktop background settings =\n\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-desktop-background
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop-background
  sudo dconf update
}

function set-rubik-as-defaultfont-settings {
  echo -e "= Sets Rubik as default desktop font =\n\n"

  # Change and lock Gnome desktop settings
  sudo sh -c $'echo "[org/gnome/desktop/interface]\n\nfont-name=\'Rubik 11\'\ntitlebar-font=\'Rubik Bold 11\'\nmonospace-font-name=\'Rubik Mono One 13\'\n">/etc/dconf/db/local.d/00-bs-ubuntutweaks-rubik-as-defaultfont'
  sudo sh -c $'echo "# Prevent changes to the following keys:\n\norg/gnome/desktop/interface/font-name\norg/gnome/desktop/interface/titlebar-font\norg/gnome/desktop/interface/monospace-font-name\n">/etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-desktop'
  sudo dconf update
}

function unset-rubik-as-defaultfont-settings {
  echo -e "= Unsets Rubik as default desktop font =\n\n"

  # Reverse changes and unlock Gnome desktop settings
  sudo rm /etc/dconf/db/local.d/00-bs-ubuntutweaks-rubik-as-defaultfont
  sudo rm /etc/dconf/db/local.d/locks/00-bs-ubuntutweaks-rubik-as-defaultfont
  sudo dconf update
}

function set-aad-settings {
  echo -e "= Sets new Azure Active Directory settings =\n\n"

  # Change AAD settings via upload new file
  sudo rm /etc/aad.conf
  sudo cp ./aad.conf /etc/aad.conf

  set-auth-nouserslist-settings

  need_reboot=1
}

function unset-aad-settings {
  echo -e "= Unsets Azure Active Directory settings =\n\n"

  # Remove AAD settings
  sudo rm /etc/aad.conf

  unset-auth-nouserslist-settings

  need_reboot=1
}

function lock-all-settings-apps {
  echo -e "= Locks all settings-apps =\n\n"

  # Disable access to settings app for non-admin users
  sudo chown root:sudo /usr/bin/gnome-control-center
  sudo chmod 750 /usr/bin/gnome-control-center
  sudo chown root:sudo /usr/bin/dconf-editor
  sudo chmod 750 /usr/bin/dconf-editor
  sudo chown root:sudo /usr/bin/gnome-tweaks
  sudo chmod 750 /usr/bin/gnome-tweaks
}

function unlock-all-settings-apps {
  echo -e "= Unlocks all settings-apps =\n\n"

  # Enable access to settings app for non-admin users
  sudo chown root:sudo /usr/bin/gnome-control-center
  sudo chmod 755 /usr/bin/gnome-control-center
  sudo chown root:sudo /usr/bin/dconf-editor
  sudo chmod 755 /usr/bin/dconf-editor
  sudo chown root:sudo /usr/bin/gnome-tweaks
  sudo chmod 755 /usr/bin/gnome-tweaks
}

function lock-important-settings-apps {
  echo -e "= Locks important settings-apps =\n\n"

  # Disable access to some settings app for non-admin users
  sudo chown root:sudo /usr/bin/dconf-editor
  sudo chmod 750 /usr/bin/dconf-editor
  sudo chown root:sudo /usr/bin/gnome-tweaks
  sudo chmod 750 /usr/bin/gnome-tweaks
}

function unlock-common-settings-apps {
  echo -e "= Unlocks common settings-apps =\n\n"

  # Enable access to some settings app for non-admin users
  sudo chown root:sudo /usr/bin/dconf-editor
  sudo chmod 755 /usr/bin/dconf-editor
  sudo chown root:sudo /usr/bin/gnome-tweaks
  sudo chmod 755 /usr/bin/gnome-tweaks
}

function install-tweaks {
  echo -e "= Installing tweaks utility into system =\n\n"

  sudo mkdir -p /var/bluesparrow/ubuntutweaks
  sudo mkdir -p /opt/bluesparrow/ubuntutweaks
  sudo git clone -b v1 https://gitlab.com/bluesparrow/ubuntutweaks.git /var/bluesparrow/ubuntutweaks
  sudo touch /etc/profile.d/custom.sh
  sudo chmod +x /etc/profile.d/custom.sh
  if [ -f "/etc/profile.d/custom.sh" ]
  then
    sudo echo -e "\nalias bs-ubuntu-tweaks='sudo bash /var/bluesparrow/ubuntutweaks/run.sh\n'" >> /etc/profile.d/custom.sh
  else
    sudo echo -e "#!/bin/sh\nalias bs-ubuntu-tweaks='sudo bash /var/bluesparrow/ubuntutweaks/run.sh\n'" > /etc/profile.d/custom.sh
  fi
}

function update-tweaks {
  sudo sh -c $'cd /var/bluesparrow/ubuntutweaks; git pull -q origin'
}

function schedule-update-tweaks {
  echo -e "= Schedules tweaks utility weekly update =\n\n"

  if [ -d "/var/bluesparrow/ubuntutweaks" ]
  then
    sudo touch /etc/cron.d/bs-ubuntutweaks-updateself
    echo -e "0 0 * * 1 root bash /var/bluesparrow/ubuntutweaks/run.sh update-self" >> /etc/cron.d/bs-ubuntutweaks-updateself
  else
    echo "Cannot schedule tweaks weekly update due to lack of their persistent installation."
  fi
}

function unschedule-update-tweaks {
  echo -e "= Unschedules tweaks utility weekly update =\n\n"

  sudo rm /etc/cron.d/bs-ubuntutweaks-updateself
}

function uninstall-tweaks {
  echo -e "= Uninstalling tweaks utility from system =\n\n"

  sudo rm -R /var/bluesparrow/ubuntutweaks
  sudo rm -R /opt/bluesparrow/ubuntutweaks
  sudo rm -R /etc/cron.d/bs-ubuntutweaks-updateself
  sudo rm -R /etc/cron.d/bs-ubuntutweaks-updatesoftware
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
    * ) echo -e "Invalid option\n"; reboot-system;;
  esac
}


## Prompt functions

# Handle main run functionality
function main-prompt {
  case "$1" in
    a | active | interactive ) interactive-prompt ;;
    i | install ) shift; install-prompt $* ;;
    c | config | configure ) configure-prompt ;;
    u | update ) update-software ;;
    r | remove ) shift; remove-prompt $* ;;
    su | schedule-update ) schedule-update-software ;;
    usu | unschedule-update ) unschedule-update-software ;;
    is | install-self ) install-tweaks ;;
    us | update-self ) update-tweaks ;;
    rs | remove-self ) uninstall-tweaks ;;
    ps | purge-self ) purge-tweaks ;;
    sus | schedule-update-self ) schedule-update-self ;;
    usus | unschedule-update-self ) unchedule-update-self ;;
    h | "-h" | help | "--help" ) print-help ;;
    * ) echo -e "Invalid option!\n\n"; print-help ;;
  esac
  if [[ need_reboot -eq 1 ]]
  then
    reboot-system
    need_reboot=0
  fi
}

function print-help {
  echo "Usage:
    bs-ubuntu-tweaks [command [agrugemnts]]

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
"
}

function print-packages {
  echo "Available packages:
- is, internet-software - Software pack contains most popular internet-browsing software (ex. MS Edge, Chromium, Spotify, Zoom.us)
- os, office-software - Software pack contains popular office suites (LibreOffice, WPS Office and TexStudio) and printing drivers
- es, edu-software - Software pack with educational-use applications (like MS Teams)
- cs, creative-software - Software pack contains creative software (like Gimp, Inkscape, LightWorks, OBS and Blender)
- ps, programming-software - Software packs contains the most popular programming languages and IDE-tools (VS Code and Unity3d)
- ose, ose-certyficate - Certyficate for OSE network project
- rs, remote-support - Software pack with Anydesk and TeamViewer remote-support software
- aad[-wc], add-auth[-without-config] - Azure Active Directory support software (with configuration from /opt/bluesparrow/ubuntutweaks/aad.conf as default)
- ui[-wc], ui-mods[-without-config] - User interface modifications pack for gnome-desktop

Available kits (with ui-mods and remote-support + ui-mods):
- ok, office-kit - Software kit for home and office usage (internet-software + office-software + ui-mods)
- sk, student-kit - Software kit for student computers (internet-software + office-software + edu-software + creative-software + programming-software + ose-certyficate + remote-support + ui-mods + limitations)
- tk, teacher-kit - Software kit for teachers computers and students home computers (internet-software + office-software + edu-software + creative-software + programming-software + ose-certyficate + remote-support + ui-mods)
- pk, proffesional-kit - Software kit for proffesional users (internet-software + office-software + creative-software + programming-software + remote-support + ui-mods)
- okaadd[-wc], office-kit-aad[-without-config] - Package office-kit with Azure Active Directory installation
- skaadd[-wc], student-kit-aad[-without-config] - Package student-kit with Azure Active Directory installation
- tkaadd[-wc], teacher-kit-aad[-without-config] - Package teacher-kit with Azure Active Directory installation
- pkaadd[-wc], proffesional-kit-aad[-without-config] - Package proffesional-kit with Azure Active Directory installation

-wc, -without-config suffixes are available only in installation prompt (when removing it no matters)
"
}

function print-config-options {
  echo "Available configuration options:
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
- l, list - Prints this help
"
}

function interactive-prompt {
  if [[ $1 != "no-introduce" ]]
  then
    echo -e "** Type commads of your choice (type exit/bye/quit/end to exit the program) **\n\n"
  fi

  read -p "> " choice
  if [[ choice != "bye" && choice != "exit" && choice != "quit" && choice != "end" ]]
  then
    main-prompt choice
    interactive-prompt no-introduce
  fi
}

function install-prompt {
  install-general-software

  for package
  do
    case "$package" in
      is | internet-software ) install-internet-software ;;
      os | office-software ) install-office-software ;;
      es | edu-software ) install-edu-software ;;
      cs | creative-software ) install-creative-software ;;
      ps | programming-software ) install-programming-software ;;
      ose | ose-certyficate ) install-ose ;;
      rs | remote-support ) install-remote-support ;;
      aad | add-auth ) install-aad; configure-prompt set-aad-settings ;;
      aad-wc | add-auth-without-config ) install-aad ;;
      ui | ui-mods ) install-ui-mods; configure-prompt set-auth-ui-mods; configure-prompt set-auth-logo; configure-prompt set-desktop-ui-mods; configure-prompt set-desktop-background; configure-prompt set-rubik-as-defaultfont ;;
      ui-wc | ui-mods-without-config ) install-ui-mods ;;
      ok | office-kit ) install-internet-software; install-office-software; install-remote-support; install-prompt ui-mods; configure-prompt lock-important-settings-apps ;;
      sk | student-kit ) install-internet-software; install-office-software; install-edu-software; install-creative-software; install-programming-software; install-ose; install-remote-support; install-prompt ui-mods; configure-prompt set-desktop-background-with-lock; configure-prompt lock-all-settings-apps ;;
      tk | teacher-kit ) install-internet-software; install-office-software; install-edu-software; install-creative-software; install-programming-software; install-ose; install-remote-support; install-prompt ui-mods; configure-prompt lock-important-settings-apps ;;
      pk | proffesional-kit ) install-internet-software; install-office-software; install-creative-software; install-programming-software; install-remote-support; install-prompt ui-mods ;;
      okaad | office-kit-aad ) install-prompt office-kit; install-aad ;;
      skaad | student-kit-aad ) install-prompt student-kit; install-aad ;;
      tkaad | teacher-kit-aad ) install-prompt teacher-kit; install-aad ;;
      pkaad | proffesional-kit-aad ) install-prompt proffesional-kit; install-aad ;;
      okaad-wc | office-kit-aad-without-config ) install-internet-software; install-office-software; install-remote-support; install-ui-mods;;
      skaad-wc | student-kit-aad-without-config ) install-internet-software; install-office-software; install-edu-software; install-creative-software; install-programming-software; install-ose; install-remote-support; install-ui-mods;;
      tkaad-wc | teacher-kit-aad-without-config ) install-internet-software; install-office-software; install-edu-software; install-creative-software; install-programming-software; install-ose; install-remote-support; install-ui-mods;;
      pkaad-wc | proffesional-kit-aad-without-config ) install-internet-software; install-office-software; install-creative-software; install-programming-software; install-remote-support; install-ui-mods ;;
      l | list ) print-packages ;;
      * ) echo -e "Invalid option!\n\n"; print-packages ;;
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
    sau | set-auth-ui-mods ) set-auth-ui-settings ;;
    usau | unset-auth-ui-mods ) unset-auth-ui-settings ;;
    sanul | set-auth-nouserslist ) set-auth-nouserslist-settings ;;
    usanul | unset-auth-nouserslist ) unset-auth-nouserslist-settings ;;
    san | set-auth-notice ) set-auth-notice-settings $2 ;;
    usan | unset-auth-notice ) unset-auth-notice-settings ;;
    sal | set-auth-logo ) set-auth-logo-settings ;;
    usal | unset-auth-logo ) unset-auth-logo-settings ;;
    sdu | set-desktop-ui-mods ) set-desktop-ui-settings ;;
    usdu | unset-desktop-ui-mods ) unset-desktop-ui-settings ;;
    sddut | set-desktop-dark-ui-theme ) set-desktop-dark-ui-settings ;;
    usddut | unset-desktop-dark-ui-theme ) unset-desktop-dark-ui-settings ;;
    sdlan | set-desktop-left-appnavigation ) set-desktop-left-appnavigation-settings ;;
    usdlan | unset-desktop-left-appnavigation ) unset-desktop-left-appnavigation-settings ;;
    sdb | set-desktop-background ) set-desktop-background-settings no-lock ;;
    sdbl | set-desktop-background-with-lock ) set-desktop-background-settings ;;
    usdb | unset-desktop-background ) unset-desktop-background-settings ;;
    srdf | set-rubik-as-defaultfont ) set-rubik-as-defaultfont-settings ;;
    usrdf | unset-rubik-as-defaultfont ) unset-rubik-as-defaultfont-settings ;;
    sa | set-add-settings ) set-add-settings ;;
    usa | unset-add-settings ) unset-add-settings ;;
    l | list ) print-options ;;
    * ) echo -e "Invalid option!\n\n"; print-packages ;;
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
      ose | ose-certyficate ) uninstall-ose ;;
      rs | remote-support ) uninstall-remote-support ;;
      aad | add-auth ) uninstall-aad; configure-prompt unset-aad-settings ;;
      ui | ui-mods ) uninstall-ui-mods; configure-prompt unset-auth-ui-mods; configure-prompt unset-auth-logo; configure-prompt unset-desktop-ui-mods; configure-prompt unset-desktop-background; configure-prompt unset-rubik-as-defaultfont ;;
      ok | office-kit ) uninstall-internet-software; uninstall-office-software; uninstall-remote-support; uninstall-prompt ui-mods; configure-prompt unlock-all-settings-apps ;;
      sk | student-kit ) uninstall-internet-software; uninstall-office-software; uninstall-edu-software; uninstall-creative-software; uninstall-programming-software; uninstall-ose; uninstall-remote-support; uninstall-prompt ui-mods; configure-prompt unlock-all-settings-apps ;;
      tk | teacher-kit ) uninstall-internet-software; uninstall-office-software; uninstall-edu-software; uninstall-creative-software; uninstall-programming-software; uninstall-ose; uninstall-remote-support; uninstall-prompt ui-mods; configure-prompt unlock-all-settings-apps ;;
      pk | proffesional-kit ) uninstall-internet-software; uninstall-office-software; uninstall-creative-software; uninstall-programming-software; uninstall-remote-support; uninstall-prompt ui-mods ;;
      okaad | office-kit-aad ) uninstall-prompt office-kit; uninstall-prompt aad ;;
      skaad | student-kit-aad ) uninstall-prompt student-kit; uninstall-prompt aad ;;
      tkaad | teacher-kit-aad ) uninstall-prompt teacher-kit; uninstall-prompt aad ;;
      pkaad | proffesional-kit-aad ) uninstall-prompt proffesional-kit; uuninstall-prompt aad ;;
      l | list ) print-packages ;;
      * ) echo -e "Invalid option!\n\n"; print-packages ;;
    esac
  done
}


echo -e "=== BlueSparrow UbuntuTweaks ===\n\n\n"
main-prompt $*
echo -e "\n\nBye!\n"

reboot-system
