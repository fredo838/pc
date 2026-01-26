## Ubuntu installer
# Keyboard "Belgian", variant "Belgian"
# Auto-install nvidia drivers

## Initial
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git gedit curl apt-transport-https ca-certificates gnupg
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