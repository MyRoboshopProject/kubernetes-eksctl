#!/bin/bash
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
USERID=$(id -u)

LOGSDIR=/tmp
# /home/centos/shellscript-logs/script-name-date.log
SCRIPT_NAME=$(basename "$0")
LOGFILE=$LOGSDIR/$SCRIPT_NAME-$DATE.log

echo -e "$Y This script runs on CentOS 8 $N"

if [[ "$USERID" -ne 0 ]];
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ];
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

yum install -y yum-utils &>>$LOGFILE

VALIDATE $? "yum-utils package installed"

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &>>$LOGFILE

VALIDATE $? "Docker Repo added"

yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y &>>$LOGFILE

VALIDATE $? "Docker components are installed"

systemctl start docker &>>$LOGFILE

VALIDATE $? "Docker Started"

systemctl enable docker &>>$LOGFILE

VALIDATE $? "Docker Enabled"

usermod -aG docker centos &>>$LOGFILE

VALIDATE $? "centos user added to docker group"

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
VALIDATE $? "Downloaded eksctl command"
chmod +x /tmp/eksctl
VALIDATE $?  "Added execute permissions to eksctl"
mv /tmp/eksctl /usr/local/bin
VALIDATE $? "moved eksctl to bin folder"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

VALIDATE $? "kubectl installed"

git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

VALIDATE $? "kubens Installation"


echo -e "$R Please logout and login again $N"