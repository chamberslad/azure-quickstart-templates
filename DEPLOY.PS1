#DEPLOY VNET1
#Remove-AzureRmResourceGroup -Name "AZF-NW-001" -Force
New-AzureRmResourceGroup -Name "AZF-NW-001" -Location "WestEurope" 
New-AzureRmResourceGroupDeployment -Name "ADDS-VN-DEPLOY" -ResourceGroupName "AZF-NW-001" -TemplateFile ".\101-vnet-two-subnets\azuredeploy.json" -TemplateParameterFile ".\101-vnet-two-subnets\azuredeploy.parameters.json" -Verbose

#DEPLOY VNET2
#Remove-AzureRmResourceGroup -Name "AZF-NW-002" -Force
New-AzureRmResourceGroup -Name "AZF-NW-002" -Location "WestEurope" 
New-AzureRmResourceGroupDeployment -Name "ADDS-VN-DEPLOY" -ResourceGroupName "AZF-NW-002" -TemplateFile ".\101-vnet-two-subnets\azuredeploy.json" -TemplateParameterFile ".\101-vnet-two-subnets\azuredeploy.parameters.json" -Verbose

#PEER VNETS
#New-AzureRmResourceGroupDeployment -Name "ADDS-VN-DEPLOY" -ResourceGroupName "AZF-NW-002" -TemplateFile ".\101-vnet-two-subnets\azuredeploy.json" -TemplateParameterFile ".\101-vnet-two-subnets\azuredeploy.parameters.json" -Verbose

#CREATE VM PASSWORD
$secretName = "VM-Password"
$vaultName = "AZ-KV-001"
$secretValue = ConvertTo-SecureString -String 'password' -AsPlainText -Force
Set-AzureKeyVaultSecret `
  -VaultName $vaultName `
  -Name $secretName `
  -SecretValue $secretValue

#ENABLE KV FOR DEPLOYMENT  
Set-AzureRmKeyVaultAccessPolicy -VaultName 'AZ-KV-001' -ResourceGroupName 'AZ-KV-001' -EnabledForDeployment

#create App for disk encryption
$aadClientSecret = "Df9238fF$!£$R!SDAF"
$aadClientSecretSec = ConvertTo-SecureString -String $aadClientSecret -AsPlainText -Force
$azureAdApplication = New-AzureRmADApplication -DisplayName "EncryptApp" -HomePage "https://MyApplicationHomePage" -IdentifierUris "https://MyApplicationUri" -Password $aadClientSecretSec
$servicePrincipal = New-AzureRmADServicePrincipal –ApplicationId $azureAdApplication.ApplicationId
#allow app access to keys
$keyVaultName = 'AZ-KV-001'
$aadClientID = '88258ba1-0c3d-4516-874d-9daa46e36af1'
$rgname = 'AZ-KV-001'
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $aadClientID -PermissionsToKeys 'WrapKey' -PermissionsToSecrets 'Set' -ResourceGroupName $rgname


#DEPLOY HA DCs
#Remove-AzureRmResourceGroup -Name "AZF-RG-001" -Force
New-AzureRmResourceGroup -Name "AZ-DC-001" -Location "WestEurope" 

#ENCRYPT VM DISK
$vmName = 'DC01';
$vmrgName = "AZ-DC-001";
$kvrgName = 'AZ-KV-001';
$KeyVaultName = 'AZ-KV-001';
$KeyVault = Get-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $kvrgname;
$diskEncryptionKeyVaultUrl = $KeyVault.VaultUri;
$KeyVaultResourceId = $KeyVault.ResourceId;
Set-AzureRmVMDiskEncryptionExtension -ResourceGroupName $vmrgname -VMName $vmName -DiskEncryptionKeyVaultUrl $diskEncryptionKeyVaultUrl -DiskEncryptionKeyVaultId $KeyVaultResourceId -AadClientID $aadClientID -AadClientSecret $aadClientSecret

#DEPLOY FIREWALL
Remove-AzureRmResourceGroup -Name "AZ-RG-002" -Force
New-AzureRmResourceGroup -Name "AZ-RG-002" -Location "WestEurope" 
New-AzureRmResourceGroupDeployment -Name "ADDS-FW-DEPLOY" -ResourceGroupName "AZ-RG-002" -TemplateFile ".\101-azurefirewall-create\azuredeploy.json" -TemplateParameterFile ".\101-azurefirewall-create\azuredeploy.parameters.json" -Verbose

#DEPLOY KV
#Remove-AzureRmResourceGroup -Name "AZ-KV-001" -Force
New-AzureRmResourceGroup -Name "AZ-KV-001" -Location "WestEurope" 
New-AzureRmResourceGroupDeployment -Name "ADDS-KV-DEPLOY" -ResourceGroupName "AZ-KV-001" -TemplateFile ".\201-key-vault-secret-create\azuredeploy.json" -TemplateParameterFile ".\201-key-vault-secret-create\azuredeploy.parameters.json" -Verbose

#DEPLOY SA
#Remove-AzureRmResourceGroup -Name "AZ-KV-001" -Force
New-AzureRmResourceGroup -Name "AZ-SA-001" -Location "WestEurope" 
New-AzureRmResourceGroupDeployment -Name "ADDS-SA-DEPLOY" -ResourceGroupName "AZ-SA-001" -TemplateFile ".\201-storage-account-service-encryption-create\azuredeploy.json" -TemplateParameterFile ".\201-storage-account-service-encryption-create\azuredeploy.parameters.json" -Verbose
