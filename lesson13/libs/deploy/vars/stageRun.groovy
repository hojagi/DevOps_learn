def call(app, value) {
    return {
        stage(app) {
		    dir(value.path) {
			    sh "mvn package -DDB.url=jdbc:postgresql://192.168.56.112:5432/webbooks"
			}
        }
    }
}