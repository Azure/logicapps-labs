---
title: 05 - Provision your Logic Apps (Standard)
description: Provision a Logic Apps (Standard) instance to host and run agent workflows.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

In this module we will provision a Logic Apps Standard instance enabling us to create and test our workflows.

1. Search for and navigate to the `Logic Apps` service

    ![Search Logic Apps](./images/05_01_search_logic_apps.png "search logic apps")

1. Click `+ Add`

    ![Add Logic Apps](./images/05_02_add_logic_apps.png "add logic apps")

1. Select `Workflow Service Plan` and click `Select`

    ![Select Workflow service plan](./images/05_03_select_workflow_service_plan.png "select workflow service plan")

1. Configure the Logic Apps instance as follows:

    - **Resource Group:** `logic-apps-ai-agents-rg`
    - **Logic App Name:** `logic-apps-ai-agents-<some-unique-extension>` **(in the example initials and date were used)**
    - **Region:** `North Central US`
    
    ![Configure Logic Apps Instance](./images/05_04_configure_logic_apps_instance.png "configure logic apps instance")

1. Click `Authentication` and configure the following:
   
   - **Host Storage (AzureWebJobsStorage)** - `Managed identity`
   - **Application Insights** - `Managed identity`
    - **Click:** `Review + Create`

   ![Configure Logic Apps Instance - Authentication](./images/05_04_configure_logic_apps_instance_authentication.png "configure logic apps instance authentication")

   **Note:** enabling managed identities will allow logic apps to securely authenticate and access Azure Blob Storage and Application Insights without needing to manage credentials like passwords or secrets.

1. Review the configuration and click `Create`

    ![Review Configuration and Create](./images/05_05_review_create_logic_apps_instance.png "review configuration and create")    


1. This will start the deployment of your Logic Apps instance 

    ![Deployment In Progress](./images/05_06_deployment_in_progress.png "deployment in progress")


1. Once the deployment is completed, you will see the following screen and the button `Go to resource` that will open the Azure Logic Apps you just deployed

    ![Deployment Complete](./images/05_07_deployment_complete.png "deployment complete")
