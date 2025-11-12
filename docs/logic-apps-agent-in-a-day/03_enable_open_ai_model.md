---
title: 03 - Enable your OpenAI model
description: Provision Azure OpenAI and deploy the GPT-4.1 model for use with a Logic Apps Agent Loop.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

In this module we will provision the Azure OpenAI service and deploy the GPT-4.1 model that will be used by the Logic Apps Agent Loop.

## Provision Azure OpenAI Service
1. Search for and navigate to the OpenAI Service

    - In the serach bar enter: `OpenAI`
        - In the search bar enter: `OpenAI`
    - Select: `Azure OpenAI` -> `Create` -> `Azure OpenAI`
    
    ![Create Azure OpenAI](./images/04_01_create_azure_open_ai.png "Create New Azure OpenAI Instance")

1. Configure the Azure OpenAI service as follows:

    - **Resource Group**: `logic-apps-ai-agents-rg`
    - **Region**: `North Central US`
    - **Name**: ` logic-apps-open-ai-{your-initials-date}`
    - **Pricing Tier**: `Standard S0`
    

    ![Configure Azure OpenAI](./images/04_02_configure_azure_open_ai.png "Configure Azure OpenAI")

1. Click `Next` twice

1. Review the configuration and click `Create`

    ![Create Azure OpenAI](./images/04_03_create_azure_open_ai.png "Create Azure OpenAI Instance")

## Deploy the GPT-4.1 Model
1. After your resource successfully deploys, click the `Go to Resource` button

1. To be able to deploy models into our Azure OpenAI instance, we need to launch the **Azure AI Foundry portal**. Click `Go to Azure AI Foundry portal` 

    ![Launch Azure AI Foundry Portal](./images/04_04_launch_azure_ai_foundry_portal.png "Launch Azure AI Foundry Portal")

1. In the Azure AI Foundry portal, go to the **Chat playground**. Click `Create new deployment -> From base models` to deploy a new model.

    ![Create New Deployment - From base model](./images/04_05_create_new_deployment_from_base_model.png "Create new deployment - from base model")

1. Search for and select `gpt-4.1` from the list of available models; then click `Confirm`

    ![Search and Confirm gpt-4.1](./images/04_06_search_confirm_gpt-4-1-model.png "Search and confirm gpt-4.1 model")

1. Accept the default configuration for the gpt-4.1 model deployment. Click `Deploy`

    ![Deploy gpt-4.1 model](./images/04_07_deploy_gpt-4-1-model.png "Deploy gpt-4.1 model")

1. Test your model's deployment by entering a prompt 

    ![Test gpt-4.1 model](./images/04_08_gpt-4-1_test_prompt.png "Test gpt-4.1 model")
