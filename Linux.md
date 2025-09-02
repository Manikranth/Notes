Linux:
----------

```
id                                                                    ## [show user’s group]
```

```
sudo –l                                                              ## [list the sudo permissions]
```
```
df –h
```
```
grep --color=always  <word>
grep --after-context=5 --before-context=10 <word> <file>
```
```
shutdown -r now
```
```
chmod +x ~/myscript.sh                              
````
```
sudo chown <userID> -R <folder>                                      ## [change the owner of the folder]
sudo chgrp <userID> -R <folder>                                      ## [change the group of the folder]
sudo chmod -R 0777 <file/folder>                                     ##  [To Give total permission]
```
```
cat mytext.txt > newfile.txt                                         ## copy the out put of the cat commend to the file
cat mytext.txt >> another-text-file.txt                              ## Append/Add text to the file 
```

```
rpm -qa | grep <s/w name>	     	                                     ##[to find the available software]
```
```
sudo mco ping -I <server_name>
```
```
sudo su - fdx_3748658						                                     ## [switch user]
```
```
ps –ef | grep 	          				                                   ##    [running servers]
	root@05a4de56ba5c:/# apt-get install procps
```
```
sudo /etc/init.d/clo ud-elmo stop		                                 ##	 [stop elmo services]
```                                  
```
sudo –u <User> <command> 			                                      ##  [use command as the user]
```

```
ps –fu cloudsvc
```
```
sudo -u cloudsvc /opt/fedex/cloud/pla*/current/bin/status_platform_service
```
```
sudo /usr/sbin/alternatives --config java
```
```
ubuntu@ip-172-31-52-90:~$ which mvn
/usr/bin/mvn
```

```
ubuntu@ip-172-31-52-90:~$ readlink -f /usr/bin/mvn
/usr/share/maven/bin/mvn
````

For any command to run from any where that file should be in /usr/bin
