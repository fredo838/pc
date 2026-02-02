## Ubuntu installer
# Keyboard "Belgian", variant "Belgian"
# Auto-install nvidia drivers

## Initial
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git gedit curl apt-transport-https ca-certificates gnupg xclip
# check nvidia-smi if GPU is installed


## Git + github
git config --global user.email "fredo.bode@gmail.com"
git config --global user.name "Frederik Bode"
ssh-keygen -t ed25519 -C "fredo.bode@gmail.com" -f ~/.ssh/id_ed25519_personal
ssh-add ~/.ssh/id_ed25519_personal
cat ~/.ssh/id_ed25519_personal.pub # add this in github.com


## GitLab
ssh-keygen -t ed25519 -C "frederik.bode@centrica.com" -f ~/.ssh/id_ed25519_centrica
ssh-add ~/.ssh/id_ed25519_centrica
cat ~/.ssh/id_ed25519_centrica.pub # add this in gitlab


## VSCode:
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install code


# pip for python
sudo apt-get install python3-pip

## Mozilla 
# Login to account
# Extensions:
#   ClearURLs
#   Privacy Badger
#   uBlock Origin
# Set up Profiles
# about:config in address bar, then identity.fxaccounts.toolbar.pxiToolbarEnabled > Toggle (all OFF)

## Outlook 
# Try Hard Refresh

## AWS VPN Client
wget -qO- https://d20adtppz83p9s.cloudfront.net/GTK/latest/debian-repo/awsvpnclient_public_key.asc | sudo tee /etc/apt/trusted.gpg.d/awsvpnclient_public_key.asc
echo "deb [arch=amd64] https://d20adtppz83p9s.cloudfront.net/GTK/latest/debian-repo ubuntu main" | sudo tee /etc/apt/sources.list.d/aws-vpn-client.listecho "deb [arch=amd64] https://d20adtppz83p9s.cloudfront.net/GTK/latest/debian-repo ubuntu main" | sudo tee /etc/apt/sources.list.d/aws-vpn-client.list
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install awsvpnclient

## AWS cli
mkdir awscli
cd awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf ./aws awscliv2.zip

## kubectl 
# CHECK IF YOU ALREADY HAVE IT!
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

## Python config files
# .netrc
touch ~/.netrc
gedit ~/.netrc

# ~/.pip/pip.conf
mkdir ~/.pip
touch ~/.pip/pip.conf
gedit ~/.pip/pip.conf
# [global]
# extra-index-url =
#     https://gitlab.com/api/v4/groups/58977424/-/packages/pypi/simple

# ~/.pypirc
touch ~/.pypirc
gedit ~/.pypirc
# [distutils]
# index-servers =
#     gitlab

# [gitlab]
# repository = https://gitlab.com/api/v4/groups/58977424/-/packages/pypi


## Cycle through windows:
gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'cycle-windows'


## Steam
# Install steam via the "App Center" (no apt :'( unfortunetaly)
# Install the extra 32 bit nvidia drivers
# sudo dpkg --add-architecture i386
# sudo apt update
# sudo apt install libnvidia-gl-590:i386
sudo add-apt-repository multiverse
sudo apt-get update
sudo apt-get install steam

### Install Hearthstone
mkdir ~/.steam/debian-installation/steamapps/common/Hearthstone
# Download Battle-net.exe and add to above folder
mv Battle.net-Setup.exe ~/.steam/debian-installation/steamapps/common/Hearthstone/
# In steam - click 'Add a Game' > 'Add a non Steam Game' > Browse > Selec Folder
# In compatability selet 'Proton Hotfix'


## Zsh
sudo apt update
sudo apt install zsh -y
# Set zsh as default terminal
chsh -s $(which zsh) + LOGOUT/LOGIN

# On mac: set keybindings:
## Slow Terminal after login:
# https://bugs.launchpad.net/ubuntu/+source/nvidia-graphics-drivers-535/+bug/2042301?comments=all

# Remove all Mac's keyboard shortcuts
# It can be you even need to rebind some even though they are not active (wtf?) 
cp .zshrc ~/.zshrc
### Mac:
# load keymap.json in iTerm2 Profile > Keys
# enable "Report keys using CSI u mode"

## Alacritty Terminal
sudo apt-get install npm
npx alacritty-themes
sudo gedit /usr/share/applications/Alacritty.desktop # set StartupNotify=false

## Prefer Dark Mode:
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

## Firefox:
# Set Firefox theme to light mode in Settings

## Golang:
sudo apt update
sudo apt install golang-go --yes

## QBitTorrent
sudo apt install qbittorrent --yes

## VLC
sudo apt install vlc

## Python
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.13 --yes

## Pulumi
curl -fsSL https://get.pulumi.com | sh