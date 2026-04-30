---
name: ai-llm-guidelines
description: Guidelines for AI/LLM interactions, guardrails, prompt structuring, and sensitive data handling. Use when building features that interact with Large Language Models (LLMs).
---

# AI / LLM Interaction Guidelines

This skill provides mandatory standards for AI and LLM interactions in this project.

- When building features that interact with Large Language Models (LLMs), always implement appropriate guardrails.
- Ensure prompts are structured to minimize hallucinations and enforce that outputs are grounded in provided context or data.
- Never pass sensitive PII or credentials directly in prompts unless the system is specifically designed and approved for secure, isolated processing.
