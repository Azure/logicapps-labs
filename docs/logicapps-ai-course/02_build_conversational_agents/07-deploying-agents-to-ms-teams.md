--- 
title: 07 - Deploy your agents to Microsoft Teams
description: Learn how to deploy Logic Apps conversational agents to Microsoft Teams to enable interacting with agents through the Teams chat.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 11/12/2025
author: brbenn
ms.author: brbenn
---

# Module 06 - Deploy your agents to Microsoft Teams

This module demonstrates how to deploy Logic Apps conversational agents to Microsoft Teams, enabling users to interact with intelligent agents directly through Teams chat interface.

When finished with this module, you'll have gained the following knowledge:

- **Teams Integration Architecture**: Understanding the three-component architecture involving Microsoft Teams, Azure Bot Service, and Logic Apps
- **Azure Bot Service Configuration**: How to create and configure Azure Bot Service as a proxy between Teams and Logic Apps
- **Custom Proxy Implementation**: Building a web application that implements the bot activity protocol to bridge Teams and Logic Apps
- **Teams App Manifest Creation**: Creating and configuring Teams app manifests for sideloading custom agents
- **End-to-End Deployment**: Complete workflow from local development to Teams production deployment

## Architecture Overview

The integration between Microsoft Teams and Logic Apps involves three key components:

1. **Microsoft Teams** - The client interface where users interact with the agent
2. **Azure Bot Service** - Intermediate service that handles authentication, schema validation, and message routing
3. **Custom Proxy Application** - Web application that implements the bot activity protocol and communicates with Logic Apps via A2A (Application-to-Application)

> [!NOTE]
> Messages don't go directly from Teams to Logic Apps. Instead, they flow through Azure Bot Service, which then forwards them to your custom proxy application that communicates with Logic Apps.

## Prerequisites

- Azure subscription with Logic Apps Standard
- Microsoft Teams with tenant admin permissions
- Visual Studio or VS Code
- Logic Apps agent already created and configured
- GitHub repository access (sample code available)

## Step 1: Create Logic App Agent

Ensure you have a Logic Apps agent configured with:
- Agent workflow with conversation handling
- OAuth connection configured (if authentication required)
- A2A (Application-to-Application) endpoint enabled

> [!TIP]
> Test your Logic Apps agent locally first using the Logic Apps designer before proceeding with Teams integration.

## Step 2: Create Azure Bot Service

1. **Navigate to Azure Portal**
   - Create a new Azure Bot Service resource
   - Configure basic settings (name, resource group, subscription)

2. **Configure Bot Settings**
   - Note the **Bot ID** (Microsoft App ID) - you'll need this for Teams manifest
   - Configure the messaging endpoint (will be updated later with proxy URL)
   - Set up authentication if required

3. **Enable Web Chat Channel**
   - Test the bot service configuration using the built-in web chat
   - Verify basic connectivity before proceeding to Teams integration

## Step 3: Setup Custom Proxy App

The proxy application bridges the gap between Azure Bot Service and Logic Apps since Logic Apps doesn't directly support the bot activity protocol.

### Key Components:

1. **Bot Activity Protocol Implementation**
   - Handles incoming messages from Azure Bot Service
   - Implements proper message formatting and response handling

2. **A2A Integration with Logic Apps**
   - Converts bot messages to Logic Apps A2A format
   - Manages conversation context and state mapping
   - Handles authentication tokens and headers

3. **Conversation ID Mapping**
   - Maps Teams conversation IDs to Logic Apps context IDs
   - Enables stateless operation without requiring custom storage
   - Handles conversation lifecycle and error recovery

### Sample Code Structure:

```csharp
// Key handler for processing messages
public async Task OnMessageAsync(ITurnContext<IMessageActivity> turnContext)
{
    // Get OAuth token for Logic Apps
    var token = await GetTokenAsync(turnContext);
    
    // Map Teams conversation ID to Logic Apps context
    var contextId = MapConversationId(turnContext.Activity.Conversation.Id);
    
    // Forward message to Logic Apps via A2A
    var response = await CallLogicAppsAsync(turnContext.Activity.Text, contextId, token);
    
    // Send response back to Teams
    await turnContext.SendActivityAsync(response);
}
```

### Configuration Requirements:

- **Feature Flag**: Enable conversation ID mapping (for Ignite candidate branch)
- **OAuth Configuration**: Configure authentication for Logic Apps access
- **Endpoint Configuration**: Set up proper routing and error handling

## Step 4: Deploy Proxy App to App Service

### Local Development Setup:

1. **Run Locally First**
   ```bash
   # Start the proxy application locally
   dotnet run
   ```

2. **Use Dev Tunnels for Testing**
   - Expose local service to cloud for testing
   - Configure Azure Bot Service messaging endpoint to use dev tunnel URL
   - Format: `https://your-dev-tunnel.devtunnels.ms/api/messages`

3. **Test with Web Chat**
   - Verify authentication flow (sign-in dialog should appear)
   - Test message exchange and conversation continuity
   - Check conversation ID mapping functionality

### Production Deployment:

1. **Deploy to Azure App Service**
   ```bash
   # Deploy using Azure CLI or Visual Studio publish
   az webapp deployment source config-zip --resource-group myResourceGroup --name myAppServiceName --src myapp.zip
   ```

2. **Update Bot Service Configuration**
   - Update messaging endpoint in Azure Bot Service
   - Use production App Service URL: `https://your-app-service.azurewebsites.net/api/messages`

3. **Configure Environment Variables**
   - Set Logic Apps endpoint URLs
   - Configure OAuth client credentials
   - Set feature flags for production

## Step 5: Configure Teams Integration

### Enable Teams Channel:

1. **In Azure Bot Service**
   - Navigate to Channels section
   - Click "Microsoft Teams" channel
   - Accept terms of service
   - Configure channel settings

### Create Teams App Manifest:

1. **Manifest Structure** (`manifest.json`):
   ```json
   {
     "$schema": "https://developer.microsoft.com/json-schemas/teams/v1.16/MicrosoftTeams.schema.json",
     "manifestVersion": "1.16",
     "version": "1.0.0",
     "id": "YOUR_BOT_ID_HERE",
     "packageName": "com.company.logicappsagent",
     "developer": {
       "name": "Your Company Name",
       "websiteUrl": "https://yourcompany.com",
       "privacyUrl": "https://yourcompany.com/privacy",
       "termsOfUseUrl": "https://yourcompany.com/terms"
     },
     "name": {
       "short": "Logic Apps Agent",
       "full": "Logic Apps Conversational Agent"
     },
     "description": {
       "short": "Intelligent agent powered by Logic Apps",
       "full": "A conversational AI agent built with Azure Logic Apps that can help with various tasks"
     },
     "icons": {
       "outline": "outline.png",
       "color": "color.png"
     },
     "accentColor": "#FFFFFF",
     "bots": [
       {
         "botId": "YOUR_BOT_ID_HERE",
         "scopes": [
           "personal"
         ],
         "supportsFiles": false,
         "isNotificationOnly": false
       }
     ],
     "permissions": [
       "identity",
       "messageTeamMembers"
     ],
     "validDomains": []
   }
   ```

2. **Required Files**:
   - `manifest.json` (configuration above)
   - `color.png` (192x192 color icon)
   - `outline.png` (32x32 outline icon)

3. **Package Creation**:
   - Compress all files into a ZIP archive
   - Ensure ZIP contains files at root level (not in subfolder)

### Sideload Teams App:

1. **Upload to Teams Admin Center**
   - Navigate to Teams Admin Center > Manage apps
   - Click "Upload a custom app"
   - Select your ZIP file

2. **Alternative: Direct Upload in Teams**
   - In Teams client: Apps > Manage your apps > Upload a custom app
   - Select "Upload for [your organization]"
   - Choose your ZIP file

3. **Test Installation**
   - Find your app in Teams app store
   - Click "Add" to install
   - Test in both personal chat and Copilot contexts

## Step 6: Testing and Validation

### Test Scenarios:

1. **Basic Conversation**
   - Send simple messages and verify responses
   - Check authentication flow (OAuth sign-in)
   - Verify conversation continuity

2. **Multiple Contexts**
   - Test in personal chat with bot
   - Test in Copilot interface (if enabled)
   - Verify conversation isolation between different contexts

3. **Error Handling**
   - Test with invalid inputs
   - Verify graceful error recovery
   - Check conversation reset functionality

### Troubleshooting:

- **Authentication Issues**: Check OAuth configuration and token handling
- **Message Delivery**: Verify Azure Bot Service messaging endpoint
- **Conversation State**: Ensure conversation ID mapping is working correctly
- **Teams Manifest**: Validate JSON schema and required fields

## Advanced Configuration

### Conversation Management:

- **Context Isolation**: Each Teams conversation gets unique Logic Apps context ID
- **State Reset**: Users can reset conversation by canceling Logic Apps runs
- **Error Recovery**: Failed contexts automatically start new conversations

### Scoping Options:

```json
"scopes": [
  "personal",        // One-on-one chats
  "team",           // Team channels
  "groupChat"       // Group conversations
]
```

### Copilot Integration:

Enable your agent to appear in Microsoft Copilot by adding the `copilotAgents` extension:

```json
"extensions": [
  {
    "requirements": {
      "copilotAgents": {}
    }
  }
]
```

## Next Steps

- **Monitor Usage**: Set up Application Insights for the proxy application
- **Scale Considerations**: Plan for multiple concurrent conversations
- **Security Review**: Implement proper authentication and authorization
- **User Training**: Provide documentation for end users on agent capabilities

## Sample Repository

The complete sample code and configuration files are available in the GitHub repository:
- **Main Branch**: Targets refresh bundle (legacy)
- **Ignite Candidate Branch**: Latest features with simplified configuration

> [!IMPORTANT]
> Use the Ignite candidate branch for new implementations as it includes the latest conversation mapping features and simplified setup process.