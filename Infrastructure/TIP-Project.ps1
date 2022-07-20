# Importing Variables
. ..\variable\TIPvariables.ps1
 
# creating azure resource group
az group create `
    -g $rgName `
    -l $location `
    --tags `
    evironment=$envsuffix `
    creator="Ewuji John"

# creating virtual network
az network vnet create `
    -n "$rPrefix-vnet" `
    -l $location `
    -g $rgName

# creating virtual network subnets (Default, VM & DB)
az network vnet subnet create `
    -g $rgName `
    --vnet-name "$rPrefix-vnet" `
    -n $subnet1 `
    --address-prefixes $("$ipPrefix.0.0/24")

az network vnet subnet create `
    -g $rgName `
    --vnet-name "$rPrefix-vnet" `
    -n $subnet2 `
    --address-prefixes $("$ipPrefix.1.0/24")

az network vnet subnet create `
    -g $rgName `
    --vnet-name "$rPrefix-vnet" `
    -n $subnet3 `
    --address-prefixes $("$ipPrefix.2.0/24")

#enabling service endpoint
az network vnet subnet update `
    --resource-group  $rgName `
    --vnet-name "$rPrefix-vnet" `
    --name $subnet1 `
    --service-endpoints "Microsoft.Storage"

az network vnet subnet update `
    --resource-group  $rgName `
    --vnet-name "$rPrefix-vnet" `
    --name $subnet2 `
    --service-endpoints "Microsoft.Storage"

# Creating a network nsg
az network nsg create `
    -g $rgName `
    -n "$rgName-nsg" `
    --tags `
    environment=$envsuffix

# Associating nsg to a virtual network subnet
az network vnet subnet update `
    -g $rgName `
    -n $subnet1 `
    --vnet-name "$rprefix-vnet" `
    --network-security-group "$rgName-nsg"

az network vnet subnet update `
    -g $rgName `
    -n $subnet2 `
    --vnet-name "$rprefix-vnet" `
    --network-security-group "$rgName-nsg"

az network vnet subnet update `
    -g $rgName `
    -n $subnet3 `
    --vnet-name "$rprefix-vnet" `
    --network-security-group "$rgName-nsg"


# Creating a network nsg rule to subnets
az network nsg rule create `
    -g $rgName `
    --nsg-name "$rgName-nsg" `
    -n "nsg-$subnet2" `
    --direction inbound `
    --destination-address-prefix $("$ipPrefix.1.0/24")`
    --destination-port-range "80" "443"`
    --access allow `
    --priority "100"

# Creating a winRM nsg inbound rule to vm and FTPserver
az network nsg rule create `
    -g $rgName `
    --nsg-name "$rgName-nsg" `
    -n "Port_5986" `
    --direction inbound `
    --destination-address-prefix $("$ipPrefix.1.0/24") $("$ipPrefix.3.0/24")`
    --destination-port-range "5986"`
    --protocol "TCP" `
    --access allow `
    --priority "140" 

# Creating a winRM nsg inbound rule to subnets
az network nsg rule create `
    -g $rgName `
    --nsg-name "$rgName-nsg" `
    -n "Port_5985" `
    --direction inbound `
    --destination-address-prefix $("$ipPrefix.1.0/24") $("$ipPrefix.3.0/24")`
    --destination-port-range "5985"`
    --protocol "TCP" `
    --access allow `
    --priority "150" 

az network nsg rule create `
    -g $rgName `
    --nsg-name "$rgName-nsg" `
    -n "nsg-$subnet2-$subnet4" `
    --direction inbound `
    --destination-address-prefix $("$ipPrefix.1.0/24") $("$ipPrefix.3.0/24")`
    --destination-port-range "3389" `
    --protocol "Tcp" `
    --access allow `
    --description "allow RDP" `
    --priority "110"

az network nsg rule create `
    -g $rgName `
    --nsg-name "$rgName-nsg" `
    -n "nsg-$subnet3" `
    --direction inbound `
    --destination-address-prefix $("$ipPrefix.2.0/24")`
    --destination-port-range "3306"`
    --access allow `
    --priority "120"

az network nsg rule create `
    -g $rgName `
    --nsg-name "$rgName-nsg" `
    -n "nsg-$subnet4" `
    --direction inbound `
    --destination-address-prefix $("$ipPrefix.3.0/24") `
    --destination-port-range "21" "22"`
    --access allow `
    --priority "130"

az network nsg rule create `
    -g $rgName `
    --nsg-name "$rgName-nsg" `
    -n "Port_80" `
    --direction inbound `
    --destination-address-prefix $("$ipPrefix.1.0/24") $("$ipPrefix.3.0/24")`
    --destination-port-range "80"`
    --protocol "TCP" `
    --access allow `
    --priority "160" 

# Creating a virtual machine (vm)
az vm create `
    --resource-group $rgName `
    --name $myVm `
    --image $vmImage `
    -l $location `
    --vnet-name "$rPrefix-vnet" `
    --subnet $subnet2 `
    --admin-username $adminUser `
    --admin-password $adminPassword `
    --public-ip-sku "Basic" `
    --public-ip-address "IIS-serverPublicIp" `
    --public-ip-address-allocation "dynamic" `
    --size "standard_B1s" `
    --data-disk-sizes-gb "4" `
    --storage-sku "Standard_LRS" `
    --os-disk-size-gb "128" `
    --storage-sku "Standard_LRS" `
    --os-disk-name "IIS-Os-Disk" `
    --public-ip-address-dns-name $publicipDNS 

# Linking vm network interface to the nsg

az network nic update `
    -g $rgName `
    -n $interface `
    --network-security-group "TIP-dev-nsg"

# Enabling vm auto shutdown
az vm auto-shutdown `
    -g $rgName `
    -n $myVm `
    --time "1800" `
    --email $emailAddress

# Creating an SQL Server
az sql server create `
	-n "$rgName-sqlserver" `
    -g $rgName `
	-l $location `
	--admin-user $admin `
    --admin-password $adminPassCode 

# Creating an SQL Database
az sql db create `
	-n "$rgName-sqldatabase" `
    -g $rgName `
    --server "$rgName-sqlserver" `
    --collation "SQL_Latin1_General_CP1_CI_AS" `
    --backup-storage-redundancy "Geo" `
    --tier "Basic" `
	--tags `
   	evironment=$envsuffix `
    creator="TIP Proj"

# Creating a virtual network rule to an sql
az sql server vnet-rule create `
    --server "$rgName-sqlserver" `
    -n "SQLServerVNETRule" `
    -g $rgName `
    --subnet $subnet3 `
    --vnet-name "$rprefix-vnet" `
    --ignore-missing-endpoint "True"

# Creating of the storage account
az storage account create `
  --name $storageacctname `
  --resource-group $rgName `
  -l $location `
  --sku Standard_RAGRS `
  --kind StorageV2 `
  --default-action Allow `
  --bypass "AzureServices" `
  --default-action "deny"

#Creating of file share
az storage share-rm create `
    --resource-group $rgName `
    --storage-account $storageacctname `
    --name "$rPrefix-fileshare" `
    --quota 1024 

#linking storage account to network
az storage account network-rule add `
    -g $rgName `
    --account-name $storageacctname `
    --vnet-name "$rPrefix-vnet" `
    --subnet $subnet1 

az storage account network-rule add `
    -g $rgName `
    --account-name $storageacctname `
    --vnet-name "$rPrefix-vnet" `
    --subnet $subnet2 

# Connecting of storage account to network-rule
az storage account network-rule add `
    -g $rgName `
    --account-name $storageacctname `
    --ip-address  "155.93.95.78" 
