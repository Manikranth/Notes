PUPPET
------------------------------------------------
Puppet users 'facts' as the first step of the puppet to gather inventory date from the agent to masters with key value pairs called "Facts"

**Fact contain** - ip adderss, hostnames, kornal version  and use the info to compalil 'catalog'

**Catalog** - is a drift d/w the expected configration and current version and send back to the agent 

After the rtesiving the catalog from the puppet master, puppet agent will act on the changes imedetally by applying the new configration 


Pupet Building Blocks:
----------------------
**Resources** - are the inbuilt funations that run in the back end to perfrom underlying operations in puppet. - file resources type (services rt to manages servicess and user rt ti manage users)

**Class** - multy samll operation working for the single goel.

**Manifest** - Directory containing puppet DSL files with ".pp (puppet program)" extenction. Puppet program contaion of defination/declareation of puppet class. 

**Modules** - are the collection of files and directorys sudn has - manifest, cless defination. There are the shearable and reuseable like - mySQL , junkies module to manage jankies 


**Example:**
	  
		File.py  ----  Manifest
		#class   ------ class
		class user:
			#functiion  ---- resources
			def cearte_user
			# code here
			end
		end
		Modules - number of sudh file used to manage 
						
						
						
**Resources:**

All operation are happen in puppet are done by the resources. - Files, user, computer, packages, group .... 
There are 3 types 
- core/built-in - Which are perbuilt that shiped with puppet.
- Defined - These are the puppet defined flexbely resourcesn to. 
- custom -  write our own customizes resources type in Rudy.

**System requrments:**
- Has to have the persistent Hoatname 
   - 2cpu /4 ram  for Master 
- No windowes for master 
- Puppet need the port 8140 to open  
- Need time sync

Puppet in EC2:
--------------
Create Ec2 - ports are open on your new EC2 instance:

- 443 — HTTPS
- 8140 — Puppet Enterprise
- 61613 — the Puppet Enterprise orchestration engine (MCollective)

		https://puppet.com/try-puppet/puppet-enterprise/download/

**Master:**


		## hostname maping -----------------
		
		ifconfig -a
		nano /etc/hosts
		     <ip>    <hostname (puppet.munn.com)> puppet
		hostnamectl set-hostname puppet.munna.com
		systemctl status firewalld

		
		
		# installing puppet --------------------
		
		yum install wget
		wget the package for the master 

		rtpm -qpi <package name>     						## if its .rpm
		tar -xzvf puppet-enterprise-2019.8.1-redhatfips-7-x86_64.tar.gz         *##if tar and unpack the tarball

		systemctl status puppet							## status of the puppet
		systemctl start puppet							## start of the puppet

		sudo /opt/puppetlabs/bin/puppetserver ca list --all
		sudo /opt/puppetlabs/bin/puppetserver ca sign <hostname> / --all

		To automate the process the process we can use the "autosign.conf":
			-- autosign.conf   							## path /ect/puppetlabs/puppet/autosign.conf
				<full hostname>
				<*.company.com>
				after the modifing the autosign.conf do not for get to restart the puppet server - systemctl restart puppet

**Agent:**

		wget the package for the  node
		rtpm -qpi <package name>
		nano /etc/puppetlab/puppet/puppet.conf
		     - copy the master hostname under the 
		       [main]
		       server = ip-172-31-31-80.us-east-2.compute.internal 

		Run pupprt agent -t   				##certificate management 



Puppet commends: 
----------------
```
puppet help resource Or puppet resource --help  		## list all actions
puppet resource --types 					## list all resource type 


sudo puppet cert clean <Host name>   				## [remove the agent cerit in master]
sudo puppet cert list <Host name>     				## [list all the unsigned cerit in master]
			         --all 			        ## [to see signed and unsigned]
sudo puppet cert sign <Host name>     				## [sign the agent cerit in master]

puppet cert generate:

puppet cert sing <hostname> 							## sign the cert from the agent 
To automate the process the process we can use the "autosign.conf":
	-- autosign.conf   							## path /ect/puppetlabs/puppet/autosign.conf
		<full hostname>
		<*.company.com>
		after the modifing the autosign.conf do not for get to restart the puppet server - systemctl restart puppet
```


Paths:
--------
```
/var/lib/puppet/ssl/						## All cert related 
/etc/puppetlabs/puppet/ssl/ca/signed				## Signed cert 
/ect/puppetlabs/puppet/puppet.conf				## puppet .conf file
/var/log/ 							## Logs
cat /etc/passwd							## store the used login detailed 
cd var/fedex/cloud/ip/logs/					[ip logs]
cd /var/fedex/mkacct/includes/                      		[To puchtocluster]
cd /var/fedex/cloud/alacarte/data/manifests/               	[manifests]
cd /var/fedex/cloud/platform_service/logs              		[Platform_logs]
cd /var/fedex/cloud/alacarte/logs/			        [alacart_logs]
cat /var/log/puppet/puppet-agent.log  			        [Agent_logs]
cd /var/fedex/cloud/acct/logs/                                	[act_logs]
cd /opt/fedex/cloud/elmo/current/bin/
grep c0011026 /var/fedex/cloud/placement/logs/application*log   [to see that SID and PID of the host that even de’comed]


```

Trouble shooting:
-----------------
if there is already cert in the ssl foulder -" Remove the old cert form the /etc/puppetlabs/puppet/ssl/certs and the run the pupprt agent -t"

