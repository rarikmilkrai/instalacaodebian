#!/bin/bash

# Instala os repositórios necessários
sudo apt-get update && sudo apt-get install -y wget gnupg2 lsb-release

# Adiciona o repositório do MySQL
wget https://dev.mysql.com/get/mysql-apt-config_0.8.18-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.18-1_all.deb

# Adiciona o repositório do Zabbix 5.4
wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian11_all.deb
sudo dpkg -i zabbix-release_5.4-1+debian11_all.deb

# Atualiza a lista de pacotes
sudo apt-get update

# Instala o MySQL Server
sudo apt-get install -y mysql-server

# Configura o MySQL
sudo mysql_secure_installation

# Cria um usuário e banco de dados para o Zabbix
sudo mysql -uroot -p -e "CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;"
sudo mysql -uroot -p -e "CREATE USER 'zabbix'@'localhost' IDENTIFIED WITH mysql_native_password BY 'zabbix';"
sudo mysql -uroot -p -e "GRANT ALL ON zabbix.* TO 'zabbix'@'localhost';"
sudo mysql -uroot -p -e "FLUSH PRIVILEGES;"

# Instala o Zabbix Server e Frontend
sudo apt-get install -y zabbix-server-mysql zabbix-frontend-php php-mysql libapache2-mod-php vim

# Cria as tabelas do Zabbix no banco de dados
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | sudo mysql -uzabbix -pzabbix zabbix

# Configura o Zabbix Server
sudo sed -i 's/# DBPassword=/DBPassword=zabbix/g' /etc/zabbix/zabbix_server.conf

# Configura o fuso horário do PHP
sudo sed -i "s/;date.timezone =/date.timezone = $(cat /etc/timezone)/g" /etc/php/*/apache2/php.ini

# Configura o PHP para aceitar conexões de até 16MB
sudo sed -i 's/post_max_size =.*/post_max_size = 16M/g' /etc/php/*/apache2/php.ini
sudo sed -i 's/upload_max_filesize =.*/upload_max_filesize = 16M/g' /etc/php/*/apache2/php.ini

# Configura o Apache para usar o Zabbix Frontend
sudo sed -i 's/#\s*php_value date.timezone Europe\/Riga/php_value date.timezone America\/Sao_Paulo/g' /etc/zabbix/apache.conf
sudo a2enconf zabbix.conf
sudo a2enmod ssl

# Reinicia os serviços
sudo systemctl restart apache2 zabbix-server

echo "Instalação concluída com sucesso!"
