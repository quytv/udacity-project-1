# Azure CLI
0. Docker setup terraform
- https://stackoverflow.com/questions/63080980/how-to-install-terraform-0-12-in-an-alpine-container-with-apk

```
apk add terraform --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community
```

1.
```bash
docker run -it mcr.microsoft.com/azure-cli
az login
{
  "environmentName": "AzureCloud",
  "homeTenantId": "",
  "id": "", #=> ARM_SUBSCRIPTION_ID
  "isDefault": true,
  "managedByTenants": [],
  "name": "Azure subscription 1",
  "state": "Enabled",
  "tenantId": "", #=> ARM_CLIENT_ID
  "user": {
    "name": "",
    "type": "user"
  }
}
```
2. Create resource group

```bash
az group create -n udacity-quytran  --location southindia
{
  "id": "/subscriptions/745082d1-7212-46df-bc06-d2612de9de33/resourceGroups/udacity-quytran",
  "location": "southindia",
  "managedBy": null,
  "name": "udacity-quytran",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}

```

3. Create Service Principal

```bash
az ad sp create-for-rbac --name service-principal-quytran --role Contributor --scopes /subscriptions/745082d1-7212-46df-bc06-d2612de9de33/resourceGroups/udacity-quytran

The underlying Active Directory Graph API will be replaced by Microsoft Graph API in Azure CLI 2.37.0. Please carefully review all breaking changes introduced during this migration: https://docs.microsoft.com/cli/azure/microsoft-graph-migration
Found an existing application instance of "d7889f22-9c63-4df9-9761-dc9bad585b01". We will patch it
Creating 'Owner' role assignment under scope '/subscriptions/745082d1-7212-46df-bc06-d2612de9de33/resourceGroups/udacity-quytran'
The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
{
  "appId": "d7889f22-9c63-4df9-9761-dc9bad585b01", #=> ARM_CLIENT_ID
  "displayName": "service-principal-quytran",
  "password": "jPFdagPR9cAL.dNgDr0_8Kn~dbTqnb0l_U", #=> ARM_CLIENT_SECRET
  "tenant": "2bd6a728-a064-49b6-8563-cd858365a3d8"
}
```

4. Create Storage Account

```bash
az storage account create -g udacity-quytran -n quytran3 --access-tier hot --sku Standard_LRS --location "East US 2"

{
  "accessTier": "Hot",
  "allowBlobPublicAccess": true,
  "allowCrossTenantReplication": null,
  "allowSharedKeyAccess": null,
  "allowedCopyScope": null,
  "azureFilesIdentityBasedAuthentication": null,
  "blobRestoreStatus": null,
  "creationTime": "2022-05-23T19:23:53.006800+00:00",
  "customDomain": null,
  "defaultToOAuthAuthentication": null,
  "dnsEndpointType": null,
  "enableHttpsTrafficOnly": true,
  "enableNfsV3": null,
  "encryption": {
    "encryptionIdentity": null,
    "keySource": "Microsoft.Storage",
    "keyVaultProperties": null,
    "requireInfrastructureEncryption": null,
    "services": {
      "blob": {
        "enabled": true,
        "keyType": "Account",
        "lastEnabledTime": "2022-05-23T19:23:53.069230+00:00"
      },
      "file": {
        "enabled": true,
        "keyType": "Account",
        "lastEnabledTime": "2022-05-23T19:23:53.069230+00:00"
      },
      "queue": null,
      "table": null
    }
  },
  "extendedLocation": null,
  "failoverInProgress": null,
  "geoReplicationStats": null,
  "id": "/subscriptions/745082d1-7212-46df-bc06-d2612de9de33/resourceGroups/udacity-quytran/providers/Microsoft.Storage/storageAccounts/quytran",
  "identity": null,
  "immutableStorageWithVersioning": null,
  "isHnsEnabled": null,
  "isLocalUserEnabled": null,
  "isSftpEnabled": null,
  "keyCreationTime": {
    "key1": "2022-05-23T19:23:53.069230+00:00",
    "key2": "2022-05-23T19:23:53.069230+00:00"
  },
  "keyPolicy": null,
  "kind": "StorageV2",
  "largeFileSharesState": null,
  "lastGeoFailoverTime": null,
  "location": "centralindia",
  "minimumTlsVersion": "TLS1_0",
  "name": "quytran",
  "networkRuleSet": {
    "bypass": "AzureServices",
    "defaultAction": "Allow",
    "ipRules": [],
    "resourceAccessRules": null,
    "virtualNetworkRules": []
  },
  "primaryEndpoints": {
    "blob": "https://quytran.blob.core.windows.net/",
    "dfs": "https://quytran.dfs.core.windows.net/",
    "file": "https://quytran.file.core.windows.net/",
    "internetEndpoints": null,
    "microsoftEndpoints": null,
    "queue": "https://quytran.queue.core.windows.net/",
    "table": "https://quytran.table.core.windows.net/",
    "web": "https://quytran.z29.web.core.windows.net/"
  },
  "primaryLocation": "centralindia",
  "privateEndpointConnections": [],
  "provisioningState": "Succeeded",
  "publicNetworkAccess": null,
  "resourceGroup": "udacity-quytran",
  "routingPreference": null,
  "sasPolicy": null,
  "secondaryEndpoints": null,
  "secondaryLocation": null,
  "sku": {
    "name": "Standard_LRS",
    "tier": "Standard"
  },
  "statusOfPrimary": "available",
  "statusOfSecondary": null,
  "storageAccountSkuConversionStatus": null,
  "tags": {},
  "type": "Microsoft.Storage/storageAccounts"
}

```
5. Add assignment
```
az role assignment create --assignee "71be5e61-a0d2-472f-b252-ecb64ccf9371" --role "Contributor" --subscription "745082d1-7212-46df-bc06-d2612de9de33"

```

6. Policy

```
az policy definition create --name 'deny-tagging-policy' --description "Name of the tag, such as 'environment'"  --mode "All" --rules "
{
      \"if\": {
        \"field\": \"[concat('tags[', parameters('tagName'), ']')]\",
        \"exists\": \"false\"
      },
      \"then\": {
        \"effect\": \"deny\"
      }
    }
" --params '
      {
        "tagName": {
          "type": "String",
          "metadata": {
            "displayName": "Tag Name",
            "description": "Name of the tag, such as environment"
          }
        }
      }
    '

```

```
az policy assignment create --name 'tagging-policy' --policy 'deny-tagging-policy' -p "{ \"tagName\": \
    { \"value\": \"enviroments\"  } }"

```
# Packer
packer validate server.json
packer build server.json

az image list
az image delete -g packer-rg -n myPackerImage
