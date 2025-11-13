--- 
title: 08 - Bring Your Own Model
description: Learn how to integrate external AI models and local models with Azure Logic Apps using APIM AI Gateway and VNET integration.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 11/06/2025
author: brbenn
ms.author: brbenn
---

# Module 08 - Bring Your Own Model

This module explains how to integrate external AI models and local models with your Azure Logic Apps agents, providing flexibility to use models beyond Azure OpenAI Service.

When finished with this module, you'll have gained the following knowledge:

- **APIM AI Gateway Integration**: How to use Azure API Management AI Gateway to connect to external AI models
- **Local Model Integration**: How to connect to local models using VNET integration

## The Benefits of Model Flexibility in Enterprise AI Applications

In enterprise AI applications, organizations often need flexibility in choosing AI models based on specific requirements such as compliance, cost optimization, specialized capabilities, or data residency requirements. Azure Logic Apps supports multiple approaches to integrate different AI models, ensuring you can choose the best model for your specific use case.

## Model Integration Approaches

Azure Logic Apps supports three primary approaches for integrating external and local AI models:

### Approach 1: APIM AI Gateway for External Models
Use Azure API Management AI Gateway to create a unified interface for external AI providers:
- **Centralized management** of multiple AI model endpoints
- **Security and authentication** handling for external services
- **Rate limiting and monitoring** capabilities
- **Cost optimization** through intelligent routing

### Approach 2: Direct External Model Integration
Connect directly to external AI model APIs:

### Approach 3: Local Model Integration via VNET
Connect to on-premises or private cloud AI models using VNET integration:
- **Private connectivity** to internal AI infrastructure
- **Compliance and data residency** requirements
- **Custom or fine-tuned models** hosted internally

## Approach 1: APIM AI Gateway Integration

## Prerequisites:
- An Azure account and subscription. If you don't have a subscription, [sign up for a free Azure account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).
- Existing Logic Apps Standard workflow app (or create one): [Create a single-tenant workflow app](https://learn.microsoft.com/azure/logic-apps/create-single-tenant-workflows-azure-portal).
- Deployed Azure OpenAI model (for example a GPT family chat/completions model): [Azure OpenAI models](https://learn.microsoft.com/azure/ai-services/openai/concepts/models).
- You have access to an Azure API Management service. For steps on setting this up, follow the guide here [Create an Azure API Management instance](https://learn.microsoft.com/en-us/azure/api-management/get-started-create-service-instance).
- You have imported an Azure AI Foundry API to your API Management Instance. For steps on importing Azure AI Foundry API, follow the guide here [Import an Azure AI Foundry API](Import an Azure AI Foundry API - Azure API Management | Microsoft Learn) and select Azure OpenAI under Client Compatibility on the Configure API tab

### Create Connection

In the Azure portal, open your Standard logic app resource. Add a new conversational agent workflow in the designer and name it `APIM-Agent`.

Click on the Agent and create a connection or scroll down to Change connection. Configure the following settings:

**Connection Name**: APIM

**Agent Model Source**: APIM GenAI Gateway (Preview)

**Authentication Type**: URL and key-based authentication

**Subscription**: Select your subscription

**Azure API Management Service**: Select your APIM instance

**Azure API Management Service APIs**: Select your API Management API

**API Endpoint**:
- Navigate to your APIM instance and click on `APIs` under `APIs` on the left navigation bar
- Then under **All APIs**, click on the API you created.
- Under Design, type `Creates a completion for the chat message` in `Search Operations`.
- Click on the `Creates a completion for the chat message` operation
- Switch to `Test` tab.
- Scroll down to Request URL and copy and paste everything up till and not including /openai. The API Endpoint will look something like this https://NAMEOFAPIMINSTANCE.azure-api.net/NAMEOFAPI

A screenshot of a computer

AI-generated content may be incorrect.

**API Key**:
- On the Test Tab of your APIM Instance, scroll further down to the `HTTP Request` section
- In the gray box under HTTP Request, press the eye icon and click elsewhere on the gray box

A close-up of a number

AI-generated content may be incorrect.

- Copy the api-key that appears and paste it in

### Test the Workflow

Type in the deployment-model for your agent.

Add a System Prompt: `Greet me in 5 languages.`

Then press `Save`.

Click on the Chat icon and type in `hello`.

The agent should successfully respond.

## Approach 2: Direct External Model Integration

## Approach 3: Local Model Integration via VNET

### Step 3 - Configure Security and Monitoring

1. **Network Security**: Ensure proper network security groups (NSGs) are configured to allow traffic only from your Logic Apps subnet.
2. **Authentication**: Implement proper authentication mechanisms for your local model API.
3. **Monitoring**: Set up monitoring for both the Logic Apps workflow and your local model infrastructure.
4. **Failover**: Consider implementing failover mechanisms to cloud-based models if local models become unavailable.

## Security Best Practices for External Model Integration

- **API Key Management**: Use Azure Key Vault to securely store API keys and connection strings
- **Network Security**: Implement proper network security controls, especially for VNET integration
- **Authentication**: Use strong authentication mechanisms for all external model connections
- **Data Privacy**: Ensure external model providers meet your data privacy and compliance requirements
- **Monitoring**: Implement comprehensive monitoring and logging for all model interactions
- **Rate Limiting**: Implement appropriate rate limiting to control costs and prevent abuse
