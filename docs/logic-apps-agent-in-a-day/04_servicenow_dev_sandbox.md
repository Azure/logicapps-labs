---
title: 04 - Setup your ServiceNow developer Sandbox
description: Set up a ServiceNow developer instance and configure OAuth for Logic Apps integration.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

A ServiceNow environment will be required to enable our integration to create and interact with incident tickets.
**Important:** Use your personal email address  when creating your ServiceNow Environment

1. Register a new account with ServiceNow:

    https://signon.service-now.com/x_snc_sso_auth.do?pageId=sign-up

1. Fill out the registration form:

    ![ServiceNow ID Signup](./images/02_01_signup_servicenow_id.png "Signup")

1. You will receive an Email Verification Code:

    ![Email Verification Code](./images/02_02_email_verificaiton_code.png "Verify your account")

1. Navigate to the developer portal: 

     https://developer.servicenow.com/dev.do

    (if prompted, sign in using the account created above)

1. Request a Developer Instance

    ![Request Developer Instance](./images/02_03_request_developer_instance.png)

1. Click the Start Building link:

    ![Start building](./images/02_04_start_building.png)

## Configure OAuth Authentication 
We will need to configure an OAuth API endpoint to enable our logic apps to authenticate to our ServiceNow instance

1. Navigate to the `OAuth -> Inbound Integrations` section
    - Using the top navigation menu
      - Select `All`
      - Enter `OAuth` in the search box
      - Select `Inbound Integrations`

      ![Menu OAuth Inbound Integrations](./images/02_05_menu_inbound_integrations.png "menu oauth inbound integrations")

1. Select `New Integration`

    ![New Integration](./images/02_06_inbound_integrations_new_integration.png "new integration")


1. Select `OAuth - Authorization code grant`
  
    ![Create OAuth Authorization Grant](./images/02_07_create_oauth_authorization_grant.png "create oauth api endpoint")

1. Configure the OAuth API endpoint as follows:
    - **Name:** `logic-apps-client`
    - **Redirect URL:** https://logic-apis-northcentralus.consent.azure-apim.net/redirect
     
       (**note:** your redirect URL will depend on the region you are deployment your Azure Logic Apps Instance. If you deployed to a different region, you will need to update your **Redirect URL:  https://logic-apis-{azure-region}.consent.azure-apim.net/redirect**)
     - Click `Submit`

    ![Configure OAuth API Endpoint](./images/02_08_oauth_authorization_code_grant_config.png "configure oauth api endpoint")

1. Save the `Client ID`, `Client Secret` and the `Instance Name` created in this module for later steps when configuring the Logic Apps connection to ServiceNow
