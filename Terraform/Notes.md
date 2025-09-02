# TERRAFORM:

It is written in the HCL (Hasicorp conf lang) with a .tf extension. It is rewritten in a declarative manner means - it does not run the code but checks the cloud and ensures it has all the resources. 

<br>

**Desired States:**

The state of the resources mentioned in the code file(.tf)

**Current States:**

The state of the current resource in the provider or state of the current resource in the .tfstate file (if it is not in sync with the provider, have to run the terraform plan/refresh)

What terraform tries to do is - it will always try to match Desired State with the Current state:
                          
                    Desired State == Current State

<br>
<br>

<span style="color: #008DB6 ;"> File system:
------------
**.Terraform foulder:**

.terraform folder gets created when we run the `terraform init` to download the plugins needed for the "provider" mentioned in the code. 

<br>

**Terraform.tfstate:**

Terraform creates a `terrafrom.tfstate` file to track what it creates whenever we do `terraform apply`. It checks to terraform.tfstate file to ensure what needs to be added or changed for the previous run. 

It's a way for the terraform to know what it has created.

<br>
<br>

<span style="color: #008DB6;"> CLI
----

**Mani Commands**

- Without running `terraform init`, terraform will not download the plugins to run the code.
- If you are creating the provider for the first time, you must run `terraform init`.
- <span style="color: #B1002B;"> Error: </span> Could not load plugin -Plugin reinitialization required. Please run `terraform init`.

            init               Initialize a Terraform working directory
            plan               Generate and show an execution plan
            apply              Builds or changes infrastructure

- target -  will get the targeted resource to destroy 
   
   ` terraform destroy -traget <total resource_name> `                                       
            
           destroy     ---       Destroy Terraform-managed infrastructure
 

- `terrform Plain` shows terraform apply output without applying                                        
            
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
            output             Read output from a state file
            providers          Prints a tree of the providers used in the configuration
            taint              Manually mark a resource for recreation
            untaint            Manually unmark a resource as tainted
            validate           Validates the Terraform files
            version            Prints the Terraform version
            workspace          Workspace management


<br>

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

<br>
<br>
<br>


<span style="color: #008DB6;">  Providers:
-----------
Terraform creates, manages, and updates infrastructure resources such as physical machines, VMs, network switches, containers, and more. Almost any infrastructure type can be represented as a resource in Terraform.

A provider is responsible for understanding API interactions and exposing resources. Most providers configure a specific infrastructure platform (either cloud or self-hosted). Providers can also offer local utilities for tasks like generating random numbers for unique resource names.
 - To work with the terraform, we need to install the necessary plugins to communicate with the Providers. 
 ```
      CODE.TF   ---------------->   TERRAFORM   <---------------->   Providers   <----------------> SOURCE Providers 
                                                      
                                                      This is the provider outside the 
                                                               terraform that 
                                                             get downloaded when 
               
                                                        run "init" for the first time

```
These providers have different versions as well. The most recent provider will be downloaded during the first ` terraform init`, if the version argument is not specified.

- For production use - you should constrain the acceptable provider version, as a new version can break the existing build. 
                                                                  


<br>

**Syntex:**
```HCL
# resource "<provider>_<resource_type>" "name" {
           #    config options......
           #}
```

```HCL                                                                  
      provider "aws" {
           region  = "us-east-1"
           version = "2.7"
                                                                            
     # How to set the version for the provider
            -- >=1.0          
            -- <=1.0
            -- ~>2.0
            -- >=2.10, <=2.30                                                            
```
- If you download the AWS CLI, you do not need to put the access_key & secret_key 

<br>

**Example1:**

```HCL

       provider "aws" {
           region  = "us-east-1"
           # Note: Use AWS CLI profile or environment variables for credentials
           # access_key = "YOUR_ACCESS_KEY"
           # secret_key = "YOUR_SECRET_KEY"
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

<br>

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
                                               # IP addr of the VCP where the subnet resides. It should take from the VCP (Not yet created VCP from the code about).
       cidr_block = "10.0.1.0/24"

        tags = {
          Name = "Prod_subnet"
        }
      }
```


<br>
<br>




**If You want to deploy in multiple reagions/different accounting:**

Aliers are the way to do for the **diff region**:

```hcl 

provider "aws" {
  region = "us-east-2"
}


provider "aws" {
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

<br>


The way to do for the **diff AWS Accounting**:

```hcl
# After you import the AWS CLI and have the AWS/credentials 

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
            
            
            
provider "aws" {
  region = "us-east-2"
}


provider "aws" {
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


<br>

<br>

**There are two major categories for terraforming providers:**

**HashiCorp Distributed providers:**  
- can be downloaded automatically during terraform init.

<br>

**3rd party Providers:**

- terraform init cannot automatically download providers that HashiCorp does not distribute
- It can happen that the official provider does not support specific functionality.
- Some organizations might have their proprietary platform for which they want to use Terraform.

**How to download the 3rde pary Providers:**

- Third-party providers must be manually installed since terraform init cannot automatically download them.
- Install third-party providers by placing their plugin executables in the user plugins directory.
              

|     OS         |         User Plugins Directory     |
|----------------|------------------------------------|  
|   WIndows      |      %APPDATA%\terraform.d\plugins |
|   other        |         ~/.terraform.d/plugins     |


- Download usimg wget
- created the Dir $ mkdir  ~/.terraform.d/plugins
- move the download file to the folder ~/.terraform.d/plugins
- run $ terrafrom inti

<br>

<br>

<br>

<span style="color: #008DB6;"> Output:
-----------

Output variables can be used to display information about the resources you've created or managed, such as IP addresses, DNS names, or other data that you may need to reference after the infrastructure has been provisioned.

Output variables are declared in your Terraform configuration files using the output keyword. For example:

```HCL
output "<name>"{
 value = <ressource name>.<attribites>  # If you do not specify the attributes, it will give all the attributes of the resource
}
```
Attributes resources we are calling like: 
```
association_id 
domain 
id 
instance_id
network_interface_id 

ETC..
```

An output attribute can also act as an input to other resources being created via terraform. Called cross-account resource:

**Cross-Account resource:**

```hcl
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ec2.id   # which ec2
  allocation_id = aws_eip.eip.id        # which  eip
}
```
**Syntex:**
```hcl
terraform output <attridit>
```

<br>

<br>

<br>

<span style="color: #008DB6;"> Variable:
---------
It is like a central source for the terraform where you put your static values and use them repeatedly.

**variable.tf:**

This is where you set the types of variables you want to input:

```hcl
variable "<name of the varable>" {
    default = <value>
}
```

<br>


**terraform.tfvars:**

          # access_key = "YOUR_ACCESS_KEY"
          # secret_key = "YOUR_SECRET_KEY"
          Subnet_id = "10.0.1.0/24"


```hcl
provider "aws" {
  region  = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

          terraform.tfvars:
          -----------------
          # access_key = "YOUR_ACCESS_KEY"
          # secret_key = "YOUR_SECRET_KEY"
          Subnet_id = "10.0.1.0/24"

```
You can mention in the run as well:
```HCL        
      terraform apply -var "<terraform_resource name> = <Vallue>" # this not apt way
````
If you do not give any input when you run the code and did not mention it in the var file - it will ask for the "enter value."


But in the workplace you don't use either of these methods- terraform will look for the file called - **"terraform.tfvars"**

        <terraform_resource name> = "10.0.100.0/24"


<br>
<br>
<br>


<span style="color: #008DB6 ;"> Data type of variable
---------------------------
The advantage of having the variable is that you specify the type you can enter in the .tfvar file.

| Variable.tf | terraform.tfvar |
|-------------|-----------------|
| variable "instance_name"{  |  instance_name = " munna-123" |
   type = number                   won't let              
   
 
| Types | Description |
|-------------|-----------------|
| string |  text  |
| list | ["0 ","munna","10.0.0.0"] |
| map | {name = "Mabel", age = 52} |
| number | 200 |
   


<br>
<br>
<br>

**Cout Parameter:**

With the count Parameter, we can simply specify the count value and the resource can be scaled accordingly.

```hcl
resource "aws_instance" "Test_terraform" {
   ami           = "ami-00514a528eadbc95b"
   instance_type = "t2.micro"
   Cout = 5    # will give that no.of es2's
   tags = {
     Name = "Terraform"
   }

```
<br>

This creates the 5 ec2 with the same name Terraform. To solve this, we use "**count.index.**"

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
<br>

**Conditional Expression:**

A Conditional Expression uses the value of a **bool** Expression to select one of two values.
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

<br>

**Local Value:**

A local value assigns a name to an expression and allows it to be used to multiply time within a module.


```hcl

locals {
     test = {
         Owner = "DevOps Team"
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
 
<br>

**Terraform Function:**

https://www.terraform.io/docs/configuration/functions.html

The terraform lang includes several built-in functions that you can use to transform and combine value.

The general syntax for function calls is a function name followed by a comma.

**Example:**
  max (5, 12, 9)
  12
  
  
Some do not support the user-defined function, and only the functions built into lang are available.

- Number 
- String
- Collection
- Encoding
- Filesystem 
- Data and time
- Hash and Crypto
- IP network
- Type Conversion

<br>
<br>
<br>

<span style="color: #008DB6 ;">  Data Scorce:
--
You write a separate block of code that will be integrated will the main code.

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
<br>
<br>
<br>

<span style="color: #008DB6 ;">  Debrugging terraform:
--
Terraform has detailed logs, which can be enabled by setting the **Tf_LOG env.** variable to any value.

``` shell
export TF_LOG=true  # will run before the terraform

export TF_LOG_PATH=/tmp/test.log
```


<br>
<br>
<br>

<span style="color: #008DB6 ;">  Terraform Formation:
--
It is an arranging tool that will arrange the line of the code - **fmt**

```shell
terraform fmt <terraform.tf>

```


<br>
<br>
<br>

<span style="color: #008DB6 ;">  Terrafrom Validate:
--
It checks whether the code is syntactically valid. It will check the error.

```shell
terraform valodate

```


<br>
<br>
<br>

<span style="color: #008DB6 ;">  Load Order & Semantics:
--
It is a way to organize the terraform code. You do not need the entire code to be in one file. You can split it into different files will the resources.


Like:

      /.
      /..
      /provider.tf
      /ec2.tf
      /iam_users.tf
      /variable.tf
      /sematics.tf
  
When you run the terraform apply it runs fine.

*** It is the best way to deal with a large infrastructure. And run specific target resources:

```shell      
   Setting Refresh as False:
      
      terraform plan -refresh=false  # stop the refresh when you run the terraform apply
      
    Setting Refresh along with Target flags
      
        terraform plan -target=<resource_full_name>
      
```

<br>
<br>
<br>

<span style="color: #008DB6 ;">  Dynamic block
--
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


<br>
<br>
<br>

<span style="color: #008DB6 ;">  Tainting:
--
The terraform taint command manually marks a Terraform-manged source as tainted, forcing it to be destroyed and recreated on the next apply.

```shell
terraform taint <full_resources_name>

```
By marking the resources trained - terraform will destroy and create that resource again.



**Spalat Experssion**

Split EXperssion allows us to get a list of all the attributes.
 

<br>
<br>
<br>

<span style="color: #008DB6 ;"> Terrafrom Graph
--

- Terrafrom Graph command generates a visual representation of either a conf. Or execution plan.

- The O/P if terraform graph is in the DOT format, which can easily be converted to an image.
 

<br>
<br>
<br>

<span style="color: #008DB6 ;"> Terrafrom Path:
--

It will save the code to a different binary file so that even if you change the code, you can run:

```shell
terrafrom plan <file_name>
terrafrom apply <file_name>
```



<br>
<br>
<br>

<span style="color: #008DB6 ;"> Terrafron Setting:
--
It's a block of code that sit supported that restrict few  versioning:

```
terraform {
  required_version = "< 0.11"
  required_providers {
    aws = "~> 2.0"
  }
}
```

 
<br>
<br>
<br>

<span style="color: #008DB6 ;"> Provisioners:
-----
Provisioners are the block of code that run set on comments in the ec2:

```hcl
provisioner "test" {
    inline = [
        "sudo yum install -y nginx1.12",
        "systemctl services nginx1 start"
    ]
}
```

<br>

**Types of Provisioners**
 - Local Exec
 - Remote-Exec

**Local Exec**

Local-exec provisioners allow us to invoke a local executable after creating the resource.

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

They are only run during creation, not during updating or any other lifecycle.

If a creation time provision fails, the resource is marked as tainted.


**Destroy time provisioners**

They are only run before the resources is destroyed.


```hcl
provisioner "local-exec" {
       when    = destroy
       command = "echo 'Destroy-time provisioner'"
     }
```

**Failuer Bhevior For the provisioners**

Even if the resources are tainted due to the creation time provisioners. We use Failuer Bhevior For the provisioners:

**on_failuer** is used

- Continue - ignore the error and continue with the creation and destruction
- fail - Raise an error and stop applying (the default behavior). If this is a creation provision, taint the resources. (default)


### Module
**DRY Principle:**

DRY (Don't repeat yourself):

Module centralizes the terraform resources and can call out from TF files whenever required.
 
Modules are like variables but outside the different folder.

```hcl
module "<name>" {
      source = "<location path>"
}

```

```hcl
    
    /.
    /..
    /module
      /ec2.tf   #where you ec2 resources is coded
                 resource "aws_instance" "myec2" {
                     ami = "ami-082b5a644766e0e6f"
                     instance_type = t2.micro
                }

    
    
    /.
    /..
    /project.tf 
              module "ec2module" {
                  source = "../../modules/ec2"
              }

```


Integrating the variable to change the resource at will:

```hcl

    /.
    /..
    /variable.tf
          variable "instance_type" {
                default = "t2.large"
          }
          
    /module
      /ec2.tf   #where you ec2 resources is coded
                 resource "aws_instance" "myec2" {
                     ami = "ami-082b5a644766e0e6f"
                     instance_type = var.instance_type
                }

    
    
    /.
    /..
    /project.tf 
              module "ec2module" {
                  source = "../../modules/ec2"
              }


```

### **Terraform Registry**

- The Terraform Registry is a repository of modules the Terraform community writes. 

- The registry can help you get started with Terraform more quickly

Basically, they are the modules in the terraform server:

```hcl
module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"  # How to call the modules from the terraform server 
  version = "2.13.0"      #model in the terraform server has the vesrion.
  # insert the 10 required variables here
}

```


### **Terraform Workspace** 

Terraform allows us to have multiple workspaces. We can have a different set of environment variables associated with each workspaces.

Terraform starts with a single workspace named "default".

This workspace is unique both because it is the default and also because it cannot ever be deleted.


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


When you switch b/w the workspace, you will get the approved instances_type
```

Terraform maintains each workspace terrafrom.tfstate file suppers in the folder terrafrom.tfstate.d


**Git**
Git is where you save the code for centralized purposes. 
it would help if you created the **.gitignor** to not save the file like:

- .terraform
- treeaform.tfstate

But you do not have the terrafrom.tfstate file how to terraform will what is the current state. So we use Remote Backend.

### **Remote Backend**

It is the server where you can save the file you couldn't save in the central repo. Remote Backend can like S3, consul, gus, swift, etc... by adding a file called resource:


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

- It is like a puppet lock file; when two people are running the terraform plan, it will lock the .tfstate file.
- Locking will not work in the Remote Backend option by default. To enable the locking to work with S3, you need to add dynamo DB:

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

- It is essential to keep the state file the same. Instead, make use of terraform state command.

- Multiple sub-commands can be used with terraform state; these include:

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
**pull**  - The terraform state pull command manually downloads and outputs the state from a remote state.

```
terraform state push
```
**push**  - The terraform state push command manually uploads a local state file to a remote state.
 
```
terraform state rm <Resource_name>
```
 **rm (remove)**    
- The terraform state rm command removes items from the Terraform state.
- Items removed from the Terraform state are not physically destroyed. 
- Items removed from the Terraform state are only no longer managed by Terraform
- For example, if you remove an AWS instance from the state, the AWS instance will continue running, but terraform plan will no longer see that instance.


```
Terraform state show <resource_name>
```
 **Show**
- The terraform state show command is used to show the attributes of a single resource in the Terraform state.


### **Terrafrom Import:**
Terraform can import existing infrastructure. This allows you to take resources you've created manually under Terraform management.

```
terraform import <resource_full-name> <id>

# But for this to work you need to have a .tf file written and link that existing manual resource to the written code

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

You do not need to put the access_key & secret_key if you download the AWS CLI. And take the from the AWS credential file. 


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

<br>
<br>
<br>
<br>

<span style="color: #008DB6 ;"> Terraform enterprise vs cloud vs open source:
----- 
https://coggle.it/diagram/X93PG__xpLL4Vk-R/t/terraform-oss-vs-cloud-vs-enterprise



<br>
<br>

**Terraform Enterprise:**

Terraform Enterprise is our self-hosted distribution of Terraform Cloud. It offers enterprises a private instance of the Terraform Cloud application, with no resource limits and with additional enterprise-grade architectural features like audit logging and SAML single sign-on.

Terraform Enterprise adds several features and benefits on top of the open-source Terraform, including:

- Collaboration and governance: It also offers role-based access control, policy enforcement, and approval workflows to maintain governance and compliance across the organization.

- Remote operations: Instead locally, Terraform Enterprise enables users to execute remote operations like 'plan' and 'apply' within a secure, isolated environment. 

- State management: Terraform Enterprise simplifies the management of Terraform state files, providing centralized storage, versioning, and locking. This reduces the risk of data loss, conflicts, and other issues associated with managing state files in a team environment.

- Private module registry: Terraform Enterprise includes a private module registry where you can store, version, and share reusable Terraform modules within your organization. This

<br>
**Sentinel:**




Resource:
---
https://www.youtube.com/watch?v=SLB_c_ayRMo 
