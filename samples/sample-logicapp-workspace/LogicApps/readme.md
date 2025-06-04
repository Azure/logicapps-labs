# Local Development Setup

This guide provides step-by-step instructions for setting up local development environment for this Logic Apps Standard project.

## Overview

The `local.settings.json` file contains configuration settings required for local development. This file should **never** be committed to source control as it contains sensitive connection strings and local-specific paths.

## Quick Setup Steps

### 1. Create local.settings.json
```bash
# Navigate to the LogicApps folder
cd LogicApps

# Copy the template file
copy cloud.settings.json local.settings.json
```

### 2. Configure Required Settings

Update the following values in your `local.settings.json` file:

| Setting Key | Description | Where to Find | Example |
|-------------|-------------|---------------|---------|
| ProjectDirectoryPath | Full local path to the LogicApps folder | Your local file system | `C:\\projects\\sample-logicapp-workspace\\LogicApps` |
| WORKFLOWS_SUBSCRIPTION_ID | Azure subscription ID for deployment | Azure Portal > Subscriptions | `12345678-1234-1234-1234-123456789012` |

### 3. Pre-configured Values (Do Not Modify)

These values are already set correctly and should remain unchanged:
- `AzureWebJobsStorage` - Set to use development storage
- `APP_KIND` - Configured for workflow applications
- `FUNCTIONS_WORKER_RUNTIME` - Set to Node.js runtime
- `IsEncrypted` - Encryption setting for local development

## Detailed Configuration Guide

### Project Directory Path
Set this to the full absolute path of your LogicApps folder. This helps the runtime locate your workflow files correctly.

**Windows Example:**
```json
"ProjectDirectoryPath": "C:\\projects\\sample-logicapp-workspace\\LogicApps"
```

**Alternative Windows Format:**
```json
"ProjectDirectoryPath": "C:/projects/sample-logicapp-workspace/LogicApps"
```

### Workflows Subscription ID
This is your Azure subscription identifier, required for deploying workflows to Azure. You can find this in the Azure Portal under Subscriptions.

## Sample Configuration

Your completed `local.settings.json` should look similar to this:

```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "APP_KIND": "workflowapp",
    "ProjectDirectoryPath": "C:\\projects\\sample-logicapp-workspace\\LogicApps",
    "WORKFLOWS_SUBSCRIPTION_ID": "12345678-1234-1234-1234-123456789012"
  }
}
```

## Verification Steps

1. **Test Local Run**: Use VS Code Azure Logic Apps extension to start the local runtime
2. **Check Connections**: Verify all connections are working in the Logic Apps Designer
3. **Test Workflows**: Run a simple test of each workflow to ensure proper configuration

## Important Security Notes

- ⚠️ **Never commit `local.settings.json` to source control**
- 🔐 **Use proper Azure RBAC permissions instead of connection strings when possible**
- 🔄 **Rotate keys regularly and update local settings accordingly**

## Troubleshooting

### Common Issues

**File Path Issues (Windows):**
- Ensure paths use double backslashes (`\\`) or forward slashes (`/`)
- Example: `C:\\projects\\myapp` or `C:/projects/myapp`

**Runtime Issues:**
- Verify .NET and Azure Functions Core Tools are installed
- Check VS Code Azure Logic Apps extension is up to date
- Review terminal output for specific error messages

**Workflow Designer Issues:**
- Ensure the ProjectDirectoryPath is correctly set
- Verify that the LogicApps folder contains your workflow directories
- Check that each workflow folder has a valid `workflow.json` file

### Getting Help

For this basic HTTP workflow:
- The workflow should be accessible at a local endpoint once running
- Test the HTTP trigger by sending a GET or POST request to the generated URL
- The response should return "Hello world" with a 200 status code
- Check the VS Code terminal for runtime logs and any error messages
