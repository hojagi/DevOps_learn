#!/bin/bash

JENKINS_USER=jenkins
JENKINS_PASS=password
JENKINS_USER_HOME=/home/$JENKINS_USER
HOSTS=( appserver )

if [ "$HOSTNAME" == 'jenkins' ]; then
    # copy private-key
    mkdir -p /home/vagrant/.ssh/
    cp /vagrant/keys/jenkins_id_rsa /home/vagrant/.ssh/
    chown vagrant:vagrant /home/vagrant/.ssh/jenkins_id_rsa
    chmod 400 /home/vagrant/.ssh/jenkins_id_rsa

    # install OpenJDK
    apt update && apt install -y fontconfig openjdk-17-jre

    # install jenkins
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y jenkins

    systemctl start jenkins
    systemctl enable jenkins
fi


if [[ ${HOSTS[*]} =~ $HOSTNAME ]]; then
    useradd -p "$(openssl passwd -6 $JENKINS_PASS)" --shell "/bin/bash" $JENKINS_USER
    usermod -aG sudo $JENKINS_USER
    mkdir -p $JENKINS_USER_HOME/.ssh/
    cat /vagrant/keys/jenkins_id_rsa.pub >> $JENKINS_USER_HOME/.ssh/authorized_keys
fi
