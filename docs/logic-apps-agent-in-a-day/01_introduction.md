---
title: 01 - Introduction
description: Learn how to build a conversational agent in Azure Logic Apps (Standard), connect it to an Azure OpenAI model, and add its first tool.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 10/12/2025
author: leonglaz
ms.author: leonglaz
---

## Harnessing the Power of Agent Loop Capabilities in Modern Automation

Welcome to the **"Logic Apps Agent in a Day"** workshop—a comprehensive, hands-on journey into the future of cloud-based automation and integration, designed for the innovators, architects, and aspiring automation specialists eager to unlock new efficiencies in their organizations.

In today’s rapid digital landscape, businesses face the ever-increasing challenge of bridging disparate systems, harmonizing workflows, and delivering intelligent, responsive automation. Microsoft Azure Logic Apps have long stood at the forefront of this transformation, empowering professionals to orchestrate powerful workflows across cloud and on-premises environments. Now, with the introduction of the revolutionary **Agent Loop** capabilities, Logic Apps has leapt into a new era of intelligent, adaptive automation.

---

## Why Logic Apps? An Evolving Landscape

Before we dive into the specifics of Agent Loop, let’s reflect on the transformative journey of Logic Apps. As organizations migrate to the cloud, the demand for reliable, scalable, and low-code integration is at an all-time high. Logic Apps gives users the power to:

- Automate routine tasks across hundreds of services—both Microsoft and third-party.
- Orchestrate business processes with robust connectors, triggers, and actions.
- Reduce development effort by empowering both IT professionals and developers with a visual, drag-and-drop designer.
- Ensure reliability and security through built-in compliance, monitoring, and governance.
- Scale to enterprise workloads with built-in redundancy, elasticity, and advanced management tools.

---

## Introducing Agent Loop: The Next Evolution

The arrival of the **Agent Loop** capability marks a paradigm shift in how Logic Apps can be harnessed for iterative, stateful, and agent-driven processes.

### What is Agent Loop?

Agent Loop empowers Logic Apps to execute repetitive or recursive operations intelligently, maintaining context and responding dynamically to changing data or states. This means that workflows can now:

- **Iterate with intelligence**: Context-aware iterations that adapt based on previous results or external input.
- **Maintain state across loops**: Support for complex scenarios like conversational AI, multi-step approvals, and event-driven automation.
- **React to real-time triggers**: Pause, resume, or branch based on evolving events.
- **Integrate seamlessly with agents**: Ideal for chatbots, RPA solutions, or intelligent assistants.

---

## The Benefits of Agent Loop Capabilities

1. **Enhanced Flexibility and Adaptivity**  
   Dynamic, intelligent orchestrating and routing for complex workflows.

2. **Improved Efficiency and Resource Utilization**  
   Event-driven and conditional looping reduces compute costs and improves performance.

3. **Streamlined Integration with Intelligent Agents**  
   Supports conversational workflows, automated troubleshooting, and iterative data enrichment.

4. **Empowerment of Human-in-the-Loop Scenarios**  
   Enables workflows that pause for approvals, gather feedback, or escalate exceptions.

5. **Advanced Error Handling and Resilience**  
   Graceful error handling, retries, and compensating actions for mission-critical apps.

6. **Simplified Design and Maintenance**  
   Declarative, visual approach democratizes automation and reduces technical debt.

---

## Workshop Overview: What You’ll Learn

- Foundational understanding of Logic Apps and cloud automation.
- Architecture and core concepts of Agent Loop.
- Hands-on workflows using Agent Loop (e.g., agent, human in the loop inteactions, dynamic approvals).
- Integration with AI, ServiceNow, and Azure storage.
- Best practices for error handling, state management, and governance.
- Collaboration and reusable pattern development.

---

## Who Should Attend?

- IT professionals modernizing integration and automation strategies.
- Developers mastering low-code, cloud-native workflow design.
- Business process owners and solution architects driving digital transformation.
- Anyone interested in agent-driven automation and AI integration.

---

## Setting the Stage for Innovation

Agent Loop is more than just a new feature—it’s a leap forward in how businesses, governments, and innovators can harness the power of AI agents in automating complex, adaptive processes.

By the end of this workshop, you’ll be equipped to turn the promise of Agent Loop into reality, driving meaningful transformation for your teams and organizations.

Here is your provided text converted into Markdown format:

---

## Lab Scenario

In today’s lab, we are going to build an **Operations Agent** who will help organizations manage their IT incidents. Our agent will leverage a free developer instance of **ServiceNow** as part of this process so we can manage these incidents.

**Agent Loop** supports both autonomous and conversational agents. For the purposes of this lab, we are going to focus on building a **conversational agent**. This will allow us to chat with our agent and issue prompts (requests), letting the agent try to fulfill those requests through the use of **Generative AI**. As a bonus exercise, we will encourage you to enable **autonomous execution** of this agent as well.

Within our agent, we will support a variety of user prompts that the agent will leverage in order to try and fulfill that request. For example, we will provide the ability to:

1. Log an IT incident in ServiceNow  
2. Update an IT incident in ServiceNow with work notes  
3. Close an IT incident in ServiceNow  
4. Send email notifications that provide updates to stakeholders  
5. Leverage a knowledge source that helps drive the severity and criticality of different request types 

**Let’s get started on this exciting journey together!**


> ### Note for instructors
> 
> If you are an instructor and is running this as a class led workshop, you can find the following resources below:
> 
> 1. [Instructor Slide Deck](https://github.com/Azure/logicapps-labs/tree/main/docs/logic-apps-agent-in-a-day/resources/Agent_In_a_Day_Instructor.zip "slide deck")
> 2. [Original repository](https://github.com/Azure/logicapps-labs/tree/main/docs/logic-apps-agent-in-a-day "repository")


