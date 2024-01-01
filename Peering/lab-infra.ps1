
Clear-Host
#Variables
$rg = read-host "(new) Resource Group Name"
$region = "eastus"
$username = "kodekloud" #username for the VM
$plainPassword = "VMP@55w0rd" #your VM password

#Creating VM credential; use your own password and username by changing the variables if needed
$password = ConvertTo-SecureString $plainPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password);

#Create RG
New-AzResourceGroup -n $rg -l $region

#########-----Create resources---------######

#Creating vnet and VMs
Write-Host "Adding EUS subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"

$eusSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'default' `
  -AddressPrefix 10.0.0.0/24

New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location eastus `
  -Name "eus-vnet" `
  -AddressPrefix 10.0.0.0/16 `
  -Subnet $eusSubnet

Write-Host "Adding WUS subnet configuration" `
-ForegroundColor "Yellow" -BackgroundColor "Black"
$wusSubnet = New-AzVirtualNetworkSubnetConfig `
  -Name 'privateSubnet' `
  -AddressPrefix 192.168.1.0/24

New-AzVirtualNetwork `
  -ResourceGroupName $rg `
  -Location westus `
  -Name "wus-vnet" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $wusSubnet

Write-Host "Creating East US VM" -ForegroundColor "Yellow" -BackgroundColor "Black"
$eusVm = New-AzVM -Name 'eus-prod-server' `
  -ResourceGroupName $rg `
  -Location eastus `
  -Size 'Standard_B1s' `
  -Image Ubuntu Minimal 22.04 LTS `
  -VirtualNetworkName eus-vnet `
  -SubnetName 'default' `
  -Credential $credential `
  -PublicIpAddressName 'eus-vm-pip'

Write-Host "Creating West US VM" -ForegroundColor "Yellow" -BackgroundColor "Black" 
$wusVm = New-AzVM -Name 'wus-prod-server' `
-ResourceGroupName $rg `
-Location westus `
-Image Ubuntu Minimal 22.04 LTS `
-Size 'Standard_B1s' `
-VirtualNetworkName wus-vnet `
-SubnetName 'default' `
-Credential $credential

$fqdn = $eusVm.FullyQualifiedDomainName
Write-Host "East US VM DNS name : $fqdn "
$fqdn = $wusVm.FullyQualifiedDomainName
Write-Host "West US VM DNS name : $fqdn "
