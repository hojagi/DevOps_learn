# создание базы данных
sudo -u postgres psql -c "CREATE DATABASE webbooks_db;"
DATA_FILE="/home/vagrnat/apps/webbooks/src/main/resources/data.sql"
sudo -u postgres psql webbooks_db < $DATA_FILE

# перезаписываем стандартный конфиг application.properties
FILE_PATH="/home/vagrnat/apps/webbooks/src/main/resources/application.properties"
NEW_CONTENT="DB.driver=org.postgresql.Driver
DB.url=jdbc:postgresql://localhost:5432/webbooks_db
DB.user=postgres
DB.password=webbooks"
echo -e "$NEW_CONTENT" > "$FILE_PATH"

# сборка приложения
cd /home/vagrnat/apps/webbooks
./mvnw package