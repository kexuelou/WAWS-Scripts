Add-AzureAccount
Select-AzureSubscription -SubscriptionId "xxxx"
Switch-AzureMode AzureResourceManager

#List all template in gallery
Get-AzureResourceGroupGalleryTemplate

#Using Filter
Get-AzureResourceGroupGalleryTemplate | Where { $_.Identity -like "*Ubuntu*" }

#List all template published by Microsoft
Get-AzureResourceGroupGalleryTemplate -Publisher Microsoft

#List all VM template published by Microsoft
Get-AzureResourceGroupGalleryTemplate -Publisher Microsoft -Category virtualMachine

#Get a specific template 
Get-AzureResourceGroupGalleryTemplate -Identity Bitnami.LAMPStack560RC30devUbuntu1404.0.2.8-preview

Get-AzureResourceGroupGalleryTemplate -Identity Microsoft.WebSiteSQLDatabase.0.3.15-preview


# | Format-Table Publisher,  ApplicationName, Version, Identity


#save a template
Save-AzureResourceGroupGalleryTemplate -Identity Microsoft.WebSiteSQLDatabase.0.3.15-preview -Path c:\temp\

Get-AzureResourceGroupGalleryTemplate -Identity Microsoft.WebSiteSQLDatabase.0.3.15-preview | Save-AzureResourceGroupGalleryTemplate -Path c:\temp\


#Create a resource from resource group
Get-AzureResourceGroupGalleryTemplate -Identity Microsoft.WebSite.0.3.17-preview | Save-AzureResourceGroupGalleryTemplate -Path c:\temp\

#Create a resource from template
New-AzureResourceGroup –Name WZhaoArmStrong -Location "East US" -GalleryTemplateIdentity Microsoft.WebSite.0.3.17-preview

Remove-AzureResourceGroup -Name WZhaoArmStrong

#Automation Create a resource from template 
Get-AzureResourceGroupGalleryTemplate -Identity Microsoft.WebSite.0.3.17-preview | Save-AzureResourceGroupGalleryTemplate -Path c:\temp\ -Force
$template = Get-Content -Raw -Path c:\temp\Microsoft.WebSite.0.3.17-preview.json | ConvertFrom-Json

$param = @{siteName="WZhaoArmStrong"; hostingPlanName = "WZhaoArmStrong"; siteLocation = "East US"}
 
New-AzureResourceGroup -Name WZhaoArmStrong –Location "East US" -TemplateFile c:\temp\Microsoft.WebSite.0.3.17-preview.json -TemplateParameterObject $param

New-AzureResourceGroupDeployment ` 
-ResourceGroupName TestRG `
-GalleryTemplateIdentity Microsoft.WebSite.0.2.6-preview `
-siteName TestWeb2 `
-hostingPlanName TestDeploy2 `
-siteLocation "North Europe" 


#Operation Log
Get-AzureResourceProviderLog  -ResourceProvider Microsoft.Web -StartTime 2015-06-01T10:30
Get-AzureResourceLog -ResourceId /subscriptions/9017868f-fad6-4da8-9b93-6cd45227d628/resourcegroups/WZhaoArmStrong/providers/Microsoft.Web/sites/wzhaoarmstrong -StartTime 2015-06-02T10:30 -DetailedOutput


#verify the Template
Test-AzureResourceGroupTemplate -ResourceGroupName wzhaowptest002 -TemplateFile C:\Work\TestCode\ARMTemplate\helloworld.json -Debug -verbose


#New an empty resource
New-AzureResourceGroup -Name "wzhao-Helloworld-arm" -Location "South Central US" -Tag @{Name="wzhao-arm-hello-world";Value="TEST"}
## This creates a RG for us to add resources to
New-AzureResourceGroupDeployment -Name "wzhao-DEPLOY-Helloworld-arm" -ResourceGroupName "wzhao-Helloworld-arm" -TemplateFile C:\Work\TestCode\ARMTemplate\helloworld.json

Get-AzureResourceGroup -Name wzhao-Helloworld-arm
Get-AzureResourceGroupDeployment -ResourceGroupName wzhao-Helloworld-arm
Get-AzureResourceGroupLog -ResourceGroup wzhao-Helloworld-arm
Get-AzureResourceLog -ResourceId /subscriptions/9017868f-fad6-4da8-9b93-6cd45227d628/resourceGroups/wzhao-Helloworld-arm

Remove-AzureResourceGroup -Name wzhao-Helloworld-arm


#New a storage
Test-AzureResourceGroupTemplate -ResourceGroupName wzhaowptest002 -TemplateFile C:\Work\TestCode\ARMTemplate\azurestorageinEastAsia.json

New-AzureResourceGroup -Name "wzhao-storage-arm" -Location "South Central US" -Tag @{Name="wzhao-storage-hello-world";Value="TEST"}
## This creates a RG for us to add resources to
New-AzureResourceGroupDeployment -Name "wzhao-DEPLOY-storage-arm" -ResourceGroupName "wzhao-storage-arm" -TemplateFile C:\Work\TestCode\ARMTemplate\azurestorageinEastAsia.json

Get-AzureResourceGroup -Name wzhao-storage-arm
Get-AzureResourceGroupDeployment -ResourceGroupName wzhao-storage-arm
Get-AzureResourceGroupLog -ResourceGroup wzhao-storage-arm
Get-AzureResourceLog -ResourceId /subscriptions/9017868f-fad6-4da8-9b93-6cd45227d628/resourceGroups/wzhao-storage-arm

Remove-AzureResourceGroup -Name wzhao-storage-arm -Force


#New a storage with parameter
Test-AzureResourceGroupTemplate -ResourceGroupName wzhaowptest002 -TemplateFile C:\Work\TestCode\ARMTemplate\azurestorage.json

New-AzureResourceGroup -Name "wzhao-storage-arm" -Location "South Central US" -Tag @{Name="wzhao-storage-hello-world";Value="TEST"}
## This creates a RG for us to add resources to
New-AzureResourceGroupDeployment -Name "wzhao-DEPLOY-storage-arm" -ResourceGroupName "wzhao-storage-arm" -TemplateFile C:\Work\TestCode\ARMTemplate\azurestorage.json  -TemplateParameterFile C:\Work\TestCode\ARMTemplate\azurestorageparameter.json

Get-AzureResourceGroup -Name wzhao-storage-arm
Get-AzureResourceGroupDeployment -ResourceGroupName wzhao-storage-arm
Get-AzureResourceGroupLog -ResourceGroup wzhao-storage-arm
Get-AzureResourceLog -ResourceId /subscriptions/9017868f-fad6-4da8-9b93-6cd45227d628/resourceGroups/wzhao-storage-arm

Remove-AzureResourceGroup -Name wzhao-storage-arm -Force



#New a site with SQL server and GITHUB
Test-AzureResourceGroupTemplate -ResourceGroupName wzhaowptest002 -TemplateFile C:\Work\TestCode\ARMTemplate\SiteAndSQL.json

New-AzureResourceGroup -Name "wzhao-storage-arm" -Location "South Central US" -Tag @{Name="wzhao-storage-hello-world";Value="TEST"}
## This creates a RG for us to add resources to
New-AzureResourceGroupDeployment -Name "wzhao-DEPLOY-storage-arm" -ResourceGroupName "wzhao-storage-arm" -TemplateFile C:\Work\TestCode\ARMTemplate\azurestorage.json  -TemplateParameterFile C:\Work\TestCode\ARMTemplate\azurestorageparameter.json

Get-AzureResourceGroup -Name wzhao-storage-arm
Get-AzureResourceGroupDeployment -ResourceGroupName wzhao-storage-arm
Get-AzureResourceGroupLog -ResourceGroup wzhao-storage-arm
Get-AzureResourceLog -ResourceId /subscriptions/9017868f-fad6-4da8-9b93-6cd45227d628/resourceGroups/wzhao-storage-arm

Remove-AzureResourceGroup -Name wzhao-storage-arm -Force


#remove test resource group
Remove-AzureResourceGroup -Name WebSitesWithSQLEU2 -Force




