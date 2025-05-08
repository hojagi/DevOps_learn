
def call(body) {
    def config= [:]
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()

    pipeline {
        agent any
        
        options {
            buildDiscarder(logRotator(numToKeepStr: '2'))
            disableConcurrentBuilds()
            timestamps()
        }

        environment {
			remoteHost = "${config.remoteHost}"
			remoteUser = "${config.remoteUser}"
			localJarPath = "${config.localJarPath}"
			remoteJarPath = "${config.remoteJarPath}"
        }

        stages {
		    // копируем артефакт сборки снаружи в целевое расположение
            stage('deploy') {
                steps {
                    script {
                        sh "scp -i /var/lib/jenkins/workspace/private_key ${localJarPath} ${remoteUser}@${remoteHost}:${remoteJarPath}"
                        }
                    }              
//				post {
//				    success {
//			    		echo 'Deploy complete'
//                    }
//				}				
            }
            // перезапускаем службу приложения, после замены файла
            stage('run') {
                steps {
                    script {
                        sh "ssh -i /var/lib/jenkins/workspace/private_key ${remoteUser}@${remoteHost} 'sudo systemctl restart webbooks.service'"
                        }
                    }
                }
				
           }
        }
    
}