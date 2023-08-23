#!/bin/bash

sudo apt update
sudo apt install -y ca-certificates curl gnupg apt-transport-https unzip snapd openjdk-17-jre openjdk-17-jre libfuse2 libssl1.1 libreoffice gimp gimp-data-extras gimp-help-common inkscape inkscape-open-symbols inkscape-tutorials kdenlive blender handbrake filezilla obs-studio codeblocks codeblocks-common codeblocks-contrib codeblocks-dev libcodeblocks0 thonny arduino dconf-tools

sudo snap install chromium
sudo snap install wps-office
sudo snap install pycharm-community --classic
sudo snap install intellij-idea-community --classic
sudo snap install code --classic
sudo snap install flutter --classic
sudo snap install kate
sudo snap install krita

wget https://github.com/obs-ndi/obs-ndi/releases/download/4.11.1/obs-ndi-4.11.1-linux-x86_64.deb /tmp/obs-ndi.deb
sudo dpkg -i /tmp/obs-ndi.deb
sudo ./ndi.sh

wget https://app.lwks.com/api/auth/download/lightworks/linux_deb /tmp/lightworks.deb
sudo dpkg -i /tmp/lightworks.deb

sudo add-apt-repository ppa:sunderme/texstudio

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | apt-key add -

echo "deb http://deb.anydesk.com/ all main" > /etc/apt/sources.list.d/anydesk-stable.list

curl -fsSL https://install.julialang.org | sh -s -- -y

wget -qO - https://hub.unity3d.com/linux/keys/public | sudo apt-key add -

sudo apt update

sudo apt install -y texstudio anydesk docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin unityhub

#gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
#settings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
#gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED
#gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 64
#gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true
#gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true

#echo -e "extend-height=false\ndock-position=BOTTOM\nunity-backlit-items=true\nshow-apps-at-top=true" >> /usr/share/glib-2.0/schemas/10_ubuntu-dock.gschema.override
#glib-compile-schemas /usr/share/glib-2.0/schemas/

git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git /opt/whitesur --depth=1
(cd /opt/whiteshur; sudo ./install.sh; sudo ./tweaks.sh -f monterey; sudo ./tweaks.sh -g -N -b "bg.jpg";)

git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git /opt/whitesur-icons --depth=1
(cd /opt/whiteshur; sudo ./install.sh -a;)

sudo apt upgrade -y
