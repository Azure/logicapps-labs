# Deployment with VS Code Extension for Logic Apps Standard

This guide is for deploying workflows to an existing Logic App resource using the Azure Logic Apps extension for VS Code. If you haven't deployed the infrastructure yet, use the [Deploy to Azure button](.././README.md#deploy-sample) first.

## When to Use This Approach

**Use the Azure Portal workflow designer if:**
- ✅ You want to edit workflows directly in the browser
- ✅ You prefer a visual, low-code experience
- ✅ You want immediate deployment and testing

**Use VS Code extension if:**
- ✅ You want to edit workflows in your local editor
- ✅ You prefer working with JSON/code directly
- ✅ You want to integrate with source control workflows
- ✅ You want local testing capabilities

---

## Prerequisites for VS Code Approach

In addition to the [main prerequisites](../README.md#prerequisites), you'll need:

- **[VS Code](https://code.visualstudio.com/)** - Code editor
- **[Azure Logic Apps extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurelogicapps)** - For workflow development
- **[.NET 8 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)** - For local runtime
- **[Azure Functions Core Tools v4](https://learn.microsoft.com/azure/azure-functions/functions-run-local)** - For local testing
- **[Azurite](https://learn.microsoft.com/azure/storage/common/storage-use-azurite)** - For local storage emulation

---

## Deployment Steps

### Step 1: Open Workspace in VS Code

1. Open the `LogicApps` folder in VS Code:
   ```bash
   cd LogicApps
   code .
   ```

2. Install the Azure Logic Apps extension if not already installed

### Step 2: Connect to Your Logic App Resource

1. Open the Azure extension panel in VS Code (Azure icon in sidebar)
2. Sign in to your Azure account
3. Expand your subscription and locate your Logic App resource
4. Right-click on the Logic App resource

### Step 3: Deploy Workflows

1. In VS Code, right-click on the `LogicApps` folder
2. Select **Deploy to Logic App**
3. Choose your Logic App resource from the list
4. Confirm the deployment

The workflows will be deployed to your existing Logic App resource.

> **📝 Note:** The infrastructure (Logic App resource, Azure OpenAI, Storage Account, RBAC assignments) must already exist. Use the [Deploy to Azure button](../README.md#deploy-sample) to create the infrastructure first.

---

## Local Development (Optional)

The `local.settings.json` file contains configuration settings required for local development. This file should **never** be committed to source control as it contains sensitive connection strings and local-specific paths.

## Quick Setup Steps

### 1. Create local.settings.json
```bash
# Navigate to the LogicApps folder
cd LogicApps

# Copy the template file (Windows)
copy cloud.settings.json local.settings.json

# Or on Mac/Linux
cp cloud.settings.json local.settings.json
```

### 2. Configure Required Settings

Update the following values in your `local.settings.json` file:

| Setting Key | Description | Where to Find | Example |
|-------------|-------------|---------------|---------|
| `WORKFLOWS_SUBSCRIPTION_ID` | Your Azure subscription ID | Azure Portal → Subscriptions | `12345678-1234-1234-1234-123456789012` |
| `WORKFLOWS_LOCATION_NAME` | Azure region for your resources | Azure Portal → Resource location | `eastus2` |
| `WORKFLOWS_RESOURCE_GROUP_NAME` | Resource group containing your Logic App | Azure Portal → Resource groups | `rg-ailoan` |
| `agent_ResourceID` | Azure OpenAI resource ID | Azure Portal → OpenAI resource → Properties | `/subscriptions/.../resourceGroups/.../providers/Microsoft.CognitiveServices/accounts/myopenai` |
| `agent_openAIEndpoint` | Azure OpenAI endpoint URL | Azure Portal → OpenAI → Keys and Endpoint | `https://myopenai.openai.azure.com/` |

### 3. Pre-configured Values (Do Not Modify)

These values are already set correctly and should remain unchanged:
- `AzureWebJobsStorage` - Set to `UseDevelopmentStorage=true` for local development with Azurite
- `APP_KIND` - Set to `workflowApp`
- `FUNCTIONS_WORKER_RUNTIME` - Set to `dotnet`
- `FUNCTIONS_INPROC_NET8_ENABLED` - Set to `1`

## Detailed Configuration Guide

### Azure OpenAI Configuration

1. Navigate to Azure Portal → Azure OpenAI Service
2. Select your OpenAI resource
3. Go to "Keys and Endpoint" section
4. Copy the endpoint URL
5. For the resource ID, go to Properties and copy the full resource ID path

**Important:** When deployed to Azure, the Logic App uses Managed Identity to authenticate to Azure OpenAI (no keys needed). For local development, the connection still uses the endpoint configuration from your settings.

### Obtaining the Resource ID

The Azure OpenAI Resource ID follows this format:
```
/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.CognitiveServices/accounts/{openai-account-name}
```

To find it:
1. Open your Azure OpenAI resource in Azure Portal
2. Click on "Properties" in the left menu
3. Copy the "Resource ID" value

## Sample Configuration

Your completed `local.settings.json` should look similar to this:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "APP_KIND": "workflowApp",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet",
    "FUNCTIONS_INPROC_NET8_ENABLED": "1",
    "WORKFLOWS_SUBSCRIPTION_ID": "12345678-1234-1234-1234-123456789012",
    "WORKFLOWS_LOCATION_NAME": "eastus2",
    "WORKFLOWS_RESOURCE_GROUP_NAME": "rg-ailoan",
    "agent_ResourceID": "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-ailoan/providers/Microsoft.CognitiveServices/accounts/myopenai",
    "agent_openAIEndpoint": "https://myopenai.openai.azure.com/"
  }
}
```

## Verification Steps

1. **Test Local Run**: Use VS Code Azure Logic Apps extension to start the local runtime
   - Press F5 or use the "Start" button in VS Code
   - Ensure Azurite is running for local storage emulation

2. **Check Connections**: Verify the Azure OpenAI connection in the Logic Apps Designer
   - Open any workflow in designer
   - Check that the agent connection shows as configured

3. **Test Workflows**: Run a simple test of the LoanApprovalAgent workflow
   - Use the test script or send an HTTP POST request
   - Verify the workflow executes successfully

## Important Security Notes

- ⚠️ **Never commit `local.settings.json` to source control**
- 🔐 **Use Managed Identity for Azure deployments** (already configured in this sample)
- 🔄 **Keep your Azure OpenAI endpoint configuration up to date**

## Troubleshooting

### Common Issues

**Azure OpenAI Connection Failures:**
- Verify the endpoint URL is correct and includes `https://`
- Ensure the endpoint URL ends with a trailing slash (`/`)
- Check that the resource ID matches your Azure OpenAI resource exactly
- Verify your Azure OpenAI deployment has the `gpt-5-mini` model deployed

**Runtime Issues:**
- Verify .NET 8 SDK is installed
- Check Azure Functions Core Tools are installed (v4.x)
- Ensure VS Code Azure Logic Apps extension is up to date
- Review terminal output for specific error messages
- Make sure Azurite is running for local storage emulation

**Workflow Execution Issues:**
- Check that all workflow JSON files are valid
- Verify the workflow trigger schema matches your test payload
- Review run history in VS Code for detailed error messages

### Getting Help

For additional support:
- Review [Azure Logic Apps Standard documentation](https://learn.microsoft.com/azure/logic-apps/)
- Check [Azure OpenAI service status](https://status.azure.com/)
- Verify your Azure OpenAI model deployment status in Azure Portal

---

## Next Steps

- **After deploying:** See [Explore Sample](../README.md#explore-sample) to test your workflows
- **To extend:** Follow [Teams Connector Setup](../TEAMS-CONNECTOR.md) to add real approvals
- **Need help?** See [Troubleshooting](../README.md#troubleshoot) in main README

