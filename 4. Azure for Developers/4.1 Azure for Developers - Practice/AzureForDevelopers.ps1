# Part 1 Container instance
#
Connect-AzAccount

$resgr = "su-5-afd-cont-rg"
$loc = "westeurope"
$contname = "su5afdcontainer"
$imagename = "shekeriev/aze-image-1"

New-AzResourceGroup -name $resgr -Location $loc

New-AzContainerGroup -Name $contname -ResourceGroupName $resgr -Location $loc -Image $imagename -DnsNameLabel $contname `
                    -Port 80 -Cpu 1 -MemoryInGB 0.5 -OsType Linux -IpAddressType Public

Get-AzContainerGroup -ResourceGroupName $resgr -Name $contname | Select-Object IpAddress, Fqdn

Get-AzContainerInstanceLog -ResourceGroupName $resgrs -Name $contname -ContainerGroupName $contname

Get-AzResourceGroup $resgr | Remove-AzResourceGroup -Force

#
# Part 2 Container image
#
docker build . -t aze-image-2
docker images
docker run -d -p 8080:80 aze-image-2
docker stop aze-image-2

$resgr = "su-5-afd-contim-rg"
$registname = "su5afdcontim"
$contname = "su5afdcontinst"
$imagename = "su5afdcontim.azurecr.io/aze-image-2:v1"
$logserv = "su5afdcontim.azurecr.io"

New-AzResourceGroup -name $resgr -Location $loc

New-AzContainerRegistry -ResourceGroupName $resgr -Location $loc -Name $registname -Sku Basic -EnableAdminUser true

docker tag aze-image-2 su5afdcontim.azurecr.io/aze-image-2:v1

Connect-AzContainerRegistry -Name $registname

docker push $imagename

Get-AzContainerRegistryRepository -RegistryName $registname | Format-Table

Get-AzContainerRegistryTag -Name $registname -RepositoryName aze-image-2  | Format-Table

New-AzContainerGroup -Name $contname -ResourceGroupName $resgr -Location $loc -Image $imagename `
    -DnsNameLabel $contname -RegistryCredential "" `
    -RegistryServerDomain $logserv `
-Port 80 -Cpu 1 -MemoryInGB 0.5 -OsType Linux -IpAddressType Public

Get-AzResourceGroup $resgr | Remove-AzResourceGroup -Force

#
# Part 3 Azure App Services
#
$resgr = "su-5-afd-webapp-rg"
$loc = "westeurope"
$webappname = "su5afdwebapp"
$appservplan = "Windows-WebApp-Plan"

New-AzResourceGroup -ResourceGroupName $resgr -Location $loc

New-AzAppServicePlan -ResourceGroupName $resgr -Location $loc -Name $appservplan -Tier Basic -HyperV

New-AzWebApp -ResourceGroupName $resgr -Location $loc -Name $webappname -AppServicePlan $appservplan

Get-AzWebApp -ResourceGroupName $resgr -Name $webappname | Format-Table

Get-AzResourceGroup $resgr | Remove-AzResourceGroup -Force
