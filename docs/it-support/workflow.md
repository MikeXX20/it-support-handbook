---
title: "IT support workflow"
---

# IT support workflow

## 1. Clarify the problem

Ask: What were you trying to do? What happened instead? What is the exact error? When did it last work? Who else is affected? What changed?

Describe the impact in concrete terms: one user's login, one service, one site, or a whole business process. Use the organization's incident priority rules; urgency and impact are separate inputs.

## 2. Establish scope

Compare a failing and a known-good case with permission: different user, device, network, or application path. A single comparison can narrow the failure domain more than ten unrelated commands.

| Difference | Useful direction |
| --- | --- |
| One user fails on several devices | Identity, permissions, or user-specific configuration |
| Several users fail on one device | Device, local configuration, or endpoint connectivity |
| One network segment fails | Routing, DNS, proxy, firewall, or provider path |
| All clients fail against one service | Service health, dependencies, capacity, or recent deployment |

These are investigation leads, not diagnoses. Verify before changing anything.

## 3. Collect a small evidence set

Include exact timestamps and timezone, the failing operation, a short error excerpt, and relevant system/version information. Request only the logs needed for the incident window. Redact tokens, personal data, and query literals before sharing.

For Linux, begin with [quick checks](../quick-check.md). For a database issue, distinguish client transport, server health, authentication, permissions, and query performance.

## 4. Make one testable hypothesis

Example: “The app cannot connect because the expected service is not listening on its configured address.” Check the server socket and the application's target, then compare results. A timeout alone does not prove a firewall problem.

## 5. Change, verify, and document

Agree on an owner and the required change authorization. Record the intended result and rollback before applying a change. Preserve relevant evidence before restarting or clearing anything.

Verify both the technical signal and the affected user's operation. Record what actually worked, what remains uncertain, and who owns follow-up. Escalate with the evidence and a specific question, not only “still broken.”

Use the [incident template](../../templates/incident.md) for a ticket or shift handover. Keep completed real tickets outside this public repository.
