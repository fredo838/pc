# Ubuntu installer
# Keyboard "Belgian", variant "Belgian"

# initial
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git gedit

# configure git + github
git config --global user.email "fredo.bode@gmail.com"
git config --global user.name "Frederik Bode"
ssh-keygen -t ed25519 -C "fredo.bode@gmail.com" -f ~/.ssh/id_ed25519_personal
ssh-add ~/.ssh/id_ed25519_personal
# add this in github.com
cat ~/.ssh/id_ed25519_personal.pub


# VSCode:
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install code

# Mozilla 
# Login to account
# Extensions:
#   ClearURLs
#   Privacy Badger
#   uBlock Origin
# about:config in address bar, then identity.fxaccounts.toolbar.pxiToolbarEnabled > Toggle (all OFF)