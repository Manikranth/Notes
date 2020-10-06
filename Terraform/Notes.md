# TERRAFORM:
------------
It witten in the ashi corp conf lang with .tf extantion. it rewriten in the declarative mammer means - it do not run the run code but accutally check the cloud (where ever you are creating) and make sure it has all the instancres are persent. 

### Desired & Current States
------------------------
**Desired States:**

The start of the resource menctioned in the code file(.tf)

**Current States:**

The stats of the current resource in the proveder or stats of the current resource in the .tfstate file (if it not in the sync with the proveder have to run the terraform plan/refresh)

Wheat terraform try to do os that it will allways try to match Desired State with Current State:
                          
                          `Desired State == Current State`


### File system:
------------
**.Terraform foulder:**

Terraform foulder is created when you run the terrafrom init so that it download the plugins that are need for the "provider" menctioned in the code. 

**Terraform.tfstate:**

Terraform creates a terrafrom.tfstate file to keep track for itself of what it created whenever terraform apply is run. it checks terraform.tfstate file to make sure what need to be added or changed. 
Bassically it's way for the terraaform to what is that it created.


### CLI
----

**Mani Commands**

- Without running "init" terrafrom will not download the plugins to run the code.
- if you are ruuning the provider for the first time you need to run "terraform init"
- Error: Could not load plugin -Plugin reinitialization required. Please run "terraform init".

            init               Initialize a Terraform working directory
            plan               Generate and show an execution plan
            apply              Builds or changes infrastructure

- Traget -  will get the trageted resource destroy 
   
   ` terraform destroy -traget <total resource_name> `                                       
            
            destroy            Destroy Terraform-managed infrastructure
 

- #it showes terraform apply output without applying                                        
            
            refresh            Update local state file against real resources
            console            Interactive console for Terraform interpolations
            show               Inspect Terraform state or plan
            env                Workspace management
            fmt                Rewrites config files to canonical format
            get                Download and install modules for the configuration
            graph              Create a visual graph of Terraform resources
            import             Import existing infrastructure into Terraform
            login              Obtain and save credentials for a remote host
            logout             Remove locally-stored credentials for a remote host
            output             Read an output from a state file
            providers          Prints a tree of the providers used in the configuration
            taint              Manually mark a resource for recreation
            untaint            Manually unmark a resource as tainted
            validate           Validates the Terraform files
            version            Prints the Terraform version
            workspace          Workspace management

**All other commands:**
        
        0.12upgrade        Rewrites pre-0.12 module source code for v0.12
        0.13upgrade        Rewrites pre-0.13 module source code for v0.13
        debug              Debug output management (experimental)
        force-unlock       Manually unlock the terraform state
        push               Obsolete command for Terraform Enterprise legacy (v1)
        state              Advanced state management
                                                            
**Subcommands:**
        
        list                List resources in the state
        mv                  Move an item in the state
        pull                Pull current state and output to stdout
        push                Update remote state from a local state file
        replace-provider    Replace provider in the state
        rm                  Remove instances from the state
        show                Show a resource in the state

## Providers
-----------
Terraform is used to create, manage, and update infrastructure resources such as physical machines, VMs, network switches, containers, and more. Almost any infrastructure type can be represented as a resource in Terraform.

A provider is responsible for understanding API interactions and exposing resources. Most providers configure a specific infrastructure platform (either cloud or self-hosted). Providers can also offer local utilities for tasks like generating random numbers for unique resource names.
 - To work with the terraform we need to install the nessary plugins to communate with the Providers. 
 ```
      CODE.TF   ---------------->   TERRAFORM   <---------------->   Providers   <----------------> SOURCE Providers 
                                                      
                                                      This is the provider out side the 
                                                               terraform that 
                                                             get downloaded when 
                                                        run "init" for the forst time

```
These providers have different vsersion as well, if version argument is not specified, the most recent provder will be downloded duting the first "init". 
 For production use - you should constrain the acceptable provider version, as a new version can brack the existing biuld. 
                                                                  
if you download the AWS CLI you do not need to put the access_key & secret_key 

**Formate**
```HCL
# resource "<provider>_<resource_type>" "name" {
           #    config options......
           #}
```

```HCL                                                                  
      provider "aws" {
           region  = "us-east-1"
           version = "2.7"
                                                                            
     # How to set the vsersion for the provider
            -- >=1.0          
            -- <=1.0
            -- ~>2.0
            -- >=2.10, <=2.30                                                            
```



**Exapmle:**

```HCL

       provider "aws" {
           region  = "us-east-1"
           access_key = "AKIAIQALPXYK5CCNX2IA"
           secret_key = "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"
           }

            resource "aws_instance" "Test_terraform" {
                   ami = "ami-00514a528eadbc95b"
                   instance_type = "t2.micro"
                   tags = {
                        Name = "Terraform"
                          }
            }

              
              resource "aws_instance" "Test_terraformtwo" {
                     ami = "ami-00514a528eadbc95b"
                     instance_type = "t2.micro"
                     tags = {
                          Name = "Terraform - 2"
                            }
             }
```

**Example:2**

**AWS_VPC**
```HCL

      resource "aws_vpc" "terraformvcp" {
        cidr_block = "10.0.0.0/16"  # ip addr from the VPC
        tags = {
          Name = "Prod-VPC"      
          }
      }

      resource "aws_subnet" "terraformsubnet" {
        vpc_id     = aws_vpc.terraformvcp.id    #vpc_id     = <resource>.<resource_name in the terraqform>.id
                                               # IP addr of the VCP where the subnet reside in. as it should have to take from the VCP (Not yet created VCP from the acode about).
       cidr_block = "10.0.1.0/24"

        tags = {
          Name = "Prod_subnet"
        }
      }
```

There are two major categories for terraform providers:

**HashiCorp Distributed providers** - can be downloaded automatically during terraform init.

### If You want to deploy in multiply reagions/ differnt accounting:

Aliers are the way to do for the **diff region**:

```hcl 

povider "aws" {
  region = "us-east-2"
}


povider "aws" {
  alias = "N.verg"
  region = "us-east-1"
}

                        resource "aws_ip" "test" {
                           VPC = "true"
                        }

                        resource "aws_ip" "test2" {
                           VPC = "true"
                           provider = "aws.N.verg"
                        }


```


The way to do for the **diff AWS Accounting**:

```hcl
# After you inport the AWS CLI and the have the AWS/credenials 

/.
/..
/.aws
    > /.
      /..
      /credenials
            [default]
            aws_access_key_id = skgfkwshflwhekaewgrlgh
            aws_secret_access_key = kewrghkwerhelhrglegrhliqhirhuweiqhweriulhqweilruhgliquh
            
                        
            [aoount02]
            aws_access_key_id = skjhlrtghlaerhgliehgliue
            aws_secret_access_key = kjalrhtlwehrtglhlwkshjgklwjehrglkwhglrwhrsjhyksegdfrkerwggh
            
            
            
povider "aws" {
  region = "us-east-2"
}


povider "aws" {
  alias = "N.verg"
  region = "us-east-1"
  profile = "account02"
}

                      resource "aws_ip" "test" {
                         VPC = "true"
                      }

                      resource "aws_ip" "test2" {
                         VPC = "true"
                         provider = "aws.N.verg"
                      }

```



### 3rde pary Providers:
---------------------
- terraform init cannot automatically download providers that are not distributed by HashiCorp
- It can happen that the official provider does not support specific functionality.
- Some organizations might have their proprietary platform for which they want to use Terraform.

**How to download the 3rde pary Providers:**

- Third-party providers must be manually installed, since terraform init cannot automatically download them.
- Install third-party providers by placing their plugin executables in the user plugins directory.
              

|     OS         |         User Plugins Directory     |
|----------------|------------------------------------|  
|   WIndows      |      %APPDATA%\terraform.d\plugins |
|   other        |         ~/.terraform.d/plugins     |


- Download usimg wget
- created the Dir $ mkdir  ~/.terraform.d/plugins
- move the dowload file to the foulder  ~/.terraform.d/plugins
- run $ terrafrom inti


### Output
-----------
Will give you the desired traget that you sepcifi when you run the "terraform apply" or "terrafrom output" after the terraform apply. 

```HCL
output "<name>"{
 value = <ressource name>.<attribites>  # If you do not specife the attribites it will give all the attribites of the ressource
}
```
Attribites mean the attribites of the ressource we are calling. like: 
```
association_id 
domain 
id 
instance_id
network_interface_id 

ETC..
```

An outputed attributes can also cak as a input to other resources being created via terraform. called cross-account resource:

**Cross-Account rescource**

```hcl
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ec2.id   # which ec2
  allocation_id = aws_eip.eip.id        # which  eip
}
```

```hcl
terrafrom output <attridit>
```


### variable:
---------
is like a central scource for the terraform where you put you static values and user repetablitaly.\

**varable.tf:**
this i waher you set the types of the varable you want to input:

```hcl
varable "<name of the varable>" {
    defult = <value>
}
```

}                                                         

**terraform.tfvars:**

          access_key = "AKIAIQALPXYK5CCNX2IA"
          secret_key = "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"
          Subnet_id = "10.0.1.0/24"


```hcl
provider "aws" {
  region  = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

          terraform.tfvars:
          -----------------
          access_key = "AKIAIQALPXYK5CCNX2IA"
          secret_key = "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"
          Subnet_id = "10.0.1.0/24"

```
You can mention in the rum as well:
```HCL        
        > terraform apply -var "<terraform_resource name> = <Vallue>" # this not apt way
````
if you do not give any input when you run the code and did not mention in the var file - basscally it wil ask for the "enter value".


But in the workplace you don't use the either of this methods- terraform looks for the file called - **"terraform.tfvars"**
                                                                                                        `<terraform_resource name> = "10.0.100.0/24"`

### **Data type of variable:**
---------------------------
The advantageof have the varable is that, you specfice the type you can enter in the .tfvar file

| Variable.tf | terraform.tfvar |
|-------------|-----------------|
| varible "instance_name"{  |  instance_name = " munna-123" |
   type = number                   won't let              
   
 
| Types | Description |
|-------------|-----------------|
| string |  text  |
| list | ["0 ","munna","10.0.0.0"] |
| map | {name = "mabel", age = 52} |
| number | 200 |
   
   
### **Cout Perameter:**

With count Perameter, we can simply specify the count value and the resource can be scaled accordingly.

```hcl
resource "aws_instance" "Test_terraform" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   Cout = 5    # will give that no.of es2's
   tags = {
     Name = "Terraform"
   }

```

This create the 5 ec2 with the same name Terraform to slove this we use **counf.index**
**Count Index:**
 
 ```hcl
 resource "aws_instance" "Test_terraform" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   count = 2
   tags = {
     Name = "Terraform.${count.index}"
   }
   }
```


```hcl 
variable "test"{
   type = list
   default = ["dev-lb","stage-lb","prod.ld"]
}

 resource "aws_instance" "Test_terraform" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   count = 2
   tags = {
     Name = var.test[count.index]
   }

```

### **Conditional Expression:**

A Conditional Expression users the value of a **bool** Expression to select one of two valuse.
```
Conditional ? ture_val : false-val
```
```hcl
variable "test" {}

 resource "aws_instance" "dev" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   count = var.test == ture ? 1 : 0
 }


 resource "aws_instance" "prod" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.large"
    count = var.test == false ? 1 : 0
 }
 ```

### **Local Value**

A local value assigns a name to an expersion, and allows it to be used multiply time within a midule.


```hcl

locals {
     test = {
         Owner = "Devops Team"
         service = "backend"
     }
 }


 resource "aws_instance" "prod" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   
   tags = local.test

 }

 resource "aws_instance" "dev" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   
   tags = local.test

 }


 resource "aws_ebs_volume" "ebs" {
   availability_zone = "us-east-1a"
   tags = local.test 
 }
 
 ```
 
 
### **Terraform Function**

https://www.terraform.io/docs/configuration/functions.html

The terraform lang include a number of built-in-funations that you can use to tranform amd combained valuse.

the general syntax for function calls is a function name followed by comma.

**Exapmle:**
  max (5, 12, 9)
  12
  
  
There are do not suppprt the used-defined function, and only the functions built in to lang are aviable for use.

- Number 
- String
- Collection
- Encoding
- Filesystem 
- Data and time
- Hash and Crypto
- IP network
- Type Conversion

### Data Scorce

You wite a supprate block of code that will be intreaated will the main code.

```hcl
Data source code:
-----------------
data "aws_ami" "app_ami" {
  most_recent = true
  owners = ["amazon"]


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}



resource "aws_instance" "instance-1" {
    ami = data.aws_ami.app_ami.id        
   instance_type = "t2.micro"
}

```

**Debrugging terraform:**
Therraform has detailde loogs which can be emabled by settinmg the **Tf_LOG env.** variable to any value.

```shell
export TF_LOG=true  # will run before the terraform

export TF_LOG_PATH=/tmp/test.log
```


**Terraform Formation**

It is an aranging tool that will aragen the line of the code - **fmt**

```shell
terraform fmt <terraform.tf>

```

**Terrafrom Validate**
It check weither the code is cyntactically valid. Basically it will check the error.

```shell
terraform valodate

```


**Load Order & Semantics**

It way to orgrizine the terrafrom code. baccically you do not need the enatir code to be in the one single fiem you can split in to different files will the resources.


Like:

      /.
      /..
      /provider.tf
      /ec2.tf
      /iam_users.tf
      /variable.tf
      /sematics.tf
  
When you run the terrafrom aplly it run fine.

*** It is best wasy to use when dealing with the large infrasturecter. and run a specifi traget ressources:

```shell      
   Setting Refresh as False:
      
      terraform plan -refresh=false  # stop the refresh when you run the terraform apply
      
    Setting Refresh along with Target flags
      
        terraform plan -target=<resource_full_name>
      
```

**Dynamic Block**

```hcl

variable "sg_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [8200, 8201,8300, 9200, 9500]
}

resource "aws_security_group" "dynamicsg" {
  name        = "dynamic-sg"
  description = "Ingress for Vault"

  dynamic "ingress" {
    for_each = var.sg_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.sg_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

```


**Tainting:**

The terraform taint command manually marks a Terraform-manged rrsource as tainted, forcing it to be destoyed and recreated on the next apply.

```shell
terraform taint <full_resources_name>

```
By marking the resources tained - terraform will destory and create that rescource again.



**Spalat EXperssion**

Spalat EXperssion allow us to get a list of all the attributes.
 

**Terrafrom Graph**

- Terrafrom Graph command is used to generate a visual representation of either a conf. or execution plan.

- The O/P if terraform graph is in the DOT format, which can can easily be converted to an image.
 

**Terrafrom Path**

It will save the code to a differnt dinaery file so that even you change the code you can sinply run:

```shell
terrafrom plan <file_name>
terrafrom apply <file_name>
```



**Terrafron Setting**

It's a block of code that sit suppertely that resterct few  versioning:

```
terraform {
  required_version = "< 0.11"
  required_providers {
    aws = "~> 2.0"
  }
}
```

 
### **Provisioners:

Provisioners are the bolck of code that run set on commants in the ec2;

```hcl
provisioner "test" {
    inline = [
        "sudo yum install -y nginx1.12",
        "systemctl services nginx1 start"
    ]
}

```
**Types of Provisioners**
 - Local Exec
 - Remote-Exec

**Local Exec**

Local-exec provisioners allow us to invoke a local executable after the resource is created.

```hcl
provisioner "local-exec" {
    command = "echo ${aws_instance.web.private_ip} >> private_ips.txt"
  }

```

One of the most used approaches of local-exec is to run ansible-playbooks on the created server after the resource is created.


**Remote-Exe**

Remote-exec provisioners allow invoking scripts directly on the remote server.

```hcl
resource "aws_instance" "terraform_ec2" {
  ami           = "ami-0dba2cb6798deb6d8"
  instance_type = "t2.micro"
  key_name = "Terraform"

    provisioner "remote-exec" {
        inline = [
            "sudo yum install -y nginx1.12",
            "systemctl start nginx1"
        ]
    }

    connection {
        type = "ssh"
        user = "ec2-user"
        private_key = file("./Terraform.pem")
        host = self.public_ip
    }
}

```

**creation time provisioners**

They are only run during creation, not during updarting or any other lifecycle.

If a creation time provisioners fails, the resecources is marker as tainted.


**Destory time provisioners**

They are only run before the rescources is destoyed.


```hcl
provisioner "local-exec" {
       when    = destroy
       command = "echo 'Destory-time provisioner'"
     }
```

**Failuer Bhevior For the provisioners**

Even if you the resources is tained due to the creation time provisioners. we use Failuer Bhevior For the provisioners:

**on_failuer** is userd

- Continue - ignore the error and continue with the creation and destruction
- fail - Raise an error and stop applying (the default brhaior). If this is a creation provisioners, taint the resources. (defulate)


### Module
**DRY Principle:**

DRY (Don't repeat youself):

Module are the centralize the terraform resources and can call out from TF files whenever required.
 
Modles are like varilables but outside the different foulder

```hcl
module "<name>" {
      source = "<location path>"
}

```

```hcl
    /.
    /..
    /module
      /ec2.tf   #where you ec2 resournes is coded
                 resource "aws_instance" "myec2" {
                     ami = "ami-082b5a644766e0e6f"
                     instance_type = t2.micro
                }

    
    
    /.
    /..
    /projest.tf 
              module "ec2module" {
                  source = "../../modules/ec2"
              }

```


Intergrating the varriable to change the resecource at will:

```hvl

    /.
    /..
    /varilable.tf
          varilable "instance_type" {
                defult = "t2.large"
          }
          
    /module
      /ec2.tf   #where you ec2 resournes is coded
                 resource "aws_instance" "myec2" {
                     ami = "ami-082b5a644766e0e6f"
                     instance_type = var.instance_type
                }

    
    
    /.
    /..
    /projest.tf 
              module "ec2module" {
                  source = "../../modules/ec2"
              }


```

### **Terraform Registry**

- The Terraform Registry is a repository of modules written by the Terraform community. 

- The registry can help you get started with Terraform more quickly

Basically therte are the mobules in the terraform server:

```hcl
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"  # How to call the modules from the terraform server 
  version = "2.13.0"      #model in the terraform server has the vesrion.
  # insert the 10 required variables here
}

```


### **Terraform Workspace** 

Terraform allows us to have multiple workspaces, with each of the workspaces we can have a different set of environment variables associated

Terraform starts with a single workspace named "default".

This workspace is special both because it is the default and also because it cannot ever be deleted.


```shell

terraform workspace

CLI:

  new 
  list 
  show  - show the current 
  select - switch b/w the workspace
  delete - Terraform workspaces.

```

```hcl
resource "aws_instance" "myec2" {
   ami = "ami-082b5a644766e0e6f"
   instance_type = lookup(var.instance_type,terraform.workspace)
}

variable "instance_type" {
  type = "map"

  default = {
    default = "t2.nano"
    dev     = "t2.micro"
    prd     = "t2.large"
  }
}


when you switch b/w the workspace you will get the approited instances_type
```

Terraform maintain the eash workspace terrafrom.tfstate file supperstly in the folder terrafrom.tfstate.d


**Git**
Git is where you save the code for the centeralzise persposess. 
you should create the **.gitignor** to not save the file like:

- .terraform
- treeaform.tfstate

But you do not have the terrafrom.tfstate file how to terraform will what is the current state. So we use Remote Backend

### **Remote Backend**

It is the server where you can save the file which you couldn't save in the central repo. Remote Backend can like S3, consul, gus, swift etc... by adding a file called resource:


```
terraform {
  backend "s3"{
    bucker = ""
    key = "xxxxx.tfstate"
    region = "US-EAST-1A"
    access_key = "aeraethevb waereartaqRT"
    secret_key = "sdfgsdfhdgfhdfgshsha"
  }
}

```

- Standard BackEnd Type:    State Storage and Locking
- Enhanced BackEnd Type:  All features of Standard + Remote Management



### **State file Locking**

- It like puppet lock file where when 2 people are running the terraform plan it will lock the .tfstate file.
- Locking will not work in the Remote Backend option by defult. To enavble the locking to work with S3 you need to add dynamoDB:

```
terraform {
  backend "s3"{
    bucker = ""
    key = "xxxxx.tfstate"
    region = "US-EAST-1A"
    access_key = "aeraethevb waereartaqRT"
    secret_key = "sdfgsdfhdgfhdfgshsha"
    dynamoDB = "table_name"
  }
}

```


### **Terraform State Management:** 

- As your Terraform usage becomes more advanced, there are some cases where you may need to modify the Terraform state.

- It is important to never modify the state file directly. Instead, make use of terraform state command.

- There are multiple sub-commands that can be used with terraform state, these include:

**Sub-commends:**
 
```
terraform state list
```
**List** - all the resources-full-name
      
```
terraform state mv <existing_name> <new_name>
```
**mv**   - you want to rename an existing resource without destroying and recreating it.

```
terraform state pull
```
**pull**  - The terraform state pull command is used to manually download and output the state from a remote state.

```
terraform state push
```
**push**  - The terraform state push command is used to manually upload a local state file to remote state.
 
```
terraform state rm <Resource_name>
```
 **rm (remove)**    
- The terraform state rm command is used to remove items from the Terraform state.
- Items removed from the Terraform state are not physically destroyed. 
- Items removed from the Terraform state are only no longer managed by Terraform
- For example, if you remove an AWS instance from the state, the AWS instance will continue running, but terraform plan will no longer see that instance.


```
terraform state show <resource_name>
```
 **Show**
- The terraform state show command is used to show the attributes of a single resource in the Terraform state.


### **Terrafrom Import:**
Terraform is able to import existing infrastructure. This allows you to take resources you've created manually under Terraform management.

```
terraform import <resource_full-name> <id>

# But to this to work you need to have a .tf file written and link that existing manual resource to the written code

resource "aws_instance" "Test_terraformtwo" {
  ami           = "ami-00514a528eadbc95b"
   instance_type = "<manual_ec2_type>"
   tags = {
     Name = "<manual_ec2_name>"
   }
   }
# add all the variables that are needed then you can link and import that resource to the .tfstart file
```



### **Handling Access & Secret Keys the Right Way in Providers**

If you download the AWS CLI you do not need to put the access_key & secret_key. And take the from the AWS credintonal file. 


```
/.
/..
/.aws
    > /.
      /..
      /credenials
            [default]
            aws_access_key_id = skgfkwshflwhekaewgrlgh
            aws_secret_access_key = kewrghkwerhelhrglegrhliqhirhuweiqhweriulhqweilruhgliquh
            
                        
            [aoount02]
            aws_access_key_id = skjhlrtghlaerhgliehgliue
            aws_secret_access_key = kjalrhtlwehrtglhlwkshjgklwjehrglkwhglrwhrsjhyksegdfrkerwggh
            
```








Resource:
---
https://www.youtube.com/watch?v=SLB_c_ayRMo 
