#/bin/bash

# For this script to work you must setup your authorized ssh keys on all your remote servers.
# Simple instructions (you many have to 
# Generate your keys with a command like: ssh-keygen -t dsa
# Copy them to your remote servers with scp:
# scp ~/.ssh/id_dsa.pub your_admin_username@yourserver:.ssh/authorized_keys
# be sure to change your_admin_username@yourserver to the your credentials and server name.
# Connect via ssh into your server and go to ~/.ssh
# chown authorized keys with your_admin_username: e.g. sudo chown admin authorized_keys
# sudo chmod 755 authorized_keys

# Script begins here:

username=''
password=''

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 1 AND, IF SO, ASSIGN TO "USERNAME"
if [ "$1" != "" ] && [ "$username" == "" ];then
    username=$1
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 2 AND, IF SO, ASSIGN TO "OLDPASSWORD"
if [ "$2" != "" ] && [ "$password" == "" ];then
    password=$2
fi

# Check all servers using curl to determine web page accessibility

# Assign the array of server names

names=(server1 server2 server 3)

# For testing purposes we can specify only one server if we want
#names=(server1)

# create domain url variable to append to server name
# enter full path including ports and subdirectories to your JBOSS app home page

domainURL="yourdomain:8443/pathToPageIfAny"

badServer=""

for((i=0; i<${#names[*]}; i++))
do
	echo "--------------------------"
	servername=${names[$i]}
	URL=$servername$domainURL
	#echo $URL
	output=`curl -s -0 "/dev/null" $URL`
	#echo "output is: "$output
	if [ -z "$output" ]; then
		echo $servername": JBOSS is down"
		badServer="$badServer $servername"
	else
		echo $servername": OK!"
	fi
done

echo "--------------------------"
printf "\nAll server checks complete..."

if [ -z $badServer ]; then
	printf "\nJBOSS is up and running on all servers!\n"
else
	echo "Servers that are down: "$badServer

	badServerArray=($badServer)

	for((i=0; i<${#badServerArray[*]}; i++))
	do
		badservername=${badServerArray[$i]}
		printf "\nLogging into and attempting to restart JBOSS on: "$badservername"\n"
		ssh $username@$badservername bash -c "'echo $password | sudo -S PUT_YOUR_JBOSS_STOP_COMMAND_HERE;sleep 5;echo $password | sudo -S PUT_YOUR_JBOSS_START_COMMAND_HERE;logout;'"
		printf "\njboss on server: "$badservername" restarted\n"
		printf "\nLogging out of "$badservername"\n"
	done
fi
exit 0;
