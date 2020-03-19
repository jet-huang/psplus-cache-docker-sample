# psplus-cache-docker-sample
Run PS+ Cache instances with Docker.

## Quick Start
1. Make sure you have "docker" and "docker-compose" installed and configured correctly.
2. Clone this repository.
3. Obtain a copy of:
   - solclient:  
   Download from https://products.solace.com/download/C_API_LINUX64
   - PubSub+ Cache:  
   Contact someone to get PS+ Cache.
4. Edit __template.conf__ in __stuff__, this is an initial configuration from PS+ Cache (1.0.7). Usually you only need to change "Username" and "Password". Please __don't__ modify any string starting with __"TEMPLATE_VAR"__ unless you want to make some changes on "startCache.sh".
5. Edit __instances.sh__ in __stuff__, this is where we set up instance configuration.
   - strSessionApplicationDescriptionPrefix:  
   The prefix of instance description.
   - strSessionApplicationDescriptionSuffix:  
   The suffix of instance description. (I don't use this yet)
   - aSessionHost:  
   A list of Solace broker(s) where instance will connect to. Use " "(SPACE) to separate each host.
   - aSessionVpnName:  
   Paired with "aSessionHost", a list of Message VPN where instance will connect to. Use " "(SPACE) to separate each VPN.
   - aSessionClientName:  
   Paired with "aSessionHost", a list of ClientName used by instance when connect to Solace broker. Use " "(SPACE) to separate each ClientName and use "__"__"(Double Quote) to identify every item.
   - aCacheInstanceName:  
   Paired with "aSessionHost", a list of Cache Instance name used by instance when connect to Solace broker. Use " "(SPACE) to separate each instance name.
   - iInstanceNum:  
   This is calculated from "aSessionHost", no need to change it.
6. Edit __Dockerfile__ in __build__. According to the version of your solclient and PubSub+ Cache then modify SOLCLIENT_VER and SOLACECACHE_VER starting with ENV (declaration of environment variables). Usually you don't need to change anything following.
7. Start the instance(s):
```shell
# Make the physical hostname available to the container. This is optional but may be useful.
export HOST
docker-compose -p poc-solace up --build
```

## Example of __instances.sh__
The attached instances.sh shows:
- There are 2 hosts (10.10.10.51 10.10.10.52) we will connect to. (Thus, 2 instances will be activated)
- First instance with the ClientName (PSCache_prod_cc01-ci01) will connect to 10.10.10.51 on VPN "prod", and being idetified with instance name "cc01-ci01".
- Second instance with the ClientName (PSCache_test01_cc01-ci01) will connect to 10.10.10.52 on VPN "test01", and being idetified with instance name "cc01-ci01".

## Q&A
- Will this hurt performance of PS+ Cache?  
I think so but during the PoC, we can have over 100Kmsgs/sec (@ 1K msg size) and over 1.5Gbps (@ 4K msg size) for single instance which customer is satisfied with. There should be some room for tuning.
- Does this violate the general rule of container usage? (One container should only have one mission)  
We have some discussion on this, customer think it's reasonable to include several instances in one container with the same domain (this means: the same market, they are FSI). But no problem, you can definitely include only one instance per container.
