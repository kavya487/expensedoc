#!\bin\bash\
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"

LOGS_FOLDER="/var/logs/expenselogs.sh"
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

dnf install mysql-server -y
validate $? "installing mysql server" &>>$LOG_FILE_NAME

systemctl enable mysqld
validate $? "enabling mysql server" &>>$LOG_FILE_NAME

systemctl start mysqld
validate $? "starting mysql server" &>>$LOG_FILE_NAME

mysql_secure_installation --set-root-pass ExpenseApp@1
validate $? "setting up root password" &>>$LOG_FILE_NAME