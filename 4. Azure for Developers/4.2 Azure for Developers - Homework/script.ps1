vConnect-AzAccount

$resgr = "su-5-afd-db-rg"
$resgrFunc = "su-5-afd-func-rg"
$loc = "West Europe"
$sqlserv = "su5afdsqlserv"
$dbname = "su5afd-db"
$firerule = "allowip"
$storacc = "su5afdstoracc"
$appPlan = "su5afdappplan"

# 1. Create resource group
New-AzResourceGroup -Name $resgr -Location $loc

# 2. Creating database server
New-AzSqlServer -ResourceGroupName $resgr `
                -Location $loc `
                -ServerName $sqlserv `
                -SqlAdministratorCredentials (Get-Credential) `
                -PublicNetworkAccess Enabled

# 3. Configuring firewall
New-AzSqlServerFirewallRule -ServerName $sqlserv `
                            -ResourceGroupName $resgr `
                            -FirewallRuleName $firerule `
                            -StartIpAddress **.**.**.*** `
                            -EndIpAddress  **.**.**.***

# 4. Create one database
New-AzSqlDatabase -DatabaseName $dbname `
                -ResourceGroupName $resgr `
                -ServerName $sqlserv `
                -Edition Basic `
                -MinimumCapacity 5

# 5. Create another resource group
New-AzResourceGroup -Name $resgrFunc -Location $loc

# 6. Create storage account
$stacc = New-AzStorageAccount -Name $storacc `
                            -ResourceGroupName $resgrFunc `
                            -Location $loc `
                            -SkuName Standard_LRS `
                            -Kind BlobStorage `
                            -AccessTier Cool
$cont = $stacc.Context
New-AzStorageContainer -Name $storcont -Context $cont

# 7. Create App Service plans
New-AzAppServicePlan -Name $appPlan -ResourceGroupName $resgrFunc -Location $loc -Tier Basic -HyperV 

# 9. Create functionapp from portal 
# 9.1. From portal -> Function App -> Add set: resource group, subscription, Publish->Code, runtime stack, version, Region
# 9.2. On Hosting tab set: Operating System -> Windows, App plan
# 9.3. Create
# 9.4. Create a HTTP triggered function: Overview -> Add 
# 9.5. on Code + Test copy and paste "function.cs" 
# 9.6. copy Get function URL  and paste into browser and add &name=Name at the end in the URL

# 10. Cleanning resource
Get-AzResourceGroup -Name "su-5-afd*" | Remove-AzResourceGroup -Force
Get-AzResourceGroup -Name "Default*" | Remove-AzResourceGroup -Force