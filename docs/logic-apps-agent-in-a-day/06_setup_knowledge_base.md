---
title: 06 - Setup your knowledge base
description: Create an Azure Storage account and upload an operational runbook for agent knowledge retrieval.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

In this module we will provision an Azure Storage account that will hold our operations manual / knowledge base used by the Logic Apps Agent Loop.

1. Search for and Navigate to `Storage Accounts`

    ![Search Storage Accounts](./images/06_01_search_storage_accounts.png "Search Storage Accounts")

1. Create a new storage account by clicking `+ Create` 

    ![Create New Storage Account](./images/06_02_create_new_storage_accounts.png "create new storage account")

1. Configure the new storage account as follows:

    - **Resource Groups**: `logic-apps-ai-agents-rg`
    - **Storage Account**: `logicappsaiagentkb<your-initials|date>`  (**Storage account name needs to be globally unique**)
    - **Redundancy**: `Locally-redundant storage (LRS)`
    - Click `Review + Create`
    - Click  `Create`

    ![Configure New Storage Account](./images/06_03_configure_new_storage_accounts.png "configure new storage account")

1. Expand `Data Storage` and select `Containers` in the left side feature options for your storage account:

    ![Storage Account Containers](./images/06_04_storage_account_containers.png "storage account containers")

1. Configure a new container as follows:
    
    - **Name:** `playbooks`
    - Click: `Create`

    ![Create new container](./images/06_05_new_storage_account_container.png "create new container")


1. Upload the playbook to the container by clicking `Upload`
 
    ![Upload playbook](./images/06_06_upload_playbook.png "upload playbook")

1. Download the knowledge base - [Agent in a Day - Operational Runbook.docx](./resources/Agent%20in%20a%20Day%20-%20Operational%20Runbook.docx "download playbook")
   
2. Navigate to the location on your machine where you downloaded the `Agent in a Day - Operational Runbook.docx` file, select it, then click `Upload`

    ![Upload Contoso Energy - Operational Runbook](./images/06_07_upload_operational_runbook.png "upload operational runbook")

    Once successfully uploaded, you will receive the following message:
    
    ![Blob Upload Successful](./images/06_08_upload_success.png "blob upload successful")

    And now be able to see the file displayed for the **playbooks** container:

    ![Playbook blob listing](./images/06_09_playbook_blob_list.png "playbook blob listing")


## Configure Access to the Storage Account
We will need to grant the Logic Apps instance access to read the blobs in our storage account. We will use Managed Identity for this purpose as it simplifies assigning access and does not require the use of security keys. To learn more about Managed Identities, please see the following article: <a href="https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview" title="Managed Identities for Azure resources">Managed Identities for Azure resources. </a>

1. Navigate to the **Access Control (IAM)** settings  fo the Storage Account 

    ![Storage Account Access Control IAM](./images/06_10_storage_account_access_control.png "storage account access control iam")

1. Select the role to add

    - Select `Add -> Add Role Assignment`
    - Search for and select the `Storage Blob Data Reader` role
    - Click `Next`

    ![Add role assignment](./images/06_11_add_role_assignment.png "add role assignment")

1. Select the Managed Identity to be granted the access

    - Select `Managed Identity`
    - Click `+ Select Members`

    ![Managed Identity](./images/06_12_managed_identity.png "managed identity")

1. Select the Logic App created in earlier module

    - In the **Managed Identity** dropdown, select `Logic Apps(Standard)`
    - Select the Logic App created in the earlier module

    ![Logic Apps Managed Identity](./images/06_13_logic_apps_managed_identity.png "logic apps managed identity")

    - Click `Select`
    - Click `Close`

1. Click `Review + Assign`

    ![IAM Review and Assign](./images/06_13_iam_review_assign.png "iam review and assign")
