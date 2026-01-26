sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git
# bookmarks for firefox
# 'saved passwords'
git config --global user.email "fredo.bode@gmail.com"
git config --global user.name "Frederik Bode"
ssh-keygen -t ed25519 -C "fredo.bode@gmail.com" -f ~/.ssh/id_ed25519_personal

# add this in github.com
cat ~/.ssh/id_ed25519_personal.pub

ssh-add ~/.ssh/id_ed25519_personal

