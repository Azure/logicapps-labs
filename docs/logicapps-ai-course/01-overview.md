---
title: Overview
description: An overview of the lesson that helps you build and deploy Agents in Azure Logic Apps.
ms.service: logic-apps
ms.topic: tutorial
ms.date: 08/19/2025
author: absaafan
ms.author: absaafan
---

This course introduces what’s possible when you build conversational and autonomous agents using Azure Logic Apps. It explains the unique capabilities that Azure Logic Apps brings to agent architectures and gives a short outline of each module.

## Building agentic workflows with Azure Logic Apps

Agents combine reasoning, state, and tools to take actions in response to user inputs or events. Agentic workflows are orchestrations that embed an AI agent’s iterative model reasoning, tool executions, and durable state to autonomously advance tasks or conversations across connected systems.

Using Azure Logic Apps for agentic workflows lets you combine the agent’s decision logic (the model, prompts, and orchestration) with reliable, production-grade execution and integration.

Azure Logic Apps provides an enterprise grade workflow engine with a visual designer and offers multiple hosting options ranging from on-premises to cloud. Adding agent loop(s) into your workflow unlocks powerful AI reasoning coupled with the extensive features and proven reliability that Azure Logic Apps are known for.

Here are the main reasons to choose Azure Logic Apps when you build agentic workflows:

- Rich connectivity: hundreds of built-in connectors, custom connectors, and HTTP actions let agents call SaaS APIs, databases, and on-premises systems without custom plumbing.
- Developer experience and automation: visual designer, ARM/Bicep/ Terraform support, and CI/CD integration help you ship and maintain agent workflows as code.
- Durable execution: logic app workflows can persist state and resume after service restarts, enabling long-running sessions, retries, and compensation patterns without losing context.
- Enterprise scale: the platform supports high concurrency, regional deployments, and resilient infrastructure to run many agent instances reliably.
- Monitoring and diagnostics: native integration with Azure Monitor, Log Analytics, and diagnostic settings gives you structured telemetry, traces, and the ability to create alerts and dashboards for agent behavior.
- Security and compliance: use Azure RBAC, managed identities, private endpoints, network controls, and platform encryption to protect secrets, connectors, and data flows.

## Agent loops in Azure Logic Apps

An agent loop is the orchestration pattern where an agent receives input (user message or event), decides on an action (generate text, call a tool, ask a clarification), executes that action, and then repeats this loop while maintaining context. In Azure Logic Apps, you implement the loop as a combination of model prompts, workflow logic, and connector actions so the agent can safely interact with external systems and persist progress.

## Conversational vs autonomous agents

This course provides a module for a conversational agents - systems that engage in back-and-forth interactions with a user (chat, help desk scenarios, guided workflows). It follows with a module discussing autonomous agents, which take independent action on behalf of a user or system. Both models share patterns that the Azure Logic Apps engine provides out-of-the-box:

- both need durable state, retries, and secure access to connectors
- both benefit from observability and audit trails
- both require clear tool boundaries and safe error handling

### Conversational agents

Conversational agents are typically user-driven, short-lived or session-based, and focus on natural language interaction.
The only way to trigger and interact with conversational agents is through a chat session so the trigger in a conversational agent workflow will always be the "When a new chat session starts" trigger.

Workflow actions can be added after the workflow triggers and before the first agent. Once the workflow execution reaches an agent, you can only run tools or hand off to other agents.

### Autonomous agents

Autonomous agents run longer, make independent decisions, and often require stronger governance, isolation, and automated rollback or compensation strategies. Autonomous agents can be triggered with any of the triggers supported in logic apps today. This flexibility allows you to add agent actions to your existing stateful workflows.

Agent actions can be added in the workflow anywhere that a workflow action can be added. You can also include multiple agent actions in a workflow.

## Course Outline

This course will help you create your first conversational agent. Starting from a basic conversational agent in the first lesson and then building on that agent with tools and patterns. The later lessons in this course will go through the deployment of the agent and a conversational chat client.

### Build conversational agents

This module teaches you how to create interactive agents that engage in back-and-forth conversations with users. You'll learn to build your first conversational agent using Azure Logic Apps, connect it to Azure OpenAI models, add tools for external service integration, incorporate user context, and deploy complete chat solutions. The module focuses on session-based interactions, debugging techniques, and the agent-to-agent (A2A) protocol for seamless communication.

[Start with: Build your first conversational agent](02_build_conversational_agents/01-create-first-conversational-agent.md)

### Build Autonomous Agents

This module focuses on creating independent agents that can take actions without continuous user interaction. You'll learn to build autonomous agents that monitor events, make decisions, and execute tasks automatically. The module covers integrating with various triggers, connecting to Azure OpenAI or Azure Foundry models, and implementing tools that enable agents to interact with external systems while maintaining proper governance and error handling for long-running operations.

[Start with: Build your first autonomous agent](03_build_autonomous_agents/01-create-first-autonomous-agent.md)

### Extend Agents functionality

This module expands your agents' capabilities by teaching advanced tool configuration and knowledge integration techniques. You'll learn to add dynamic parameters to tools, implement sophisticated patterns for tool behavior, integrate knowledge bases and retrieval systems, and extend tools with custom code. The focus is on making agents more intelligent and adaptable while maintaining clear observability into parameter generation and tool execution.

[Start with: Add parameters to your tools](04_agent_functionality/01-add-parameters-to-tools.md)

### Multi-agent workflow patterns

This module teaches you to orchestrate multiple specialized agents working together to handle complex scenarios. You'll learn various coordination patterns including prompt chaining, parallelization, routing, evaluator-optimizer loops, orchestrator-worker architectures, and handoff patterns. The module emphasizes reliability, maintainability, and scalability advantages of distributed agent systems over monolithic approaches, with practical implementations using Azure Logic Apps.

[Start with: Multi-agent workflow patterns overview](05_build_multi_agent_systems/01-build-multi-agent-sysystem.md)