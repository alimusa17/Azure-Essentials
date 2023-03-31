Connect-AzAccount

$resgr = "su-4-da-sa-rg"
$loc = "West Europe"
$sqlserv = "su4dbaserv"
$dbname = "su4dba-db"
$firerule = "su-4-dba-frule"
$storacc = "su4dbastoracc"
$storcont1 = "su4dbacont"
$storcont2 = "su4dbasacont"
$sajob = "su4dbasaj"

New-AzResourceGroup -Name $resgr -Location $loc

New-AzSqlServer -ResourceGroupName $resgr `
                -Location $loc `
                -ServerName $sqlserv `
                -SqlAdministratorCredentials (Get-Credential) `
                -PublicNetworkAccess Enabled

New-AzSqlServerFirewallRule -ServerName $sqlserv `
                            -ResourceGroupName $resgr `
                            -FirewallRuleName $firerule `
                            -StartIpAddress 77.70.53.108 `
                            -EndIpAddress  77.70.53.108

New-AzSqlDatabase -DatabaseName $dbname `
                -ResourceGroupName $resgr `
                -ServerName $sqlserv `
                -Edition Basic `
                -MinimumCapacity 5

$stacc = New-AzStorageAccount -Name $storacc `
                            -ResourceGroupName $resgr `
                            -Location $loc `
                            -SkuName Standard_LRS `
                            -Kind BlobStorage `
                            -AccessTier Cool

$cont = $stacc.Context
New-AzStorageContainer -Name $storcont1 -Context $cont
New-AzStorageContainer -Name $storcont2 -Context $cont

# New-AzStreamAnalyticsJob -Name $sajob -ResourceGroupName -ResourceGroupName $resgr
Start-AzStreamAnalyticsJob -ResourceGroupName $resgr -Name $sajob
Stop-AzStreamAnalyticsJob -ResourceGroupName $resgr -Name $sajob

Get-AzResourceGroup -Name $resgr | Remove-AzResourceGroup -Force