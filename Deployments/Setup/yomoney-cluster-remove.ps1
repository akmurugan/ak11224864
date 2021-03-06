param([Parameter(Mandatory=$false)] [string] $resourceGroup,
        [Parameter(Mandatory=$false)] [string] $clusterName, 
        [Parameter(Mandatory=$false)] [string] $acrName,
        [Parameter(Mandatory=$false)] [string] $keyVaultName,
        [Parameter(Mandatory=$false)] [string] $aksVNetName,
        [Parameter(Mandatory=$false)] [string] $appgwName,
        [Parameter(Mandatory=$false)] [string] $apimName,
        [Parameter(Mandatory=$false)] [string] $subscriptionId)

$aksSPIdName = $clusterName + "-sp-id"
$publicIpAddressName = "$appgwName-pip"
$subscriptionCommand = "az account set -s $subscriptionId"

# PS Select Subscriotion 
Select-AzSubscription -SubscriptionId $subscriptionId

# CLI Select Subscriotion 
Invoke-Expression -Command $subscriptionCommand

az aks delete --name $clusterName --resource-group $resourceGroup --yes

Remove-AzApplicationGateway -Name $appgwName `
-ResourceGroupName $resourceGroup -Force

Remove-AzPublicIpAddress -Name $publicIpAddressName `
-ResourceGroupName $resourceGroup -Force

Remove-AzApiManagement -Name $apimName `
-ResourceGroupName $resourceGroup

Remove-AzVirtualNetwork -Name $aksVNetName `
-ResourceGroupName $resourceGroup -Force

Remove-AzContainerRegistry -Name $acrName `
-ResourceGroupName $resourceGroup

$keyVault = Get-AzKeyVault -ResourceGroupName $resourceGroup `
-VaultName $keyVaultName
if ($keyVault)
{

    $spAppId = Get-AzKeyVaultSecret -VaultName $keyVaultName `
    -Name $aksSPIdName
    if ($spAppId)
    {        
     
        Remove-AzADServicePrincipal `
        -ApplicationId $spAppId.SecretValueText -Force
        
    }

    Remove-AzKeyVault -InputObject $keyVault -Force

}

Write-Host "Successfully Removed!"