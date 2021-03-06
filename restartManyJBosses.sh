#/bin/bash

# For this script to work you must setup your authorized ssh keys on all your remote servers.
# Simple instructions: You many have to generate your keys with a command like: ssh-keygen -t dsa
# If NO authorized_keys file exists in the account home dir/.ssh folder of your remote server:
# 	copy your public key to your remote servers with scp:
# 	scp ~/.ssh/id_dsa.pub your_admin_username@yourserver:.ssh/authorized_keys
# If an authorized keys file already exists on your remote server:
# 	you can copy your public key to the ~/.ssh folder as i.e. mykey.pub
#	scp ~/.ssh/id_dsa.pub your_admin_username@yourserver:.ssh/mykey.pub
#	append mykey.pub to authorized keys with: cat ~/.ssh/mykey.pub >> authorized_keys
# Be sure to change your_admin_username@yourserver to the your credentials and server name.
# You _may_ need to:
# 	Connect via ssh into your server and go to ~/.ssh
# 	Chown the authorized_keys file with your_admin_username: e.g. sudo chown admin authorized_keys
# 	Update the permission: sudo chmod 755 authorized_keys
#
# If you run this on a Macintosh you can hardwire the username and password, the rename the script with the file extension .command in order to make it double-clickable.
#
# The stop and start jboss commands will vary between applications. If you are running a scholastic server it will look something like this:
# sudo launchctl stop com.scholastic.slms.jboss.launchd
#                         and
# sudo launchctl start com.scholastic.slms.jboss.launchd
#
# If you are running a JAMF JSS server it will look like:
# sudo launchctl unload /Library/LaunchDaemons/com.jamfsoftware.tomcat.plist
#                         and
# sudo launchctl load /Library/LaunchDaemons/com.jamfsoftware.tomcat.plist
# --------------------
# Script begins here:

username=''
password=''

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 1 AND, IF SO, ASSIGN TO "USERNAME"
if [ "$1" != "" ] && [ "$username" == "" ];then
    username=$1
fi

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 2 AND, IF SO, ASSIGN TO "PASSWORD"
if [ "$2" != "" ] && [ "$password" == "" ];then
    password=$2
fi

# Assign the array of server names

# CHANGE THE NEXT LINE TO MATCH YOUR SERVERS

names=(server1 server2 server 3)

# For testing purposes we can specify only one server if we want by uncommenting the next line and allowing the script to run on only 1 or selected servers.
#names=(server1)

# create domain url variable to append to server name
# enter full path including ports and subdirectories to your JBOSS app home page
# e.g. domainURL="myserver.123.edu:8443/anyapp/home"

# CHANGE THE NEXT LINE TO MATCH YOUR TOMCAT URL

domainURL="myserver.mydomain:PortNumber/pathToPageIfAny"

badServer=""

# Check all servers using curl to determine web page accessibility

for((i=0; i<${#names[*]}; i++))
do
	echo "--------------------------"
	servername=${names[$i]}
	URL=$servername$domainURL
	output=`curl -s -0 "/dev/null" $URL`
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
# CHANGE THE JBOSS STOP / START COMMANDS ON THE FOLLOWING LINE:
		ssh $username@$badservername bash -c "'echo $password | sudo -S PUT_YOUR_JBOSS_STOP_COMMAND_HERE;sleep 5;echo $password | sudo -S PUT_YOUR_JBOSS_START_COMMAND_HERE;logout;'"
		printf "\nJBOSS on server: "$badservername" restarted\n"
		printf "\nLogging out of "$badservername"\n"
	done
fi
exit 0;
