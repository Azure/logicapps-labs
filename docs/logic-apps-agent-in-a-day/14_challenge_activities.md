---
title: 14 - Challenge activities
description: Extend the agent solution with email notifications, autonomous execution, and knowledge base updates.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

## Challenge 1 - Add a new tool for email notification
Create a new tool that will send an email to the requester, providing them updates when the incident is created and when the incident is resolved.

*Hints:*
- Leverage existing Logic Apps Connectors such as *Outlook.com*, *Office 365 Outlook*, or *Gmail* to simplify interacting with the email clients.
- Leverage agent parameters when populating the contents of your email.
- Tools include one or more actions.

## Challenge 2 - Make the workflow autonomous 
In this challenge you will modify the workflow to execute in an autonomous manner. 

An autonomous workflow will require the user to provide all parameters in advance and potentially return a response.

*Hints:*
- The trigger action `When a HTTP request is received` will need to accept all inputs that are required for the agent to process the event.
- The System Instructions will need to be refined as there will be no user interaction between the agent and user requesting additional input variables or validation.
- The `Complete Workflow` action can be used to stop the workflow once you have completed closing the ServiceNow incident and sent out the notification.

## Challenge 3 - Updating the Knowledgebase
When the agent encounters a new scenario not present in the knowledgebase, the agent will:
- Update the knowledgebase with the new scenario.
- Send a notification.



