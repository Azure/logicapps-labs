# LogicApps

This folder contains the Logic Apps Standard workflows for the AI Product Return Agent sample.

## Workflows

- **ProductReturnAgent** - Main agent workflow that orchestrates return approvals using AI
- **GetOrderHistory** - Returns mock order data for testing
- **CalculateRefund** - Calculates refund amounts based on return policies

## Local Development

To develop and test these workflows locally:

1. Install [Azure Logic Apps (Standard) VS Code extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurelogicapps)
2. Install [Azure Functions Core Tools v4](https://learn.microsoft.com/azure/azure-functions/functions-run-local)
3. Install [Azurite](https://learn.microsoft.com/azure/storage/common/storage-use-azurite) for local storage emulation

4. Update `cloud.settings.json` with your Azure OpenAI details:
   ```json
   {
     "WORKFLOWS_SUBSCRIPTION_ID": "your-subscription-id",
     "WORKFLOWS_LOCATION_NAME": "eastus2",
     "WORKFLOWS_RESOURCE_GROUP_NAME": "your-resource-group",
     "agent_openAIEndpoint": "https://your-openai.openai.azure.com/",
     "agent_ResourceID": "/subscriptions/.../your-openai-resource"
   }
   ```

5. Start Azurite for local storage:
   ```powershell
   azurite --silent --location ./__azurite__ --debug ./__azurite__/debug.log
   ```

6. Press F5 in VS Code to start the Logic App runtime

7. Test workflows using the local endpoints displayed in the terminal

## Deployment

These workflows are automatically deployed when using the 1-click deployment. For manual deployment:

1. Navigate to the parent folder and run:
   ```powershell
   cd ../1ClickDeploy
   .\BundleAssets.ps1
   ```

2. This creates `workflows.zip` which can be deployed to Azure Logic Apps Standard using:
   ```bash
   az functionapp deployment source config-zip \
     --resource-group <resource-group-name> \
     --name <logic-app-name> \
     --src workflows.zip
   ```

## Files

- `connections.json` - Defines the Azure OpenAI connection using Managed Identity
- `host.json` - Logic Apps runtime configuration
- `parameters.json` - Workflow parameters (empty for this sample)
- `cloud.settings.json` - Cloud environment settings (for local development reference)
- `.funcignore` / `.gitignore` - Excludes development artifacts from deployment

## Agent Configuration

The ProductReturnAgent workflow uses Azure OpenAI GPT-4o-mini model with these settings:

- **System prompt:** Instructs agent to call one tool per turn in sequence
- **Tools:** 5 tools for policy, orders, customer status, refund calculation, and escalation
- **Model:** gpt-4o-mini (version 2024-07-18)
- **Authentication:** Managed Identity (no API keys required)

See the [main README](../README.md) for more details on testing and extending the workflows.
