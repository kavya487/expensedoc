#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT
dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enabling nodejs"
dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nodejs"


id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then 
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "adding expense user"
else
    echo -e "expense user alredy exots  ... $Y skiipping $N"
    fi

mkdir  -p /app &>>$LOG_FILE_NAME
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE  $? "downloading backend"

cd /app
rm -rf /app/*

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip the backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "install dependencies"

cp  /home/ec2-user/expensedoc/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE  $? "installing mysql client"

mysql -h  172.31.1.108 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "setting up transaxtion shema "

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "deamon relosd  "

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "starting bckend "

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE? "enabling backend "