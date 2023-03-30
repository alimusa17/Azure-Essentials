$resgr = "su-4-da-db-rg"
$dbservername = "su-4-da-db-srv"
$databesename = "su-4-da-db"

Connect-AzAccount

New-AzResourceGroup -Name $resgr -Location 'West Europe'

Get-Command *azsqlsercer*

Get-Command *azsqldatabase*

Get-AzSqlDatabase -ServerName $dbservername -ResourceGroupName $resgr

Get-AzSqlDatabase -ServerName $dbservername -ResourceGroupName $resgr | Select-Object -Property DatabaseName

New-AzSqlDatabase -DatabaseName $databesename -ResourceGroupName $resgr -ServerName $dbservername -Edition Basic

Get-AzResourceGroup $resgr | Remove-AzResourceGroup -Force
