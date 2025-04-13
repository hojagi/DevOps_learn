#!/bin/bash
# создание локального пользователя webbooks под которым будет запускаться приложение
sudo useradd -m -s /bin/bash -G sudo webbooks
sudo passwd webbooks
sudo chmod -R 777 /home/ivan/2025-02-example

# установка OpenJDK
wget 'https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_linux-x64_bin.tar.gz'
tar -xvf openjdk-17.0.1_linux-x64_bin.tar.gz
sudo mv jdk-17.0.1 /opt/

# установка mvn
wget https://archive.apache.org/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz
tar -xvf apache-maven-3.2.5-bin.tar.gz
sudo mv apache-maven-3.2.5 /opt/

# определяем владельца и права для нового пользователя
sudo chown -R webbooks:webbooks /home/webbooks
sudo chmod -R 777 "/home/webbooks"

# добавляем содержимое в .profile для определения новых переменных
{
    echo "export JAVA_HOME='/opt/jdk-17.0.1'"
    echo 'export PATH="$JAVA_HOME/bin:$PATH"'
    echo "export M2_HOME='/opt/apache-maven-3.2.5'"
    echo 'export PATH="$M2_HOME/bin:$PATH"'
} >> ~/.profile
source /home/ivan/.profile

# установка postgreSQL
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
sudo apt update -y
sudo apt install -y postgresql-12 postgresql-client-12
sudo -u postgres psql -c "alter user postgres with password 'webbooks'";
CONFIG_FILE="/etc/postgresql/12/main/postgresql.conf"
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $CONFIG_FILE
sudo systemctl restart postgresql.service

# создание базы данных
sudo -u postgres psql -c "CREATE DATABASE webbooks_db;"
DATA_FILE="/home/ivan/2025-02-example/apps/webbooks/src/main/resources/data.sql"
sudo -u postgres psql webbooks_db < $DATA_FILE

# перезаписываем стандартный конфиг application.properties
FILE_PATH="/home/ivan/2025-02-example/apps/webbooks/src/main/resources/application.properties"
NEW_CONTENT="DB.driver=org.postgresql.Driver
DB.url=jdbc:postgresql://localhost:5432/webbooks_db
DB.user=postgres
DB.password=webbooks"
echo -e "$NEW_CONTENT" > "$FILE_PATH"

# сборка приложения
cd /home/ivan/2025-02-example/apps/webbooks
./mvnw package
sudo cp -r /home/ivan/2025-02-example /home/webbooks

# создание unit-файла
SERVICE_FILE="/etc/systemd/system/webbooks.service"
cat <<EOL | sudo tee $SERVICE_FILE
[Unit]
Description=Webbooks Java Application
After=network.target

[Service]
ExecStart=/opt/jdk-17.0.1/bin/java -jar /home/webbooks/2025-02-example/apps/webbooks/target/DigitalLibrary-0.0.1-SNAPSHOT.jar
User=webbooks

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl daemon-reload
sudo systemctl start webbooks.service
sudo systemctl enable webbooks.service

# установка и настройка nginx
sudo apt update
sudo apt install -y nginx

sudo mkdir -p /var/www/webdom/html
CONFIG_FILE="/etc/nginx/sites-available/webdom"
cat <<EOL | sudo tee $CONFIG_FILE
server {
    listen 80;
    listen [::]:80;

    root /var/www/webdom/html;
    index index.html index.htm index.nginx-debian.html;
    
    server_name webdom www.webdom.local;

    location / {
        proxy_pass http://127.0.0.1:8080;
    }
}
EOL

sudo ln -s $CONFIG_FILE /etc/nginx/sites-enabled/
sudo systemctl reload nginx

# добавление записи в /etc/hosts
HOSTS_FILE="/etc/hosts"
NEW_LINE="127.0.0.1  localhost webdom www.webdom.local"
sudo sed -i "1s/.*/$NEW_LINE/" "$HOSTS_FILE"