# Cloud server provisioning and hardening 

####  IMPORTANT: Target development and deployment server is <span style="color:maroon"> Ubuntu 20.04 x86_64 </span>. Scripts will not work on any other environment.

### <span style="color:maroon">Pre-requisites</span>
1. You have Linux/Macbook desktop/server for development environment.
2. You have installed ansible and terraform.
3. LXD is installed on your PC. (**OPTIONAL** - Only if you provision using LXD.)
4. You have go lang environment setup. (**OPTIONAL** - Only if you provision using LXD.)

Confirm your installation/environment as shown below.
```
rohitv@da09 ➜  ~ uname -a
Linux da09 5.4.0-40-generic #44-Ubuntu SMP Tue Jun 23 00:01:04 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux

rohitv@da09 ➜  ~ ansible --version                                                         
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/home/rohitv/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.2 (default, Apr 27 2020, 15:53:34) [GCC 9.3.0]

rohitv@da09 ➜  ~ terraform version  
Terraform v0.12.28

rohitv@da09 ➜  ~ go version
go version go1.14.2 linux/amd64
rohitv@da09 ➜  ~ 


```

### <span style="color:maroon">terraform</span>
This folder contains terraform scripts for 2 providers. Before setting up cloud server on Hetzner or any other provider, it is highly recommended to experiment locally on your PC using lxd which is host level containerization software offered by Canonical. This will be very low overhead and extremely fast host level virtualization platform ( LXD is best place to start without incurring any cloud provider cost). Feel free to skip if you would rather go straight to Hetzner cloud. 

#### Terraform provision will consist of 4 commands for all types of providers.

```
# This will automatically download terraform dependencies to execute your plan.
# terraform lxd provider is manually installed (See the steps below under LXD section)
terraform init 

# Dry run of resources that will be created if applied
terraform plan

# Execute plan
terraform apply

# To remove all resources for a given provider
terraform destroy 

```

## Provision using Hetzner provider (Change server type/image inside hetzner.tf file)
#### NOTE: Create API token from Hetzner website
#### Hetzner token are provided by environment variable so keep it safe (TF_VAR_ automatically passed to terraform variables, htoken variable is used to authenticate)
export TF_VAR_htoken=******************

```
rohitv@da09 ➜  hz-cpx11 pwd
/home/rohitv/Bitbucket/cloudsetup/terraform/hz-cpx11
rohitv@da09 ➜  hz-cpx11 terraform init
rohitv@da09 ➜  hz-cpx11 terraform plan
rohitv@da09 ➜  hz-cpx11 terraform apply

# Note down IP address and update your hosts file in this folder, so that ansible script can refer to it.
# Update [hz_automated] section inside your hosts file to actual IP address

```

## Provision using LXD Provider

On ubuntu lxd can be installed with
```
rohitv@da09 ➜  ~ sudo apt install lxd
Reading package lists... Done
Building dependency tree       
Reading state information... Done
lxd is already the newest version (1:0.9).
0 to upgrade, 0 to newly install, 0 to remove and 0 not to upgrade.
rohitv@da09 ➜  ~ 

```

```
# Confirm if you have lxc installed properly and 
rohitv@da09 ➜  lxc version  
Client version: 4.0.2
Server version: 4.0.2
rohitv@da09 ➜  
```

```
# configure lxd init and specify bridge CIDR and storage pool, here is the settings for my PC.

rohitv@da09 ➜  ~ lxd init --dump
config: {}
networks:
- config:
    ipv4.address: 192.168.10.1/24
    ipv4.nat: "true"
    ipv6.address: none
  description: ""
  name: lxdbr0
  type: bridge
storage_pools:
- config:
    size: 30GB
    source: /var/snap/lxd/common/lxd/disks/default.img
    zfs.pool_name: default
  description: ""
  name: default
  driver: zfs
profiles:
- config: {}
  description: Default LXD profile
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
```


```
# Now provision lxd resources
# cd to cloudsetup/terraform/lxd
rohitv@da09 ➜  lxd pwd
/home/rohitv/Bitbucket/cloudsetup/terraform/lxd
rohitv@da09 ➜  terraform init
rohitv@da09 ➜  terraform plan
rohitv@da09 ➜  terraform apply

# If all goes well, you will see 4 lxd containers provision using your bridge CIDR ip address
rohitv@da09 ➜  ~ lxc list
+------+---------+----------------------+------+-----------+-----------+
| NAME |  STATE  |         IPV4         | IPV6 |   TYPE    | SNAPSHOTS |
+------+---------+----------------------+------+-----------+-----------+
| lxd1 | RUNNING | 192.168.10.56 (eth0) |      | CONTAINER | 0         |
+------+---------+----------------------+------+-----------+-----------+
| lxd2 | RUNNING | 192.168.10.30 (eth0) |      | CONTAINER | 0         |
+------+---------+----------------------+------+-----------+-----------+
| lxd3 | RUNNING | 192.168.10.12 (eth0) |      | CONTAINER | 0         |
+------+---------+----------------------+------+-----------+-----------+
| lxd4 | RUNNING | 192.168.10.37 (eth0) |      | CONTAINER | 0         |
+------+---------+----------------------+------+-----------+-----------+

# Now it is a good idea to update your /etc/hosts to update ip address (Change as per yours)
192.168.10.56 lxd1
192.168.10.30 lxd2
192.168.10.12 lxd3
192.168.10.37 lxd4

# From now on you can use standard ansible scripts to install any packages etc you want.

```





### <span style="color:maroon">ansible</span>
This folder contains scripts required to be run **AFTER** provisioning the servers.

