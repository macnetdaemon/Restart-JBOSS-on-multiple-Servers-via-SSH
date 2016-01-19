# Restart-JBOSS-on-multiple-Servers-via-SSH
This script can be used to detect if JBOSS is not running or is running but not properly rendering the home webpage. It will then attempt to connect to the server(s) jboss is running on and restart the service.

The script is dependent on the user preparing the remote service with their ssh authorized_keys and knowing the command(s) to stop and restart the jboss service running on their remote server(s).

You can also use the script to execute a number of commands on a remote server or servers.
