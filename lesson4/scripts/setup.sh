# установка OpenJDK
wget 'https://download.java.net/java/GA/jdk17.0.1/2a2082e5a09d4267845be086888add4f/12/GPL/openjdk-17.0.1_linux-x64_bin.tar.gz'
tar -xvf openjdk-17.0.1_linux-x64_bin.tar.gz
sudo mv jdk-17.0.1 /opt/

# установка mvn
wget https://archive.apache.org/dist/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz
tar -xvf apache-maven-3.2.5-bin.tar.gz
sudo mv apache-maven-3.2.5 /opt/

# установка postgreSQL
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
sudo apt update -y
sudo apt install -y postgresql-12 postgresql-client-12
sudo -u postgres psql -c "alter user postgres with password 'webbooks'";
CONFIG_FILE="/etc/postgresql/12/main/postgresql.conf"
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $CONFIG_FILE
sudo systemctl restart postgresql.service

# добавляем содержимое в .profile для определения новых переменных
{
    echo "export JAVA_HOME='/opt/jdk-17.0.1'"
    echo 'export PATH="$JAVA_HOME/bin:$PATH"'
    echo "export M2_HOME='/opt/apache-maven-3.2.5'"
    echo 'export PATH="$M2_HOME/bin:$PATH"'
} >> ~/.profile