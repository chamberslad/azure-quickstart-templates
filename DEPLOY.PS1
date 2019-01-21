#DEPLOY HA DCs
#Remove-AzureRmResourceGroup -Name "PACD-RG-001" -Force
New-AzureRmResourceGroup -Name "PACD-RG-001" -Location "WestEurope" 
New-AzureRmResourceGroupDeployment -Name "ADDS-HA-DEPLOY" -ResourceGroupName "PACD-RG-001" -TemplateFile ".\zz_active-directory-new-domain-ha-2-dc\azuredeploy.json" -TemplateParameterFile ".\zz_active-directory-new-domain-ha-2-dc\azuredeploy.parameters.json" -Verbose

#STOP AZURE DCs
Stop-AzureRmVm -Name "AZ-DC-001" -Force -ResourceGroupName "AZ-RG-001"
Stop-AzureRmVm -Name "AZ-DC-002" -Force -ResourceGroupName "AZ-RG-001"


#DEPLOY FIREWALL
Remove-AzureRmResourceGroup -Name "AZ-RG-002" -Force
New-AzureRmResourceGroup -Name "AZ-RG-002" -Location "WestEurope" 
New-AzureRmResourceGroupDeployment -Name "ADDS-FW-DEPLOY" -ResourceGroupName "AZ-RG-002" -TemplateFile ".\101-azurefirewall-create\azuredeploy.json" -TemplateParameterFile ".\101-azurefirewall-create\azuredeploy.parameters.json" -Verbose
