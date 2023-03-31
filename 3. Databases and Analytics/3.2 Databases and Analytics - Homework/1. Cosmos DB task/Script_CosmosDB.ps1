Connect-AzAccount

$resgr = "su-4-dba-cosDB-rg"
$loc = "westeurope"
$cosmosDBAccName = "su4dbacosdbacc"
$comsmosDBDatabeseName = "su-4-dBa-cosDB-db"
$cosmosDBContainerName = "persondata"

# 1. Create resource group
New-AzResourceGroup -Name $resgr -Location $loc

# 2. Create Azure Cosmos DB's API for MongoDB
New-AzCosmosDBAccount -Name $cosmosDBAccName -ResourceGroupName $resgr -Location $loc -ApiKind MongoDB -ServerVersion 4.0  -Verbose

# 3. Create Azure Cosmos DB's database
New-AzCosmosDBMongoDBDatabase -ResourceGroupName $resgr -AccountName $cosmosDBAccName -Name $comsmosDBDatabeseName -Throughput 400

# 4. Create collection
New-AzCosmosDBMongoDBCollection -ResourceGroupName $resgr `
                                -AccountName $cosmosDBAccName `
                                -DatabaseName $comsmosDBDatabeseName `
                                -Name $cosmosDBContainerName `
                                -Throughput 400

# 5. Clean up
Get-AzResourceGroup $resgr | Remove-AzResourceGroup -Force