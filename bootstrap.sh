#!/bin/bash
set -x
source "credentials.sh"
source "definitions.sh"

#Create Resource Group, Storage Account & FunctionApp in Azure
az group create --name $rgName --location $location
az storage account create --name $storageName --location $location --resource-group $rgName --sku Standard_LRS --kind StorageV2
az functionapp create --name $functionAppName --os-type Windows --storage-account $storageName --consumption-plan-location $location --resource-group $rgName --runtime node --runtime-version 10
az functionapp config appsettings set --name $functionAppName --resource-group $rgName --settings FUNCTIONS_EXTENSION_VERSION=~3

:'
az functionapp identity assign --name $functionAppName --resource-group $rgName

az keyvault create --name $vaultname --resource-group $rgName --location $location
az keyvault secret set --vault-name $vaultname --name TWITTERCONSUMERKEY --value $TWITTERCONSUMERKEY
az keyvault secret set --vault-name $vaultname --name TWITTERCONSUMERSECRET --value $TWITTERCONSUMERSECRET
az keyvault secret set --vault-name $vaultname --name TWITTERACCESSTOKEN --value $TWITTERACCESSTOKEN
az keyvault secret set --vault-name $vaultname --name TWITTERACCESSTOKENSECRET --value $TWITTERACCESSTOKENSECRET
az keyvault secret set --vault-name $vaultname --name TWITTERSCREENNAME --value $TWITTERSCREENNAME
az keyvault secret set --vault-name $vaultname --name TWITTERTWEETMODE --value $TWITTERTWEETMODE
az keyvault secret set --vault-name $vaultname --name TWITTERMAXTWEETS --value $TWITTERMAXTWEETS

principalId=$(az functionapp identity show -n $functionAppName -g $rgName --query principalId -o tsv)
tenantId=$(az functionapp identity show -n $functionAppName -g $rgName --query tenantId -o tsv)

az keyvault set-policy -n $vaultname -g $rgName --object-id $principalId --secret-permissions get

TWITTERCONSUMERKEY_SECRET=$(az keyvault secret show -n TWITTERCONSUMERKEY --vault-name $vaultname --query "id" -o tsv)
TWITTERCONSUMERSECRET_SECRET=$(az keyvault secret show -n TWITTERCONSUMERSECRET --vault-name $vaultname --query "id" -o tsv)
TWITTERACCESSTOKEN_SECRET=$(az keyvault secret show -n TWITTERACCESSTOKEN --vault-name $vaultname --query "id" -o tsv)
TWITTERACCESSTOKENSECRET_SECRET=$(az keyvault secret show -n TWITTERACCESSTOKENSECRET --vault-name $vaultname --query "id" -o tsv)
TWITTERSCREENNAME_SECRET=$(az keyvault secret show -n TWITTERSCREENNAME --vault-name $vaultname --query "id" -o tsv)
TWITTERTWEETMODE_SECRET=$(az keyvault secret show -n TWITTERTWEETMODE --vault-name $vaultname --query "id" -o tsv)
TWITTERMAXTWEETS_SECRET=$(az keyvault secret show -n TWITTERMAXTWEETS --vault-name $vaultname --query "id" -o tsv)

az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERCONSUMERKEY=@Microsoft.KeyVault(SecretUri=$TWITTERCONSUMERKEY_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERCONSUMERSECRET=@Microsoft.KeyVault(SecretUri=$TWITTERCONSUMERSECRET_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERACCESSTOKEN=@Microsoft.KeyVault(SecretUri=$TWITTERACCESSTOKEN_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERACCESSTOKENSECRET=@Microsoft.KeyVault(SecretUri=$TWITTERACCESSTOKENSECRET_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERSCREENNAME=@Microsoft.KeyVault(SecretUri=$TWITTERSCREENNAME_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERTWEETMODE=@Microsoft.KeyVault(SecretUri=$TWITTERTWEETMODE_SECRET)"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERMAXTWEETS=@Microsoft.KeyVault(SecretUri=$TWITTERMAXTWEETS_SECRET)"
'

az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERCONSUMERKEY=$TWITTERCONSUMERKEY"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERCONSUMERSECRET=$TWITTERCONSUMERSECRET"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERACCESSTOKEN=$TWITTERACCESSTOKEN"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERACCESSTOKENSECRET=$TWITTERACCESSTOKENSECRET"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERSCREENNAME=$TWITTERSCREENNAME"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERTWEETMODE=$TWITTERTWEETMODE"
az functionapp config appsettings set -n $functionAppName -g $rgName --settings "TWITTERMAXTWEETS=$TWITTERMAXTWEETS"


az functionapp config appsettings list --name $functionAppName -g $rgName
#Retrieve these credentials locally
func azure functionapp fetch-app-settings $functionAppName
