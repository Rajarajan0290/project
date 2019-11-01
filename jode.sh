#/bin/bash
rm -f $LOG
LOG=/tmp/jode.log
HOME=/home/centos/
rm -rf $HOME/node-hello
#curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo  bash - &>>$LOG
Head() {
    echo -e " \n -----  $1   ------ \n" >>$LOG
    echo -e "\n\t\t\e[1;36m<<\e[4m $1 \e[0m\e[1;36m>>\e[0m"
}

Task_Print() {
    echo -e " \n -----  $1   ------ \n" >>$LOG
    echo -n -e "    $1 =\t"
}

Stat() {
    if [ $1 -eq 0 ]; then 
        echo -e "\e[1;32mSUCCESS\e[0m"
    else 
        echo -e "\e[1;31mFAILURE\e[0m"
        echo "Check the log file :: $LOG fore more information"
        exit 1
    fi
}
## Check whether the script is executed as root user or not 
USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then 
    echo "You should be running this script as root user or with sudo command"
    exit 1
fi 

Head "Nodejs"
Task_Print "Install Nodejs\t\t\t\t"
yum install nodejs -y &>>$LOG 
Stat $?

Head "Git"
Task_Print "Install Git\t\t\t\t"
yum install git -y &>>$LOG 
Stat $?

Task_Print "Download project from GITHUB\t\t"
cd $HOME
sudo git clone https://github.com/opsworkshop/node-hello.git
Stat $?

# Need to move app.js from home folder, because adding systemd setting. so customized the  configuration in app.js file
Task_Print "Move app.js file"
cd $HOME
if [  -f app.js ] ;then
    sudo mv app.js $HOME/node-hello/app.js
    stat 0
else
    echo -e "\e[33m app.js not found\e[0m" &>>$LOG
    Stat $?
fi

#If Newly creating EC2 IP, need to change in app.js file
Head "checking Public_ip.txt"
Task_Print "changing the ips in app.js"

cd $HOME
if [  -f public_ips.txt ] ;then
    Public_ip=`cat public_ips.txt`
    sed -i -e "s/\${hostname}/$Public_ip/g ;s/\${port}/8000/g" /home/centos/node-hello/app.js &>>$LOG
    stat 0
else
 echo -e "\e[33m Public_ip.txt file not found\e[0m" &>>$LOG
    Stat $?
    
fi

#Converting NODEJS as systemd
Head "checking app.services  "
Task_Print "Move to system folder "
cd $HOME

if [  -f app.service ] ;then
    Public_ip=`cat public_ips.txt`
    sudo mv $HOME/app.service /lib/systemd/system/app.service
    stat 0 
else
    echo -e "\e[33m app.service file not found\e[0m" &>>$LOG
    Stat $?
fi

Task_Print "Export Environment variable & start the services"
export NODE_PORT=8001 
sudo systemctl daemon-reload   &>>$LOG
sudo systemctl start app    &>>$LOG
 stat 0

echo -e "\e[33m   console.log(Server running at http://$Public_ip:8001/) \e[0m"
