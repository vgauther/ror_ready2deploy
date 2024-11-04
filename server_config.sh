#!/bin/bash

# Définition des couleurs
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # Pas de couleur

# Fonction pour afficher un titre
function print_title {
  echo -e "${CYAN}=============================="
  echo -e "$1"
  echo -e "==============================${NC}"
}

# Mise à jour des paquets
print_title "${GREEN}Mise à jour des paquets${NC}"
sudo apt update

# Installation des paquets nécessaires
print_title "${GREEN}Installation des paquets${NC}"
sudo apt install -y curl git-core postgresql postgresql-contrib libpq-dev nodejs yarn nginx gnupg zsh

# Installation de Certbot pour le SSL avec Nginx
print_title "${GREEN}Installation de Certbot et de Certbot Nginx${NC}"
sudo apt install -y certbot python3-certbot-nginx

print_title "${GREEN}Précision du localhost${NC}"
echo "127.0.1.1   debian" | tee -a /etc/hosts > /dev/null
echo "127.0.0.1   debian" | tee -a /etc/hosts > /dev/null

print_title "${GREEN}Installation de RVM${NC}"

gpg --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/deploy/.rvm/scripts/rvm

print_title "${GREEN}Installation de Ruby 3.2.2${NC}"

rvm install 3.2.2
rvm use 3.2.2 --default

print_title "${GREEN}gem install bundler${NC}"

gem install bundler

print_title "${GREEN}ssh-keygen${NC}"
ssh-keygen -t rsa -b 4096

# Fin du script
echo -e "${YELLOW}Installation terminée !${NC}"
