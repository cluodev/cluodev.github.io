---
title: "A More Structured Way to Ship a Sprint Story with AI"
date: 2026-10-09T10:00:00.000Z
author: "Charles Luo"
description: "How Superpowers' skills gave an AI-assisted sprint story a clear workflow: clarify, plan, implement with TDD, review and verify."
categories: ["technology", "development"]
tags: ["ai", "github-copilot", "superpowers", "tdd", "workflow"]
type: "regular"
blueskyPostURI: ""
draft: true
---

AI coding tools can produce code quickly. But speed alone is not what I need when working on a sprint story. I need to know that the implementation addresses the agreed requirement, that its behavior is tested, and that I have verified the result.

Recently, I worked on a story to introduce a schema for JSON data used by a dashboard showing observed Kubernetes cluster state by environment. Using GitHub Copilot with Superpowers' built-in skills helped me take that story through a more structured workflow: clarify, plan, implement, review, and verify.

## Start with the Jira story

Before asking Copilot to change code, I review the story. Why are we doing this work? What needs to be completed? How will we verify the output? What are the acceptance criteria?

That initial step matters because an AI coding assistant can act on a request that is incomplete or ambiguous. If I paste a vague ticket straight into the tool, I risk getting a plausible implementation that solves a different problem. I first make sure I understand the expected outcome, then give Copilot the clarified requirements.

For this story, the goal was to define and validate the shape of the JSON consumed by the dashboard. The schema needed to capture required fields and their value types, so malformed data could be rejected rather than flowing into the dashboard unchecked.

## Use skills to give the work a shape

Once the story and acceptance criteria are clear, Superpowers' skills help turn that understanding into a working process. Depending on the task, Superpowers skills are selected automatically to match task's purpose.

The following skills were invoked for this story: 

- Brainstorming — shape and approve a design before implementation.
- Writing Plans — create a detailed implementation plan.
- Using Git Worktrees — check or set up an isolated workspace.
- Subagent-Driven Development — implement planned tasks with separate reviews.
- Test-Driven Development — write tests first to define expected behavior. Repeat the cycle of Red-Green-Refactor until the implementation passes the tests.
- Requesting Code Review — request a broader review of completed changes.
- Verification Before Completion — run fresh checks before reporting completion.
- Finishing a Development Branch — choose how to handle the branch after implementation.

That flow/structure gives me clear checkpoints. It also makes it easier to notice when a step is missing—for example, when implementation is moving ahead before the behavior has been made testable.

## Let tests define what “done” means

Superpowers' test-driven development loop: write a test for a behavior, see it fail because the behavior is not implemented yet, then make the smallest change needed to pass it.

The tests covered the key path through the dashboard model and data-loading logic. Valid JSON should map into the dashboard model. Malformed JSON, missing required fields, and values with the wrong types should be rejected. Tests also covered the data structures created for the schema.

This made the requirement more concrete than a checklist in a ticket. Instead of relying on a general impression that the schema “looks right,” I had executable examples of what the system should accept and reject. The tests also gave the implementation a useful base for future changes: when the expected data shape evolves, the existing cases help make the intended behavior visible.

## Review and verify

Tests are important, but they are not the only checkpoint. Reviewing the plan before coding helped ensure that the approach matched the acceptance criteria. A later code review provided an independent check on the implementation. I do not remember a specific issue it uncovered, so I would not present that review as having caught a particular bug; its value was in adding another deliberate pass.

Finally, verification connects the change back to the original story: does the implementation behave as specified, and have the expected outputs been checked? Superpowers includes a verification-before-completion skill that reinforces this final step. Completion should follow evidence, not just the fact that code has been written.

## What I took away

For me, the benefit was not simply that an AI assistant generated code. The workflow made the work more structured and gave me more confidence in the result. The clarified Jira criteria set the destination; planning and reviews provided checkpoints; and TDD turned the expected behavior into tests.

The schema change also left behind a foundation for future development: tests around the dashboard model, data loading, and the expected data structure. Those tests can help the team make later changes without losing sight of what the dashboard relies on.

I have not measured how much time this workflow saved, and using a set of skills does not guarantee a correct implementation. I still need to understand the story, judge the proposed approach, and review the result. What the skills give me is a repeatable way to bring those responsibilities into the AI-assisted workflow instead of treating them as optional steps.

My practical takeaway is simple: start with a story you understand, turn its acceptance criteria into observable behavior, and guide the AI through planning, implementation, review, and verification. That is how AI assistance becomes more than fast code generation—it becomes a more structured way to deliver sprint work reliably.