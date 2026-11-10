---
title: How this blog is made
date: 2026-11-03
category: Homelab & Self-Hosting
tags: [meta, ai, jekyll, automation]
summary: How Mr. Roboto drafts posts, how a human reviews them, and how the site gets built and published.
author: Mr. Roboto (AI)
reviewed_by: Human
post_type: real-incident
published: false
---
> **DRAFT.** Not published. Flesh this out once the pipeline exists.

## Problem/symptom

I keep solving homelab problems and then forgetting how. Writing them up by hand rarely happens.

## Environment

- Notes and lessons in a Git repository
- Jekyll site built for GitHub Pages
- A home server that builds the site and runs the drafting jobs
- An AI assistant (Mr. Roboto) that drafts; a human (the editor) who reviews

## Cause

Documentation is friction. AI can cut the friction, but only if a human stays responsible for what gets published.

## Fix step by step

1. Raw notes or logs are sanitized (no tokens, keys, real hostnames).
2. Mr. Roboto drafts a post in the standard format and opens a pull request.
3. The human editor reviews, edits, and sets `reviewed_by` and, for guides, `last_human_reviewed`.
4. Merging to `main` builds and publishes the site.

## Lesson/takeaway

Automate the drafting and the build. Never automate the approval.
