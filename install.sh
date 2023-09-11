#!/bin/bash

echo -e "=== BlueSparrow ===\n\n**Ubuntu Tweaks**\nInstallation...\n\n"

# Change __DIR__ to script root
cd $(dirname $0)

# Upate software list
sudo apt update

# Install software and libs from ubuntu repositories
sudo apt install -y ca-certificates curl gnupg software-properties-common apt-transport-https unzip git snapd openjdk-17-jre openjdk-17-jre libfuse2 libreoffice gimp gimp-data-extras gimp-help-common inkscape inkscape-open-symbols inkscape-tutorials kdenlive blender handbrake filezilla obs-studio codeblocks codeblocks-common codeblocks-contrib codeblocks-dev libcodeblocks0 thonny arduino dconf-cli dconf-editor mc

# Install software from snap
sudo snap install chromium
sudo snap install wps-office
sudo snap install pycharm-community --classic
sudo snap install intellij-idea-community --classic
sudo snap install code --classic
sudo snap install brackets --classic
sudo snap install flutter --classic
sudo snap install kate --classic
sudo snap install krita

# Install NDI with OBS NDI addon
sudo rm -R /tmp/ndi.deb
sudo rm -R /tmp/obs-ndi.deb
wget -qO - https://github.com/obs-ndi/obs-ndi/releases/download/4.11.1/libndi5_5.5.3-1_amd64.deb | sudo tee /tmp/ndi.deb
wget -qO - https://github.com/obs-ndi/obs-ndi/releases/download/4.11.1/obs-ndi-4.11.1-linux-x86_64.deb | sudo tee /tmp/obs-ndi.deb
sudo dpkg -i /tmp/ndi.deb
sudo apt --fix-broken install
sudo dpkg -i /tmp/obs-ndi.deb
sudo apt --fix-broken install -y

# Add MS Edge repository
echo 'deb [signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge.list
sudo wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/microsoft-edge.gpg

# Add Lightworks repository
sudo rm -R /tmp/lightworks.deb
wget -qO - https://app.lwks.com/api/auth/download/lightworks/linux_deb | sudo tee /tmp/lightworks.deb
sudo dpkg -i /tmp/lightworks.deb
sudo apt --fix-broken install -y

# Add TexStudio repository
sudo add-apt-repository -y ppa:sunderme/texstudio

# Add Docker repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Add Anydesk repository
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo tee /etc/apt/trusted.gpg.d/anydesk.asc
echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list

# Install Julialang
curl -fsSL https://install.julialang.org | sh -s -- -y

# Add Unity3D repository and install libssl1.1
wget -qO - https://hub.unity3d.com/linux/keys/public | sudo tee /etc/apt/trusted.gpg.d/unityhub.asc
sudo sh -c 'echo "deb https://hub.unity3d.com/linux/repos/deb stable main" > /etc/apt/sources.list.d/unityhub.list'
#rm -R /tmp/libssl11.deb
#wget -qO - http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1l-1ubuntu1.6_amd64.deb | sudo tee /tmp/libssl11.deb
#sudo dpkg -i /tmp/libssl11.deb

# Install OSE ceryficate
sudo mkdir /tmp/ose;
sudo rm -R /tmp/ose.zip
sudo rm -R /tmp/ose
wget -qO - https://ose.gov.pl/media/2022/09/pliki_linux.zip | sudo tee /tmp/ose.zip
unzip /tmp/ose.zip -d /tmp/ose
sudo /tmp/ose/cert_install/cert_install.sh

# Upate software list
sudo apt update

# Install software from added repositories
sudo apt install -y microsoft-edge-stable texstudio anydesk docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unityhub

# Copy background file
sudo cp bg.jpg /opt/bg.jpg

sudo apt install -y gnome-shell-extensions

sudo mkdir /opt/blur-my-shell;
sudo git clone https://github.com/aunetx/blur-my-shell /opt/blur-my-shell --depth=1
(cd /opt/blur-my-shell; make install)

# Install MacOS-like skin
sudo mkdir /opt/whitesur;
sudo git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git /opt/whitesur --depth=1
(cd /opt/whitesur; sudo ./install.sh -i ubuntu; sudo ./tweaks.sh -f monterey; sudo ./tweaks.sh -g -N -b "/opt/bg.jpg";)

# Install MacOS-like icons
sudo mkdir /opt/whitesur-icons;
sudo git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /opt/whitesur-icons --depth=1
(cd /opt/whitesur-icons; sudo ./install.sh -a;)

# Update software
sudo apt upgrade -y

# Lock Gnome desktop settings and change background
sudo mkdir -p /etc/dconf/profile
sudo sh -c 'echo "user-db:user\nsystem-db:local">/etc/dconf/profile/user'
sudo mkdir -p /etc/dconf/db/local.d/locks
sudo sh -c $'echo "[org/gnome/desktop/background]\n\n# URI to use for the background image\npicture-uri=\'file:///opt/bg.jpg\'\n\n# Specify one of the rendering options for the background image:\npicture-options=\'zoom\'\n\n# Specify the left or top color when drawing gradients, or the solid color\nprimary-color=\'2E405D\'\n\n# Specify the right or bottom color when drawing gradients\nsecondary-color=\'DFEAF7\'\n\n[org/gnome/desktop/screensaver]\n\n# URI to use for the background image\npicture-uri=\'file:///opt/bg.jpg\'\n\n# Specify one of the rendering options for the background image:\npicture-options=\'zoom\'\n\n# Specify the left or top color when drawing gradients, or the solid color\nprimary-color=\'2E405D\'\n\n# Specify the right or bottom color when drawing gradients\nsecondary-color=\'DFEAF7\'\nlogout-enabled=true\nlock-delay=360\n\n[org/gnome/online-accounts]\n\n# Disable gnome online accounts\nwhitelisted-providers=[\'\']\n\n[org/gnome/shell/extensions/dash-to-dock]\n\nextend-height=false\ndock-position=\'BOTTOM\'\nshow-apps-at-top=true\n\n[org/gnome/desktop/interface]\n\ngtk-theme=\'WhiteSur-Light\'\nicon-theme=\'WhiteSur-light\'\n\n[org/gnome/desktop/wm/preferences]\n\ntheme=\'WhiteSur-Light\'">/etc/dconf/db/local.d/00-lockdown'
sudo sh -c $'echo "# Prevent changes to the following keys:\n\n/org/gnome/desktop/background/picture-uri\n/org/gnome/desktop/background/picture-options\n/org/gnome/desktop/background/primary-color\n/org/gnome/desktop/background/secondary-color\n/org/gnome/desktop/screensaver/picture-uri\n/org/gnome/desktop/screensaver/picture-options\n/org/gnome/desktop/screensaver/primary-color\n/org/gnome/desktop/screensaver/secondary-color\n/org/gnome/desktop/screensaver/logout-enabled\n/org/gnome/desktop/screensaver/lock-delay\n/org/gnome/online-accounts/whitelisted-providers\norg/gnome/shell/extensions/dash-to-dock/extend-height\norg/gnome/shell/extensions/dash-to-dock/dock-position\norg/gnome/shell/extensions/dash-to-dock/show-apps-at-top\norg/gnome/desktop/interface/gtk-theme\norg/gnome/desktop/interface/icon-theme\norg/gnome/desktop/wm/preferences/theme">/etc/dconf/db/local.d/locks/lockdown'
sudo dconf update

# Disable access to settings app for non-admin users
sudo chown root:sudo /usr/bin/gnome-control-center
sudo chmod 750 /usr/bin/gnome-control-center
sudo chown root:sudo /usr/bin/dconf-editor
sudo chmod 750 /usr/bin/dconf-editor
sudo chown root:sudo /usr/bin/gnome-tweaks
sudo chmod 750 /usr/bin/gnome-tweaks

echo -e "\n\nDone!\n"
