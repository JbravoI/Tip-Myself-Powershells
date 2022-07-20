. ..\variable\TIPvariables.ps1

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
    
# az network nsg rule create `
#     -g $rgName `
#     --nsg-name "$rgName-nsg" `
#     -n "nsg-$subnet4" `
#     --direction inbound `
#     --destination-address-prefix $("$ipPrefix.3.0/24")`
#     --destination-port-range "80" "443"`
#     --access allow `
#     --priority "170"  


# az vm start -g john-dev -n IIS-Server
# az vm start -g tip-dev -n TIP-server
#winrm quickconfig  (for enabling winrm)

# az storage account network-rule add `
# -g john-dev `
# --account-name johnsa `
# --ip-address 197.210.45.121 155.93.95.78 

# az storage account update `
#     --name $storageacctname `
#     -g $rgName `
#     --enable-large-file-share

